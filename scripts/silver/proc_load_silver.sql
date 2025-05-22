/*
=========================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=========================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL silver.load_silver();
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE PLPGSQL -- Use PLPGSQL instead of SQL for RAISE support
AS $$
BEGIN
  BEGIN
    RAISE NOTICE '=========================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '=========================================================';

    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE 'Loadin CRM Tables';
    RAISE NOTICE '---------------------------------------------------------';

    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO
    silver.crm_cust_info (
      cst_id,
      cst_key,
      cst_firstname,
      cst_lastname,
      cst_marital_status,
      cst_gndr,
      cst_create_date
    )
    SELECT
      cst_id,
      cst_key,
      TRIM(cst_firstname) AS cst_firstname,
      TRIM(cst_lastname) AS cst_lastname,
      CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
      END AS cst_marital_status,
      CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
      END AS cst_gndr,
      cst_create_date
    FROM
      (
        SELECT
          *,
          ROW_NUMBER() OVER (
            PARTITION BY
              cst_id
            ORDER BY
              cst_create_date DESC NULLS LAST
          ) AS flag_last
        FROM
          bronze.crm_cust_info
      ) t
    WHERE
      t.flag_last = 1;

    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO
      silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_date,
        prd_end_date
      )
    SELECT
      prd_id,
      REPLACE (SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
      SUBSTRING(prd_key, 7, LENGTH (prd_key)) as prd_key,
      prd_nm,
      COALESCE(prd_cost, 0) AS prd_cost,
      CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        when 'T' THEN 'Touring'
        ELSE 'n/a'
      END AS prd_line,
      CAST(prd_start_date AS date) AS prd_start_date,
      CAST(
        LEAD (prd_start_date) OVER (
          PARTITION BY
            prd_key
          ORDER BY
            prd_start_date
        ) -1 AS DATE
      ) AS prd_end_date
    FROM
      bronze.crm_prd_info;

    RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO
      silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_date,
        sls_ship_date,
        sls_due_date,
        sls_sales,
        sls_quantity,
        sls_price
      )
    SELECT
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      CASE
        WHEN LENGTH (CAST(sls_order_date AS TEXT)) = 0
        OR LENGTH (CAST(sls_order_date AS TEXT)) != 8 THEN NULL
        ELSE TO_DATE (CAST(sls_order_date AS TEXT), 'YYYYMMDD')
      END AS sls_order_date,
      CASE
        WHEN LENGTH (CAST(sls_ship_date AS TEXT)) = 0
        OR LENGTH (CAST(sls_ship_date AS TEXT)) != 8 THEN NULL
        ELSE TO_DATE (CAST(sls_ship_date AS TEXT), 'YYYYMMDD')
      END AS sls_ship_date,
      CASE
        WHEN LENGTH (CAST(sls_due_date AS TEXT)) = 0
        OR LENGTH (CAST(sls_due_date AS TEXT)) != 8 THEN NULL
        ELSE TO_DATE (CAST(sls_due_date AS TEXT), 'YYYYMMDD')
      END AS sls_due_date,
      CASE
        WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
      END AS sls_sales,
      sls_quantity,
      CASE
        WHEN sls_price IS NULL
        OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
      END AS sls_price
    FROM
      bronze.crm_sales_details;

    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE 'Loadin ERP Tables';
    RAISE NOTICE '---------------------------------------------------------';
    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO
      silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
      CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH (cid))
        ELSE cid
      END AS cid,
      CASE
        WHEN bdate > NOW () THEN NULL
        ELSE bdate
      END AS bdate, -- Set future birthdates to NULL
      CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
      END AS gen -- Normalize gender values and handle unknown cases
    FROM
      bronze.erp_cust_az12;

    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
    INSERT INTO
      silver.erp_loc_a101 (cid, cntry)
    SELECT
      REPLACE (cid, '-', '') cid,
      CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = ''
        OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
      END AS cntry
    FROM
      bronze.erp_loc_a101;

    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO
      silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT
      id,
      cat,
      subcat,
      maintenance
    FROM
      bronze.erp_px_cat_g1v2;
  END;
END;
$$

