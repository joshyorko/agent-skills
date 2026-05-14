# 37signals Skill Caveats

These skills are community-maintained and 37signals-inspired. They are not
official Basecamp or 37signals style guides unless a claim is tied to a
Basecamp-owned repo, public 37signals guide, public 37signals article, or
upstream project owned by Basecamp/37signals.

## Source Scope

- `dhh-rails-judgment` may use DHH/Rails Doctrine language when the prompt is
  explicitly about Rails architecture.
- Product design, scope judgment, communication, and Shape Up are broader
  37signals/Basecamp/Jason/DHH synthesis. Do not write "DHH says" there.
- Existing project conventions, production safety, user constraints, compliance,
  security, accessibility, tenancy, and data integrity beat style preference.

## Runtime Scope

This plugin is static judgment, not a live Basecamp/Fizzy/HEY integration. For
live product data or mutations, use the relevant CLI-backed skill instead.

## Writing Rules

- Say "prefer" or "reach for first" for style defaults.
- Reserve "never" for security, data loss, or correctness hazards.
- Mark inference when no public source directly supports a claim.
- Load only the recipe cards needed for the current task.
