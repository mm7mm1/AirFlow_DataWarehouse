/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema).

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- View: gold.dim_customers 

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id DESC) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    cl.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca 
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl 
ON ci.cst_key = cl.cid;

select * from gold.dim_customers;
-- View: gold.dim_products

CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
    pi.prd_id as product_id,
    pi.prd_key as product_number,
    pi.prd_nm as product_name,
    pi.cat_id as category_id,
    pc.cat as category,
    pc.subcat as subcategory,
    pc.maintenance as maintenance,
    pi.prd_cost as product_cost,
    pi.prd_line as product_line,
    pi.prd_start_dt as product_start_date
FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc 
ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; -- filter all historical data


CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount, 
    sd.sls_quantity AS quantity,
    sd.sls_price AS price,
    ROUND(CAST(sd.sls_sales * er_eur.rate AS NUMERIC), 2) AS sales_amount_eur,
    ROUND(CAST(sd.sls_sales * er_uah.rate AS NUMERIC), 2) AS sales_amount_uah

FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS dp
    ON sd.sls_prd_key = dp.product_number
LEFT JOIN gold.dim_customers AS dc
    ON sd.sls_cust_id = dc.customer_id
-- API joins
LEFT JOIN silver.api_exchange_rates er_eur 
    ON er_eur.target_currency = 'EUR'
LEFT JOIN silver.api_exchange_rates er_uah 
    ON er_uah.target_currency = 'UAH';
    