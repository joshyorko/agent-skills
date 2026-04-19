---
name: 37signals-kamal
description: >-
  Deploys Rails applications with Kamal using roles, accessories, hooks,
  secrets, and deploy-safe operational patterns aligned with modern Rails and
  37signals-style infrastructure choices. Use when setting up Kamal, editing
  deploy config, shipping Rails changes, or debugging deploy/runtime issues.
license: MIT
metadata:
  author: Josh Yorko
  version: "1.0"
  source: Kamal docs
  source_repo: basecamp/kamal
  source_ref: main
  source_path: kamal-deploy.org/docs
  compatibility: Ruby 3.3+, Rails 8.x, Kamal 2
---

# 37signals Kamal

Use this skill for Rails deployment and runtime operations with Kamal.

Kamal is the concrete deployment layer missing from the rest of the Rails / 37signals skill set. Keep application architecture in the other skills; use this one for `config/deploy.yml`, `.kamal/secrets`, roles, accessories, hooks, builders, healthchecks, and deploy-safe operational changes.

## Core approach

- Keep infrastructure boring: one Rails app image, explicit roles, few moving parts.
- Prefer Kamal defaults unless there is a proven need to customize them.
- Treat deployment work as part of the feature, not as an afterthought.
- Keep secrets out of git and deployment behavior reproducible from repo-owned config.

## What this skill owns

- `config/deploy.yml` and destination-specific Kamal config
- `.kamal/secrets*` conventions and environment wiring
- web/job role layout
- accessories for stateful dependencies
- hooks for deploy reporting or preflight checks
- builder and registry decisions
- deploy, rollback, and runtime debugging commands

## Default workflow

1. Confirm the runtime shape.
   - web only, or web plus workers
   - accessories needed, or externally managed services
   - single destination, or staging plus production
2. Make the app boot cleanly in a container first.
3. Add or tighten Kamal config.
4. Verify healthchecks, secrets, and role commands.
5. Choose the smallest safe deploy command.
6. Leave behind a repeatable operational path, not tribal knowledge.

## Default patterns

### Roles

- Put HTTP traffic on the primary web role.
- Give long-running job processors their own role when shutdown behavior or concurrency differs from web.
- Keep role commands explicit instead of overloading one container with unrelated entrypoints.

### Healthchecks

- Let Kamal switch traffic only after the new container responds cleanly.
- Use the app’s real readiness endpoint, typically `/up` unless the app needs a different check.
- If a worker or accessory needs a custom health command, define it directly in config.

### Secrets and environment

- Keep secrets in `.kamal/secrets`, `.kamal/secrets-common`, or destination-specific variants.
- Pass only the needed variables under `env`.
- Keep clear values and secret values distinct.
- Do not commit secrets or rely on ad hoc shell state that the deploy host cannot reproduce.

### Accessories

- Use accessories for deploy-managed dependencies that belong with the app.
- Keep them separate from the main app roles.
- Be explicit about ports, volumes, and env so replacement and recovery are predictable.

### Hooks

- Use hooks for narrow operational tasks, not for hiding application behavior.
- Fail fast on non-zero exit status.
- Prefer hooks for deploy notifications, preflight checks, or controlled maintenance steps.

### Builders and registry

- Be explicit about target architecture when local and server architectures differ.
- Use a remote builder when local builds are too slow or incompatible.
- Keep registry auth and build secrets out of the Dockerfile and out of git.

## Rails-specific guidance

- Pair deploy changes with app-layer changes that affect startup, migrations, assets, or worker shutdown.
- Treat migrations as deploy choreography, not just schema edits.
- If a Rails change adds a new long-running process, background queue, or extra dependency, update Kamal roles and accessories in the same change.
- Keep worker shutdown behavior in mind for Solid Queue or other job processors.

## Commands you can use

```bash
bundle add kamal
bin/kamal init
bin/kamal setup
bin/kamal deploy
bin/kamal rollback
bin/kamal app exec --interactive "bin/rails console"
bin/kamal app logs
```

## Boundaries

### Always

- Keep deploy config repo-owned and reviewable.
- Use explicit roles, healthchecks, and secrets wiring.
- Make deploy changes verifiable from commands another engineer can run.

### Ask first

- Multi-region or multi-cluster rollouts.
- Non-default proxy behavior.
- Unusual builder or registry topology.
- Hook logic that mutates application state.

### Never

- Smuggle secrets into committed files.
- Hide critical deploy behavior in undocumented shell one-liners.
- Treat Kamal config as optional when the Rails change clearly affects runtime behavior.
