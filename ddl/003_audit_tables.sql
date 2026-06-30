CREATE TABLE audit.etl_runs (
    run_id BIGSERIAL PRIMARY KEY,          -- ID único autoincremental de cada ejecución del pipeline
    pipeline_name VARCHAR(100) DEFAULT 'chocolate_sales_pipeline',
    start_time TIMESTAMP NOT NULL,         -- Momento exacto en que arrancó el pipeline
    end_time TIMESTAMP,                    -- Momento exacto en que terminó (nulo mientras está RUNNING)
    status VARCHAR(20),                    -- Estado actual: RUNNING | SUCCESS | FAILED
    total_rows_extracted INTEGER,          -- Total de filas leídas de todos los CSVs
    total_rows_loaded INTEGER,             -- Total de filas que llegaron al DW
    total_rows_rejected INTEGER,           -- Total de filas que no pasaron el control de calidad
    execution_time_seconds INTEGER,        -- Duración total del pipeline en segundos
    triggered_by VARCHAR(100) DEFAULT 'airflow', -- Quién disparó la ejecución: local | airflow
    batch_id BIGINT,                       -- ID único que identifica esta carga — viaja hasta fact_sales
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Momento en que se creó el registro en la tabla
);

CREATE TABLE audit.quality_checks (
    check_id BIGSERIAL PRIMARY KEY,        -- ID único autoincremental de cada validación registrada
    run_id BIGINT REFERENCES audit.etl_runs(run_id), -- A qué ejecución del pipeline pertenece este check
    table_name VARCHAR(50),                -- Tabla que se estaba validando: sales, products, customers...
    check_name VARCHAR(100),              -- Nombre descriptivo del check: "order_id no nulo"
    check_type VARCHAR(50),               -- Categoría del check: NULL_CHECK | DUPLICATE | RANGE | FK | BUSINESS_RULE
    failed_records INTEGER,               -- Cuántos registros fallaron esta validación
    passed_records INTEGER,               -- Cuántos registros pasaron esta validación
    severity VARCHAR(20),                 -- Qué tan crítico es este check: LOW | MEDIUM | HIGH
    execution_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Momento exacto en que se ejecutó el check
);

CREATE TABLE audit.rejected_records (
    reject_id BIGSERIAL PRIMARY KEY,      -- ID único autoincremental de cada registro rechazado
    run_id BIGINT REFERENCES audit.etl_runs(run_id), -- A qué ejecución del pipeline pertenece este rechazo
    table_name VARCHAR(50),               -- De qué tabla viene el registro rechazado: sales, products...
    business_key VARCHAR(50),             -- El ID del registro rechazado: order_id, product_id, customer_id...
    error_type VARCHAR(100),              -- Código del error: NULL_PRIMARY_KEY | INVALID_NUMERIC_RANGE...
    error_description TEXT,               -- Detalle específico: columna afectada y valor encontrado
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Momento exacto del rechazo
    batch_id BIGINT                       -- ID de la carga a la que pertenecía este registro
);