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
   - proxied roles, non-proxy roles, and rollout controls
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

- Distinguish proxied and non-proxy roles.
- Proxied roles are checked through `proxy.healthcheck`.
- Non-proxy roles should use Docker healthchecks such as `health-cmd` under container options.
- Use the app’s real readiness endpoint, typically `/up` unless the app needs a different check.
- Kamal rollout safety also depends on `deploy_timeout`, `drain_timeout`, and `readiness_delay`.
- Rails 8 Docker defaults assume Thruster in front of Puma, so the proxy checks port `80` by default. If the app still exposes Puma directly on `3000`, set `proxy.app_port: 3000`.

### Secrets and environment

- Keep secrets in `.kamal/secrets`, `.kamal/secrets-common`, or destination-specific variants.
- Prefer credentials-backed secret fetching when the app already keeps deploy secrets in Rails credentials.
- Keep `env.clear` and `env.secret` explicit instead of relying on ambient shell state.
- Pass only the needed variables under `env`.
- Keep clear values and secret values distinct.
- Do not commit secrets or rely on ad hoc shell state that the deploy host cannot reproduce.
- Remember that values from `.kamal/secrets*` are for Kamal secret resolution, not a general-purpose source for `deploy.yml` ERB or arbitrary ENV lookups.

Example:

```sh
KAMAL_REGISTRY_PASSWORD=$(rails credentials:fetch kamal.registry_password)
```

### Accessories

- Use accessories for deploy-managed dependencies that belong with the app.
- Keep them separate from the main app roles.
- Be explicit about ports, volumes, and env so replacement and recovery are predictable.
- Accessories have their own lifecycle: they are not updated as part of normal app deploys and they do not get zero-downtime deployment behavior.

### Hooks

- Use hooks for narrow operational tasks, not for hiding application behavior.
- Store them under `.kamal/hooks` with extensionless filenames that exactly match the hook name.
- Fail fast on non-zero exit status.
- Prefer hooks for deploy notifications, preflight checks, or controlled maintenance steps.
- Use the available `KAMAL_*` variables when you need deploy audit context in a hook.

### Builders and registry

- Be explicit about target architecture when local and server architectures differ.
- Use a remote builder when local builds are too slow or incompatible.
- For simple deploys, local-registry flows are a valid default; move to a remote registry when scale or topology actually requires it.
- Keep registry auth and build secrets out of the Dockerfile and out of git.

### Rollout controls

- Use `boot.limit`, `boot.wait`, and `boot.parallel_roles` deliberately on multi-host or multi-role deploys.
- Slow boots and sensitive migrations should change rollout settings explicitly instead of hoping the defaults fit.

## Rails-specific guidance

- Pair deploy changes with app-layer changes that affect startup, migrations, assets, or worker shutdown.
- Treat migrations as deploy choreography, not just schema edits.
- If a Rails change adds a new long-running process, background queue, or extra dependency, update Kamal roles and accessories in the same change.
- Keep worker shutdown behavior in mind for Solid Queue or other job processors; Kamal’s default container shutdown window is short enough that long-running jobs should be interruption-safe.
- If the app does long-running Active Job work, evaluate `ActiveJob::Continuable` or a similar resumable design instead of assuming workers will always finish before shutdown.

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
