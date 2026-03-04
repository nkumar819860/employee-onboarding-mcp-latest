# Asset Allocation MCP Server - Script-Based Database Initialization Guide

## Overview

The Asset Allocation MCP Server has been updated to use a **script-based approach** for database initialization instead of the traditional DDL approach. This provides better control, more detailed data population, and improved maintainability.

## What Changed

### Previous Approach (DDL-based)
- Used `init-h2.sql` with basic DDL statements
- Simple table creation with minimal data
- Basic referential integrity
- Limited sample data

### New Approach (Script-based)
- Uses `init-script.sql` with comprehensive initialization logic
- Advanced table creation with sequences and constraints
- Rich sample data with detailed specifications
- Proper referential integrity management
- Performance indexes
- Data validation and verification

## Implementation Details

### 1. Script File: `init-script.sql`

The new initialization script includes:

#### Database Setup
```sql
-- Enable H2 features
SET MODE REGULAR;
SET REFERENTIAL_INTEGRITY FALSE;

-- Clean existing data
DELETE FROM asset_allocations WHERE id IS NOT NULL;
DELETE FROM assets WHERE id IS NOT NULL;  
-- ... other tables

-- Create sequences for auto-incrementing IDs
CREATE SEQUENCE IF NOT EXISTS dept_seq START WITH 1 INCREMENT BY 1;
-- ... other sequences
```

#### Table Creation with Enhanced Features
```sql
CREATE TABLE IF NOT EXISTS assets (
    id INT DEFAULT NEXT VALUE FOR asset_seq PRIMARY KEY,
    asset_tag VARCHAR(50) NOT NULL UNIQUE,
    asset_name VARCHAR(100) NOT NULL,
    -- ... other fields with proper constraints
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'ALLOCATED', 'MAINTENANCE', 'RETIRED')),
    condition_status VARCHAR(20) DEFAULT 'NEW' CHECK (condition_status IN ('NEW', 'GOOD', 'FAIR', 'POOR', 'DAMAGED')),
    specifications VARCHAR(2000),
    -- ... timestamps and audit fields
);
```

#### Rich Sample Data
- **5 Departments**: IT, HR, Engineering, Marketing, Sales
- **5 Employees**: With proper department assignments
- **8 Asset Categories**: LAPTOP, ID_CARD, MOBILE_PHONE, MONITOR, HEADSET, KEYBOARD, MOUSE, WEBCAM
- **11 Assets**: With detailed specifications in JSON format
- **2 Initial Allocations**: Demonstrating the allocation process

#### Performance Optimization
```sql
-- Create performance indexes
CREATE INDEX IF NOT EXISTS idx_employees_employee_id ON employees(employee_id);
CREATE INDEX IF NOT EXISTS idx_assets_tag ON assets(asset_tag);
CREATE INDEX IF NOT EXISTS idx_asset_allocations_status ON asset_allocations(allocation_status);
-- ... other indexes
```

### 2. Mule Configuration Update

Updated the `create-h2-tables` flow in `assets-allocation-mcp-server.xml`:

```xml
<flow name="create-h2-tables" doc:name="Create H2 Tables via Script">
    <logger level="INFO" message="Initializing H2 database using script-based approach..."/>
    
    <try doc:name="Execute H2 Initialization Script">
        <db:execute-script config-ref="H2_Database_Config" file="init-script.sql" />
        <logger level="INFO" message="✅ H2 database initialization script executed successfully"/>
        
        <!-- Verify script execution with summary query -->
        <db:select config-ref="H2_Database_Config" doc:name="Verify Script Execution">
            <db:sql><![CDATA[
                SELECT 
                    'Script Execution Summary' as status,
                    (SELECT COUNT(*) FROM departments WHERE name != '_SCRIPT_INIT_COMPLETE_') as departments_count,
                    (SELECT COUNT(*) FROM employees) as employees_count,  
                    -- ... other counts
                    CURRENT_TIMESTAMP as verified_at
            ]]></db:sql>
        </db:select>
        
        <logger level="INFO" message="📊 Database initialization summary: #[payload[0]]"/>
    </try>
</flow>
```

## Key Benefits

### 1. **Enhanced Data Quality**
- Detailed asset specifications in JSON format
- Proper employee-department relationships
- Realistic sample data for testing

