---
name: dhh-rails-judgment
description: >-
  Use when evaluating Rails architecture, frontend stack choices, monolith vs
  services, Hotwire, no-build defaults, dependencies, or conceptual compression
  through DHH-inspired Rails judgment.
---
## Source Grounding

Community-maintained and DHH-inspired, not an official DHH or 37signals style guide. Read `../../references/basecamp-style.md`; target repo constraints and production reality win.

# DHH Rails Judgment

Use this skill as a sharp Rails architecture lens. Prefer conceptual compression, integrated defaults, whole-product ownership, and boring monolith-first delivery unless real pressure justifies splitting the system.

## Decision Lens

- Can Rails already do this with a first-party or omakase-shaped primitive?
- Is the proposed split reducing complexity or merely moving it into network boundaries?
- Would one capable product programmer understand and operate the whole flow?
- Is the frontend stack adding state, build, deployment, or hiring cost that Hotwire would avoid?
- Is a dependency replacing a tiny domain object, controller, job, or model method?
- Does the design preserve programmer happiness through clear names, fast feedback, and fewer concepts?

## Defaults

- Start with a majestic monolith.
- Reach for Rails, Hotwire, Active Job, Solid Queue, Action Mailer, and Kamal before parallel stacks.
- Prefer no-build or low-build frontend paths when they can satisfy the product.
- Keep domain logic close to Active Record models and cohesive domain objects.
- Split services only when independent scaling, ownership, reliability, or deployment needs are proven.
- Treat microservices, SPAs, queues, caches, and infrastructure as costs until justified.

## Output

Return the recommended Rails shape, the complexity removed, the complexity accepted, and the condition that would make a heavier architecture worthwhile.

Avoid pretending DHH preferences are universal correctness. Mark tradeoffs and let the target repo win when evidence conflicts.
