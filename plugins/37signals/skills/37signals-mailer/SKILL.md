---
name: 37signals-mailer
description: >-
  Use when a Rails app needs Action Mailer, transactional email, notification
  delivery, mailer tests, preview cleanup, or async mail delivery review.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Action Mailer
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target mailer conventions and provider constraints win.

# Mailer

Keep mailers transactional and boring. Prefer explicit mailer methods, previews, and tests over a generic notification framework unless the app already has one.

## Workflow

1. Inspect existing mailers, previews, layouts, delivery jobs, unsubscribe rules, URL options, tenancy, and tests.
2. Identify trigger source: user action, state record, event, scheduled job, or admin action.
3. Put send/no-send business decisions in models or policy methods, not templates.
4. Use `deliver_later` from request paths; `deliver_now` is acceptable inside a job when that job owns delivery.
5. Include account/tenant context in URL generation and record lookup.
6. Add mailer tests, preview coverage where useful, and job tests if delivery is async.

## Guardrails

- Ask before changing provider config, sender domains, unsubscribe semantics, or bulk email flows.
- Never leak cross-tenant URLs or data in email content.
- Do not enqueue duplicate emails without idempotency.
- Do not hardcode production hostnames unless app config already does.

## Output

State mailer method, trigger, delivery timing, tenant URL handling, tests run, and unverified provider/deploy assumptions.
