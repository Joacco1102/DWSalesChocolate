CREATE TABLE IF NOT EXISTS dw.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(20) NOT NULL,
    date_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    discount NUMERIC(5,2),
    revenue NUMERIC(12,2) NOT NULL,
    cost NUMERIC(12,2) NOT NULL,
    profit NUMERIC(12,2) NOT NULL,

    batch_id BIGINT,
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES dw.dim_date(date_key),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key)
        REFERENCES dw.dim_product(product_key),

    CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key)
        REFERENCES dw.dim_customer(customer_key),

    CONSTRAINT fk_fact_store
        FOREIGN KEY (store_key)
        REFERENCES dw.dim_store(store_key)

);