---
name: 37signals-kamal
description: >-
  Use when setting up Kamal, editing deploy config, changing roles/secrets/hooks,
  shipping Rails runtime changes, or debugging Kamal deployment issues.
license: MIT
metadata:
  author: Josh Yorko
  version: "1.0"
  source: Kamal docs
  source_repo: basecamp/kamal
  source_ref: main checked 2026-05-03
  source_note: Basecamp-owned source. Verify installed version and current docs before applying.
  source_path: kamal-deploy.org/docs
  compatibility: Ruby 3.3+, Rails 8.x, Kamal 2
---
## Source Grounding

Grounded in the Basecamp-owned Kamal project. Read `../../references/basecamp-style.md`, then verify the installed Kamal version and app deploy files before copying commands.

# Kamal

Kamal deploys Dockerized apps to VMs or bare metal. It is not Rails-only and not a Kubernetes abstraction.

## Workflow

1. Inspect `config/deploy*.yml`, `.kamal/`, `Dockerfile`, registry, secrets, roles, accessories, hooks, healthcheck, and CI/deploy docs.
2. Determine whether the task is config authoring, deploy debugging, secret handling, role topology, or runtime change support.
3. Keep web, job, cron, and accessory roles explicit. Match app code changes to deploy/runtime config.
4. Put secrets outside committed files. Use the app's existing secret flow.
5. Prefer official Kamal commands for validation and deploy, but verify syntax against installed version.
6. Report production risk before running mutating deploy commands.

## Guardrails

- Ask before running production deploys, rebooting hosts, changing registry/secrets, or replacing runtime topology.
- Do not claim Kamal solves database backup, observability, or tenant isolation by itself.
- Do not edit Kubernetes guidance as if Kamal applies there.
- Do not expose secrets in final output or logs.

## Output

State inspected deploy files, changed roles/secrets/hooks, commands run, production impact, and anything not verified against live infrastructure.
