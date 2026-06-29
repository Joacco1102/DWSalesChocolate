CREATE TABLE IF NOT EXISTS dw.dim_product(
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(20) NOT NULL,
    product_name VARCHAR(200),
    brand VARCHAR(100),
    category VARCHAR(100),
    cocoa_percent INTEGER,
    weight_g INTEGER,
    CONSTRAINT uk_dim_product_id UNIQUE (product_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    age INTEGER,
    gender VARCHAR(10),
    loyalty_member INTEGER,
    join_date DATE,
    CONSTRAINT uk_dim_customer_id UNIQUE (customer_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id VARCHAR(20) NOT NULL,
    store_name VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100),
    store_type VARCHAR(50),
    CONSTRAINT uk_dim_store_id UNIQUE (store_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key INTEGER PRIMARY KEY,
    date DATE,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    week INTEGER,
    day_of_week INTEGER
);