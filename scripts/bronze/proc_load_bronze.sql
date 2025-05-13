/*
=========================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `COPY` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.
*/


TRUNCATE TABLE bronze.crm_cust_info;
COPY bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_material_status, cst_gndr, cst_create_dt)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
DELIMITER ',' 
CSV HEADER;

TRUNCATE TABLE bronze.crm_prd_info;
COPY bronze.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_create_dt, prd_end_dt)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
DELIMITER ',' 
CSV HEADER;

TRUNCATE TABLE bronze.crm_sales_details;
COPY bronze.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
DELIMITER ',' 
CSV HEADER;

TRUNCATE TABLE bronze.erp_loc_a101;
COPY bronze.erp_loc_a101 (cid, cntry)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
DELIMITER ',' 
CSV HEADER;

TRUNCATE TABLE bronze.erp_cust_az12;
COPY bronze.erp_cust_az12 (cid, bdate, gen)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
DELIMITER ',' 
CSV HEADER;

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
COPY bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
DELIMITER ',' 
CSV HEADER;

