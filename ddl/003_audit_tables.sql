CREATE TABLE audit.etl_runs (
    run_id BIGSERIAL PRIMARY KEY,
    pipeline_name VARCHAR(100) DEFAULT 'chocolate_sales_pipeline',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status VARCHAR(20), 
    -- RUNNING | SUCCESS | FAILED
    total_rows_extracted INTEGER,
    total_rows_loaded INTEGER,
    total_rows_rejected INTEGER,
    execution_time_seconds INTEGER,
    triggered_by VARCHAR(100) DEFAULT 'airflow',
    batch_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE audit.quality_checks (
    check_id BIGSERIAL PRIMARY KEY,
    run_id BIGINT REFERENCES audit.etl_runs(run_id),
    table_name VARCHAR(50),
    check_name VARCHAR(100),
    check_type VARCHAR(50),
    -- NULL_CHECK | DUPLICATE | RANGE | FK | BUSINESS_RULE
    failed_records INTEGER,
    passed_records INTEGER,
    severity VARCHAR(20),
    -- LOW | MEDIUM | HIGH
    execution_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE audit.rejected_records (
    reject_id BIGSERIAL PRIMARY KEY,
    run_id BIGINT REFERENCES audit.etl_runs(run_id),
    table_name VARCHAR(50),
    business_key VARCHAR(50),
    error_type VARCHAR(100),
    error_description TEXT,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    batch_id BIGINT
);