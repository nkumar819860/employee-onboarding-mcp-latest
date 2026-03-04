-- Asset Allocation MCP Server Database Initialization Script
-- Using Script-Based Approach for H2 Database

-- Enable H2 features
SET MODE REGULAR;
SET REFERENTIAL_INTEGRITY FALSE;

-- Drop existing data first
DELETE FROM asset_allocations WHERE id IS NOT NULL;
DELETE FROM assets WHERE id IS NOT NULL;  
DELETE FROM asset_categories WHERE id IS NOT NULL;
DELETE FROM employees WHERE id IS NOT NULL;
DELETE FROM departments WHERE id IS NOT NULL;

-- Reset sequences
DROP SEQUENCE IF EXISTS dept_seq;
DROP SEQUENCE IF EXISTS emp_seq; 
DROP SEQUENCE IF EXISTS cat_seq;
DROP SEQUENCE IF EXISTS asset_seq;
DROP SEQUENCE IF EXISTS alloc_seq;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS dept_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS emp_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS cat_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS asset_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS alloc_seq START WITH 1 INCREMENT BY 1;

-- Create tables with proper constraints
CREATE TABLE IF NOT EXISTS departments (
    id INT DEFAULT NEXT VALUE FOR dept_seq PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    manager_name VARCHAR(100),
    budget_allocation DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employees (
    id INT DEFAULT NEXT VALUE FOR emp_seq PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department_id INT,
    position VARCHAR(100),
    hire_date DATE DEFAULT CURRENT_DATE,
    termination_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'TERMINATED')),
    manager_id INT,
    location VARCHAR(100),
    cost_center VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES employees(id)
);

CREATE TABLE IF NOT EXISTS asset_categories (
    id INT DEFAULT NEXT VALUE FOR cat_seq PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    requires_approval BOOLEAN DEFAULT FALSE,
    max_allocation_per_employee INT DEFAULT 1 CHECK (max_allocation_per_employee > 0),
    depreciation_years INT DEFAULT 3 CHECK (depreciation_years > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS assets (
    id INT DEFAULT NEXT VALUE FOR asset_seq PRIMARY KEY,
    asset_tag VARCHAR(50) NOT NULL UNIQUE,
    asset_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    brand VARCHAR(50),
    model VARCHAR(100),
    serial_number VARCHAR(100) UNIQUE,
    purchase_date DATE DEFAULT CURRENT_DATE,
    purchase_cost DECIMAL(10,2) DEFAULT 0.00,
    warranty_expiry DATE,
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'ALLOCATED', 'MAINTENANCE', 'RETIRED')),
    condition_status VARCHAR(20) DEFAULT 'NEW' CHECK (condition_status IN ('NEW', 'GOOD', 'FAIR', 'POOR', 'DAMAGED')),
    location VARCHAR(100),
    vendor VARCHAR(100),
    specifications VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_asset_category FOREIGN KEY (category_id) REFERENCES asset_categories(id)
);

CREATE TABLE IF NOT EXISTS asset_allocations (
    id INT DEFAULT NEXT VALUE FOR alloc_seq PRIMARY KEY,
    asset_id INT NOT NULL,
    employee_id INT NOT NULL,
    allocated_date DATE DEFAULT CURRENT_DATE,
    expected_return_date DATE,
    actual_return_date DATE,
    allocation_status VARCHAR(20) DEFAULT 'ALLOCATED' CHECK (allocation_status IN ('ALLOCATED', 'RETURNED', 'LOST', 'DAMAGED')),
    allocation_reason VARCHAR(255),
    approved_by VARCHAR(100),
    approval_date DATE DEFAULT CURRENT_DATE,
    return_condition VARCHAR(20) CHECK (return_condition IN ('GOOD', 'FAIR', 'POOR', 'DAMAGED') OR return_condition IS NULL),
    notes VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_alloc_asset FOREIGN KEY (asset_id) REFERENCES assets(id),
    CONSTRAINT fk_alloc_emp FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Create performance indexes
CREATE INDEX IF NOT EXISTS idx_employees_employee_id ON employees(employee_id);
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_employees_status ON employees(status);
CREATE INDEX IF NOT EXISTS idx_assets_tag ON assets(asset_tag);
CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category_id);
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_asset_allocations_asset ON asset_allocations(asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_allocations_employee ON asset_allocations(employee_id);
CREATE INDEX IF NOT EXISTS idx_asset_allocations_status ON asset_allocations(allocation_status);

-- Re-enable referential integrity
SET REFERENTIAL_INTEGRITY TRUE;

-- Populate initial data using script approach
-- Insert departments
INSERT INTO departments (name, description, manager_name, budget_allocation) VALUES
('IT', 'Information Technology Department', 'John Smith', 500000.00),
('HR', 'Human Resources Department', 'Jane Doe', 200000.00),
('Engineering', 'Software Engineering Department', 'Bob Wilson', 750000.00),
('Marketing', 'Marketing Department', 'Alice Brown', 300000.00),
('Sales', 'Sales Department', 'Charlie Green', 400000.00);

-- Insert initial employees with proper references
INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) 
SELECT 
    'EMP001', 'John', 'Smith', 'john.smith@company.com', '+1-555-0101', 
    d.id, 'IT Manager', '2024-01-15', 'ACTIVE', 'Building A', 'IT001'
