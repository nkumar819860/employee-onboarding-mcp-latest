-- Asset Allocation MCP Server Database Initialization
-- Compatible with both H2 and PostgreSQL
-- Manages laptop, ID card, and other asset allocations for employees

-- Drop tables if they exist (for clean restart)
DROP TABLE IF EXISTS asset_maintenance CASCADE;
DROP TABLE IF EXISTS asset_allocations CASCADE;
DROP TABLE IF EXISTS assets CASCADE;
DROP TABLE IF EXISTS asset_categories CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- Create departments table
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    manager_name VARCHAR(100),
    budget_allocation DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INTEGER REFERENCES departments(id),
    position VARCHAR(100),
    hire_date DATE,
    termination_date DATE NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    manager_id INTEGER REFERENCES employees(id),
    location VARCHAR(100),
    cost_center VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create asset categories table
CREATE TABLE asset_categories (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    requires_approval BOOLEAN DEFAULT FALSE,
    max_allocation_per_employee INTEGER DEFAULT 1,
    depreciation_years INTEGER DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create assets table
CREATE TABLE assets (
    id SERIAL PRIMARY KEY,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES asset_categories(id),
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
    specifications TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create asset allocations table
CREATE TABLE asset_allocations (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES assets(id),
    employee_id INTEGER REFERENCES employees(id),
    allocated_date DATE DEFAULT CURRENT_DATE,
    expected_return_date DATE,
    actual_return_date DATE NULL,
    allocation_status VARCHAR(20) DEFAULT 'ALLOCATED',
    allocation_reason VARCHAR(255),
    approved_by VARCHAR(100),
    approval_date DATE,
    return_condition VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create asset maintenance table
CREATE TABLE asset_maintenance (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES assets(id),
    maintenance_type VARCHAR(50) NOT NULL,
    maintenance_date DATE DEFAULT CURRENT_DATE,
    description TEXT,
    cost DECIMAL(10,2),
    performed_by VARCHAR(100),
    next_maintenance_date DATE,
    status VARCHAR(20) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample departments
INSERT INTO departments (name, description, manager_name, budget_allocation) VALUES
('Information Technology', 'IT operations and support', 'John Mitchell', 500000.00),
('Human Resources', 'Employee management and relations', 'Sarah Johnson', 75000.00),
('Engineering', 'Software development and technical operations', 'Michael Chen', 750000.00),
('Marketing', 'Brand promotion and customer engagement', 'Emily Rodriguez', 200000.00),
('Finance', 'Financial planning and accounting', 'David Kim', 100000.00),
('Operations', 'Business operations and logistics', 'Lisa Thompson', 300000.00),
('Security', 'Physical and cybersecurity', 'Robert Garcia', 150000.00);

-- Insert sample employees
INSERT INTO employees (employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, location, cost_center) VALUES
('EMP001', 'John', 'Smith', 'john.smith@company.com', '+1-555-0101', 3, 'Senior Software Engineer', '2024-01-15', 'ACTIVE', 'New York', 'ENG-001'),
('EMP002', 'Maria', 'Garcia', 'maria.garcia@company.com', '+1-555-0201', 4, 'Marketing Manager', '2024-02-01', 'ACTIVE', 'Los Angeles', 'MKT-001'),
('EMP003', 'Robert', 'Wilson', 'robert.wilson@company.com', '+1-555-0301', 2, 'HR Specialist', '2024-01-20', 'ACTIVE', 'Chicago', 'HR-001'),
('EMP004', 'Jennifer', 'Brown', 'jennifer.brown@company.com', '+1-555-0401', 5, 'Financial Analyst', '2024-02-15', 'ACTIVE', 'Boston', 'FIN-001'),
('EMP005', 'Alex', 'Davis', 'alex.davis@company.com', '+1-555-0501', 3, 'Junior Developer', '2024-03-01', 'ACTIVE', 'Seattle', 'ENG-002'),
('EMP006', 'Lisa', 'Thompson', 'lisa.thompson@company.com', '+1-555-0601', 6, 'Operations Manager', '2024-01-10', 'ACTIVE', 'Denver', 'OPS-001'),
('EMP007', 'Mark', 'Anderson', 'mark.anderson@company.com', '+1-555-0701', 1, 'IT Support Specialist', '2024-02-20', 'ACTIVE', 'Austin', 'IT-001'),
('EMP008', 'Rachel', 'Martinez', 'rachel.martinez@company.com', '+1-555-0801', 7, 'Security Officer', '2024-03-05', 'ACTIVE', 'Miami', 'SEC-001');

-- Insert asset categories
INSERT INTO asset_categories (category_name, description, requires_approval, max_allocation_per_employee, depreciation_years) VALUES
('LAPTOP', 'Laptop computers for employees', TRUE, 1, 4),
('DESKTOP', 'Desktop computers for office use', TRUE, 1, 5),
('ID_CARD', 'Employee identification cards', FALSE, 1, 2),
('ACCESS_CARD', 'Building and system access cards', TRUE, 1, 3),
('MOBILE_PHONE', 'Company mobile phones', TRUE, 1, 3),
('TABLET', 'Tablet devices for mobile work', TRUE, 1, 4),
('MONITOR', 'External monitors for workstations', FALSE, 2, 6),
('KEYBOARD', 'Computer keyboards', FALSE, 1, 3),
('MOUSE', 'Computer mice', FALSE, 1, 2),
('HEADSET', 'Audio headsets for communication', FALSE, 1, 2),
('DOCKING_STATION', 'Laptop docking stations', FALSE, 1, 5),
('PARKING_PASS', 'Employee parking passes', FALSE, 1, 1);

-- Insert sample assets
INSERT INTO assets (asset_tag, asset_name, category_id, brand, model, serial_number, purchase_date, purchase_cost, warranty_expiry, status, condition_status, location, vendor, specifications) VALUES
-- Laptops
('LAP-001', 'Dell Latitude 7420', 1, 'Dell', 'Latitude 7420', 'DL7420-001', '2024-01-15', 1299.99, '2027-01-15', 'ALLOCATED', 'NEW', 'New York', 'Dell Technologies', '16GB RAM, 512GB SSD, Intel i7'),
('LAP-002', 'MacBook Pro 14"', 1, 'Apple', 'MacBook Pro', 'MBP14-002', '2024-01-20', 2499.99, '2027-01-20', 'ALLOCATED', 'NEW', 'Los Angeles', 'Apple Inc', '32GB RAM, 1TB SSD, M3 Pro'),
('LAP-003', 'HP EliteBook 850', 1, 'HP', 'EliteBook 850', 'HPE850-003', '2024-02-01', 1199.99, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage', 'HP Inc', '16GB RAM, 256GB SSD, Intel i5'),
('LAP-004', 'Lenovo ThinkPad X1', 1, 'Lenovo', 'ThinkPad X1 Carbon', 'TPX1-004', '2024-02-10', 1599.99, '2027-02-10', 'ALLOCATED', 'NEW', 'Chicago', 'Lenovo', '16GB RAM, 512GB SSD, Intel i7'),
('LAP-005', 'Dell XPS 13', 1, 'Dell', 'XPS 13', 'DXPS13-005', '2024-02-15', 1099.99, '2027-02-15', 'AVAILABLE', 'NEW', 'IT Storage', 'Dell Technologies', '16GB RAM, 512GB SSD, Intel i5'),

-- ID Cards
('ID-001', 'Employee ID Card - EMP001', 3, 'HID Global', 'ProxCard II', 'HID-001', '2024-01-15', 5.99, '2026-01-15', 'ALLOCATED', 'NEW', 'New York', 'HID Global', 'RFID enabled, photo ID'),
('ID-002', 'Employee ID Card - EMP002', 3, 'HID Global', 'ProxCard II', 'HID-002', '2024-02-01', 5.99, '2026-02-01', 'ALLOCATED', 'NEW', 'Los Angeles', 'HID Global', 'RFID enabled, photo ID'),
('ID-003', 'Employee ID Card - EMP003', 3, 'HID Global', 'ProxCard II', 'HID-003', '2024-01-20', 5.99, '2026-01-20', 'ALLOCATED', 'NEW', 'Chicago', 'HID Global', 'RFID enabled, photo ID'),
('ID-004', 'Employee ID Card - EMP004', 3, 'HID Global', 'ProxCard II', 'HID-004', '2024-02-15', 5.99, '2026-02-15', 'ALLOCATED', 'NEW', 'Boston', 'HID Global', 'RFID enabled, photo ID'),
('ID-005', 'Employee ID Card - EMP005', 3, 'HID Global', 'ProxCard II', 'HID-005', '2024-03-01', 5.99, '2026-03-01', 'ALLOCATED', 'NEW', 'Seattle', 'HID Global', 'RFID enabled, photo ID'),

-- Mobile Phones
('PHN-001', 'iPhone 15 Pro', 5, 'Apple', 'iPhone 15 Pro', 'IPH15P-001', '2024-01-10', 999.99, '2025-01-10', 'ALLOCATED', 'NEW', 'New York', 'Apple Inc', '256GB, 5G enabled'),
('PHN-002', 'Samsung Galaxy S24', 5, 'Samsung', 'Galaxy S24', 'SGS24-002', '2024-01-25', 799.99, '2025-01-25', 'AVAILABLE', 'NEW', 'IT Storage', 'Samsung', '256GB, 5G enabled'),
('PHN-003', 'iPhone 15', 5, 'Apple', 'iPhone 15', 'IPH15-003', '2024-02-05', 699.99, '2025-02-05', 'ALLOCATED', 'NEW', 'Los Angeles', 'Apple Inc', '128GB, 5G enabled'),

-- Access Cards
('ACC-001', 'Building Access Card - EMP001', 4, 'HID Global', 'iCLASS SE', 'ICSE-001', '2024-01-15', 12.99, '2027-01-15', 'ALLOCATED', 'NEW', 'New York', 'HID Global', 'Multi-frequency, encrypted'),
('ACC-002', 'Building Access Card - EMP002', 4, 'HID Global', 'iCLASS SE', 'ICSE-002', '2024-02-01', 12.99, '2027-02-01', 'ALLOCATED', 'NEW', 'Los Angeles', 'HID Global', 'Multi-frequency, encrypted'),
('ACC-003', 'Building Access Card - EMP003', 4, 'HID Global', 'iCLASS SE', 'ICSE-003', '2024-01-20', 12.99, '2027-01-20', 'ALLOCATED', 'NEW', 'Chicago', 'HID Global', 'Multi-frequency, encrypted'),

-- Monitors
('MON-001', 'Dell UltraSharp 27"', 7, 'Dell', 'U2723QE', 'DU27-001', '2024-01-15', 399.99, '2027-01-15', 'ALLOCATED', 'NEW', 'New York', 'Dell Technologies', '4K, USB-C, Height adjustable'),
('MON-002', 'LG 32" 4K Monitor', 7, 'LG', '32UN880-B', 'LG32-002', '2024-02-01', 499.99, '2027-02-01', 'AVAILABLE', 'NEW', 'IT Storage', 'LG Electronics', '4K, USB-C, Ergonomic stand'),
('MON-003', 'ASUS ProArt 27"', 7, 'ASUS', 'PA279CV', 'APA27-003', '2024-02-10', 349.99, '2027-02-10', 'ALLOCATED', 'NEW', 'Los Angeles', 'ASUS', '4K, Color accurate, USB-C');

-- Insert sample asset allocations
INSERT INTO asset_allocations (asset_id, employee_id, allocated_date, allocation_status, allocation_reason, approved_by, approval_date, notes) VALUES
(1, 1, '2024-01-15', 'ALLOCATED', 'New employee laptop allocation', 'John Mitchell', '2024-01-14', 'Primary work laptop for senior engineer'),
(2, 2, '2024-02-01', 'ALLOCATED', 'Marketing manager laptop', 'John Mitchell', '2024-01-31', 'High-performance laptop for design work'),
(4, 3, '2024-01-20', 'ALLOCATED', 'HR specialist laptop', 'John Mitchell', '2024-01-19', 'Standard business laptop'),
(6, 1, '2024-01-15', 'ALLOCATED', 'Employee identification', 'Sarah Johnson', '2024-01-15', 'Standard employee ID card'),
(7, 2, '2024-02-01', 'ALLOCATED', 'Employee identification', 'Sarah Johnson', '2024-02-01', 'Standard employee ID card'),
(8, 3, '2024-01-20', 'ALLOCATED', 'Employee identification', 'Sarah Johnson', '2024-01-20', 'Standard employee ID card'),
(9, 4, '2024-02-15', 'ALLOCATED', 'Employee identification', 'Sarah Johnson', '2024-02-15', 'Standard employee ID card'),
(10, 5, '2024-03-01', 'ALLOCATED', 'Employee identification', 'Sarah Johnson', '2024-03-01', 'Standard employee ID card'),
(11, 1, '2024-01-15', 'ALLOCATED', 'Company mobile phone', 'John Mitchell', '2024-01-14', 'Primary business phone'),
(13, 2, '2024-02-01', 'ALLOCATED', 'Company mobile phone', 'John Mitchell', '2024-01-31', 'Marketing team communication'),
(14, 1, '2024-01-15', 'ALLOCATED', 'Building access authorization', 'Robert Garcia', '2024-01-14', 'Full building access'),
(15, 2, '2024-02-01', 'ALLOCATED', 'Building access authorization', 'Robert Garcia', '2024-01-31', 'Standard office access'),
(16, 3, '2024-01-20', 'ALLOCATED', 'Building access authorization', 'Robert Garcia', '2024-01-19', 'HR department access'),
(17, 1, '2024-01-15', 'ALLOCATED', 'External monitor for workstation', 'John Mitchell', '2024-01-14', 'Dual monitor setup'),
(19, 2, '2024-02-10', 'ALLOCATED', 'Design work monitor', 'John Mitchell', '2024-02-09', 'Color-accurate monitor for marketing');

-- Insert sample maintenance records
INSERT INTO asset_maintenance (asset_id, maintenance_type, maintenance_date, description, cost, performed_by, next_maintenance_date, status) VALUES
(1, 'ROUTINE_CHECKUP', '2024-03-15', 'Quarterly health check and software updates', 0.00, 'IT Support', '2024-06-15', 'COMPLETED'),
(2, 'SOFTWARE_UPDATE', '2024-03-01', 'macOS update and security patches', 0.00, 'IT Support', '2024-06-01', 'COMPLETED'),
(6, 'CARD_REACTIVATION', '2024-02-01', 'Reactivated access after system upgrade', 5.00, 'Security Team', '2025-02-01', 'COMPLETED');

-- Create indexes for better performance
CREATE INDEX idx_employees_employee_id ON employees(employee_id);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_assets_tag ON assets(asset_tag);
CREATE INDEX idx_assets_serial ON assets(serial_number);
CREATE INDEX idx_assets_category ON assets(category_id);
CREATE INDEX idx_assets_status ON assets(status);
CREATE INDEX idx_allocations_asset ON asset_allocations(asset_id);
CREATE INDEX idx_allocations_employee ON asset_allocations(employee_id);
CREATE INDEX idx_allocations_status ON asset_allocations(allocation_status);
CREATE INDEX idx_allocations_date ON asset_allocations(allocated_date);
CREATE INDEX idx_maintenance_asset ON asset_maintenance(asset_id);
CREATE INDEX idx_maintenance_date ON asset_maintenance(maintenance_date);

-- Insert completion marker
INSERT INTO departments (name, description) VALUES ('_INIT_COMPLETE_', 'Asset allocation database initialization completed successfully');
