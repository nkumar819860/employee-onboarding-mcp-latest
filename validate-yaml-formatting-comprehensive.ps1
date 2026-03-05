# Comprehensive YAML Formatting Validation Script
# Validates all HTML files for YAML lint issues and provides detailed reporting

param(
    [string]$Directory = "HTML",
    [switch]$Fix = $false,
    [switch]$DetailedReport = $true
)

Write-Host "🔍 Comprehensive YAML Formatting Validation" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

$totalFiles = 0
$filesWithIssues = 0
$totalIssuesFound = 0
$totalIssuesFixed = 0
$validationResults = @()

# Define patterns to check
$yamlPatterns = @{
    "CSS_QUOTED_PROPERTIES" = @{
        Pattern = "`"([a-z-]+)`"\s*:"
        Description = "CSS properties incorrectly quoted"
        Fix = { param($match) $match -replace "`"([a-z-]+)`"\s*:", '$1:' }
        FileTypes = @("*.html")
        Context = "CSS"
    }
    
    "YAML_UNQUOTED_BOOLEAN_LIKE" = @{
        Pattern = ":\s*(true|false|yes|no|on|off)\s*$"
        Description = "YAML boolean-like values that should be quoted in specific contexts"
        Fix = { param($match) $match -replace ":\s*(true|false|yes|no|on|off)\s*$", ': "`$1"' }
        FileTypes = @("*.html", "*.yaml", "*.yml")
        Context = "YAML"
        Conditional = $true
    }
    
    "YAML_SPECIAL_CHARACTERS" = @{
        Pattern = ":\s*([^`"\s][^:\n]*[{}\[\]@#|>*&!%^``~?])"
        Description = "YAML values with special characters that should be quoted"
        Fix = { param($match) $match -replace ":\s*([^`"\s][^:\n]*[{}\[\]@#|>*&!%^``~?])", ': "`$1"' }
        FileTypes = @("*.html", "*.yaml", "*.yml")
        Context = "YAML"
    }
    
    "YAML_NUMERIC_STRINGS" = @{
        Pattern = ":\s*([0-9]+\.[0-9]+\.[0-9]+)"
        Description = "Version numbers that should be quoted"
        Fix = { param($match) $match -replace ":\s*([0-9]+\.[0-9]+\.[0-9]+)", ': "`$1"' }
        FileTypes = @("*.html", "*.yaml", "*.yml")
        Context = "YAML"
    }
    
    "YAML_TIME_VALUES" = @{
        Pattern = ":\s*([0-9]+[smhd])"
        Description = "Time values that may need quoting"
        Fix = { param($match) $match -replace ":\s*([0-9]+[smhd])", ': "`$1"' }
        FileTypes = @("*.html", "*.yaml", "*.yml")
        Context = "YAML"
    }
}

function Test-YamlFormatting {
    param(
        [string]$FilePath,
        [hashtable]$Patterns
    )
    
    $issues = @()
    $content = Get-Content -Path $FilePath -Raw
    $lines = Get-Content -Path $FilePath
    
    foreach ($patternName in $Patterns.Keys) {
        $pattern = $Patterns[$patternName]
        $regex = [regex]::new($pattern.Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $matches = $regex.Matches($content)
        
        foreach ($match in $matches) {
            # Find line number
            $beforeMatch = $content.Substring(0, $match.Index)
            $lineNumber = ($beforeMatch -split "`n").Count
            
            # Skip if this is in a context we should ignore
            $contextOk = $true
            if ($pattern.Context -eq "CSS" -and $beforeMatch -notmatch '<style>') {
                continue
            }
            if ($pattern.Context -eq "YAML" -and $beforeMatch -notmatch 'yaml-block') {
                continue
            }
            
            # For conditional patterns, add additional logic
            if ($pattern.Conditional -and $patternName -eq "YAML_UNQUOTED_BOOLEAN_LIKE") {
                # Only flag booleans that are clearly in YAML context and not already properly formatted
                $line = $lines[$lineNumber - 1]
                if ($line -match '^\s*[a-zA-Z0-9_-]+\s*:\s*(true|false)\s*$' -and $line -notmatch '"(true|false)"') {
                    # This is a boolean that should be quoted
                } else {
                    continue
                }
            }
            
            $issues += [PSCustomObject]@{
                PatternName = $patternName
                Description = $pattern.Description
                LineNumber = $lineNumber
                Context = if ($lineNumber -gt 0) { $lines[$lineNumber - 1].Trim() } else { "" }
                Match = $match.Value
                CanFix = $Fix -and $pattern.Fix
                FixFunction = $pattern.Fix
            }
        }
    }
    
    return $issues
}

function Fix-YamlFormatting {
    param(
        [string]$FilePath,
        [array]$Issues
    )
    
    $content = Get-Content -Path $FilePath -Raw
    $fixedCount = 0
    
    # Group issues by pattern for more efficient fixing
    $issueGroups = $Issues | Group-Object -Property PatternName
    
    foreach ($group in $issueGroups) {
        $pattern = $yamlPatterns[$group.Name]
        if ($pattern.Fix) {
            $regex = [regex]::new($pattern.Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
            $newContent = $regex.Replace($content, $pattern.Fix)
            if ($newContent -ne $content) {
                $content = $newContent
                $fixedCount += $group.Count
            }
        }
    }
    
    if ($fixedCount -gt 0) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Write-Host "  ✅ Fixed $fixedCount issues in $FilePath" -ForegroundColor Green
    }
    
    return $fixedCount
}

# Get all files to check
$files = @()
foreach ($pattern in $yamlPatterns.Values) {
    foreach ($fileType in $pattern.FileTypes) {
        $files += Get-ChildItem -Path $Directory -Filter $fileType -Recurse
    }
}
$files = $files | Sort-Object -Property FullName -Unique

Write-Host "📁 Checking $($files.Count) files in directory: $Directory" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $files) {
    $totalFiles++
    Write-Host "🔎 Analyzing: $($file.Name)" -ForegroundColor White
    
    $issues = Test-YamlFormatting -FilePath $file.FullName -Patterns $yamlPatterns
    
    if ($issues.Count -gt 0) {
        $filesWithIssues++
        $totalIssuesFound += $issues.Count
        
        Write-Host "  ⚠️  Found $($issues.Count) potential issues:" -ForegroundColor Yellow
        
        foreach ($issue in $issues) {
            Write-Host "    • Line $($issue.LineNumber): $($issue.Description)" -ForegroundColor Red
            if ($DetailedReport) {
                Write-Host "      Context: $($issue.Context)" -ForegroundColor Gray
                Write-Host "      Match: '$($issue.Match)'" -ForegroundColor Gray
            }
        }
        
        if ($Fix) {
            $fixed = Fix-YamlFormatting -FilePath $file.FullName -Issues $issues
            $totalIssuesFixed += $fixed
        }
        
        $validationResults += [PSCustomObject]@{
            File = $file.Name
            Path = $file.FullName
            IssueCount = $issues.Count
            Issues = $issues
            Fixed = if ($Fix) { $fixed } else { 0 }
        }
    } else {
        Write-Host "  ✅ No issues found" -ForegroundColor Green
    }
    
    Write-Host ""
}

# Generate summary report
Write-Host "📊 VALIDATION SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host "Total files checked: $totalFiles" -ForegroundColor White
Write-Host "Files with issues: $filesWithIssues" -ForegroundColor $(if ($filesWithIssues -eq 0) { "Green" } else { "Yellow" })
Write-Host "Total issues found: $totalIssuesFound" -ForegroundColor $(if ($totalIssuesFound -eq 0) { "Green" } else { "Red" })

if ($Fix) {
    Write-Host "Total issues fixed: $totalIssuesFixed" -ForegroundColor Green
    Write-Host "Remaining issues: $($totalIssuesFound - $totalIssuesFixed)" -ForegroundColor $(if (($totalIssuesFound - $totalIssuesFixed) -eq 0) { "Green" } else { "Yellow" })
}

# Issue breakdown by type
if ($totalIssuesFound -gt 0) {
    Write-Host ""
    Write-Host "📈 ISSUE BREAKDOWN BY TYPE:" -ForegroundColor Cyan
    Write-Host "-" * 40 -ForegroundColor Gray
    
    $issuesByType = @{}
    foreach ($result in $validationResults) {
        foreach ($issue in $result.Issues) {
            if (-not $issuesByType.ContainsKey($issue.PatternName)) {
                $issuesByType[$issue.PatternName] = 0
            }
            $issuesByType[$issue.PatternName]++
        }
    }
    
    foreach ($issueType in $issuesByType.Keys | Sort-Object) {
        $count = $issuesByType[$issueType]
        $description = $yamlPatterns[$issueType].Description
        Write-Host "$issueType : $count issues" -ForegroundColor Yellow
        Write-Host "  $description" -ForegroundColor Gray
    }
}

# Generate detailed HTML report if requested
if ($DetailedReport -and $validationResults.Count -gt 0) {
    $reportPath = "yaml-validation-report.html"
    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YAML Formatting Validation Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .summary { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .file-section { border: 1px solid #bdc3c7; margin: 15px 0; border-radius: 5px; }
        .file-header { background: #34495e; color: white; padding: 10px; font-weight: bold; }
        .issue { margin: 10px; padding: 10px; background: #fff5f5; border-left: 4px solid #e74c3c; }
        .issue-type { color: #c0392b; font-weight: bold; }
        .line-number { color: #7f8c8d; }
        .context { background: #f8f9fa; padding: 8px; border-radius: 3px; font-family: monospace; margin: 5px 0; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: #3498db; color: white; padding: 15px; border-radius: 5px; text-align: center; }
        .stat-number { font-size: 2em; font-weight: bold; }
        .fixed { background: #d5f4e6; border-left-color: #27ae60; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 YAML Formatting Validation Report</h1>
        
        <div class="summary">
            <h2>📊 Summary</h2>
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number">$totalFiles</div>
                    <div>Files Checked</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">$filesWithIssues</div>
                    <div>Files with Issues</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">$totalIssuesFound</div>
                    <div>Total Issues</div>
                </div>
"@

    if ($Fix) {
        $htmlContent += @"
                <div class="stat-card" style="background: #27ae60;">
                    <div class="stat-number">$totalIssuesFixed</div>
                    <div>Issues Fixed</div>
                </div>
"@
    }

    $htmlContent += @"
            </div>
        </div>
        
        <h2>📁 File Details</h2>
"@

    foreach ($result in $validationResults) {
        $htmlContent += @"
        <div class="file-section">
            <div class="file-header">
                📄 $($result.File) ($($result.IssueCount) issues)
            </div>
"@
        
        foreach ($issue in $result.Issues) {
            $issueClass = if ($Fix -and $issue.CanFix) { "issue fixed" } else { "issue" }
            $htmlContent += @"
            <div class="$issueClass">
                <div class="issue-type">$($issue.Description)</div>
                <div class="line-number">Line $($issue.LineNumber)</div>
                <div class="context">$($issue.Context -replace '<', '<' -replace '>', '>')</div>
            </div>
"@
        }
        
        $htmlContent += "</div>"
    }

    $htmlContent += @"
    </div>
</body>
</html>
"@

    Set-Content -Path $reportPath -Value $htmlContent -Encoding UTF8
    Write-Host ""
    Write-Host "📋 Detailed HTML report generated: $reportPath" -ForegroundColor Cyan
}

# Final status
Write-Host ""
Write-Host "🎯 FINAL STATUS:" -ForegroundColor Cyan
Write-Host "-" * 20 -ForegroundColor Gray

if ($totalIssuesFound -eq 0) {
    Write-Host "✅ All files pass YAML formatting validation!" -ForegroundColor Green
    exit 0
} elseif ($Fix -and $totalIssuesFixed -eq $totalIssuesFound) {
    Write-Host "✅ All issues have been automatically fixed!" -ForegroundColor Green
    exit 0
} elseif ($Fix) {
    Write-Host "⚠️  $($totalIssuesFound - $totalIssuesFixed) issues remain after auto-fix" -ForegroundColor Yellow
    Write-Host "   Manual review may be required for remaining issues" -ForegroundColor Gray
    exit 1
} else {
    Write-Host "⚠️  $totalIssuesFound issues found across $filesWithIssues files" -ForegroundColor Yellow
    Write-Host "   Run with -Fix switch to attempt automatic fixes" -ForegroundColor Gray
    exit 1
}
