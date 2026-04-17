#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

param(
  [string]$RepoPath = "$HOME/src/agent-skills",
  [string]$RepoUrl = $(if ($env:REPO_URL) { $env:REPO_URL } else { "https://github.com/joshyorko/agent-skills.git" }),
  [string]$CodexHome = "$HOME/.codex",
  [string]$MarketplaceName = "agent-skills",
  [ValidateSet("link", "copy")] [string]$SkillMode = "link",
  [switch]$Force,
  [switch]$Help
)

function Show-Usage {
  @"
Usage: pwsh -File scripts/install-codex-assets.ps1 [-RepoPath PATH] [-RepoUrl URL] [-CodexHome PATH] [-MarketplaceName NAME] [-SkillMode link|copy] [-Force]

Bootstrap Codex plugins and skills from this repository into a user-level installation.

Parameters:
  -RepoPath          Destination for the agent-skills clone (default: $HOME/src/agent-skills)
  -RepoUrl           Git clone URL to use (default: https://github.com/joshyorko/agent-skills.git)
  -CodexHome         Codex user directory (default: $HOME/.codex)
  -MarketplaceName   Marketplace name to register (default: agent-skills)
  -SkillMode         link (default) or copy
  -Force             Replace conflicting skill entries

Examples:
  # Fresh environment: clone once, then install from the stable checkout
  if (-not (Test-Path "$HOME/src/agent-skills/.git")) { git clone https://github.com/joshyorko/agent-skills.git "$HOME/src/agent-skills" } ; pwsh -File "$HOME/src/agent-skills/scripts/install-codex-assets.ps1" -RepoPath "$HOME/src/agent-skills"

  # Install into a custom location with copies instead of symlinks
  pwsh -File "$HOME/code/agent-skills/scripts/install-codex-assets.ps1" -RepoPath "$HOME/code/agent-skills" -SkillMode copy -Force
"@
}

if ($Help) {
  Show-Usage
  exit 0
}

function Log { param([string]$Message) Write-Host "[codex-bootstrap] $Message" }
function Warn { param([string]$Message) Write-Warning "[codex-bootstrap] $Message" }

function Normalize-Path {
  param([string]$Path)
  $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
  return [IO.Path]::GetFullPath($resolved)
}

$RepoPath = Normalize-Path $RepoPath
$CodexHome = Normalize-Path $CodexHome
$MarketplaceName = $MarketplaceName
$MarketplaceStatus = "not attempted"

$SkillsRoot = Join-Path $CodexHome "skills"
$CatalogPath = Join-Path $RepoPath "marketplaces/catalog.json"
$LegacyAgentsHome = Normalize-Path "$HOME/.agents"

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Clone-Or-UpdateRepo {
  if (Test-Path -LiteralPath (Join-Path $RepoPath ".git")) {
    Log "Updating existing repository at $RepoPath"
    git -C $RepoPath fetch --tags --prune
    git -C $RepoPath pull --ff-only
  }
  elseif (Test-Path -LiteralPath $RepoPath) {
    throw "Target path $RepoPath exists but is not a git repository."
  }
  else {
    Ensure-Directory (Split-Path -Parent $RepoPath)
    Log "Cloning $RepoUrl into $RepoPath"
    git clone $RepoUrl $RepoPath
  }
}

function Register-Marketplace {
  $codexCmd = Get-Command codex -ErrorAction SilentlyContinue
  if (-not $codexCmd) {
    $script:MarketplaceStatus = "not registered automatically (codex CLI not found)"
    Warn "codex CLI not found; skipping marketplace registration. Run manually: codex marketplace add `"$RepoPath`""
    return
  }

  $originalCodexHome = $env:CODEX_HOME
  $env:CODEX_HOME = $CodexHome
  try {
    & codex marketplace add $RepoPath | Out-Null
    if ($LASTEXITCODE -eq 0) {
      $script:MarketplaceStatus = "registered via ``codex marketplace add `"$RepoPath`"``"
      Log "Registered marketplace `"$MarketplaceName`" via codex marketplace add $RepoPath"
    }
    else {
      throw "codex marketplace add returned exit code $LASTEXITCODE"
    }
  }
  catch {
    $script:MarketplaceStatus = "not registered automatically (codex marketplace add failed)"
    Warn "failed to register marketplace via codex; run manually: CODEX_HOME=`"$CodexHome`" codex marketplace add `"$RepoPath`" ($($_.Exception.Message))"
  }
  finally {
    $env:CODEX_HOME = $originalCodexHome
  }
}

function Remove-LegacyMarketplace {
  $marketplaceFile = Join-Path $LegacyAgentsHome "plugins/marketplace.json"
  if (-not (Test-Path -LiteralPath $marketplaceFile)) {
    return
  }

  try {
    $data = Get-Content -Raw -LiteralPath $marketplaceFile | ConvertFrom-Json
    $entries = @()
    $style = "single"

    if ($data.PSObject.Properties.Name -contains "marketplaces" -and $data.marketplaces -is [System.Collections.IEnumerable]) {
      $entries = @($data.marketplaces)
      $style = "list"
    }
    elseif ($data.PSObject.Properties.Name -contains "plugins") {
      $entries = @($data)
    }
    else {
      throw "Unexpected marketplace format"
    }

    $filtered = $entries | Where-Object { $_.name -ne $MarketplaceName }
    if ($filtered.Count -eq $entries.Count) {
      return
    }

    if ($filtered.Count -eq 0) {
      Remove-Item -LiteralPath $marketplaceFile -Force
      Log "Removed legacy marketplace file $marketplaceFile"
      return
    }

    if ($style -eq "list" -or $filtered.Count -gt 1) {
      $output = @{ marketplaces = $filtered }
    }
    else {
      $output = $filtered[0]
    }

    $json = ($output | ConvertTo-Json -Depth 6)
    Set-Content -LiteralPath $marketplaceFile -Value ($json + "`n")
    Log "Removed legacy marketplace entry `"$MarketplaceName`" from $marketplaceFile"
  }
  catch {
    Warn "skipping legacy marketplace cleanup: $($_.Exception.Message)"
  }
}

function Test-IsSymlink {
  param([string]$Path)
  $item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
  return $null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Resolve-Target {
  param([string]$Path)
  (Resolve-Path -LiteralPath $Path).Path
}

function Link-Skill {
  param([string]$Source, [string]$Target)
  $sourceFull = Normalize-Path $Source
  $targetFull = Normalize-Path $Target

  if (Test-Path -LiteralPath $targetFull) {
    if (Test-IsSymlink $targetFull) {
      $current = Resolve-Target $targetFull
      if ([string]::Equals($current, $sourceFull, [StringComparison]::OrdinalIgnoreCase)) {
        return $true
      }
      if (-not $Force) {
        Warn "skill $targetFull already points to $current; use -Force to replace"
        return $false
      }
      Remove-Item -LiteralPath $targetFull -Force
    }
    else {
      if (-not $Force) {
        Warn "skill $targetFull exists; use -Force to replace"
        return $false
      }
      Remove-Item -LiteralPath $targetFull -Recurse -Force
    }
  }

  try {
    New-Item -ItemType SymbolicLink -Path $targetFull -Target $sourceFull -Force | Out-Null
    return $true
  }
  catch {
    Warn "failed to create symlink $targetFull -> $sourceFull ($_). Consider -SkillMode copy."
    return $false
  }
}

function Copy-Skill {
  param([string]$Source, [string]$Target)
  $targetFull = Normalize-Path $Target

  if (Test-Path -LiteralPath $targetFull) {
    if (-not $Force) {
      Warn "skill $targetFull exists; use -Force to replace"
      return $false
    }
    Remove-Item -LiteralPath $targetFull -Recurse -Force
  }

  Copy-Item -LiteralPath $Source -Destination $targetFull -Recurse
  return $true
}

function Install-Skills {
  Ensure-Directory $SkillsRoot
  $linked = 0
  $copied = 0
  $skipped = 0

  $skillDirs = Get-ChildItem -Path (Join-Path $RepoPath "plugins") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Get-ChildItem -Path (Join-Path $_.FullName "skills") -Directory -ErrorAction SilentlyContinue
  }

  foreach ($skill in $skillDirs) {
    $target = Join-Path $SkillsRoot $skill.Name
    if ($SkillMode -eq "copy") {
      if (Copy-Skill $skill.FullName $target) { $copied++ } else { $skipped++ }
    }
    else {
      if (Link-Skill $skill.FullName $target) { $linked++ } else { $skipped++ }
    }
  }

  Log "Skills installed: linked=$linked copied=$copied skipped=$skipped"
}

function Main {
  Clone-Or-UpdateRepo

  if (-not (Test-Path -LiteralPath $CatalogPath)) {
    throw "Catalog not found at $CatalogPath"
  }

  Remove-LegacyMarketplace
  Register-Marketplace
  Install-Skills

  @"

Codex assets installed.
- Repository path: $RepoPath
- Marketplace: $MarketplaceStatus
- Skills directory: $SkillsRoot

Next steps:
- Restart Codex if marketplace registration succeeded.
- Run "/plugins" or inspect available skills in your client.
- If marketplace registration failed or Codex is not installed, run manually: CODEX_HOME="$CodexHome" codex marketplace add "$RepoPath"
"@ | Write-Host
}

Main
