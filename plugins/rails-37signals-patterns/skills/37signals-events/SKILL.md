---
name: 37signals-events
description: >-
  Use when a Rails app needs activity feeds, audit trails, webhook delivery,
  event records, lifecycle history, or event-model review.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Solid Queue
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app event model wins.

# Events

Prefer explicit domain records for business-significant events. Use generic JSON only for supplemental metadata, not as the whole domain.

## Workflow

1. Inspect current activity/audit/webhook models, callbacks, jobs, retries, tenancy, and tests.
2. Decide whether the event is a dedicated model, a state record, an activity wrapper, or a webhook delivery.
3. Persist subject, actor, account/tenant, timestamps, and meaningful domain associations.
4. Fan out after commit to broadcasts, activity entries, webhook deliveries, or reporting jobs.
5. Make external delivery retryable and observable.
6. Test creation, authorization, idempotency, retry behavior, and tenant isolation.

## Guardrails

- Ask before introducing full event sourcing, streaming infrastructure, or cross-service contracts.
- Do not deliver slow webhooks inline with the request unless explicitly acceptable.
- Do not hide important events inside anonymous JSON blobs.
- Do not record cross-account activity without explicit admin/audit design.

## Output

State event model, fan-out path, retry/visibility model, tests run, and unverified external contract risk.
