param(
    [string]$TargetPath = ".",
    [switch]$InstallGlobally
)

$ErrorActionPreference = "Stop"

# Determine dotfiles root directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = (Get-Location).Path
}
$dotfilesRoot = (Get-Item (Join-Path $scriptDir "..")).FullName

Write-Host "=================================================="
Write-Host "Antigravity Agent Configuration Bootstrapper"
Write-Host "=================================================="

if ($InstallGlobally) {
    $globalConfigBase = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
    Write-Host "Installing configurations globally into $globalConfigBase..."
    
    $globalSkillsPath = Join-Path $globalConfigBase "skills"
    $globalAgentsPath = Join-Path $globalConfigBase "agents"
    $globalRulesPath = Join-Path $globalConfigBase "rules"
    
    if (-not (Test-Path $globalSkillsPath)) { New-Item -ItemType Directory -Path $globalSkillsPath -Force | Out-Null }
    if (-not (Test-Path $globalAgentsPath)) { New-Item -ItemType Directory -Path $globalAgentsPath -Force | Out-Null }
    if (-not (Test-Path $globalRulesPath)) { New-Item -ItemType Directory -Path $globalRulesPath -Force | Out-Null }
    
    $rulesSource = Join-Path $dotfilesRoot ".agents\rules"
    if (Test-Path $rulesSource) {
        Write-Host "Copying rules to $globalRulesPath..."
        Copy-Item -Path "$rulesSource\*" -Destination $globalRulesPath -Recurse -Force
    }
    
    $agentsSource = Join-Path $dotfilesRoot ".agents\agents"
    if (Test-Path $agentsSource) {
        Write-Host "Copying agent configurations to $globalAgentsPath..."
        Copy-Item -Path "$agentsSource\*" -Destination $globalAgentsPath -Recurse -Force
    }
    
    $skillsSource = Join-Path $dotfilesRoot ".agents\skills"
    if (Test-Path $skillsSource) {
        Write-Host "Copying skills to $globalSkillsPath..."
        Copy-Item -Path "$skillsSource\*" -Destination $globalSkillsPath -Recurse -Force
    }
    
    Write-Host "Global bootstrap installation complete!"
} else {
    $resolvedPath = (Resolve-Path $TargetPath).Path
    Write-Host "Bootstrapping local project workspace: $resolvedPath"
    
    $localAgentsPath = Join-Path $resolvedPath ".agents"
    $localScriptsPath = Join-Path $resolvedPath "scripts"
    
    if (-not (Test-Path $localAgentsPath)) { New-Item -ItemType Directory -Path $localAgentsPath -Force | Out-Null }
    if (-not (Test-Path $localScriptsPath)) { New-Item -ItemType Directory -Path $localScriptsPath -Force | Out-Null }
    
    # Avoid copying onto itself
    $dotfilesAgentsResolved = (Resolve-Path (Join-Path $dotfilesRoot ".agents") -ErrorAction SilentlyContinue).Path
    $destAgentsResolved = (Resolve-Path $localAgentsPath -ErrorAction SilentlyContinue).Path
    
    if ($null -ne $dotfilesAgentsResolved -and $dotfilesAgentsResolved -ne $destAgentsResolved) {
        Write-Host "Copying rules and skills templates..."
        Copy-Item -Path (Join-Path $dotfilesRoot ".agents\*") -Destination $localAgentsPath -Recurse -Force
        
        Write-Host "Copying verification script..."
        Copy-Item -Path (Join-Path $dotfilesRoot "scripts\verify-project.ps1") -Destination $localScriptsPath -Force
        
        Write-Host "Copying AGENTS.md..."
        Copy-Item -Path (Join-Path $dotfilesRoot "AGENTS.md") -Destination $resolvedPath -Force
        
        Write-Host "Copying .antigravityignore..."
        Copy-Item -Path (Join-Path $dotfilesRoot ".antigravityignore") -Destination $resolvedPath -Force
    } else {
        Write-Host "Target matches dotfiles source. Skipping copying templates onto themselves."
    }
    
    $gitignorePath = Join-Path $resolvedPath ".gitignore"
    $gitignoreEntries = @(
        "",
        "# Antigravity / Agent Temporary Files",
        ".gemini/",
        "**/scratch/",
        "**/browser_recordings/",
        "html_artifacts/",
        "task.md",
        "implementation_plan.md",
        "walkthrough.md",
        ".env",
        ".env.local"
    )
    
    if (Test-Path $gitignorePath) {
        Write-Host "Modifying .gitignore..."
        $existingContent = Get-Content $gitignorePath
        $newEntries = $gitignoreEntries | Where-Object { $existingContent -notcontains $_ }
        if ($newEntries.Count -gt 0) {
            Add-Content -Path $gitignorePath -Value $newEntries
        }
    } else {
        Write-Host "Creating .gitignore..."
        Set-Content -Path $gitignorePath -Value $gitignoreEntries
    }
    
    if (-not (Test-Path (Join-Path $resolvedPath ".git"))) {
        Write-Host "Initializing Git repository..."
        try {
            Start-Process -FilePath "git" -ArgumentList "init" -WorkingDirectory $resolvedPath -NoNewWindow -Wait
        } catch {
            Write-Warning "Could not automatically run 'git init'. Ensure Git is installed and available in PATH."
        }
    }
    
    # Configure Git pre-commit hook
    $gitHooksDir = Join-Path $resolvedPath ".git\hooks"
    if (Test-Path $gitHooksDir) {
        $preCommitFile = Join-Path $gitHooksDir "pre-commit"
        Write-Host "Configuring Git pre-commit hook..."
        $hookContent = "#!/bin/sh`n# Run the project verification pipeline before commit`npowershell.exe -ExecutionPolicy Bypass -File ./scripts/verify-project.ps1`nif [ `$? -ne 0 ]; then`n    echo 'Pre-commit verification failed! Commit aborted.'`n    exit 1`nfi`n"
        [System.IO.File]::WriteAllText($preCommitFile, $hookContent)
    }
    
    Write-Host "Local project bootstrap configuration complete!"
}
Write-Host "=================================================="
