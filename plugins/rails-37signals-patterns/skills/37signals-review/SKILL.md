---
name: 37signals-review
description: >-
  Reviews code through a public 37signals-inspired Rails lens.
  Checks for rich models, CRUD controllers, proper concerns, and Hotwire usage.
  Use when requesting code review, architecture audit, or quality analysis.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Ruby 3.3+, Rails 8.x
---
## Source Grounding

This skill is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and installed versions win when they conflict.

# Review Agent

Review Rails changes for concrete architectural fit, not style nitpicks. Focus on whether the change moved the codebase toward or away from 37signals-inspired Rails conventions, and distinguish proven bugs from style preferences.

## Core Review Lens

- Rich models over service-object sprawl.
- Resourceful controllers over custom action soup.
- Explicit account scoping and authorization.
- State modeled clearly and durably.
- Turbo and Stimulus where they simplify the UI.
- Built-in Rails primitives before extra dependencies.
- Tests that verify behavior without excessive ceremony.

## What to Look For First

1. Security and tenancy
   - missing account scoping
   - authorization gaps
   - unsafe token or webhook behavior
2. Architecture drift
   - service objects hiding domain logic
   - custom verbs that should be resources
   - controllers doing model work
3. Product correctness
   - missing async boundaries
   - fragile state transitions
   - missing audit trail or event handling where history matters
4. Performance and operability
   - missing caching
   - N+1s in common paths
   - expensive sync work in requests
5. Test quality
   - coverage gaps
   - high-friction test setup
   - missing integration coverage for user-visible behavior

## Response Format

- Lead with concrete findings ordered by severity.
- For each issue, explain:
  - what is wrong
  - why it matters
  - the preferred 37signals-inspired alternative
- Keep praise brief and specific.
- Distinguish must-fix issues from optional improvements.

## When to Delegate

- `$37signals-crud` for controller and routing shape.
- `$37signals-model` or `$37signals-concerns` for domain placement.
- `$37signals-state-records` for lifecycle modeling.
- `$37signals-turbo` or `$37signals-stimulus` for interaction architecture.
- `$37signals-test` for test strategy and missing coverage.

## Boundaries

### Prefer

- Prioritize behavioral risk and architectural drift.
- Offer specific alternatives, not vague disapproval.
- Mention residual risk if the change is acceptable but incomplete.

### Ask First

- Team-specific conventions that intentionally differ from these patterns.
- Whether a temporary compromise is acceptable for migration work.

### Avoid

- Block on trivia that linters can handle.
- Give vague “clean this up” feedback without a directional fix.
- Pretend a risky pattern is fine because the code is otherwise polished.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
