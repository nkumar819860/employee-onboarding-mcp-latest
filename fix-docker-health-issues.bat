@echo off
echo ========================================
echo   Docker Health Issues Fix Script
echo ========================================
echo.

echo [Step 1] Stopping all containers...
cd employee-onboarding-agent-fabric
docker-compose down
echo.

echo [Step 2] Fixing H2 database initialization script encoding...
echo Recreating init-h2.sql with proper encoding...

REM Create a clean H2 init script
(
echo -- Employee Onboarding MCP Server Database Initialization for H2
echo -- H2-Compatible SQL with correct syntax
echo.
echo -- Drop tables if they exist ^(for clean restart^)
echo DROP TABLE IF EXISTS employee_documents CASCADE;
echo DROP TABLE IF EXISTS employees CASCADE;
echo DROP TABLE IF EXISTS departments CASCADE;
echo.
echo -- Create departments table ^(H2 compatible^)
echo CREATE TABLE departments ^(
echo     id INT AUTO_INCREMENT PRIMARY KEY,
echo     name VARCHAR^(100^) NOT NULL,
echo     description VARCHAR^(255^),
echo     manager_name VARCHAR^(100^),
echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
echo     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
echo ^);
echo.
echo -- Create employees table ^(H2 compatible^)
echo CREATE TABLE employees ^(
echo     id INT AUTO_INCREMENT PRIMARY KEY,
echo     employee_id VARCHAR^(20^) UNIQUE NOT NULL,
echo     first_name VARCHAR^(50^) NOT NULL,
echo     last_name VARCHAR^(50^) NOT NULL,
echo     email VARCHAR^(100^) UNIQUE NOT NULL,
echo     phone VARCHAR^(20^),
echo     department_id INT,
echo     position VARCHAR^(100^),
echo     hire_date DATE,
echo     status VARCHAR^(20^) DEFAULT 'PENDING',
echo     salary DECIMAL^(10,2^),
echo     manager_id INT,
echo     address VARCHAR^(500^),
echo     emergency_contact_name VARCHAR^(100^),
echo     emergency_contact_phone VARCHAR^(20^),
echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
echo     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
echo ^);
echo.
echo -- Create employee_documents table ^(H2 compatible^)
echo CREATE TABLE employee_documents ^(
echo     id INT AUTO_INCREMENT PRIMARY KEY,
echo     employee_id INT,
echo     document_type VARCHAR^(50^) NOT NULL,
echo     document_name VARCHAR^(100^) NOT NULL,
echo     document_path VARCHAR^(255^),
echo     document_status VARCHAR^(20^) DEFAULT 'PENDING',
echo     uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
echo     verified_at TIMESTAMP NULL,
echo     verified_by VARCHAR^(100^)
echo ^);
echo.
echo -- Add foreign key constraints after tables are created
echo ALTER TABLE employees ADD CONSTRAINT fk_emp_dept FOREIGN KEY ^(department_id^) REFERENCES departments^(id^);
echo ALTER TABLE employees ADD CONSTRAINT fk_emp_mgr FOREIGN KEY ^(manager_id^) REFERENCES employees^(id^);
echo ALTER TABLE employee_documents ADD CONSTRAINT fk_doc_emp FOREIGN KEY ^(employee_id^) REFERENCES employees^(id^);
echo.
echo -- Insert sample departments
echo INSERT INTO departments ^(name, description, manager_name^) VALUES
echo ^('Human Resources', 'Employee management and relations', 'Sarah Johnson'^),
echo ^('Engineering', 'Software development and technical operations', 'Michael Chen'^),
echo ^('Marketing', 'Brand promotion and customer engagement', 'Emily Rodriguez'^),
echo ^('Finance', 'Financial planning and accounting', 'David Kim'^),
echo ^('Operations', 'Business operations and logistics', 'Lisa Thompson'^);
echo.
echo -- Insert sample employees
echo INSERT INTO employees ^(employee_id, first_name, last_name, email, phone, department_id, position, hire_date, status, salary, address, emergency_contact_name, emergency_contact_phone^) VALUES
echo ^('EMP001', 'John', 'Smith', 'john.smith@company.com', '+1-555-0101', 2, 'Senior Software Engineer', '2024-01-15', 'ACTIVE', 85000.00, '123 Main St, City, State 12345', 'Jane Smith', '+1-555-0102'^),
echo ^('EMP002', 'Maria', 'Garcia', 'maria.garcia@company.com', '+1-555-0201', 3, 'Marketing Manager', '2024-02-01', 'ACTIVE', 75000.00, '456 Oak Ave, City, State 12346', 'Carlos Garcia', '+1-555-0202'^),
echo ^('EMP003', 'Robert', 'Wilson', 'robert.wilson@company.com', '+1-555-0301', 1, 'HR Specialist', '2024-01-20', 'ACTIVE', 60000.00, '789 Pine Rd, City, State 12347', 'Nancy Wilson', '+1-555-0302'^),
echo ^('EMP004', 'Jennifer', 'Brown', 'jennifer.brown@company.com', '+1-555-0401', 4, 'Financial Analyst', '2024-02-15', 'PENDING', 65000.00, '321 Elm St, City, State 12348', 'Tom Brown', '+1-555-0402'^),
echo ^('EMP005', 'Alex', 'Davis', 'alex.davis@company.com', '+1-555-0501', 2, 'Junior Developer', '2024-03-01', 'PENDING', 55000.00, '654 Maple Dr, City, State 12349', 'Sam Davis', '+1-555-0502'^);
echo.
echo -- Insert sample employee documents
echo INSERT INTO employee_documents ^(employee_id, document_type, document_name, document_status^) VALUES
echo ^(1, 'ID_PROOF', 'drivers_license.pdf', 'VERIFIED'^),
echo ^(1, 'ADDRESS_PROOF', 'utility_bill.pdf', 'VERIFIED'^),
echo ^(1, 'EDUCATION', 'degree_certificate.pdf', 'VERIFIED'^),
echo ^(2, 'ID_PROOF', 'passport.pdf', 'VERIFIED'^),
echo ^(2, 'ADDRESS_PROOF', 'lease_agreement.pdf', 'PENDING'^),
echo ^(3, 'ID_PROOF', 'drivers_license.pdf', 'VERIFIED'^),
echo ^(3, 'EDUCATION', 'hr_certification.pdf', 'VERIFIED'^),
echo ^(4, 'ID_PROOF', 'state_id.pdf', 'PENDING'^),
echo ^(4, 'EDUCATION', 'mba_certificate.pdf', 'PENDING'^),
echo ^(5, 'ID_PROOF', 'drivers_license.pdf', 'PENDING'^);
echo.
echo -- Create indexes for better performance
echo CREATE INDEX idx_employees_employee_id ON employees^(employee_id^);
echo CREATE INDEX idx_employees_email ON employees^(email^);
echo CREATE INDEX idx_employees_department ON employees^(department_id^);
echo CREATE INDEX idx_employees_status ON employees^(status^);
echo CREATE INDEX idx_employee_documents_employee_id ON employee_documents^(employee_id^);
echo CREATE INDEX idx_employee_documents_type ON employee_documents^(document_type^);
echo CREATE INDEX idx_employee_documents_status ON employee_documents^(document_status^);
) > mcp-servers\employee-onboarding-mcp-server\src\main\resources\init-h2.sql

echo H2 script recreated successfully!
echo.

echo [Step 3] Clean up Docker images and containers...
docker system prune -f
echo.

echo [Step 4] Rebuild and start services in correct order...
echo Starting database first...
docker-compose up -d employee-onboarding-postgres

echo Waiting for database to be ready...
timeout /t 10 >nul

echo Starting MCP servers...
docker-compose up -d employee-onboarding-agent-broker employee-onboarding-mcp-server assets-allocation-mcp-server email-notification-mcp-server

echo Waiting for MCP servers to start...
timeout /t 15 >nul

echo Starting React client...
docker-compose up -d employee-onboarding-client

echo.
echo [Step 5] Waiting for services to fully start...
timeout /t 20 >nul

echo.
echo [Step 6] Checking container status...
docker ps

echo.
echo [Step 7] Testing health endpoints...
echo Testing localhost:8081/api/health...
curl -f http://localhost:8081/api/health 2>nul || echo "Health endpoint not ready yet"

echo.
echo ========================================
echo   Fix script completed!
echo ========================================
echo.
echo Please wait a few more minutes for all services to fully initialize.
echo Then test: http://localhost:8081/api/health
echo.
pause
