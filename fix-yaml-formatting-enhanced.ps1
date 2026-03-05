# Enhanced HTML YAML Code Block Formatting Fix Tool - PowerShell Version
Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  Enhanced HTML YAML Code Block Formatting Fix Tool" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "[INFO] Scanning HTML files in HTML folder for YAML formatting issues and navigation headers..." -ForegroundColor Yellow
Write-Host ""

# Create backup directory
$backupDir = "HTML\backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Counters
$filesProcessed = 0
$filesFixed = 0

# Read the navigation header from index.html
$indexPath = "HTML\index.html"
$navbarHtml = ""
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw -Encoding UTF8
    # Extract the navbar section
    if ($indexContent -match '(?s)<!-- Navigation -->.*?</nav>') {
        $navbarHtml = $matches[0]
        Write-Host "[INFO] Extracted navigation header from index.html" -ForegroundColor Cyan
    }
}

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
        
        # Fix navigation header for 03-Flex-Gateway-Policies.html
        if ($file.Name -eq "03-Flex-Gateway-Policies.html" -and $navbarHtml -ne "") {
            # Check if proper navbar exists
            if ($content -notmatch '(?s)<nav class="navbar">.*?</nav>') {
                Write-Host "  Adding missing navigation header..." -ForegroundColor Gray
                # Replace the existing navigation with the proper navbar
                $content = $content -replace '(?s)<nav class="navigation">.*?</nav>', $navbarHtml
                $modified = $true
            }
        }
        
        # Check if file contains code blocks
        if ($content -match '(?s)<div class="yaml-block">.*?</div>' -or $content -match '(?s)class="yaml-block"') {
            Write-Host "  Found YAML code blocks, applying enhanced fixes..." -ForegroundColor Gray
            
            # Enhanced YAML key fixing patterns
            $yamlKeys = @(
                # Basic patterns
                'allowedOrigins', 'allowedMethods', 'allowedHeaders', 'exposedHeaders', 'allowCredentials',
                'maxAge', 'optionsPassthrough', 'allowedIPs', 'deniedIPs', 'blockedIPs', 'headerName', 
                'trustProxy', 'requireTLS', 'minVersion', 'cipherSuites', 'redirectToHTTPS',
                'inboundHeaders', 'outboundHeaders', 'removeHeaders', 'overwrite',
                
                # JWT and OAuth keys
                'jwtKeyOrigin', 'jwksUrl', 'jwksServiceTimeToLive', 'audience', 'issuer', 'validateAudience',
                'validateIssuer', 'validateExp', 'validateNbf', 'clockSkew', 'mandatoryClaims',
                'customValidations', 'errorMessage', 'introspectionUrl', 'clientId', 'clientSecret',
                'requiredScopes', 'scopeValidationCriteria', 'cacheConfiguration', 'customHeaders',
                
                # Rate limiting keys
                'rateLimits', 'maximumRequests', 'timePeriod', 'timePeriodTimeUnit', 'identifier',
                'keyResolver', 'quotas', 'algorithm', 'distributeQuota', 'exposeHeaders', 
                'headersConfiguration', 'queuingRequestTimeout', 'delayTimeInMillis', 'delayAttempts',
                'keySelector',
                
                # Circuit breaker and load balancing
                'onErrorContinue', 'failureThreshold', 'successThreshold', 'timeout', 'delay',
                'tripOnTimeouts', 'tripOnConnectFailure', 'trip5xx', 'trip4xx', 'customErrorStatuses',
                'fallbackResponse', 'statusCode', 'body', 'headers', 'healthCheck', 'enabled',
                'interval', 'path', 'expectedStatus', 'unhealthyThreshold', 'healthyThreshold',
                'stickySession', 'cookieName', 'cookiePath', 'cookieSecure',
                
                # Transformation and protection
                'maxArrayElementCount', 'maxContainerDepth', 'maxObjectEntryCount', 'maxObjectEntryNameLength',
                'maxStringValueLength', 'maxDocumentLength', 'allowComments', 'allowDuplicateKeys',
                'strictValidation', 'errorResponse', 'requestTransformation', 'responseTransformation',
                'expression', 'errorHandling', 'logErrors', 'continueOnError',
                
                # Monitoring and analytics
                'enableAnalytics', 'collectRequestData', 'collectResponseData', 'collectHeaders',
                'excludeHeaders', 'customDimensions', 'businessEvents', 'eventName', 'condition',
                'healthCheckPath', 'detailedHealth', 'includeUpstreamHealth', 'customHealthChecks',
                'responseFormat', 'serviceName', 'serviceVersion', 'exporterEndpoint', 'exporterType',
                'samplingRate', 'resourceAttributes', 'spanAttributes', 'propagationFormats',
                'metricsPath', 'defaultMetrics', 'customMetrics',
                
                # Compliance keys
                'dataSubjectRights', 'rightToAccess', 'rightToRectification', 'rightToErasure',
                'rightToPortability', 'consentManagement', 'required', 'consentHeader',
                'validConsentValues', 'dataMinimization', 'allowedFields', 'restrictedFields',
                'auditLogging', 'logDataAccess', 'logDataModification', 'logConsentChanges',
                'retentionPeriod', 'encryption', 'inTransit', 'atRest', 'keyRotation',
                'accessControls', 'minimumAuthentication', 'sessionTimeout', 'automaticLogoff',
                'roleBasedAccess', 'auditControls', 'logAllAccess', 'logFailedAttempts',
                'alertOnSuspiciousActivity', 'dataIntegrity', 'checksumValidation', 'digitallySigned',
                'immutableLogs', 'businessAssociate', 'requireBAA', 'validateBAACertificate',
                'emergencyAccess', 'breakGlassAccess', 'emergencyLogLevel'
            )
            
            # Apply fixes for each YAML key
            foreach ($key in $yamlKeys) {
                $pattern = "(?m)^(\s+)($key):(?!\s*[`"''])"
                $replacement = '$1"$2":'
                if ($content -match $pattern) {
                    $content = $content -replace $pattern, $replacement
                    $modified = $true
                }
            }
            
            # Fix keys with hyphens, dots, and underscores that aren't already quoted
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*-[a-zA-Z0-9_-]*):(?!\s*["''])', '$1"$2":'
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*\.[a-zA-Z0-9_.-]*):(?!\s*["''])', '$1"$2":'
            $content = $content -replace '(?m)^(\s+)([a-zA-Z][a-zA-Z0-9_]*_[a-zA-Z0-9_]*):(?!\s*["''])', '$1"$2":'
            
            # Check if content was modified by YAML fixes
            if ($content -ne $originalContent) {
                $modified = $true
            }
        }
        
        if ($modified) {
            # Write modified content back to file
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            if ($file.Name -eq "03-Flex-Gateway-Policies.html") {
                Write-Host "  [SUCCESS] Added navigation header and fixed YAML formatting" -ForegroundColor Green
            } else {
                Write-Host "  [SUCCESS] YAML formatting issues corrected" -ForegroundColor Green
            }
            $filesFixed++
        } else {
            Write-Host "  [OK] No issues found" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "  [ERROR] Failed to process file: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "  Enhanced YAML Formatting Fix Summary" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files Processed: $filesProcessed" -ForegroundColor White
Write-Host "Files Fixed: $filesFixed" -ForegroundColor White
Write-Host ""
Write-Host "[INFO] Backups created in HTML\backup\ directory" -ForegroundColor Yellow
Write-Host ""

if ($filesFixed -gt 0) {
    Write-Host "[SUCCESS] Fixed issues in $filesFixed HTML files" -ForegroundColor Green
    Write-Host ""
    Write-Host "Fixed Issues Include:" -ForegroundColor White
    Write-Host "  - Added missing navigation header to 03-Flex-Gateway-Policies.html" -ForegroundColor Gray
    Write-Host "  - Quoted YAML keys with special characters" -ForegroundColor Gray
    Write-Host "  - Fixed configuration key formatting" -ForegroundColor Gray
    Write-Host "  - Enhanced YAML lint compatibility" -ForegroundColor Gray
} else {
    Write-Host "[INFO] No issues found in HTML files" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[INFO] All YAML lint issues should now be resolved" -ForegroundColor Green
Write-Host ""

# Pause equivalent for PowerShell
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
