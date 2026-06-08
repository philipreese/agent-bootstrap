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
Write-Host "Agent Configuration Bootstrapper (Antigravity & Claude)"
Write-Host "=================================================="

if ($InstallGlobally) {
    # Antigravity Global Setup
    $globalConfigBase = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
    Write-Host "Installing Antigravity configurations globally into $globalConfigBase..."
    
    $globalSkillsPath = Join-Path $globalConfigBase "skills"
    $globalAgentsPath = Join-Path $globalConfigBase "agents"
    $globalRulesPath = Join-Path $globalConfigBase "rules"
    
    if (-not (Test-Path $globalSkillsPath)) { New-Item -ItemType Directory -Path $globalSkillsPath -Force | Out-Null }
    if (-not (Test-Path $globalAgentsPath)) { New-Item -ItemType Directory -Path $globalAgentsPath -Force | Out-Null }
    if (-not (Test-Path $globalRulesPath)) { New-Item -ItemType Directory -Path $globalRulesPath -Force | Out-Null }

    # Claude Code Global Setup
    $globalClaudeBase = Join-Path $env:USERPROFILE ".claude"
    Write-Host "Installing Claude Code configurations globally into $globalClaudeBase..."
    
    $globalClaudeSkillsPath = Join-Path $globalClaudeBase "skills"
    $globalClaudeRulesPath = Join-Path $globalClaudeBase "rules"
    
    if (-not (Test-Path $globalClaudeSkillsPath)) { New-Item -ItemType Directory -Path $globalClaudeSkillsPath -Force | Out-Null }
    if (-not (Test-Path $globalClaudeRulesPath)) { New-Item -ItemType Directory -Path $globalClaudeRulesPath -Force | Out-Null }
    
    # Copy Rules
    $rulesSource = Join-Path $dotfilesRoot ".agents\rules"
    if (Test-Path $rulesSource) {
        Write-Host "Copying rules to Antigravity & Claude global paths..."
        Copy-Item -Path "$rulesSource\*" -Destination $globalRulesPath -Recurse -Force
        Copy-Item -Path "$rulesSource\*" -Destination $globalClaudeRulesPath -Recurse -Force
    }
    
    # Copy Agents
    $agentsSource = Join-Path $dotfilesRoot ".agents\agents"
    if (Test-Path $agentsSource) {
        Write-Host "Copying agent configurations to Antigravity global path..."
        Copy-Item -Path "$agentsSource\*" -Destination $globalAgentsPath -Recurse -Force
    }
    
    # Copy Skills
    $skillsSource = Join-Path $dotfilesRoot ".agents\skills"
    if (Test-Path $skillsSource) {
        Write-Host "Copying skills to Antigravity & Claude global paths..."
        Copy-Item -Path "$skillsSource\*" -Destination $globalSkillsPath -Recurse -Force
        Copy-Item -Path "$skillsSource\*" -Destination $globalClaudeSkillsPath -Recurse -Force
    }

    # Copy Root Instructions
    Write-Host "Copying global guidelines..."
    $globalAgentsMd = Join-Path $globalConfigBase "AGENTS.md"
    $globalClaudeMd = Join-Path $globalClaudeBase "CLAUDE.md"
    
    Copy-Item -Path (Join-Path $dotfilesRoot "AGENTS.md") -Destination $globalAgentsMd -Force
    Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $globalClaudeMd -Force
    
    # Update absolute paths for global guidelines
    $globalConfigBaseForward = $globalConfigBase.Replace("\", "/")
    $globalClaudeBaseForward = $globalClaudeBase.Replace("\", "/")
    
    if (Test-Path $globalAgentsMd) {
        $content = Get-Content $globalAgentsMd -Raw
        $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.agents", "file:///${globalConfigBaseForward}"
        Set-Content -Path $globalAgentsMd -Value $content -Force
    }
    if (Test-Path $globalClaudeMd) {
        $content = Get-Content $globalClaudeMd -Raw
        $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.claude", "file:///${globalClaudeBaseForward}"
        Set-Content -Path $globalClaudeMd -Value $content -Force
    }
    
    Write-Host "Global bootstrap installation complete!"
} else {
    $resolvedPath = (Resolve-Path $TargetPath).Path
    Write-Host "Bootstrapping local project workspace: $resolvedPath"
    
    $localAgentsPath = Join-Path $resolvedPath ".agents"
    $localClaudePath = Join-Path $resolvedPath ".claude"
    $localScriptsPath = Join-Path $resolvedPath "scripts"
    
    if (-not (Test-Path $localAgentsPath)) { New-Item -ItemType Directory -Path $localAgentsPath -Force | Out-Null }
    if (-not (Test-Path $localClaudePath)) { New-Item -ItemType Directory -Path $localClaudePath -Force | Out-Null }
    if (-not (Test-Path $localScriptsPath)) { New-Item -ItemType Directory -Path $localScriptsPath -Force | Out-Null }
    
    # Avoid copying onto itself
    $dotfilesAgentsResolved = (Resolve-Path (Join-Path $dotfilesRoot ".agents") -ErrorAction SilentlyContinue).Path
    $destAgentsResolved = (Resolve-Path $localAgentsPath -ErrorAction SilentlyContinue).Path
    
    if ($null -ne $dotfilesAgentsResolved -and $dotfilesAgentsResolved -ne $destAgentsResolved) {
        Write-Host "Copying rules and skills templates for Antigravity & Claude..."
        Copy-Item -Path (Join-Path $dotfilesRoot ".agents\*") -Destination $localAgentsPath -Recurse -Force
        Copy-Item -Path (Join-Path $dotfilesRoot ".agents\*") -Destination $localClaudePath -Recurse -Force
        
        Write-Host "Copying verification script..."
        Copy-Item -Path (Join-Path $dotfilesRoot "scripts\verify-project.ps1") -Destination $localScriptsPath -Force
        
        Write-Host "Copying AGENTS.md & CLAUDE.md..."
        Copy-Item -Path (Join-Path $dotfilesRoot "AGENTS.md") -Destination $resolvedPath -Force
        Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $resolvedPath -Force
        
        Write-Host "Copying ignore files..."
        Copy-Item -Path (Join-Path $dotfilesRoot ".antigravityignore") -Destination $resolvedPath -Force
        Copy-Item -Path (Join-Path $dotfilesRoot ".claudeignore") -Destination $resolvedPath -Force
        
        # Update hardcoded rule index paths to match the target workspace
        $targetForwardSlashes = $resolvedPath.Replace("\", "/")
        
        $agentsMdPath = Join-Path $resolvedPath "AGENTS.md"
        if (Test-Path $agentsMdPath) {
            $content = Get-Content $agentsMdPath -Raw
            $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.agents", "file:///${targetForwardSlashes}/.agents"
            Set-Content -Path $agentsMdPath -Value $content -Force
        }
        
        $claudeMdPath = Join-Path $resolvedPath "CLAUDE.md"
        if (Test-Path $claudeMdPath) {
            $content = Get-Content $claudeMdPath -Raw
            $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.claude", "file:///${targetForwardSlashes}/.claude"
            Set-Content -Path $claudeMdPath -Value $content -Force
        }
    } else {
        Write-Host "Target matches dotfiles source. Skipping copying templates onto themselves."
    }
    
    $gitignorePath = Join-Path $resolvedPath ".gitignore"
    $gitignoreEntries = @(
        "",
        "# Antigravity / Claude Code / Agent Temporary Files",
        ".gemini/",
        ".claude/settings.local.json",
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
        [System.IO.File]::WriteAllBytes($preCommitFile, [System.Text.Encoding]::UTF8.GetBytes($hookContent))
    }
    
    Write-Host "Local project bootstrap configuration complete!"
}
Write-Host "=================================================="
