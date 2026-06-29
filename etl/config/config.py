from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from utils.logger import get_logger

logger = get_logger("config")  # Logger identificado como "config" en cada línea del log


class Settings(BaseSettings):
    """
    Lee el archivo .env y valida que todas las variables existan.
    Si falta alguna, el pipeline falla aquí antes de ejecutar cualquier cosa.
    """

    DB_URL: str          # Cadena de conexión a PostgreSQL
    RAW_DATA_PATH: str   # Ruta a la carpeta con los CSVs
    LOGS_PATH: str       # Ruta a la carpeta de logs
    TRIGGERED_BY: str    # Quién ejecuta el pipeline: local | airflow

    model_config = SettingsConfigDict(
        env_file=Path(__file__).resolve().parent.parent / ".env",  # Busca .env en etl/
        env_file_encoding="utf-8"
    )


def get_engine(settings: Settings) -> Engine:
    """
    Entrada : objeto settings con DB_URL
    Proceso : crea el engine de SQLAlchemy con pool de conexiones
    Salida  : Engine listo para usar en cualquier script
    """
    engine = create_engine(
        settings.DB_URL,
        pool_size=5,       # Conexiones simultáneas disponibles
        max_overflow=10,   # Conexiones extra si el pool está lleno
        pool_pre_ping=True # Verifica que la conexión esté viva antes de usarla
    )
    return engine


def test_connection(engine: Engine) -> bool:
    """
    Entrada : Engine de SQLAlchemy
    Proceso : ejecuta SELECT 1 para verificar conectividad real con PostgreSQL
    Salida  : True si conecta, False si falla — el pipeline se detiene si retorna False
    """
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))  # Consulta mínima estándar para verificar conexión
        logger.info("Conexión a PostgreSQL exitosa")
        return True
    except Exception as e:
        logger.critical(f"Fallo de conexión a PostgreSQL: {e}")
        return False


# ------------------------------------------------------------
# INSTANCIAS GLOBALES
# Se crean una vez. Todos los scripts importan desde aquí.
# from config.config import settings, engine
# ------------------------------------------------------------
settings = Settings()          # Lee y valida el .env
engine   = get_engine(settings) # Prepara la conexión a PostgreSQL