FROM departments d WHERE d.name = 'IT';

INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) 
SELECT 
    'EMP002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', '+1-555-0201', 
    d.id, 'Senior Developer', '2024-01-20', 'ACTIVE', 'Building B', 'ENG001'
FROM departments d WHERE d.name = 'Engineering';

INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) 
SELECT 
    'EMP003', 'Mike', 'Davis', 'mike.davis@company.com', '+1-555-0301', 
    d.id, 'Marketing Specialist', '2024-02-01', 'ACTIVE', 'Building A', 'MKT001'
FROM departments d WHERE d.name = 'Marketing';

INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) 
SELECT 
    'EMP004', 'Lisa', 'Wilson', 'lisa.wilson@company.com', '+1-555-0401', 
    d.id, 'HR Coordinator', '2024-02-15', 'ACTIVE', 'Building C', 'HR001'
FROM departments d WHERE d.name = 'HR';

INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) 
SELECT 
    'EMP005', 'David', 'Brown', 'david.brown@company.com', '+1-555-0501', 
    d.id, 'Sales Representative', '2024-03-01', 'ACTIVE', 'Building A', 'SALES001'
FROM departments d WHERE d.name = 'Sales';

-- Insert asset categories
INSERT INTO asset_categories (category_name, description, max_allocation_per_employee, requires_approval) VALUES
('LAPTOP', 'Corporate Laptops and Portable Computers', 2, FALSE),
('ID_CARD', 'Employee Identification Cards', 1, TRUE),
('MOBILE_PHONE', 'Corporate Mobile Phones and Devices', 1, TRUE),
('MONITOR', 'External Monitors and Displays', 2, FALSE),
('HEADSET', 'Audio Headsets and Communication Devices', 1, FALSE),
('KEYBOARD', 'Computer Keyboards', 1, FALSE),
('MOUSE', 'Computer Mice and Pointing Devices', 1, FALSE),
('WEBCAM', 'Video Cameras and Conference Equipment', 1, FALSE);

-- Insert sample assets with proper category references
INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'LAP-001', 'Dell Latitude 7420 Business Laptop', c.id, 'Dell', 'Latitude 7420', 'DL7420001', 1200.00, '2027-01-15', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Dell Technologies', '{"processor": "Intel i7-1185G7", "memory": "16GB DDR4", "storage": "512GB NVMe SSD", "display": "14 FHD", "os": "Windows 11 Pro"}'
FROM asset_categories c WHERE c.category_name = 'LAPTOP';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'LAP-002', 'Apple MacBook Pro 16-inch', c.id, 'Apple', 'MacBook Pro 16"', 'MBP16002', 2400.00, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Apple Inc.', '{"processor": "Apple M3 Pro", "memory": "32GB Unified", "storage": "1TB SSD", "display": "16 Liquid Retina XDR", "os": "macOS Sonoma"}'
FROM asset_categories c WHERE c.category_name = 'LAPTOP';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'LAP-003', 'Lenovo ThinkPad X1 Carbon', c.id, 'Lenovo', 'ThinkPad X1 Carbon Gen 11', 'TP1C003', 1500.00, '2027-01-30', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Lenovo', '{"processor": "Intel i7-1355U", "memory": "16GB LPDDR5", "storage": "1TB NVMe SSD", "display": "14 WUXGA", "os": "Windows 11 Pro"}'
FROM asset_categories c WHERE c.category_name = 'LAPTOP';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'ID-001', 'Employee ID Card - Level 2 Access', c.id, 'HID Global', 'ProxCard II', 'HID001', 25.00, '2029-01-01', 'AVAILABLE', 'NEW', 'Security Office', 'HID Global Corp', '{"access_level": "Level 2", "features": "RFID, Photo ID, Building Access", "technology": "125 kHz Proximity"}'
FROM asset_categories c WHERE c.category_name = 'ID_CARD';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'ID-002', 'Employee ID Card - Level 2 Access', c.id, 'HID Global', 'ProxCard II', 'HID002', 25.00, '2029-01-01', 'AVAILABLE', 'NEW', 'Security Office', 'HID Global Corp', '{"access_level": "Level 2", "features": "RFID, Photo ID, Building Access", "technology": "125 kHz Proximity"}'
FROM asset_categories c WHERE c.category_name = 'ID_CARD';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'PHN-001', 'iPhone 15 Pro Corporate Device', c.id, 'Apple', 'iPhone 15 Pro', 'IPH15001', 999.00, '2026-03-01', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Apple Inc.', '{"storage": "256GB", "carrier": "Corporate Plan", "plan": "Unlimited Business", "color": "Natural Titanium"}'
FROM asset_categories c WHERE c.category_name = 'MOBILE_PHONE';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'PHN-002', 'Samsung Galaxy S24 Business Phone', c.id, 'Samsung', 'Galaxy S24', 'SGS24002', 899.00, '2026-03-15', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Samsung Electronics', '{"storage": "256GB", "carrier": "Corporate Plan", "plan": "Unlimited Business", "color": "Phantom Black"}'
FROM asset_categories c WHERE c.category_name = 'MOBILE_PHONE';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'MON-001', 'Dell UltraSharp 27-inch 4K Monitor', c.id, 'Dell', 'UltraSharp U2720Q', 'DUS27001', 350.00, '2027-01-15', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Dell Technologies', '{"size": "27 inch", "resolution": "3840x2160 4K UHD", "panel": "IPS", "connectivity": "USB-C, HDMI, DisplayPort", "color_accuracy": "99% sRGB"}'
FROM asset_categories c WHERE c.category_name = 'MONITOR';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'MON-002', 'LG 4K UHD Monitor 32-inch', c.id, 'LG', '32UN650-W', 'LG32001', 400.00, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage Room', 'LG Electronics', '{"size": "32 inch", "resolution": "3840x2160 4K UHD", "panel": "VA", "connectivity": "HDMI, DisplayPort, USB-C", "hdr": "HDR10"}'
FROM asset_categories c WHERE c.category_name = 'MONITOR';

INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications)
SELECT 
    'HS-001', 'Logitech H390 USB Headset', c.id, 'Logitech', 'H390', 'LH390001', 39.99, '2026-01-15', 'AVAILABLE', 'NEW', 'IT Storage Room', 'Logitech International', '{"type": "USB Wired", "microphone": "Noise-canceling", "controls": "In-line volume and mute", "compatibility": "Windows, Mac, Chrome OS"}'
FROM asset_categories c WHERE c.category_name = 'HEADSET';

-- Create some initial allocations for demonstration
-- Allocate laptop to EMP001 (John Smith)
INSERT INTO asset_allocations (asset_id, employee_id, allocated_date, allocation_status, allocation_reason, approved_by, approval_date, notes)
SELECT 
    a.id, e.id, '2024-01-16', 'ALLOCATED', 'New Employee Onboarding Setup', 'System Admin', '2024-01-16', 'Initial allocation for IT Manager role - Dell Latitude laptop assigned'
FROM assets a, employees e 
WHERE a.asset_tag = 'LAP-001' AND e.employee_id = 'EMP001';

-- Allocate ID card to EMP001
INSERT INTO asset_allocations (asset_id, employee_id, allocated_date, allocation_status, allocation_reason, approved_by, approval_date, notes)
SELECT 
    a.id, e.id, '2024-01-16', 'ALLOCATED', 'Employee Access Card Issuance', 'Security Admin', '2024-01-16', 'Level 2 access card issued for building and system access'
FROM assets a, employees e 
WHERE a.asset_tag = 'ID-001' AND e.employee_id = 'EMP001';

-- Update asset status for allocated items
UPDATE assets SET status = 'ALLOCATED', updated_at = CURRENT_TIMESTAMP 
WHERE asset_tag IN ('LAP-001', 'ID-001');

-- Insert completion marker with metadata
INSERT INTO departments (name, description, manager_name, budget_allocation) VALUES 
('_SCRIPT_INIT_COMPLETE_', 'H2 Asset Allocation Database initialization completed successfully via script-based approach', 'MCP System', 0.00);

-- Final validation query to ensure data integrity
-- This will be logged by the application
SELECT 
    'Initialization Summary' as status,
    (SELECT COUNT(*) FROM departments) as departments_count,
    (SELECT COUNT(*) FROM employees) as employees_count,  
    (SELECT COUNT(*) FROM asset_categories) as categories_count,
    (SELECT COUNT(*) FROM assets) as assets_count,
    (SELECT COUNT(*) FROM asset_allocations) as allocations_count,
    (SELECT COUNT(*) FROM assets WHERE status = 'AVAILABLE') as available_assets,
    (SELECT COUNT(*) FROM assets WHERE status = 'ALLOCATED') as allocated_assets,
    CURRENT_TIMESTAMP as completed_at;
