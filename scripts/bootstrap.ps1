<#
.SYNOPSIS
    Bootstraps Claude Code workspace configuration into a target project or globally.
.DESCRIPTION
    Copies CLAUDE.md, .claudeignore, .claude/ scaffolding, and verify-project.ps1 into
    a target repository and wires up the Git pre-commit hook.
#>
param(
    [string]$TargetPath = ".",
    [switch]$InstallGlobally
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = (Get-Location).Path
}
$dotfilesRoot = (Get-Item (Join-Path $scriptDir "..")).FullName

Write-Host "=================================================="
Write-Host "Claude Code Workspace Bootstrapper"
Write-Host "=================================================="

if ($InstallGlobally) {
    $globalClaudeBase = Join-Path $env:USERPROFILE ".claude"
    Write-Host "Installing Claude Code configurations globally into $globalClaudeBase..."

    if (-not (Test-Path $globalClaudeBase)) { New-Item -ItemType Directory -Path $globalClaudeBase -Force | Out-Null }

    Write-Host "Copying CLAUDE.md..."
    $globalClaudeMd = Join-Path $globalClaudeBase "CLAUDE.md"
    Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $globalClaudeMd -Force

    $globalClaudeBaseForward = $globalClaudeBase.Replace("\", "/")
    if (Test-Path $globalClaudeMd) {
        $content = Get-Content $globalClaudeMd -Raw
        $content = $content -replace "file://__PROJECT_ROOT__/\.claude", "file:///${globalClaudeBaseForward}"
        [System.IO.File]::WriteAllText($globalClaudeMd, $content, [System.Text.Encoding]::UTF8)
    }

    Write-Host "Global installation complete!" -ForegroundColor Green
} else {
    $resolvedPath = (Resolve-Path $TargetPath).Path
    Write-Host "Bootstrapping project workspace: $resolvedPath"

    $targetForwardSlashes = $resolvedPath.Replace("\", "/")

    # Create .claude/ scaffold
    $localClaudePath = Join-Path $resolvedPath ".claude"
    if (-not (Test-Path $localClaudePath)) { New-Item -ItemType Directory -Path $localClaudePath -Force | Out-Null }

    $dotfilesClaudeResolved = (Resolve-Path (Join-Path $dotfilesRoot ".claude") -ErrorAction SilentlyContinue).Path
    $destClaudeResolved = (Resolve-Path $localClaudePath -ErrorAction SilentlyContinue).Path

    if ($null -ne $dotfilesClaudeResolved -and $dotfilesClaudeResolved -ne $destClaudeResolved) {
        Write-Host "Copying .claude/ contents..."
        Copy-Item -Path (Join-Path $dotfilesRoot ".claude\*") -Destination $localClaudePath -Recurse -Force
    } else {
        Write-Host "Target matches dotfiles source. Skipping .claude/ copy."
    }

    Write-Host "Copying CLAUDE.md..."
    Copy-Item -Path (Join-Path $dotfilesRoot "CLAUDE.md") -Destination $resolvedPath -Force

    $claudeMdPath = Join-Path $resolvedPath "CLAUDE.md"
    if (Test-Path $claudeMdPath) {
        $content = Get-Content $claudeMdPath -Raw
        $content = $content -replace "file://__PROJECT_ROOT__", "file:///${targetForwardSlashes}"
        [System.IO.File]::WriteAllText($claudeMdPath, $content, [System.Text.Encoding]::UTF8)
    }

    Write-Host "Copying .claudeignore..."
    Copy-Item -Path (Join-Path $dotfilesRoot ".claudeignore") -Destination $resolvedPath -Force

    # Copy verification script
    $localScriptsPath = Join-Path $resolvedPath "scripts"
    if (-not (Test-Path $localScriptsPath)) { New-Item -ItemType Directory -Path $localScriptsPath -Force | Out-Null }
    Write-Host "Copying verify-project.ps1..."
    Copy-Item -Path (Join-Path $dotfilesRoot "scripts\verify-project.ps1") -Destination $localScriptsPath -Force

    # Configure .gitignore
    $gitignorePath = Join-Path $resolvedPath ".gitignore"
    $gitignoreEntries = @(
        "",
        "# AI Agent / Verification Temporary Files",
        ".claude/settings.local.json",
        ".pixi/",
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
        Write-Host "Updating .gitignore..."
        $existingContent = Get-Content $gitignorePath
        $newEntries = $gitignoreEntries | Where-Object { $existingContent -notcontains $_ }
        if ($newEntries.Count -gt 0) {
            Add-Content -Path $gitignorePath -Value $newEntries
        }
    } else {
        Write-Host "Creating .gitignore..."
        [System.IO.File]::WriteAllText($gitignorePath, ($gitignoreEntries -join "`n"), [System.Text.Encoding]::UTF8)
    }

    # Initialize git if needed
    if (-not (Test-Path (Join-Path $resolvedPath ".git"))) {
        Write-Host "Initializing Git repository..."
        try {
            Start-Process -FilePath "git" -ArgumentList "init" -WorkingDirectory $resolvedPath -NoNewWindow -Wait
        } catch {
            Write-Warning "Could not run 'git init'. Ensure Git is installed and in PATH."
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

    Write-Host "Bootstrap complete!" -ForegroundColor Green
}
Write-Host "=================================================="
