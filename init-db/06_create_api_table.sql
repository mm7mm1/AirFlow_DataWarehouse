--  Creating table with data from API fro bronze
CREATE TABLE IF NOT EXISTS bronze.api_exchange_rates (
    base_currency VARCHAR(10),
    target_currency VARCHAR(10),
    rate NUMERIC,
    extraction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating table with data from API for silver with clean data
CREATE TABLE IF NOT EXISTS silver.api_exchange_rates (
    base_currency VARCHAR(10),
    target_currency VARCHAR(10),
    rate NUMERIC,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);