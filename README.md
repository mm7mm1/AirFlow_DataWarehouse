# 🚀 Project #1: Orchestration with Apache Airflow

## 📌 Project Goal
To automate data collection from external APIs and integrate it into an existing Data Warehouse (DWH). This project simulates a **hybrid data system**: legacy Order data (ERP) arrives as CSV files (simulating a legacy system), while market prices and currency exchange rates are fetched in real-time via REST API.

Airflow orchestrates the entire process: it waits for the file, pulls data from the API, cleans it, and merges everything into a **Gold** reporting table.

---

## 🛠 Tech Stack & Environment
* **Orchestration:** Apache Airflow (Official image: `apache/airflow`)
* **Database:** PostgreSQL 15
* **Infrastructure:** Docker & Docker Compose
* **Architecture:** Medallion (Bronze -> Silver -> Gold)

---

## 💡 Key Features
* **Hybrid Data Integration:** Combines static CSV datasets with dynamic JSON API data streams.
* **Resilience:** Configured `retries` and `retry_delay` for API tasks to handle intermittent network failures.
* **Automated DB Init:** Using `docker-entrypoint-initdb.d` with ordered SQL scripts (01-08) for seamless schema and view creation.
* **Python & SQL Synergy:** Uses `PythonOperator` for API logic and `PostgresOperator` for heavy DWH transformations.

---

## 🏗 DAG Implementation
* **Extract:** Python script fetching data from public APIs (Open Exchange Rates) and ingesting CSV datasets into the Bronze layer.
* **Transform:** Data cleaning, type casting, and currency conversion using PostgreSQL Stored Procedures.
* **Load:** Loading into Postgres using **Upsert** logic (replacing existing records to avoid duplicates).

---

## 🚀 Deployment Guide (Instruction)

### 1. Setup
Clone the repository and run:
```bash
docker-compose up -d
````

### 2\. Manual Initialization

If the Airflow webserver doesn't start automatically or containers exit, run:

```bash
docker-compose run --rm airflow-webserver airflow users create \
    --username admin \
    --firstname Admin \
    --lastname Admin \
    --role Admin \
    --email admin@example.com \
    --password admin
```

### 3\. Airflow Configuration

1.  Open Airflow UI: [http://localhost:8085](https://www.google.com/search?q=http://localhost:8085)
2.  **Login:** `admin` | **Password:** `admin`
3.  In the Airflow menu: **Admin -\> Connections**.
4.  Click **"+"** and fill in `postgres_default`:
      * **Conn Id:** `postgres_default`
      * **Conn Type:** `Postgres`
      * **Host:** `dwh_db`
      * **Schema:** `DataWarehouse`
      * **Login:** `admin`
      * **Password:** `root`
      * **Port:** `5432`

### 4\. Running and Verification

  * Toggle the DAG `initial_data_load_v2` to **On** and trigger it.
  * **Troubleshooting:** If the log shows "Procedure not found", manually execute the scripts in `init-db/05_procedures` via SQLTools or DBeaver. Clear the failed tasks and resume.
  * **Final Check:** Verify the results with a test query from quality_checks_gold.sql:

<!-- end list -->

```sql
-- Check if sales figures are correctly converted via API rates
SELECT 
    order_number, 
    sales_amount_eur, 
    sales_amount_uah 
FROM gold.fact_sales 
LIMIT 10;
```
## License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.


## About me 
Hey, my name is Anastasiia, I am a Data Engineer wanting to achieve high results.
<br>
I'm open to feedback and would love to discuss the architectural choices I made in this project! <br>
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anastasiia-kukhar-mm7mm1/)
