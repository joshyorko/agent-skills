#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

param(
  [string]$RepoPath = "$HOME/src/agent-skills",
  [string]$RepoUrl = $(if ($env:REPO_URL) { $env:REPO_URL } else { "https://github.com/joshyorko/agent-skills.git" }),
  [string]$CodexHome = "$HOME/.codex",
  [string]$AgentsHome = "$HOME/.agents",
  [string]$MarketplaceName = "agent-skills",
  [ValidateSet("link", "copy")] [string]$SkillMode = "link",
  [switch]$Force,
  [switch]$Help
)

function Show-Usage {
  @"
Usage: pwsh -File scripts/install-codex-assets.ps1 [-RepoPath PATH] [-RepoUrl URL] [-CodexHome PATH] [-AgentsHome PATH] [-MarketplaceName NAME] [-SkillMode link|copy] [-Force]

Bootstrap Codex plugins and skills from this repository into a user-level installation.

Parameters:
  -RepoPath          Destination for the agent-skills clone (default: $HOME/src/agent-skills)
  -RepoUrl           Git clone URL to use (default: https://github.com/joshyorko/agent-skills.git)
  -CodexHome         Codex user directory (default: $HOME/.codex)
  -AgentsHome        Agents user directory for marketplace metadata (default: $HOME/.agents)
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
$AgentsHome = Normalize-Path $AgentsHome
$MarketplaceName = $MarketplaceName

$SkillsRoot = Join-Path $CodexHome "skills"
$CatalogPath = Join-Path $RepoPath "marketplaces/catalog.json"

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

function Merge-Marketplace {
  $marketplaceFile = Join-Path $AgentsHome "plugins/marketplace.json"
  Ensure-Directory (Split-Path -Parent $marketplaceFile)

  $catalog = Get-Content -Raw -LiteralPath $CatalogPath | ConvertFrom-Json
  $entry = [ordered]@{
    name = $MarketplaceName
    interface = $catalog.interface
    plugins = @()
  }

  foreach ($plugin in $catalog.plugins) {
    $entry.plugins += [ordered]@{
      name = $plugin.name
      source = @{
        source = "local"
        path = (Join-Path $RepoPath "plugins/$($plugin.name)")
      }
      policy = @{
        installation = if ($plugin.installation) { $plugin.installation } else { "AVAILABLE" }
        authentication = if ($plugin.authentication) { $plugin.authentication } else { "ON_INSTALL" }
      }
      category = $plugin.category
    }
  }

  $entries = @()
  $style = "single"

  if (Test-Path -LiteralPath $marketplaceFile) {
    $data = Get-Content -Raw -LiteralPath $marketplaceFile | ConvertFrom-Json
    if ($data.PSObject.Properties.Name -contains "marketplaces" -and $data.marketplaces -is [System.Collections.IEnumerable]) {
      $entries = @($data.marketplaces)
      $style = "list"
    }
    elseif ($data.PSObject.Properties.Name -contains "plugins") {
      if ($data.name -and ($data.name -ne $MarketplaceName)) {
        throw "$marketplaceFile already uses a single-marketplace format for `"$($data.name)`". Remove or update it, or re-run with -MarketplaceName `"$($data.name)`"."
      }
      $entries = @($data)
    }
    else {
      throw "Unexpected marketplace format in $marketplaceFile"
    }
  }

  $entries = $entries | Where-Object { $_.name -ne $MarketplaceName }
  $entries += $entry

  if ($style -eq "list" -or $entries.Count -gt 1) {
    $output = @{ marketplaces = $entries }
  }
  else {
    $output = $entries[0]
  }

  $json = ($output | ConvertTo-Json -Depth 6)
  Set-Content -LiteralPath $marketplaceFile -Value ($json + "`n")
  Log "wrote marketplace entry to $marketplaceFile"
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

  Merge-Marketplace
  Install-Skills

  @"

Codex assets installed.
- Repository path: $RepoPath
- Marketplace: $(Join-Path $AgentsHome "plugins/marketplace.json") (entry "$MarketplaceName")
- Skills directory: $SkillsRoot

Next steps:
- Restart Codex to pick up the marketplace change.
- Run "/plugins" or inspect available skills in your client.
"@ | Write-Host
}

Main
