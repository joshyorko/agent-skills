---
name: 37signals-api
description: >-
  Builds REST APIs using respond_to blocks with Jbuilder templates following the
  37signals same-controllers-different-formats philosophy. Use when adding API
  endpoints, JSON responses, token authentication, or when user mentions API,
  JSON, REST, or Jbuilder.
license: MIT
metadata:
  author: 37signals
  version: "1.0"
  source: 37signals-patterns
  source_repo: ThibautBaissac/rails_ai_agents
  source_ref: e063fc8d8f4444178f4bbda96407e03d339e2c75
  source_path: 37signals_skills/37signals-api
  compatibility: Ruby 3.3+, Rails 8.2+, Jbuilder
---

# API Agent

Build Rails APIs the 37signals way: the same controller serves HTML and JSON, JSON lives in Jbuilder templates, and the API stays RESTful and boring.

The complete upstream guide, examples, and edge cases are preserved in `references/full-guide.md`.

## Core Approach

- Reuse the main Rails controller with `respond_to` blocks instead of splitting into a large `Api::` controller tree unless versioning forces it.
- Render JSON with `*.json.jbuilder` templates and partials, not inline controller hashes and not serializer frameworks.
- Prefer standard REST resources, nested resources where they express ownership clearly, and HTTP status codes for success and failure.
- Keep authentication simple. Use token-based auth only when the request path truly needs non-session access.
- Apply account scoping, preload associations, and use caching headers where they materially reduce API work.

## Default Workflow

1. Identify the existing HTML resource and extend that controller first.
2. Add or update `respond_to` blocks so `format.html` and `format.json` both work cleanly.
3. Create Jbuilder views and partials for collection and member payloads.
4. Add authentication or authorization checks only where the endpoint needs them.
5. Add request or integration coverage for both happy paths and structured JSON errors.
6. If payload size or frequency matters, add `fresh_when`, `stale?`, or collection caching.

## Default Patterns

### Controllers

- Keep resource loading, authorization, and format negotiation in the controller.
- Do not build JSON inline unless the response is trivial and one-off.
- Return explicit statuses like `:created`, `:unprocessable_entity`, `:not_found`, and `:unauthorized`.

### Views

- Use Jbuilder partials for reusable objects such as cards, comments, or users.
- Keep payload shape stable and explicit.
- Add conditional attributes only when they are permission- or state-dependent.

### Authentication

- Use session auth for browser requests.
- Use API tokens for machine or external client access.
- Implement token extraction as a small controller concern instead of scattering it across endpoints.

### Performance

- Preload associations before rendering JSON.
- Paginate large collections.
- Use HTTP caching headers before introducing heavier infrastructure.

## Boundaries

### Always

- Prefer one controller with multiple formats.
- Use Jbuilder templates and partials.
- Keep endpoints RESTful and resource-oriented.
- Scope queries to the current account or tenant.

### Ask First

- URL-based or header-based versioning.
- Batch operations that do not fit standard CRUD cleanly.
- Public webhook or callback endpoints with unusual auth or replay constraints.

### Never

- Reach for GraphQL by default.
- Introduce serializer gems just to shape JSON.
- Split the app into a parallel API architecture when the existing Rails resource can handle both formats.

## Reference

- Detailed patterns, examples, pagination, caching, token auth, webhooks, and testing live in `references/full-guide.md`.
