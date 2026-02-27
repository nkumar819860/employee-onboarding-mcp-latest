-- Asset Allocation MCP Server Database Initialization for H2
-- H2-Compatible SQL with correct syntax

-- Drop tables if they exist (for clean restart)
DROP TABLE IF EXISTS asset_allocations CASCADE;
DROP TABLE IF EXISTS assets CASCADE;
DROP TABLE IF EXISTS asset_categories CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- Create departments table (H2 compatible)
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    manager_name VARCHAR(100),
    budget_allocation DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create employees table (H2 compatible)
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INT,
    position VARCHAR(100),
    hire_date DATE,
    termination_date DATE NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    manager_id INT,
    location VARCHAR(100),
    cost_center VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create asset_categories table (H2 compatible)
CREATE TABLE asset_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    requires_approval BOOLEAN DEFAULT FALSE,
    max_allocation_per_employee INT DEFAULT 1,
    depreciation_years INT DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create assets table (H2 compatible)
CREATE TABLE assets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    category_id INT,
    brand VARCHAR(50),
    model VARCHAR(100),
    serial_number VARCHAR(100) UNIQUE,
    purchase_date DATE,
    purchase_cost DECIMAL(10,2),
    warranty_expiry DATE,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    condition_status VARCHAR(20) DEFAULT 'NEW',
    location VARCHAR(100),
    vendor VARCHAR(100),
    specifications CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create asset_allocations table (H2 compatible)
CREATE TABLE asset_allocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT,
    employee_id INT,
    allocated_date DATE DEFAULT CURRENT_DATE,
    expected_return_date DATE,
    actual_return_date DATE NULL,
    allocation_status VARCHAR(20) DEFAULT 'ALLOCATED',
    allocation_reason VARCHAR(255),
    approved_by VARCHAR(100),
    approval_date DATE,
    return_condition VARCHAR(20),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraints after tables are created
ALTER TABLE employees ADD CONSTRAINT fk_emp_dept FOREIGN KEY (department_id) REFERENCES departments(id);
ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id) REFERENCES employees(id);
ALTER TABLE assets ADD CONSTRAINT fk_asset_category FOREIGN KEY (category_id) REFERENCES asset_categories(id);
ALTER TABLE asset_allocations ADD CONSTRAINT fk_alloc_asset FOREIGN KEY (asset_id) REFERENCES assets(id);
ALTER TABLE asset_allocations ADD CONSTRAINT fk_alloc_emp FOREIGN KEY (employee_id) REFERENCES employees(id);

-- Insert sample departments
INSERT INTO departments (name, description, manager_name, budget_allocation) VALUES
('IT', 'Information Technology', 'John Smith', 500000.00),
('HR', 'Human Resources', 'Jane Doe', 200000.00),
('Engineering', 'Software Engineering', 'Bob Wilson', 750000.00),
('Marketing', 'Marketing Department', 'Alice Brown', 300000.00),
('Sales', 'Sales Department', 'Charlie Green', 400000.00);

-- Insert sample employees
INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) VALUES
('EMP001', 'John', 'Smith', 'john.smith@company.com', '+1-555-0101', 1, 'IT Manager', '2024-01-15', 'ACTIVE', 'Building A', 'IT001'),
('EMP002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', '+1-555-0201', 3, 'Senior Developer', '2024-01-20', 'ACTIVE', 'Building B', 'ENG001'),
('EMP003', 'Mike', 'Davis', 'mike.davis@company.com', '+1-555-0301', 4, 'Marketing Specialist', '2024-02-01', 'ACTIVE', 'Building A', 'MKT001'),
('EMP004', 'Lisa', 'Wilson', 'lisa.wilson@company.com', '+1-555-0401', 2, 'HR Coordinator', '2024-02-15', 'ACTIVE', 'Building C', 'HR001'),
('EMP005', 'David', 'Brown', 'david.brown@company.com', '+1-555-0501', 5, 'Sales Representative', '2024-03-01', 'ACTIVE', 'Building A', 'SALES001');

-- Insert sample asset categories
INSERT INTO asset_categories (category_name, description, max_allocation_per_employee, requires_approval) VALUES
('LAPTOP', 'Corporate Laptops', 2, FALSE),
('ID_CARD', 'Employee ID Cards', 1, TRUE),
('MOBILE_PHONE', 'Corporate Mobile Phones', 1, TRUE),
('MONITOR', 'External Monitors', 2, FALSE),
('HEADSET', 'Audio Headsets', 1, FALSE),
('KEYBOARD', 'Keyboards', 1, FALSE),
('MOUSE', 'Computer Mice', 1, FALSE),
('WEBCAM', 'Video Cameras', 1, FALSE);

