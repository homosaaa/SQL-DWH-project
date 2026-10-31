# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates a data warehousing solution built on **SQL Server**, from loading raw source files to a business-ready star schema. It was built as a portfolio project while following the [Data With Baraa](https://www.youtube.com/watch?v=9GVqKuTVANE) course "SQL Data Warehouse from Scratch".

---

## 🏗️ Data Architecture

The data architecture follows the **Medallion Architecture** with **Bronze**, **Silver**, and **Gold** layers:

<img width="806" height="419" alt="Data Architecture" src="https://github.com/user-attachments/assets/05d9df2a-4e70-4b7f-8df6-a977a29bd128" />

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into the SQL Server database (`DWH`).
2. **Silver Layer**: Cleansing, standardization, and normalization of the bronze data. It is loaded by the stored procedure `silver.load_silver`.
3. **Gold Layer**: Business-ready data modeled as a star schema (views) for reporting and analytics.

---

## 📖 Project Overview

### Source systems
- **CRM**: `cust_info`, `prd_info`, `sales_details`
- **ERP**: `cust_az12`, `loc_a101`, `px_cat_g1v2`

### What was built

**1. Silver layer (6 tables + load procedure)**

| Table | Main transformations |
|---|---|
| `silver.crm_cust_info` | Removed duplicate customers (kept the latest record), trimmed names, mapped marital status and gender codes to readable values |
| `silver.crm_prd_info` | Split the product key into `cat_id` and `prd_key`, replaced NULL cost with 0, mapped product line codes, rebuilt `prd_end_dt` using `LEAD()` (next version's start date minus one day) |
| `silver.crm_sales_details` | Converted integer dates (`yyyymmdd`) to `DATE`, recalculated invalid sales and price values |
| `silver.erp_cust_az12` | Removed the `NAS` prefix from the customer id, nulled future birth dates, standardized gender |
| `silver.erp_loc_a101` | Removed dashes from the customer id, standardized country names |
| `silver.erp_px_cat_g1v2` | Loaded as-is (already clean) |

- `silver.load_silver` truncates and reloads all silver tables, prints the load duration of each table and of the whole batch, and handles errors with `TRY...CATCH`.

**2. Gold layer (star schema as views)**
- `gold.dim_customers`: CRM customers enriched with ERP birth date, gender, and country, with a surrogate key.
- `gold.dim_products`: current version of each product (`prd_end_dt IS NULL`) enriched with category data, with a surrogate key.
- `gold.fact_sales`: sales details linked to the dimensions through the surrogate keys.

**3. Data quality checks**
- Silver: duplicate or NULL keys, unwanted spaces, standardized values, invalid date ranges, and sales = quantity × price consistency.
- Gold: surrogate key uniqueness, duplicates introduced by joins, referential integrity between the fact and the dimensions, and row counts against the silver layer.

### Next step
- Analytics and reporting on top of the gold layer (SQL reports and dashboards).

---

## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/                       # Raw source files (CRM and ERP CSVs)
│
├── scripts/
│   ├── bronze/                     # Bronze layer scripts (tables and loading)
│   ├── silver/
│   │   ├── ddl_silver.sql              # Creates the silver tables
│   │   └── proc_load_silver.sql        # Stored procedure: silver.load_silver
│   └── gold/
│       └── ddl_gold.sql                # Creates the gold views (star schema)
│
├── tests/
│   ├── quality_checks_silver.sql   # Data quality checks for the silver layer
│   └── quality_checks_gold.sql     # Data quality checks for the gold layer
│
└── README.md
```

---

## ▶️ How to Run

1. Create the `DWH` database and the `bronze`, `silver`, and `gold` schemas.
2. Create the bronze tables and load the CSV files.
3. Create the silver tables: run `ddl_silver.sql`.
4. Create the load procedure: run `proc_load_silver.sql`, then load the silver layer:
   ```sql
   EXEC silver.load_silver;
   ```
5. Run `quality_checks_silver.sql` and confirm it returns no unexpected rows.
6. Create the gold views: run `ddl_gold.sql`.
7. Run `quality_checks_gold.sql` and confirm it returns no unexpected rows.

---

## 🛠️ Tools

- **SQL Server** and **SQL Server Management Studio (SSMS)**
- **Git / GitHub** for version control

---

## 🌟 About Me

Hi there! I'm **Mohmed Mahmoud**, working on data engineering and analytics projects with SQL.  
This project follows the course by [Data With Baraa](https://www.youtube.com/@DataWithBaraa), and all credit for the original project design goes to him.
