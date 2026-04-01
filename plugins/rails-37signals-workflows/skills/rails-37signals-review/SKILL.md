---
name: rails-37signals-review
description: Use when reviewing Rails code or a pull request for 37signals-style architecture, especially to catch service-object drift, CRUD violations, boolean state modeling, missing tenant scoping, Hotwire mismatches, or testing patterns that do not fit a Minitest-and-fixtures Rails stack.
---

# Rails 37signals Review

## Overview

Use this skill for code review, architecture audits, and convention checks against the 37signals Rails style. It ports the original review-oriented Claude agent into a Codex skill that prioritizes actionable findings.

## Quick Start

1. Read `references/review-checklist.md` before reviewing a PR or changed area.
2. Read `references/conventions.md` if you need the underlying style assumptions.
3. Scan structure first, then controllers, models, tests, jobs, and views.
4. Report findings in severity order with file, problem, and concrete fix direction.

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

## Load These References When Needed

- `references/review-checklist.md`: prioritized review dimensions and output format.
- `references/conventions.md`: baseline architecture expectations behind the review.
