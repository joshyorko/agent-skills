---
name: 37signals-stimulus
description: >-
  Use when adding Stimulus behavior, progressive enhancement, DOM controllers,
  form interaction, importmap/npm choices, or JavaScript simplification.
license: MIT
metadata:
  author: agent-skills
  version: "1.0"
  source: public-basecamp-style-synthesis
  compatibility: Stimulus 3.2+, Turbo 8+, Importmap
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; target frontend stack wins.

# Stimulus

Use Stimulus to enhance server-rendered HTML. Keep controllers small enough to understand, but domain-specific controllers are fine when product behavior is cohesive.

## Workflow

1. Inspect existing controllers, import path, build system, Turbo usage, data attributes, tests/system tests, and accessibility behavior.
2. Decide whether behavior belongs in HTML/Turbo first. Add Stimulus only for client-side interaction.
3. Name controllers after behavior or domain concept, not implementation detail.
4. Use targets, values, classes, and actions instead of manual DOM spelunking when possible.
5. Follow the app's dependency path: importmap, jsbundling, npm, or existing vendor assets.
6. Verify in browser/system tests for keyboard, focus, Turbo navigation, and reconnect behavior.

## Guardrails

- Ask before adding npm packages, changing build tooling, or introducing a frontend framework.
- Do not put authorization or canonical state only in JavaScript.
- Do not assume importmap can load arbitrary npm-only packages.
- Do not let Stimulus duplicate server-rendered truth.

## Output

State controller name, DOM contract, dependency path, accessibility/browser checks, and unverified UI risk.
