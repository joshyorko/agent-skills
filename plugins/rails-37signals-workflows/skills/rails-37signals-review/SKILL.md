---
name: rails-37signals-review
description: Use when reviewing Rails code or a pull request through a 37signals-inspired architecture lens.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
---
## Source Grounding

This workflow is community-maintained and 37signals-inspired. It is not an official Basecamp style guide. Read `../../references/basecamp-style.md` first; target repo conventions and user intent win when they conflict.

# Rails 37signals Review

## Overview

Use this skill for code review, architecture audits, and convention checks against a 37signals-inspired Rails style. It prioritizes actionable findings and treats target repo conventions as the deciding context.

## Quick Start

1. Read `../../references/basecamp-style.md` for the source-grounded defaults and boundaries.
2. Scan structure first, then controllers, models, tests, jobs, and views.
3. Report findings in severity order with file, problem, and concrete fix direction.

## Review Priorities

- Missing account scoping or other tenant leaks.
- Custom controller actions that should be resources.
- Service-object-heavy business logic that belongs in models.
- Boolean state fields that should be modeled explicitly.
- Fat controllers or jobs with domain logic inside them.
- Frontend patterns that bypass standard Rails plus Hotwire flow without a clear reason.
- Tests that fight the surrounding stack instead of supporting it.

## Output Expectations

- Keep the summary brief.
- Lead with findings, not compliments.
- For each finding, explain the problem, why it matters, and what shape of fix to prefer.
- If no findings are present, say that clearly and mention any residual risk or missing test coverage.
- Call out unverified production, tenant, auth, deploy, or async assumptions.

## Reference

- Shared source-grounding and boundaries live in `../../references/basecamp-style.md`.