-- Insert sample assets
INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications) VALUES
('LAP-001', 'Dell Latitude 7420', 1, 'Dell', 'Latitude 7420', 'DL7420001', 1200.00, '2027-01-15', 'AVAILABLE', 'NEW', 'IT Storage', 'Dell Technologies', '{"processor": "Intel i7", "memory": "16GB", "storage": "512GB SSD"}'),
('LAP-002', 'MacBook Pro 16"', 1, 'Apple', 'MacBook Pro 16"', 'MBP16002', 2400.00, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage', 'Apple Inc.', '{"processor": "Apple M3 Pro", "memory": "32GB", "storage": "1TB SSD"}'),
('LAP-003', 'ThinkPad X1 Carbon', 1, 'Lenovo', 'ThinkPad X1 Carbon', 'TP1C003', 1500.00, '2027-01-30', 'AVAILABLE', 'NEW', 'IT Storage', 'Lenovo', '{"processor": "Intel i7", "memory": "16GB", "storage": "1TB SSD"}'),
('ID-001', 'Employee ID Card', 2, 'HID Global', 'ProxCard II', 'HID001', 25.00, '2029-01-01', 'AVAILABLE', 'NEW', 'Security Office', 'HID Global Corp', '{"access_level": "Level 2", "features": "RFID, Photo ID"}'),
('ID-002', 'Employee ID Card', 2, 'HID Global', 'ProxCard II', 'HID002', 25.00, '2029-01-01', 'AVAILABLE', 'NEW', 'Security Office', 'HID Global Corp', '{"access_level": "Level 2", "features": "RFID, Photo ID"}'),
('PHN-001', 'iPhone 15 Pro', 3, 'Apple', 'iPhone 15 Pro', 'IPH15001', 999.00, '2026-03-01', 'AVAILABLE', 'NEW', 'IT Storage', 'Apple Inc.', '{"storage": "256GB", "carrier": "Corporate Plan"}'),
('PHN-002', 'Samsung Galaxy S24', 3, 'Samsung', 'Galaxy S24', 'SGS24002', 899.00, '2026-03-15', 'AVAILABLE', 'NEW', 'IT Storage', 'Samsung Electronics', '{"storage": "256GB", "carrier": "Corporate Plan"}'),
('MON-001', 'Dell UltraSharp 27"', 4, 'Dell', 'UltraSharp U2720Q', 'DUS27001', 350.00, '2027-01-15', 'AVAILABLE', 'NEW', 'IT Storage', 'Dell Technologies', '{"size": "27 inch", "resolution": "4K UHD"}'),
('MON-002', 'LG 4K Monitor 32"', 4, 'LG', '32UN650-W', 'LG32001', 400.00, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage', 'LG Electronics', '{"size": "32 inch", "resolution": "4K UHD"}'),
('HS-001', 'Logitech H390 Headset', 5, 'Logitech', 'H390', 'LH390001', 39.99, '2026-01-15', 'AVAILABLE', 'NEW', 'IT Storage', 'Logitech International', '{"type": "USB Wired", "microphone": "Noise-canceling"}');

-- Insert sample asset allocations
INSERT INTO asset_allocations (asset_id, employee_id, allocated_date, allocation_status, allocation_reason, approved_by, approval_date, notes) VALUES
(1, 1, '2024-01-16', 'ALLOCATED', 'New Employee Setup', 'System Admin', '2024-01-16', 'Allocated for IT Manager onboarding'),
(4, 1, '2024-01-16', 'ALLOCATED', 'New Employee Setup', 'Security Admin', '2024-01-16', 'ID card issued for building access');

-- Create indexes for better performance
CREATE INDEX idx_employees_employee_id ON employees(employee_id);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_assets_tag ON assets(asset_tag);
CREATE INDEX idx_assets_category ON assets(category_id);
CREATE INDEX idx_assets_status ON assets(status);
CREATE INDEX idx_asset_allocations_asset ON asset_allocations(asset_id);
CREATE INDEX idx_asset_allocations_employee ON asset_allocations(employee_id);
CREATE INDEX idx_asset_allocations_status ON asset_allocations(allocation_status);

-- Insert completion marker
INSERT INTO departments (name, description) VALUES ('_INIT_COMPLETE_', 'H2 Asset Allocation Database initialization completed successfully');
