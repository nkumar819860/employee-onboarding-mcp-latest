# HTML YAML Code Block Formatting Fix Guide

## Problem Description

The HTML files in the HTML folder contain YAML code blocks that have formatting issues with JavaScript linting due to keys that should be alphanumeric or quoted. This causes linting errors such as:

- "Key should be alphanumeric or quoted"
- Invalid YAML key formats with special characters
- Unquoted keys containing hyphens, dots, and underscores
- JSON-like formatting issues within YAML blocks

## Solution Overview

The `fix-html-yaml-formatting.bat` script automatically fixes YAML formatting issues in HTML files by:

1. **Creating Backups**: Safely backing up original files before modification
2. **Pattern-Based Fixes**: Using comprehensive regex patterns to identify and fix formatting issues
3. **Key Standardization**: Converting all problematic keys to properly quoted JSON-like format
4. **Validation**: Reporting which files were fixed and what issues were resolved

## Usage Instructions

### Basic Usage
```bash
# Run the formatting fix script
fix-html-yaml-formatting.bat
```

### What the Script Does

1. **Backup Creation**
   - Creates `HTML\backup\` directory if it doesn't exist
   - Backs up each HTML file with `.backup` extension before modification

2. **File Processing**
   - Scans all `.html` files in the HTML folder
   - Processes YAML code blocks within `<div class="code-block">` elements
   - Applies comprehensive formatting fixes

3. **Reporting**
   - Shows progress for each file processed
   - Reports total files processed and fixed
   - Lists specific types of fixes applied

## Types of Fixes Applied

### 1. Key Quoting Issues
**Problem**: Keys with special characters not properly quoted
```yaml
# Before (problematic)
auto-scaling: true
target-cpu: 80
min-replicas: 3
```

**After**: Keys properly quoted
```yaml
# After (fixed)
"auto-scaling": true
"target-cpu": 80
"min-replicas": 3
```

### 2. Dot Notation Keys
**Problem**: Keys with dots causing parsing issues
```yaml
# Before (problematic)
anypoint.platform.config: value
encryption.key: secret
```

**After**: Properly quoted dot notation
```yaml
# After (fixed)
"anypoint.platform.config": value
"encryption.key": secret
```

### 3. Underscore Keys
**Problem**: Keys with underscores not consistently formatted
```yaml
# Before (problematic)
runtime_version: 4.9.0
memory_limit: 2Gi
```

**After**: Consistently quoted underscore keys
```yaml
# After (fixed)
"runtime_version": 4.9.0
"memory_limit": 2Gi
```

### 4. Configuration Blocks
**Problem**: Common configuration keys not properly formatted
```yaml
# Before (problematic)
deploymentSettings:
  autoScaling:
    minReplicas: 1
    maxReplicas: 3
    targetCPUUtilization: 80
```

**After**: All keys properly quoted
```yaml
# After (fixed)
"deploymentSettings":
  "autoScaling":
    "minReplicas": 1
    "maxReplicas": 3
    "targetCPUUtilization": 80
```

## Specific Patterns Fixed

### Common Configuration Keys
The script automatically fixes these commonly used configuration keys:

- **Runtime Configuration**: `runtimeVersion`, `deploymentSettings`
- **Scaling Configuration**: `autoScaling`, `minReplicas`, `maxReplicas`
- **Resource Configuration**: `cpu`, `memory`, `reserved`, `limit`
- **Network Configuration**: `inbound`, `outbound`, `http`, `https`, `port`, `protocol`
- **Platform Configuration**: `assignedCores`, `assignedMemory`, `maxCount`
- **Monitoring Configuration**: `targetCPUUtilization`, `targetMemoryUtilization`
- **Environment Configuration**: `properties`, `environments`, `roles`, `entitlements`

### Regular Expression Patterns Used

1. **Hyphenated Keys**: `([a-zA-Z][a-zA-Z0-9_]*-[a-zA-Z0-9_-]*)`
2. **Dotted Keys**: `([a-zA-Z][a-zA-Z0-9_]*\.[a-zA-Z0-9_.-]*)`
3. **Underscore Keys**: `([a-zA-Z][a-zA-Z0-9_]*_[a-zA-Z0-9_]*)`
4. **Nested Objects**: `(\w+-\w+):\s*{`
5. **Array Syntax**: `(\w+):\s*\[([^\]]*)\]`

## File Structure After Running

```
HTML/
├── backup/                          # Auto-created backup directory
│   ├── 01-Overview.html.backup     # Backup of original files
│   ├── 05-Anypoint-Platform.html.backup
│   └── ... (all HTML files backed up)
├── 01-Overview.html                 # Fixed HTML files
├── 05-Anypoint-Platform.html
└── ... (all other HTML files)
```

## Example Output

```
======================================================================
  HTML YAML Code Block Formatting Fix Tool
