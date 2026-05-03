---
name: 37signals-model
description: >-
  Use when creating or changing Rails models, validations, associations, scopes,
  callbacks, rich domain methods, or service-object-heavy model refactors.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target app model style wins.

# Model

Prefer rich domain models with clear public methods. POROs and operation-like objects are fine when they represent cohesive domain concepts, not a generic service layer.

## Workflow

1. Inspect model, associations, callbacks, concerns, database constraints, tests, callers, and tenant/auth context.
2. Put business behavior where the domain language lives. Use model methods for state changes and invariants.
3. Keep controller/job calls explicit: load scoped record, authorize, call model API.
4. Use concerns only for cohesive shared traits.
5. Make callbacks narrow and unsurprising; prefer explicit methods when side effects are important.
6. Add tests through public behavior and important integration paths.

## Guardrails

- Ask before large service-object migrations, callback rewrites, or changing public model APIs.
- Do not hide actor/account in `Current` when explicit arguments make behavior safer.
- Do not move all code into models if a cohesive domain object is clearer.
- Do not use validations as the only enforcement for security or tenant isolation.

## Output

State domain API added/changed, caller changes, side effects, tests run, and any behavior not covered.
