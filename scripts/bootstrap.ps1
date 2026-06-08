param(
    [string]$TargetPath = ".",
    [switch]$InstallGlobally,
    [ValidateSet("both", "antigravity", "claude")]
    [string]$Tool
)

$ErrorActionPreference = "Stop"

# Determine dotfiles root directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = (Get-Location).Path
}
$dotfilesRoot = (Get-Item (Join-Path $scriptDir "..")).FullName

Write-Host "=================================================="
Write-Host "Agent Configuration Bootstrapper"
Write-Host "=================================================="

# Interactive prompting if $Tool is not specified
if ([string]::IsNullOrEmpty($Tool)) {
    $isInteractive = $true
    try {
        if ([System.Console]::KeyAvailable -eq $false -and [System.Console]::In.GetType().Name -ne 'StreamReader') {
            $isInteractive = $false
        }
    } catch {
        $isInteractive = $false
    }

    if ($isInteractive) {
        Write-Host "Which agentic workspace configuration would you like to set up?" -ForegroundColor Cyan
        Write-Host "1) Both Antigravity CLI & Claude Code (Default)"
        Write-Host "2) Antigravity CLI only"
        Write-Host "3) Claude Code only"
        $choice = Read-Host "Select option [1-3]"
        switch ($choice) {
            "2" { $Tool = "antigravity" }
            "3" { $Tool = "claude" }
            default { $Tool = "both" }
        }
    } else {
        $Tool = "both"
    }
}

$setupAntigravity = ($Tool -eq "both" -or $Tool -eq "antigravity")
$setupClaude = ($Tool -eq "both" -or $Tool -eq "claude")

Write-Host "Configuration Mode: $Tool" -ForegroundColor Green

