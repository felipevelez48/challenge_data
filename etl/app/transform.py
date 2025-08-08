from __future__ import annotations
import os, logging, re
import pandas as pd
import psycopg

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

RAW_TABLE = "analytics_raw"
CLEAN_TABLE = "analytics_clean"

# conexión a la bd

def get_conn():
    return psycopg.connect(
        host=os.getenv("POSTGRES_HOST", "db"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        autocommit=True,
    )

# Quitamos tildes, espacios o mayúsculas
def to_snake(col: str) -> str:
    col = col.strip().lower()
    col = re.sub(r"[^a-z0-9_ ]", "", col)
    return re.sub(r"\s+", "_", col)

# Hacemos carga del archivo cruda al df
def load_raw() -> pd.DataFrame:
    with get_conn() as conn:
        return pd.read_sql(f"SELECT * FROM {RAW_TABLE};", conn)


def basic_clean(df: pd.DataFrame) -> pd.DataFrame:
    # 1) nombres a snake_case
    df = df.rename(columns={c: to_snake(c) for c in df.columns})

    # 2) verificamos númericos
    for col in df.columns:
        if df[col].dtype == object and df[col].str.fullmatch(r"[0-9.]+", na=False).all():
            df[col] = pd.to_numeric(df[col], errors="coerce")

    # 3) rellenamos nulos
    for col in df.columns:
        if pd.api.types.is_numeric_dtype(df[col]):
            df[col].fillna(0, inplace=True)
        else:
            df[col].fillna("", inplace=True)
    return df

# Hacemos función para insertar el nuevo df limpio
def write_clean(df: pd.DataFrame):
    logging.info("Escribiendo %d filas en %s", len(df), CLEAN_TABLE)

    type_map = {
        "object": "text",
        "float64": "numeric",
        "int64": "bigint",
        "datetime64[ns]": "timestamp",
    }
    cols = ", ".join(f'"{c}" {type_map.get(str(t), "text")}' for c, t in df.dtypes.items())

    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(f"DROP TABLE IF EXISTS {CLEAN_TABLE};")
        cur.execute(f"CREATE TABLE {CLEAN_TABLE} ({cols});")
        with cur.copy(f"COPY {CLEAN_TABLE} FROM STDIN WITH CSV HEADER") as cp:
            df.to_csv(cp, index=False)

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main():
    df_raw = load_raw()
    df_clean = basic_clean(df_raw.copy())
    write_clean(df_clean)
    print(f"Filas limpias: {len(df_clean)} | Nulos totales: {df_clean.isna().sum().sum()}")

if __name__ == "__main__":
    main()