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

Usage Example:
    CALL bronze.load_bronze();
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE PLPGSQL -- Use PLPGSQL instead of SQL for RAISE support

AS $$
BEGIN
  BEGIN --TRY
    RAISE NOTICE '=========================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '=========================================================';


    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE 'Loadin CRM Tables';
    RAISE NOTICE '---------------------------------------------------------';

    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
    DELIMITER ',' 
    CSV HEADER;

    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_date, prd_end_date)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
    DELIMITER ',' 
    CSV HEADER;

    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_date, sls_ship_date, sls_due_date, sls_sales, sls_quantity, sls_price)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
    DELIMITER ',' 
    CSV HEADER;

    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE 'Loadin ERP Tables';
    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101 (cid, cntry)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
    DELIMITER ',' 
    CSV HEADER;

    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12 (cid, bdate, gen)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
    DELIMITER ',' 
    CSV HEADER;

    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    FROM '/Users/nicki/Desktop/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
    DELIMITER ',' 
    CSV HEADER;

    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '=========================================================';
        RAISE WARNING 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        RAISE WARNING 'Error Message: %', SQLERRM;
        RAISE WARNING 'Error State: %', SQLSTATE;
        RAISE NOTICE '=========================================================';
  END; --TRY
END;
$$;

