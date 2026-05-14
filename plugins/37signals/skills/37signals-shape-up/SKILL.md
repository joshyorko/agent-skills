---
name: 37signals-shape-up
description: >-
  Use when shaping a raw product idea, feature request, spike, or project into
  a 37signals-inspired pitch with appetite, problem, solution sketch, rabbit
  holes, no-gos, risks, and a clear build/no-build recommendation.
---
## Source Grounding

Community-maintained and 37signals-inspired, not official Basecamp guidance. Read `../../references/basecamp-style.md`; user constraints and current project truth win.

# 37signals Shape Up

Shape before planning. The output is not a backlog ticket dump; it is a small decision artifact that makes the bet, appetite, boundaries, and risks clear enough to decide whether to build.

## Workflow

1. State the raw idea in one sentence.
2. Name the appetite: tiny spike, one-day patch, one-week feature, or larger cycle.
3. Define the problem and the user-visible progress that would count.
4. Sketch the solution at the interface/domain level, not task-by-task implementation.
5. List rabbit holes that could consume the appetite.
6. List no-gos: what this intentionally will not solve.
7. Decide: bet, reshape smaller, research first, or reject.

## Pitch Shape

- **Problem:** what hurts and for whom.
- **Appetite:** fixed time and why that amount is enough.
- **Solution:** a concrete sketch of the core interaction, object model, or workflow.
- **Boundaries:** no-gos and explicit non-goals.
- **Rabbit holes:** unknowns, integration traps, migration traps, and ambiguous ownership.
- **Circuit breaker:** what to cut or stop if the appetite is exceeded.

## Defaults

- Prefer one shaped pitch over many backlog items.
- Prefer the smallest version that makes the product meaningfully better.
- Keep research separate from build scope when the unknown is still too large.
- Reject ideas that only add surface area, coordination, or settings without core value.

## AI Feature Checks

When shaping AI-backed work, explicitly decide:

- What source data the output may use and how the user can inspect it.
- Whether the first version can be deterministic if generation quality misses the appetite.
- Where human review is required before sending, publishing, deleting, or changing records.
- What permissions, tenant boundaries, prompt/data retention, and cost controls must exist before shipping.

## Output Contract

Return the pitch, the recommendation, and the next smallest validation step. Do not turn a shaped pitch into an implementation plan unless the user asks.
