-- =====================================================
-- SALES
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.sales_raw (
    order_id VARCHAR(20),
    order_date DATE,
    product_id VARCHAR(20),
    store_id VARCHAR(20),
    customer_id VARCHAR(20),
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    discount NUMERIC(5,2),
    revenue NUMERIC(12,2),
    cost NUMERIC(12,2),
    profit NUMERIC(12,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.sales_clean (
    order_id VARCHAR(20),
    order_date DATE,
    product_id VARCHAR(20),
    store_id VARCHAR(20),
    customer_id VARCHAR(20),
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    discount NUMERIC(5,2),
    revenue NUMERIC(12,2),
    cost NUMERIC(12,2),
    profit NUMERIC(12,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.sales_rejected (
    order_id VARCHAR(20),
    order_date DATE,
    product_id VARCHAR(20),
    store_id VARCHAR(20),
    customer_id VARCHAR(20),
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    discount NUMERIC(5,2),
    revenue NUMERIC(12,2),
    cost NUMERIC(12,2),
    profit NUMERIC(12,2),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    rejection_reason TEXT
);

-- =====================================================
-- PRODUCTS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.products_raw (
    product_id VARCHAR(20),
    product_name VARCHAR(200),
    brand VARCHAR(100),
    category VARCHAR(100),
    cocoa_percent INTEGER,
    weight_g INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.products_clean (
    product_id VARCHAR(20),
    product_name VARCHAR(200),
    brand VARCHAR(100),
    category VARCHAR(100),
    cocoa_percent INTEGER,
    weight_g INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.products_rejected (
    product_id VARCHAR(20),
    product_name VARCHAR(200),
    brand VARCHAR(100),
    category VARCHAR(100),
    cocoa_percent INTEGER,
    weight_g INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    rejection_reason TEXT
);

-- =====================================================
-- CUSTOMERS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.customers_raw (
    customer_id VARCHAR(20),
    age INTEGER,
    gender VARCHAR(10),
    loyalty_member INTEGER,
    join_date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.customers_clean (
    customer_id VARCHAR(20),
    age INTEGER,
    gender VARCHAR(10),
    loyalty_member INTEGER,
    join_date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.customers_rejected (
    customer_id VARCHAR(20),
    age INTEGER,
    gender VARCHAR(10),
    loyalty_member INTEGER,
    join_date DATE,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    rejection_reason TEXT
);

-- =====================================================
-- STORES
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.stores_raw (
    store_id VARCHAR(20),
    store_name VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100),
    store_type VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.stores_clean (
    store_id VARCHAR(20),
    store_name VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100),
    store_type VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.stores_rejected (
    store_id VARCHAR(20),
    store_name VARCHAR(200),
    city VARCHAR(100),
    country VARCHAR(100),
    store_type VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    rejection_reason TEXT
);

-- =====================================================
-- CALENDAR
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.calendar_raw (
    date DATE,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    week INTEGER,
    day_of_week INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.calendar_clean (
    date DATE,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    week INTEGER,
    day_of_week INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS staging.calendar_rejected (
    date DATE,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    week INTEGER,
    day_of_week INTEGER,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    rejection_reason TEXT
);