---
name: 37signals-crud
description: >-
  Use when adding Rails controllers, routes, REST resources, nested resources,
  or state-change endpoints that may be modeled as resources.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Turbo
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target routes and product language win.

# CRUD

Use resource modeling as the first lens. A state change like archive, publish, close, pin, or assign often becomes its own singular or nested resource. Do not contort webhooks, imports, callbacks, or stable public APIs just to avoid a custom action.

## Workflow

1. Inspect `config/routes.rb`, existing controller namespace, authorization, tenant scoping, Turbo response style, and tests.
2. Name the domain resource behind the action. Prefer nouns: `Closure`, `Publication`, `Assignment`, `Position`.
3. Choose route shape: singular `resource` for toggles/lifecycle, plural `resources` for collections, nested only when ownership is real.
4. Keep controllers thin: load scoped records, authorize, call a model API, respond.
5. Add HTML and Turbo responses that match the surrounding app.
6. Verify with route output and controller/integration tests.

## Guardrails

- Ask before changing public routes, API contracts, or URL tenancy shape.
- Do not create nested resources that bypass account scope.
- Do not move business rules into controllers.
- Do not add clever routing if a plain custom action is clearer for an external callback.

## Output

State resource chosen, route shape, controller path, scoped lookup, tests run, and any route compatibility risk.
