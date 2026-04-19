/*
============================================================
Create Schemas for Medallion Architecture
============================================================
Project: SQL Data Warehouse
Database: DataWarehouse
Author: Anastasiia

Purpose:
    This script sets up three distinct schemas to organize 
    the data flow from raw ingestion to analytics:
    - 'bronze': Raw data imported from ERP and CRM CSV files.
    - 'silver': Cleaned and transformed data.
    - 'gold': Final aggregated data for BI and reporting.
============================================================
*/

-- Creating schemas if they do not already exist
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

