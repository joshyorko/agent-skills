#!/usr/bin/env node
'use strict';

const { spawnSync } = require('node:child_process');
const path = require('node:path');

const ROOT = path.resolve(__dirname, '..');

const POWERSHELL_ARG_NAMES = new Map([
  ['--repo-path', '-RepoPath'],
  ['--repo-url', '-RepoUrl'],
  ['--codex-home', '-CodexHome'],
  ['--marketplace-name', '-MarketplaceName'],
  ['--skill-mode', '-SkillMode'],
  ['--install-method', '-InstallMethod'],
  ['--ref', '-Ref'],
  ['--force', '-Force'],
  ['--help', '-Help'],
  ['-h', '-Help']
]);

function normalizePowerShellArgs(args) {
  const normalized = [];
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === '--link') {
      normalized.push('-SkillMode', 'link');
    } else if (arg === '--copy') {
      normalized.push('-SkillMode', 'copy');
    } else if (POWERSHELL_ARG_NAMES.has(arg)) {
      normalized.push(POWERSHELL_ARG_NAMES.get(arg));
    } else {
      normalized.push(arg);
    }
  }
  return normalized;
}

function scriptForPlatform(platform = process.platform) {
  return platform === 'win32' ? path.join(ROOT, 'install.ps1') : path.join(ROOT, 'install.sh');
}

function commandForPlatform(platform, args) {
  const script = scriptForPlatform(platform);
  if (platform === 'win32') {
    return {
      candidates: ['pwsh', 'powershell'],
      args: ['-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script, ...normalizePowerShellArgs(args)]
    };
  }

  return {
    candidates: ['bash'],
    args: [script, ...args]
  };
}

function runInstaller(args, platform = process.platform) {
  const command = commandForPlatform(platform, args);
  const missing = [];

  for (const candidate of command.candidates) {
    const result = spawnSync(candidate, command.args, { stdio: 'inherit' });
    if (result.error && result.error.code === 'ENOENT') {
      missing.push(candidate);
      continue;
    }
    if (result.error) {
      throw result.error;
    }
    return result.status ?? 0;
  }

  console.error(`Unable to find a command to run ${scriptForPlatform(platform)}. Tried: ${missing.join(', ')}`);
  return 1;
}

function main() {
  process.exitCode = runInstaller(process.argv.slice(2));
}

if (require.main === module) {
  main();
}

module.exports = {
  commandForPlatform,
  normalizePowerShellArgs,
  runInstaller,
  scriptForPlatform
};
