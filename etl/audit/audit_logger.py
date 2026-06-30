from datetime import datetime
from sqlalchemy import text
from config.config import engine, settings
from utils.logger import get_logger

logger = get_logger("audit")  # Logger identificado como "audit" en cada línea del log


class AuditLogger:
    """
    Registra en PostgreSQL la ejecución completa del pipeline.
    Escribe en tres tablas: etl_runs, quality_checks, rejected_records.
    """

    def __init__(self, engine):
        self.engine = engine  # Engine de SQLAlchemy compartido con todos los scripts
        self.triggered_by = settings.TRIGGERED_BY  # Quién ejecuta el pipeline: local | airflow
    # ----------------------------------------------------------------
    # start_run
    # Entrada : nada
    # Proceso : INSERT en audit.etl_runs con status RUNNING
    #           genera batch_id como timestamp epoch (entero único por ejecución)
    # Salida  : run_id (BIGSERIAL generado por PostgreSQL)
    #           batch_id (timestamp epoch generado por Python)
    # ----------------------------------------------------------------
    def start_run(self) -> tuple[int, int]:

        batch_id  = int(datetime.now().timestamp())  # Entero único basado en timestamp: 1719223931
        start_time = datetime.now()                  # Momento exacto de inicio del pipeline

        sql = text("""
            INSERT INTO audit.etl_runs (
                start_time,
                status,
                triggered_by,
                batch_id
            ) VALUES (
                :start_time,
                :status,
                :triggered_by,
                :batch_id
            )
            RETURNING run_id
        """)
        # RETURNING run_id le dice a PostgreSQL que retorne el ID generado
        # sin necesidad de hacer un SELECT después del INSERT

        try:
            with self.engine.begin() as conn:  # begin() abre y cierra la transacción automáticamente
                result     = conn.execute(sql, {
                    "start_time"   : start_time,
                    "status"       : "RUNNING",       # Estado inicial siempre RUNNING
                    "triggered_by" : self.triggered_by,         # local | airflow según .env
                    "batch_id"     : batch_id
                })
                run_id = result.fetchone()[0]  # Obtiene el run_id retornado por PostgreSQL

            logger.info(f"Pipeline iniciado | run_id={run_id} | batch_id={batch_id}")
            return run_id, batch_id

        except Exception as e:
            logger.critical(f"Error al registrar inicio del pipeline: {e}")
            raise  # Relanza la excepción — si audit falla el pipeline no debe continuar

    # ----------------------------------------------------------------
    # end_run
    # Entrada : run_id, status final, conteos de filas
    # Proceso : UPDATE en audit.etl_runs cerrando el registro
    #           calcula execution_time_seconds desde start_time
    # Salida  : nada
    # ----------------------------------------------------------------
    def end_run(
        self,
        run_id             : int,   # ID de la ejecución a cerrar
        status             : str,   # SUCCESS | FAILED
        total_extracted    : int,   # Total filas leídas de CSVs
        total_loaded       : int,   # Total filas insertadas en el DW
        total_rejected     : int    # Total filas rechazadas en calidad
    ) -> None:

        end_time = datetime.now()  # Momento exacto de cierre del pipeline

        sql = text("""
            UPDATE audit.etl_runs
            SET
                end_time                = :end_time,
                status                  = :status,
                total_rows_extracted    = :total_extracted,
                total_rows_loaded       = :total_loaded,
                total_rows_rejected     = :total_rejected,
                execution_time_seconds  = EXTRACT(EPOCH FROM (:end_time - start_time))
            WHERE run_id = :run_id
        """)
        # EXTRACT(EPOCH FROM ...) calcula la diferencia en segundos directamente en PostgreSQL
        # No necesitamos calcularlo en Python

        try:
            with self.engine.begin() as conn:
                conn.execute(sql, {
                    "end_time"        : end_time,
                    "status"          : status,
                    "total_extracted" : total_extracted,
                    "total_loaded"    : total_loaded,
                    "total_rejected"  : total_rejected,
                    "run_id"          : run_id
                })

            logger.info(f"Pipeline cerrado | run_id={run_id} | status={status} | extraídos={total_extracted} | cargados={total_loaded} | rechazados={total_rejected}")

        except Exception as e:
            logger.error(f"Error al cerrar run_id={run_id}: {e}")

    # ----------------------------------------------------------------
    # log_quality_check
    # Entrada : run_id, datos del check ejecutado
    # Proceso : INSERT en audit.quality_checks
    # Salida  : nada
    # ----------------------------------------------------------------
    def log_quality_check(
        self,
        run_id          : int,  # ID de la ejecución actual
        table_name      : str,  # Tabla validada: sales, products, customers...
        check_name      : str,  # Descripción de la regla: "order_id no nulo"
        check_type      : str,  # Categoría: NULL_CHECK | DUPLICATE | RANGE | FK | BUSINESS_RULE
        failed_records  : int,  # Cuántos registros fallaron
        passed_records  : int,  # Cuántos registros pasaron
        severity        : str   # Criticidad: LOW | MEDIUM | HIGH
    ) -> None:

        sql = text("""
            INSERT INTO audit.quality_checks (
                run_id,
                table_name,
                check_name,
                check_type,
                failed_records,
                passed_records,
                severity
            ) VALUES (
                :run_id,
                :table_name,
                :check_name,
                :check_type,
                :failed_records,
                :passed_records,
                :severity
            )
        """)

        try:
            with self.engine.begin() as conn:
                conn.execute(sql, {
                    "run_id"         : run_id,
                    "table_name"     : table_name,
                    "check_name"     : check_name,
                    "check_type"     : check_type,
                    "failed_records" : failed_records,
                    "passed_records" : passed_records,
                    "severity"       : severity
                })

            logger.info(f"Quality check registrado | tabla={table_name} | check={check_name} | fallaron={failed_records} | pasaron={passed_records}")

        except Exception as e:
            logger.error(f"Error al registrar quality check | tabla={table_name} | check={check_name}: {e}")

    # ----------------------------------------------------------------
    # log_rejected_record
    # Entrada : run_id, datos del registro rechazado
    # Proceso : INSERT en audit.rejected_records
    # Salida  : nada
    # ----------------------------------------------------------------
    def log_rejected_record(
        self,
        run_id            : int,  # ID de la ejecución actual
        table_name        : str,  # Tabla origen del registro: sales, products...
        business_key      : str,  # ID del registro rechazado: order_id, product_id...
        error_type        : str,  # Código del error: NULL_PRIMARY_KEY | INVALID_NUMERIC_RANGE...
        error_description : str,  # Detalle: columna afectada y valor encontrado
        batch_id          : int   # ID de la carga a la que pertenecía este registro
    ) -> None:

        sql = text("""
            INSERT INTO audit.rejected_records (
                run_id,
                table_name,
                business_key,
                error_type,
                error_description,
                batch_id
            ) VALUES (
                :run_id,
                :table_name,
                :business_key,
                :error_type,
                :error_description,
                :batch_id
            )
        """)

        try:
            with self.engine.begin() as conn:
                conn.execute(sql, {
                    "run_id"            : run_id,
                    "table_name"        : table_name,
                    "business_key"      : str(business_key),  # Forzado a string — business_key es VARCHAR en la tabla
                    "error_type"        : error_type,
                    "error_description" : error_description,
                    "batch_id"          : batch_id
                })

            logger.warning(f"Registro rechazado | tabla={table_name} | key={business_key} | error={error_type}")

        except Exception as e:
            logger.error(f"Error al registrar rechazo | tabla={table_name} | key={business_key}: {e}")