if ($InstallGlobally) {
    if ($setupAntigravity) {
        # Antigravity Global Setup
        $globalConfigBase = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
        Write-Host "Installing Antigravity configurations globally into $globalConfigBase..."
        
        $globalSkillsPath = Join-Path $globalConfigBase "skills"
        $globalAgentsPath = Join-Path $globalConfigBase "agents"
        $globalRulesPath = Join-Path $globalConfigBase "rules"
        
        if (-not (Test-Path $globalSkillsPath)) { New-Item -ItemType Directory -Path $globalSkillsPath -Force | Out-Null }
        if (-not (Test-Path $globalAgentsPath)) { New-Item -ItemType Directory -Path $globalAgentsPath -Force | Out-Null }
        if (-not (Test-Path $globalRulesPath)) { New-Item -ItemType Directory -Path $globalRulesPath -Force | Out-Null }
        
        $rulesSource = Join-Path $dotfilesRoot ".agents\rules"
        if (Test-Path $rulesSource) {
            Write-Host "Copying rules to Antigravity global rules path..."
            Copy-Item -Path "$rulesSource\*" -Destination $globalRulesPath -Recurse -Force
        }
        
        $agentsSource = Join-Path $dotfilesRoot ".agents\agents"
        if (Test-Path $agentsSource) {
            Write-Host "Copying agent configurations to Antigravity global agents path..."
            Copy-Item -Path "$agentsSource\*" -Destination $globalAgentsPath -Recurse -Force
        }
        
        $skillsSource = Join-Path $dotfilesRoot ".agents\skills"
        if (Test-Path $skillsSource) {
            Write-Host "Copying skills to Antigravity global skills path..."
            Copy-Item -Path "$skillsSource\*" -Destination $globalSkillsPath -Recurse -Force
        }

        Write-Host "Copying global AGENTS.md..."
        $globalAgentsMd = Join-Path $globalConfigBase "AGENTS.md"
        Copy-Item -Path (Join-Path $dotfilesRoot "AGENTS.md") -Destination $globalAgentsMd -Force

        $globalConfigBaseForward = $globalConfigBase.Replace("\", "/")
        if (Test-Path $globalAgentsMd) {
            $content = Get-Content $globalAgentsMd -Raw
            $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.agents", "file:///${globalConfigBaseForward}"
            Set-Content -Path $globalAgentsMd -Value $content -Force
        }
    }

    if ($setupClaude) {
        # Claude Code Global Setup
        $globalClaudeBase = Join-Path $env:USERPROFILE ".claude"
        Write-Host "Installing Claude Code configurations globally into $globalClaudeBase..."
        
        $globalClaudeSkillsPath = Join-Path $globalClaudeBase "skills"
        $globalClaudeRulesPath = Join-Path $globalClaudeBase "rules"
        
        if (-not (Test-Path $globalClaudeSkillsPath)) { New-Item -ItemType Directory -Path $globalClaudeSkillsPath -Force | Out-Null }
        if (-not (Test-Path $globalClaudeRulesPath)) { New-Item -ItemType Directory -Path $globalClaudeRulesPath -Force | Out-Null }
        
        $rulesSource = Join-Path $dotfilesRoot ".agents\rules"
        if (Test-Path $rulesSource) {
            Write-Host "Copying rules to Claude global rules path..."
            Copy-Item -Path "$rulesSource\*" -Destination $globalClaudeRulesPath -Recurse -Force
        }
        
        $skillsSource = Join-Path $dotfilesRoot ".agents\skills"
        if (Test-Path $skillsSource) {
            Write-Host "Copying skills to Claude global skills path..."
            Copy-Item -Path "$skillsSource\*" -Destination $globalClaudeSkillsPath -Recurse -Force
        }

        Write-Host "Copying global CLAUDE.md..."
        $globalClaudeMd = Join-Path $globalClaudeBase "CLAUDE.md"
        Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $globalClaudeMd -Force

        $globalClaudeBaseForward = $globalClaudeBase.Replace("\", "/")
        if (Test-Path $globalClaudeMd) {
            $content = Get-Content $globalClaudeMd -Raw
            $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.claude", "file:///${globalClaudeBaseForward}"
            Set-Content -Path $globalClaudeMd -Value $content -Force
        }
    }
    
    Write-Host "Global bootstrap installation complete!"
} else {
    $resolvedPath = (Resolve-Path $TargetPath).Path
    Write-Host "Bootstrapping local project workspace: $resolvedPath"
    
    $localScriptsPath = Join-Path $resolvedPath "scripts"
    if (-not (Test-Path $localScriptsPath)) { New-Item -ItemType Directory -Path $localScriptsPath -Force | Out-Null }

    $targetForwardSlashes = $resolvedPath.Replace("\", "/")
    
    if ($setupAntigravity) {
        $localAgentsPath = Join-Path $resolvedPath ".agents"
        if (-not (Test-Path $localAgentsPath)) { New-Item -ItemType Directory -Path $localAgentsPath -Force | Out-Null }
        
        $dotfilesAgentsResolved = (Resolve-Path (Join-Path $dotfilesRoot ".agents") -ErrorAction SilentlyContinue).Path
        $destAgentsResolved = (Resolve-Path $localAgentsPath -ErrorAction SilentlyContinue).Path
        
        if ($null -ne $dotfilesAgentsResolved -and $dotfilesAgentsResolved -ne $destAgentsResolved) {
            Write-Host "Copying rules, agents, and skills templates for Antigravity..."
            Copy-Item -Path (Join-Path $dotfilesRoot ".agents\*") -Destination $localAgentsPath -Recurse -Force
            
            Write-Host "Copying AGENTS.md..."
            Copy-Item -Path (Join-Path $dotfilesRoot "AGENTS.md") -Destination $resolvedPath -Force
            
            Write-Host "Copying .antigravityignore..."
            Copy-Item -Path (Join-Path $dotfilesRoot ".antigravityignore") -Destination $resolvedPath -Force
            
            $agentsMdPath = Join-Path $resolvedPath "AGENTS.md"
            if (Test-Path $agentsMdPath) {
                $content = Get-Content $agentsMdPath -Raw
                $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.agents", "file:///${targetForwardSlashes}/.agents"
                Set-Content -Path $agentsMdPath -Value $content -Force
            }
        } else {
            Write-Host "Target matches dotfiles source. Skipping copying Antigravity templates onto themselves."
        }
    }

    if ($setupClaude) {
        $localClaudePath = Join-Path $resolvedPath ".claude"
        if (-not (Test-Path $localClaudePath)) { New-Item -ItemType Directory -Path $localClaudePath -Force | Out-Null }
        
        $dotfilesAgentsResolved = (Resolve-Path (Join-Path $dotfilesRoot ".agents") -ErrorAction SilentlyContinue).Path
        $destClaudeResolved = (Resolve-Path $localClaudePath -ErrorAction SilentlyContinue).Path
        
        if ($null -ne $dotfilesAgentsResolved -and $dotfilesAgentsResolved -ne $destClaudeResolved) {
            Write-Host "Copying rules and skills templates for Claude Code..."
            $localClaudeRules = Join-Path $localClaudePath "rules"
            $localClaudeSkills = Join-Path $localClaudePath "skills"
            if (-not (Test-Path $localClaudeRules)) { New-Item -ItemType Directory -Path $localClaudeRules -Force | Out-Null }
            if (-not (Test-Path $localClaudeSkills)) { New-Item -ItemType Directory -Path $localClaudeSkills -Force | Out-Null }
            Copy-Item -Path (Join-Path $dotfilesRoot ".agents\rules\*") -Destination $localClaudeRules -Recurse -Force
            Copy-Item -Path (Join-Path $dotfilesRoot ".agents\skills\*") -Destination $localClaudeSkills -Recurse -Force
            
            Write-Host "Copying CLAUDE.md..."
            Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $resolvedPath -Force
            
            Write-Host "Copying .claudeignore..."
            Copy-Item -Path (Join-Path $dotfilesRoot ".claudeignore") -Destination $resolvedPath -Force
            
            $claudeMdPath = Join-Path $resolvedPath "CLAUDE.md"
            if (Test-Path $claudeMdPath) {
                $content = Get-Content $claudeMdPath -Raw
                $content = $content -replace "file:///C:/Users/pbree/source/repos/dotfiles/\.claude", "file:///${targetForwardSlashes}/.claude"
                Set-Content -Path $claudeMdPath -Value $content -Force
            }
        } else {
            Write-Host "Target matches dotfiles source. Skipping copying Claude templates onto themselves."
        }
    }
    
    # Copy verification script
    Write-Host "Copying verification script..."
    Copy-Item -Path (Join-Path $dotfilesRoot "scripts\verify-project.ps1") -Destination $localScriptsPath -Force
    
    # Configure gitignore
    $gitignorePath = Join-Path $resolvedPath ".gitignore"
    $gitignoreEntries = @(
        "",
        "# AI Agent / Verification Temporary Files"
    )
    if ($setupAntigravity) {
        $gitignoreEntries += ".gemini/"
    }
    if ($setupClaude) {
        $gitignoreEntries += ".claude/settings.local.json"
    }
    $gitignoreEntries += @(
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
