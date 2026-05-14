---
name: 37signals-product-design
description: >-
  Use when designing or reviewing product UI, frontend flows, Rails/Hotwire
  screens, onboarding, settings, empty states, or product copy through
  37signals-inspired interface-first and epicenter design principles.
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target users, product constraints, and existing design system win.

# 37signals Product Design

Design the product from the interface inward. Use real screens, real copy, and the smallest useful workflow to expose product truth before adding architecture, navigation, settings, or explanation.

## Workflow

1. Find the epicenter: the object, decision, or action that makes the product valuable.
2. Design that moment first with real user-facing language.
3. Add only the surrounding screens needed to complete the workflow.
4. Prefer depth over surface area: strengthen the core flow before adding more modes.
5. Check context over consistency: reuse patterns when they clarify the moment, not by reflex.
6. Verify the flow in browser-sized constraints, including mobile, loading, empty, error, and permission states.

## UI Defaults

- Prefer calm, dense, legible product screens over marketing composition.
- Use plain nouns and verbs from the domain, not generic SaaS abstractions.
- Treat copy as part of the interface: labels, empty states, confirmation text, and errors should do work.
- Keep navigation proportional to the product's real surface area.
- Avoid dashboards, settings, filters, roles, and customization until the core workflow needs them.
- Prefer Rails/Hotwire-friendly server-rendered interactions unless the target app already has another frontend contract.

## Concrete Screen Shape

- Start with one workbench page around the main object and action.
- Use tabs only for distinct, frequent jobs; three obvious tabs are usually more credible than five vague ones.
- Start filters as search plus one or two meaningful states; add advanced filters only when volume proves it.
- Move settings away from the main workflow unless a setting is required to complete the job.
- Include finished edge states: empty, loading, validation failure, no permission, no matching results, archived/closed records, and duplicate-prevention paths.

## Review Lens

- What is the user trying to finish?
- Is the main object obvious without explanatory text?
- Does the screen get deeper or merely wider?
- Can the interface remove a decision, step, or setting?
- Are edge states designed, not left to default framework behavior?
- Does the implementation match the intended product feel?

## Boundaries

Ask before rebranding, deleting committed workflows, introducing a new frontend framework, or replacing a design system. Avoid persona imitation; use source-grounded heuristics and explain tradeoffs.
