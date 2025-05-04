/*
=========================================================
Create Database and Schemas
=========================================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after chekcing if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
  within the database: 'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the entire 'DataWarehouse' database if it exists.
  All data in the database will be permanently deleted. Proceed with caution 
  and ensure you have proper backups before running this script
*/

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'DataWarehouse') THEN
        -- Disconnect other users (if any) by terminating their connections
        PERFORM pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = 'DataWarehouse'
        AND pid <> pg_backend_pid();
    END IF;
END $$;

DROP DATABASE IF EXISTS "DataWarehouse";

CREATE DATABASE "DataWarehouse";

-- Switch connection to the new database manually
-- After reconnecting to "DataWarehouse", you can run these commands to create the schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
