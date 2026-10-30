/*
===============================================================================
Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    Runs data quality checks on the 'silver' schema tables:
        - NULL or duplicate primary keys
        - Unwanted spaces in text columns
        - Data standardization and consistency
        - Invalid date ranges and orders
        - Data consistency between related columns

Usage:
    Run after EXEC silver.load_silver;
    Expectation: every check returns NO ROWS, unless a comment says otherwise.
===============================================================================
*/

USE DWH;
GO

-- ====================================================================
-- silver.crm_cust_info
-- ====================================================================

-- NULL or duplicate PK (Expectation: No Result)
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces (Expectation: No Result)
SELECT cst_fname FROM silver.crm_cust_info WHERE cst_fname != TRIM(cst_fname);
SELECT cst_lname FROM silver.crm_cust_info WHERE cst_lname != TRIM(cst_lname);
SELECT cst_gndr  FROM silver.crm_cust_info WHERE cst_gndr  != TRIM(cst_gndr);

-- Standardization (Expectation: Single / Married / n/a  and  Female / Male / n/a)
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- ====================================================================
-- silver.crm_prd_info
-- ====================================================================

-- NULL or duplicate PK (Expectation: No Result)
SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Unwanted spaces (Expectation: No Result)
SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm != TRIM(prd_nm);

-- NULL or negative cost (Expectation: No Result)
SELECT prd_cost FROM silver.crm_prd_info WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Standardization (Expectation: Mountain / Road / Other Sales / Touring / n/a)
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Invalid date order (Expectation: No Result)
SELECT * FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- silver.crm_sales_details
-- ====================================================================

-- Invalid date order (Expectation: No Result)
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Sales = Quantity * Price, no NULL / zero / negative (Expectation: No Result)
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Orders whose customer or product does not exist in the silver tables (Expectation: No Result)
SELECT * FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

SELECT * FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- ====================================================================
-- silver.erp_cust_az12
-- ====================================================================

-- Out-of-range birth dates (Expectation: review any rows returned)
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Standardization (Expectation: Female / Male / n/a)
SELECT DISTINCT gen FROM silver.erp_cust_az12;

-- cid without a match in the CRM customers (Expectation: No Result)
SELECT * FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- ====================================================================
-- silver.erp_loc_a101
-- ====================================================================

-- Standardization (Expectation: full country names, no codes like DE / US / USA)
SELECT DISTINCT cntr FROM silver.erp_loc_a101 ORDER BY cntr;

-- cid without a match in the CRM customers (Expectation: No Result)
SELECT * FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- ====================================================================
-- silver.erp_px_cat_g1v2
-- ====================================================================

-- Unwanted spaces (Expectation: No Result)
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Standardization (review the values)
SELECT DISTINCT cat FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;

-- ====================================================================
-- Row counts: silver vs bronze
-- (differences are expected only for crm_cust_info, where duplicates are removed)
-- ====================================================================
SELECT 'crm_cust_info'     AS tbl, (SELECT COUNT(*) FROM bronze.crm_cust_info)     AS bronze_rows, (SELECT COUNT(*) FROM silver.crm_cust_info)     AS silver_rows
UNION ALL
SELECT 'crm_prd_info',            (SELECT COUNT(*) FROM bronze.crm_prd_info),            (SELECT COUNT(*) FROM silver.crm_prd_info)
UNION ALL
SELECT 'crm_sales_details',       (SELECT COUNT(*) FROM bronze.crm_sales_details),       (SELECT COUNT(*) FROM silver.crm_sales_details)
UNION ALL
SELECT 'erp_cust_az12',           (SELECT COUNT(*) FROM bronze.erp_cust_az12),           (SELECT COUNT(*) FROM silver.erp_cust_az12)
UNION ALL
SELECT 'erp_loc_a101',            (SELECT COUNT(*) FROM bronze.erp_loc_a101),            (SELECT COUNT(*) FROM silver.erp_loc_a101)
UNION ALL
SELECT 'erp_px_cat_g1v2',         (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2),         (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2);
