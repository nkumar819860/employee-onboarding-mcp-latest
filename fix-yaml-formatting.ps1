# HTML YAML Code Block Formatting Fix Tool - PowerShell Version
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  HTML YAML Code Block Formatting Fix Tool" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "[INFO] Scanning HTML files in HTML folder for YAML formatting issues..." -ForegroundColor Yellow
Write-Host ""

# Create backup directory
$backupDir = "HTML\backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Counters
$filesProcessed = 0
$filesFixed = 0

# Get all HTML files
$htmlFiles = Get-ChildItem -Path "HTML\*.html" -File

foreach ($file in $htmlFiles) {
    Write-Host "[PROCESSING] $($file.FullName)" -ForegroundColor Cyan
    $filesProcessed++
    
    try {
        # Create backup
        $backupPath = Join-Path $backupDir "$($file.Name).backup"
        Copy-Item $file.FullName $backupPath -Force
        
        # Read file content
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        $modified = $false
        
        # Check if file contains code blocks
        if ($content -match '(?s)<div class="code-block">.*?</div>') {
            Write-Host "  Found code blocks, applying YAML fixes..." -ForegroundColor Gray
            
            # Fix keys with hyphens that aren't quoted
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*-[a-zA-Z0-9_-]*):(?!\s*["''])', '$1"$2":'
            
            # Fix keys with dots that aren't quoted  
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*\.[a-zA-Z0-9_.-]*):(?!\s*["''])', '$1"$2":'
            
            # Fix keys with underscores that aren't quoted
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*_[a-zA-Z0-9_]*):(?!\s*["''])', '$1"$2":'
            
            # Fix specific configuration keys commonly found in deployment YAML
            $configKeys = @(
                'runtimeVersion', 'autoScaling', 'deploymentSettings', 'assignedCores', 'assignedMemory', 'maxCount',
                'minReplicas', 'maxReplicas', 'targetCPUUtilization', 'targetMemoryUtilization',
                'cpu', 'memory', 'reserved', 'limit',
                'inbound', 'outbound', 'http', 'https', 'port', 'protocol',
                'properties', 'environments', 'roles', 'entitlements',
                'businessEvents', 'customMetrics', 'loggingLevel',
                'enabled', 'clustered', 'publicUrl',
                'name', 'type', 'status', 'condition', 'actions'
            )
            
            foreach ($key in $configKeys) {
                $pattern = "(?m)^(\s+)($key):(?!\s*[`"''])"
                $replacement = '$1"$2":'
                $content = $content -replace $pattern, $replacement
            }
            
            # Check if content was modified
            if ($content -ne $originalContent) {
                $modified = $true
            }
        }
        
        if ($modified) {
            # Write modified content back to file
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Host "  [SUCCESS] YAML formatting issues corrected" -ForegroundColor Green
            $filesFixed++
        } else {
            Write-Host "  [OK] No YAML formatting issues found" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "  [ERROR] Failed to process file: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  YAML Formatting Fix Summary" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files Processed: $filesProcessed" -ForegroundColor White
Write-Host "Files Fixed: $filesFixed" -ForegroundColor White
Write-Host ""
Write-Host "[INFO] Backups created in HTML\backup\ directory" -ForegroundColor Yellow
Write-Host ""

if ($filesFixed -gt 0) {
    Write-Host "[SUCCESS] Fixed YAML formatting issues in $filesFixed HTML files" -ForegroundColor Green
    Write-Host ""
    Write-Host "Fixed Issues Include:" -ForegroundColor White
    Write-Host "  - Quoted keys with hyphens, dots, and underscores" -ForegroundColor Gray
    Write-Host "  - Proper JSON-like formatting for YAML blocks" -ForegroundColor Gray
    Write-Host "  - Fixed configuration key formatting" -ForegroundColor Gray
    Write-Host "  - Standardized deployment configuration formatting" -ForegroundColor Gray
} else {
    Write-Host "[INFO] No YAML formatting issues found in HTML files" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[INFO] You can now run JavaScript linting without YAML key formatting errors" -ForegroundColor Green
Write-Host ""

# Pause equivalent for PowerShell
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
