# 🛠️ PRUEBA DATOS – Data Engineering Challenge

---

## 📖 Descripción

Este proyecto implementa scripts automatizados para la ingesta, transformación y envío de datos a bases de datos PostgreSQL mediante Python y Docker Compose. Facilita la carga desde archivos Excel o CSV, la limpieza y normalización de la información, y su posterior publicación en un entorno reproducible y escalable.

Entregables:

Parte I: Archivo solutions.sql con las respuestas a los ejercicios SQL.

Parte II: Script ETL en Python (etl.py y transform.py), configuración de Docker Compose y datos de prueba.

## 📂 1 · Estructura del repo
```
challenge/
├── docker-compose.yml        # DB + pgAdmin + contenedor ETL genérico
├── .env.example              # credenciales (copia a .env)
│
├── db/
│   ├── init.sql              # esquema + datos base
│   └── solutions.sql         # respuestas a los 6 ejercicios SQL
│
├── etl/
│   ├── Dockerfile            # imagen Python 3.11.8
│   ├── requirements.txt      # pandas, openpyxl, psycopg
│   ├── app/
│   │   ├── etl.py            # ingesta Excel/CSV → analytics_raw
│   │   └── transform.py      # limpieza simple → analytics_clean
│   └── tests/ (opcional)     # calidad con pytest
│
├── data/
│   └── Base PRUEBA - ANALITICA.xlsx   # archivo fuente
└── .gitignore
```

---

## 🚀 2 · Requisitos
| Herramienta  | Versión mínima |
|--------------|----------------|
| Docker Engine| 24.x |
| Docker Compose v2 | 2.x |
| Git          | Cualquiera |

> **Tip Windows + Git Bash**: Si encuentras problemas con rutas, exporta: 
```bash
export MSYS2_ARG_CONV_EXCL=/data
```
Con PowerShell/CMD no es necesario.

---

## ⚙️ 3 · Instalación rápida
```bash
# Clonar
git clone https://github.com/<tu-user>/prueba-datos.git
cd prueba-datos

# Variables de entorno
cp .env.example .env

# Levantar stack
docker compose up -d --build        # Postgres y pgAdmin quedarán arriba
```
*Base de datos `prueba` se llena automáticamente con **init.sql***

Acceso pgAdmin → <http://localhost:5050> – usuario y contraseña definidos en `.env`.

---

## 4 · Parte I – SQL
1. Ejecutar respuestas:
   ```bash
   docker compose exec db \
     psql -U postgres -d prueba \
     -f /docker-entrypoint-initdb.d/solutions.sql
   ```
2. Verificar, por ejemplo:
   ```bash
   docker compose exec db psql -U postgres -d prueba -c "SELECT * FROM empleados;"
   ```
Ejercicios incluidos:

    - Inserción y actualización de registros.

    - Creación de triggers (stock automático).

    - Consultas avanzadas con window functions y agregaciones.

    - Diseño de índices para optimización.

---

## 🐍 5 · Parte II – ETL & Transformación
### 5.1 Ingesta (Excel/CSV → analytics_raw)
```bash
# usa el CMD por defecto del contenedor
MSYS2_ARG_CONV_EXCL=/data docker compose run --rm etl \
  "/data/Base PRUEBA - ANALITICA.xlsx"
```
Salida típica:
```
Ingresadas 33668 filas de Base PRUEBA - ANALITICA.xlsx en analytics_raw
```

### 5.2 Limpieza (analytics_raw → analytics_clean)
```bash
docker compose run --rm etl transform.py
```
Salida típica:
```
Filas limpias: 33668 | Nulos totales: 0
```

> `transform.py` normaliza nombres, convierte numéricos y rellena nulos de forma genérica. Warnings de Pandas sobre futuras versiones son esperados y no afectan el resultado.

---

## ✅ 6 · Tests (opcional)
Si deseas lanzar pruebas de calidad básica:
```bash
docker compose run --rm etl pytest
```
(Se incluye un ejemplo en `etl/tests/` que valida que no queden nulos y que la cuenta de filas sea consistente).

---

## 🛠️ 7 · Comandos útiles
| Acción | Comando |
|--------|---------|
| Ver contenedores | `docker compose ps` |
| Entrar en psql | `docker compose exec db psql -U postgres -d prueba` |
| Reiniciar solo ETL | `docker compose build etl && docker compose run --rm etl` |
| Apagar y limpiar | `docker compose down -v` |

---

## 📝 8 · Notas finales
* La imagen ETL usa **ENTRYPOINT ["python"]**; cualquier script se ejecuta pasándolo como argumento.
* Las advertencias *UserWarning / FutureWarning* de Pandas se dejan visibles para que el revisor note decisiones pendientes (uso de SQLAlchemy, copia vs vista). No afectan el funcionamiento.

# 💡 Autor 📊🤖
## John Felipe Vélez
### Data Engineer