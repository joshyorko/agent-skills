---
name: 37signals-jobs
description: >-
  Use when a Rails app needs background jobs, Solid Queue, async side effects,
  scheduled work, worker topology, or job reliability review.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Solid Queue
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; installed queue adapter and deploy topology win.

# Jobs

Keep jobs shallow. Jobs should find records, set context, and call durable model APIs. Business rules belong in models or cohesive domain objects.

## Workflow

1. Inspect `config.active_job.queue_adapter`, Solid Queue config, Procfile/Kamal roles, existing jobs, retries, and tests.
2. Decide if the work must be async: slow IO, external API, fan-out, scheduled work, or retryable side effect.
3. Put durable behavior in a model method. Let the job set tenant/current context and call it.
4. Make jobs idempotent, retry-aware, and safe after deploy restarts.
5. Add `*_later` convenience methods only when the app already uses that naming style or it clarifies the domain.
6. Verify job tests plus any deploy/runtime config touched.

## Guardrails

- Ask before changing queue adapter, worker roles, production queue DB, or replacing Sidekiq/Redis.
- Do not rely on Solid Queue internals.
- Do not enqueue work before transaction commit when it needs committed records.
- Do not make long jobs non-resumable if partial progress matters.

## Output

State queue adapter, job role, model method called, idempotency strategy, tests run, and unverified production worker assumptions.
