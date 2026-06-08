<#
.SYNOPSIS
    Standardized project verification script to run linters, tests, and security scans.
.DESCRIPTION
    Auto-detects project runtime (Node.js, Python, .NET, Go) and executes local verification quality gates.
#>

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "[i] Starting Code Quality & Verification Pipelines" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$hasErrors = $false

# 1. Secret Scanning
Write-Host "[i] Scanning for hardcoded secrets..." -ForegroundColor Yellow
$secretsDetected = $false
$filesToScan = Get-ChildItem -Recurse -File -Exclude "*.md", "*.png", "*.jpg", "*.gif", "*.pdf", "*.cmd", "*.ps1"
foreach ($file in $filesToScan) {
    $content = Get-Content -Path $file.FullName -Raw
    # Using single quotes for the regex string. Single quotes are escaped by doubling them ('').
    if ($content -match '(?i)(api[_-]?key|client[_-]?secret|password|db[_-]?conn|private[_-]?key)\s*[:=]\s*[''"].+[''"]') {
        Write-Warning "Potential secret found in $($file.FullName)"
        $secretsDetected = $true
    }
}

if ($secretsDetected) {
    Write-Error "Security Audit Failed: Potential hardcoded secrets found!"
    $hasErrors = $true
} else {
    Write-Host "[+] Secret scan passed. No obvious credentials leaked." -ForegroundColor Green
}

# 2. Project Detection and Framework Verification
$projectDetected = $false

# Node.js Project Detection
if (Test-Path "package.json") {
    $projectDetected = $true
    Write-Host "[i] Node.js project detected." -ForegroundColor Cyan
    
    # Run Linting
    if (Get-Content "package.json" | ConvertFrom-Json | Select-Object -ExpandProperty scripts -ErrorAction SilentlyContinue | Select-Object -ExpandProperty lint -ErrorAction SilentlyContinue) {
        Write-Host "[i] Running linter..." -ForegroundColor Yellow
        npm run lint
    } else {
        Write-Host "No lint script found in package.json. Skipping linting." -ForegroundColor Gray
    }
    
    # Run Tests & Coverage
    if (Get-Content "package.json" | ConvertFrom-Json | Select-Object -ExpandProperty scripts -ErrorAction SilentlyContinue | Select-Object -ExpandProperty test -ErrorAction SilentlyContinue) {
        Write-Host "[i] Running tests..." -ForegroundColor Yellow
        npm run test
    } else {
        Write-Host "No test script found in package.json. Skipping testing." -ForegroundColor Gray
    }
}

# Python Project Detection
if ((Test-Path "requirements.txt") -or (Test-Path "pyproject.toml") -or (Test-Path "setup.py")) {
    $projectDetected = $true
    Write-Host "[i] Python project detected." -ForegroundColor Cyan
    
    # Linting check
    if (Get-Command "flake8" -ErrorAction SilentlyContinue) {
        Write-Host "[i] Running flake8..." -ForegroundColor Yellow
        flake8 .
    } elseif (Get-Command "pylint" -ErrorAction SilentlyContinue) {
        Write-Host "[i] Running pylint..." -ForegroundColor Yellow
        pylint .
    } else {
        Write-Host "Linter (flake8/pylint) not installed in global environment. Skipping linting." -ForegroundColor Gray
    }

    # Testing & Coverage check
    if (Get-Command "pytest" -ErrorAction SilentlyContinue) {
        Write-Host "[i] Running pytest..." -ForegroundColor Yellow
        pytest --cov
    } else {
        Write-Host "pytest not installed in environment. Skipping testing." -ForegroundColor Gray
    }
}

# .NET Project Detection
$csproj = Get-ChildItem -Filter "*.csproj" -Recurse
$sln = Get-ChildItem -Filter "*.sln" -Recurse
if ($csproj -or $sln) {
    $projectDetected = $true
    Write-Host "[i] .NET project detected." -ForegroundColor Cyan

    # Lint / Formatting check
    Write-Host "[i] Formatting check..." -ForegroundColor Yellow
    dotnet format --verify-no-changes

    # Test Run
    Write-Host "[i] Running dotnet tests..." -ForegroundColor Yellow
    dotnet test /p:CollectCoverage=true
}

# Go Project Detection
if (Test-Path "go.mod") {
    $projectDetected = $true
    Write-Host "[i] Go project detected." -ForegroundColor Cyan

    # Format check
    Write-Host "[i] Running go fmt..." -ForegroundColor Yellow
    go fmt ./...

    # Test Run
    Write-Host "[i] Running tests with coverage..." -ForegroundColor Yellow
    go test -cover ./...
}

if (-not $projectDetected) {
    Write-Host "No supported package environments (Node, Python, .NET, Go) detected in root path. Running standalone validations only." -ForegroundColor Yellow
}

Write-Host "==================================================" -ForegroundColor Cyan
if ($hasErrors) {
    Write-Host "[-] Verification Pipeline Failed!" -ForegroundColor Red
    Exit 1
} else {
    Write-Host "[+] All Quality and Safety Pipeline checks passed successfully!" -ForegroundColor Green
    Exit 0
}