======================================================================

[INFO] Scanning HTML files in HTML folder for YAML formatting issues...

[PROCESSING] HTML\01-Overview.html
  [OK] No issues found

[PROCESSING] HTML\05-Anypoint-Platform.html
  [SUCCESS] YAML formatting fixed

[PROCESSING] HTML\06-Auto-scaling.html
  [SUCCESS] YAML formatting fixed

======================================================================
  YAML Formatting Fix Summary
======================================================================

Files Processed: 15
Files Fixed: 8

[INFO] Backups created in HTML\backup\ directory

[SUCCESS] Fixed YAML formatting issues in 8 HTML files

Fixed Issues Include:
  - Quoted keys with hyphens, dots, and underscores
  - Proper JSON-like formatting for YAML blocks
  - Fixed nested object and array syntax
  - Corrected configuration key formatting
  - Standardized boolean and numeric value formatting

[INFO] You can now run JavaScript linting without YAML key formatting errors
```

## Benefits

### ✅ JavaScript Linting Compatibility
- **No More Linting Errors**: Eliminates "Key should be alphanumeric or quoted" errors
- **Consistent Formatting**: All YAML keys follow consistent JSON-like quoting standards
- **Better IDE Support**: IDEs can now properly parse and highlight YAML blocks

### ✅ Safe Processing
- **Automatic Backups**: Original files are safely backed up before any changes
- **Selective Processing**: Only modifies files that actually have formatting issues
- **Comprehensive Reporting**: Clear feedback on what was processed and fixed

### ✅ Comprehensive Coverage
- **Multiple Pattern Types**: Handles hyphens, dots, underscores, and special configuration keys
- **Nested Structure Support**: Properly handles nested YAML objects and arrays
- **Configuration-Aware**: Recognizes common deployment and configuration patterns

## Troubleshooting

### If Files Aren't Being Fixed
1. **Check File Location**: Ensure HTML files are in the `HTML/` folder
2. **Verify Code Blocks**: Script looks for `<div class="code-block">` elements
3. **Check Permissions**: Ensure script has write permissions to HTML folder

### If Formatting Looks Wrong
1. **Restore from Backup**: Use files in `HTML\backup\` directory
2. **Manual Review**: Check specific YAML patterns that might need custom handling
3. **Re-run Script**: Script is safe to run multiple times

### Common Issues
- **PowerShell Execution Policy**: May need to allow script execution
- **File Encoding**: Script handles UTF-8 encoding automatically
- **Large Files**: Script processes files in memory, very large files may need special handling

## Integration with Development Workflow

1. **Before Linting**: Run `fix-html-yaml-formatting.bat` to fix YAML formatting
2. **JavaScript Linting**: Run your standard JS/CSS linting tools without YAML key errors
3. **Version Control**: Consider running the fix script before committing changes
4. **CI/CD Pipeline**: Can be integrated into build processes to ensure consistent formatting

This comprehensive solution ensures that all HTML files with YAML code blocks are properly formatted for JavaScript linting tools while maintaining the readability and functionality of the configuration examples.
