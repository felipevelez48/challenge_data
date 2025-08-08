import os, sys, pandas as pd, psycopg, pathlib

SRC_PATH = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path("/data/Base PRUEBA - ANALITICA.xlsx")
TABLE = "analytics_raw"

def read_source(path: pathlib.Path) -> pd.DataFrame:
    if path.suffix.lower() in {".xlsx", ".xls"}:
        return pd.read_excel(path, sheet_name=0)      # usa primera hoja
    else:
        return pd.read_csv(path)

def create_table_like(df: pd.DataFrame, cur, tbl: str):
    cols_sql = ", ".join(f'"{c}" TEXT' for c in df.columns)
    cur.execute(f'CREATE TABLE IF NOT EXISTS {tbl} ({cols_sql});')

def copy_df(df: pd.DataFrame, cur, tbl: str):
    with cur.copy(f'COPY {tbl} FROM STDIN WITH CSV HEADER') as copy:
        df.to_csv(copy, index=False)

def main():
    df = read_source(SRC_PATH)
    conn_cfg = dict(
        host=os.getenv("POSTGRES_HOST", "db"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    )
    with psycopg.connect(**conn_cfg, autocommit=True) as conn, conn.cursor() as cur:
        create_table_like(df, cur, TABLE)
        cur.execute(f"TRUNCATE {TABLE};")
        copy_df(df, cur, TABLE)
    print(f"Ingresadas {len(df)} filas de {SRC_PATH.name} en {TABLE}")

if __name__ == "__main__":
    main()