### 2. **Better Performance**
- Pre-created indexes for common queries
- Optimized table structures
- Sequence-based ID generation

### 3. **Improved Maintainability**
- Single script file for all initialization
- Clear separation of concerns
- Easy to modify and extend

### 4. **Production Readiness**
- Proper constraint validation
- Referential integrity management
- Audit trail capabilities

### 5. **Testing Support**
- Rich sample data for comprehensive testing
- Completion markers for verification
- Detailed logging and monitoring

## Testing the Implementation

### 1. Run the Test Script
```bash
cd employee-onboarding-agent-fabric/mcp-servers/assets-allocation-mcp-server
./test-script-based-initialization.bat
```

### 2. Expected Results
- Health check returns `HEALTHY` status
- Asset allocation uses H2 with script-based initialization
- Assets list shows 8 categories with detailed specifications
- Database shows completion marker: `_SCRIPT_INIT_COMPLETE_`
- Allocated assets include JSON specifications

### 3. Verification Points
- Check logs for script execution confirmation
- Verify asset data includes detailed specifications
- Confirm proper category relationships
- Test asset allocation and return functionality

## Sample Data Structure

### Assets with Specifications
```json
{
  "processor": "Intel i7-1185G7",
  "memory": "16GB DDR4", 
  "storage": "512GB NVMe SSD",
  "display": "14 FHD",
  "os": "Windows 11 Pro"
}
```

### Employee-Department Relationships
- EMP001 (John Smith) → IT Department → IT Manager
- EMP002 (Sarah Johnson) → Engineering → Senior Developer
- EMP003 (Mike Davis) → Marketing → Marketing Specialist
- EMP004 (Lisa Wilson) → HR → HR Coordinator
- EMP005 (David Brown) → Sales → Sales Representative

### Asset Categories
1. **LAPTOP** - Corporate Laptops (max 2 per employee)
2. **ID_CARD** - Employee ID Cards (requires approval)
3. **MOBILE_PHONE** - Corporate Phones (requires approval)  
4. **MONITOR** - External Displays (max 2 per employee)
5. **HEADSET** - Communication Devices
6. **KEYBOARD** - Computer Keyboards
7. **MOUSE** - Pointing Devices
8. **WEBCAM** - Video Conference Equipment

## Migration Notes

### From DDL to Script-Based Approach

1. **Backup Existing Data**: The script cleans existing tables
2. **Update References**: Any external references to `init-h2.sql` should point to `init-script.sql`
3. **Test Thoroughly**: Verify all MCP operations work with new data structure
4. **Monitor Performance**: Check that indexes improve query performance

### Rollback Plan

If needed to rollback:
1. Restore the original `create-h2-tables` flow
2. Replace `init-script.sql` reference with `init-h2.sql`
3. Restart the MCP server

## Troubleshooting

### Common Issues

1. **Script Execution Fails**
   - Check H2 database connectivity
   - Verify script syntax
   - Review constraint violations in logs

2. **Missing Data**
   - Confirm completion marker exists
   - Check referential integrity settings
   - Verify sequence initialization

3. **Performance Issues**
   - Ensure indexes are created
   - Monitor query execution plans
   - Check for constraint violations

### Debug Commands

```sql
-- Check initialization status
SELECT name FROM departments WHERE name = '_SCRIPT_INIT_COMPLETE_';

-- Verify data counts
SELECT 
    (SELECT COUNT(*) FROM assets) as asset_count,
    (SELECT COUNT(*) FROM employees) as employee_count,
    (SELECT COUNT(*) FROM asset_categories) as category_count;

-- Check asset specifications
SELECT asset_tag, asset_name, specifications FROM assets WHERE specifications IS NOT NULL;
```

## Future Enhancements

### Planned Improvements
1. **Dynamic Configuration**: Environment-specific data loading
2. **Data Validation**: Enhanced constraint checking
3. **Migration Scripts**: Version-based database updates
4. **Performance Tuning**: Additional indexes based on usage patterns

### Extension Points
- Add more asset categories
- Include cost center management
- Implement approval workflows
- Add asset lifecycle tracking

## Conclusion

The script-based initialization approach provides a robust, maintainable, and feature-rich database setup for the Asset Allocation MCP Server. It supports comprehensive testing, production deployment, and future enhancements while maintaining backward compatibility with the existing MCP API.
