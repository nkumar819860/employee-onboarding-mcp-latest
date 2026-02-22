-- PostgreSQL Database Initialization for Employee Onboarding System
-- This script creates separate databases and users for different MCP services

-- Create databases
CREATE DATABASE employee_onboarding;
CREATE DATABASE asset_allocation;

-- Create users with passwords
CREATE USER employee_user WITH PASSWORD 'employee_pass';
CREATE USER asset_user WITH PASSWORD 'asset_pass';

-- Grant privileges on employee_onboarding database
GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO employee_user;

-- Grant privileges on asset_allocation database
GRANT ALL PRIVILEGES ON DATABASE asset_allocation TO asset_user;

-- Connect to employee_onboarding database to set up schema permissions
\c employee_onboarding;
GRANT ALL ON SCHEMA public TO employee_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO employee_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO employee_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO employee_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO employee_user;

-- Connect to asset_allocation database to set up schema permissions  
\c asset_allocation;
GRANT ALL ON SCHEMA public TO asset_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO asset_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO asset_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO asset_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO asset_user;

-- Return to postgres database
\c postgres;

-- Create extension for UUID generation if needed
\c employee_onboarding;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c asset_allocation;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log completion
\c postgres;
INSERT INTO pg_catalog.pg_description (objoid, classoid, objsubid, description) VALUES (0, 0, 0, 'Employee Onboarding Database Setup Completed');
