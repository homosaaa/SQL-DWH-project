
-- =====================================================
-- Project: Data Warehouse
-- Description: Create Bronze Layer tables using DDL,
-- OBJECT_ID(), IF conditions, and SQL Server data types.
-- =====================================================

use DWH ;
go 
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

create table bronze.crm_cust_info(
cst_id int,
cst_key varchar(50),
cst_fname varchar(50),
cst_lname varchar(50),
cst_marital_status varchar(50),
cst_gndr varchar(50),
cst_create_date date ,

) ;
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

create table bronze.crm_prd_info(
prd_id int ,
prd_key varchar(50),
prd_nm varchar(50),
prd_cost int ,
prd_line varchar (50),
prd_start_dt date , 
prd_end_dt date 
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
 
 IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
cid varchar(50) ,
bdate date, 
gen varchar(50)

) ;
 
 IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

create table bronze.erp_loc_a101(
cid varchar (50),
cntr varchar (50)
);
 IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

create table bronze.erp_px_cat_g1v2(
id varchar(50),
cat varchar(50),
subcat varchar(50),
maintenance varchar(50)
) ;
