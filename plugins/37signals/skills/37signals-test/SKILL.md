---
name: 37signals-test
description: >-
  Use when writing Rails tests, choosing Minitest/fixtures vs existing stack,
  adding integration/system coverage, or reviewing behavior coverage.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x, Minitest
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target test stack wins.

# Test

Prefer Minitest and fixtures when the app follows that stack. Preserve RSpec/factories unless the user asks for migration or the repo is already moving.

## Workflow

1. Inspect test framework, fixture/factory style, system-test setup, auth helpers, tenancy helpers, and CI commands.
2. Choose the smallest test that proves behavior: model for invariants, integration/request for controller flow, system for real user workflow.
3. Use fixtures for stable domain objects when available. Keep setup readable and close to app conventions.
4. Test public behavior, not private method choreography.
5. Cover tenant leaks, auth boundaries, async job enqueue/perform behavior, Turbo responses, and mail delivery where relevant.
6. Run targeted tests first; broaden only when the change touches shared behavior.

## Guardrails

- Ask before migrating test frameworks.
- Do not mock away the behavior under review.
- Do not add brittle full-browser tests for every branch.
- Do not claim complete coverage when only a narrow command ran.

## Output

State test framework, files added, behavior covered, command output summary, and residual risk.
