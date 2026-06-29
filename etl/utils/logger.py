import logging
import sys
from pathlib import Path
from datetime import datetime


def get_logger(module_name: str) -> logging.Logger:
    """
    Entrada : nombre del módulo que llama al logger (ej: "extract", "config")
    Proceso : crea un logger con dos destinos — archivo .log y consola
    Salida  : objeto Logger listo para usar en cualquier script

    Uso:
        Se importa: from utils.logger import get_logger
        Se llama: logger = get_logger("extract")
        Se define el nivel y su mensaje correspondiente:logger.info("Mensaje")
    """

    log_dir = Path(__file__).resolve().parent.parent.parent / "logs"  # Sube hasta Chocolate_Sales_DW/ y entra a logs/
    log_dir.mkdir(exist_ok=True)                                       # Crea la carpeta si no existe, no lanza error si ya existe

    log_filename = log_dir / f"etl_{datetime.now().strftime('%Y-%m-%d')}.log"  # Un archivo por día: etl_2026-06-24.log

    logger = logging.getLogger(module_name)  # Retorna el mismo objeto si el nombre ya existe — evita duplicados

    if logger.handlers:   # Si ya está configurado lo retorna tal cual
        return logger     # Evita duplicar mensajes si el mismo módulo llama get_logger dos veces

    logger.setLevel(logging.DEBUG)  # Acepta todos los niveles — los handlers filtran qué muestran

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)-8s | %(name)-25s | %(message)s",  # Formato: fecha | nivel | módulo | mensaje
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    file_handler = logging.FileHandler(log_filename, encoding="utf-8")  # Escribe en archivo desde nivel DEBUG
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    console_handler = logging.StreamHandler(sys.stdout)  # Escribe en consola desde nivel INFO — no satura la terminal
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    logger.addHandler(file_handler)    # Registra handler de archivo
    logger.addHandler(console_handler) # Registra handler de consola

    return logger