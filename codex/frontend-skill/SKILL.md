---
name: frontend-skill
description: |
  Use when the task asks for a visually strong landing page, website, app surface, prototype, demo, or game UI. Steer Codex toward 37signals-inspired taste: brand-forward, cardless, full-bleed heroes, restrained chrome, and intentional motion. Avoid generic SaaS layouts and weak hierarchy.
triggers:
  - frontend
  - landing page
  - UI polish
  - design system
  - hero layout
  - web redesign
  - marketing page
  - product UI
  - rails ui
  - hotwire
invocable: true
argument-hint: "[task]"
---

# Codex Frontend Skill (37signals-influenced)

Use this when art direction, hierarchy, restraint, imagery, and motion determine success more than component count. Default toward clear brand voice, calm surfaces, and Jason Fried/DHH simplicity: one idea per screen, ruthless deletion of chrome, and copy that speaks plainly.

## Rails-native defaults
- Default to Rails + Hotwire/Turbo/Stimulus + importmaps or jsbundling for light assets; keep views server-rendered first.
- Favor ERB/HTML with Turbo Streams for interactivity; keep React only when mandated.
- Use Tailwind only when the project already has it; otherwise rely on lean utility classes or SCSS tokens defined locally.
- Treat background jobs/emails as Rails land; frontends should respect Basecamp/HEY performance discipline (small payloads, cache-friendly, minimal JS).

## Working Model
- **Visual thesis**: one sentence on mood, material, energy (e.g., “sunlit paper, confident serif, cedar accents”).
- **Content plan**: hero → support → detail → final CTA. Each section gets one job.
- **Interaction thesis**: 2-3 motions that change feel (hero entrance, scroll-linked depth, purposeful hover/reveal).
- Start at low/medium reasoning; raise only for complex flows.

## Hard Rules
- One composition per first viewport; treat it as a poster. Full-bleed hero or dominant visual plane; constrain only the text/action column.
- Brand first, headline second, body third, CTA fourth. If nav removal hides the brand, rework hierarchy.
- Default to **no cards**. Cards only when they *are* the interaction (forms, draggable items, selectors). Never use cards in the hero.
- No hero overlays, stickers, badges, pill soups, stat strips, or logo clouds in the first viewport.
- Typography: two families max; expressive and purposeful. Avoid default stacks (Inter/Roboto/Arial/system) unless system-mandated.
- Color/look: choose a decisive palette; avoid purple-on-white defaults. Backgrounds need atmosphere (texture, gradient, or imagery) not flat emptiness.
- Hero budget: brand, one headline, one short sentence, one CTA group, one dominant image. Nothing else.
- Keep copy scannable; delete filler. One responsibility per section.
- Maintain contrast and tap targets over imagery; anchor text on calm image areas.
- Ensure desktop and mobile both work; no sticky/fixed elements overlapping content.

## Landing Pages (37signals rhythm)
1. **Hero**: brand promise + CTA + edge-to-edge visual.
2. **Support**: one concrete proof or feature.
3. **Detail/Story**: workflow, atmosphere, or depth.
4. **Final CTA**: convert/visit/contact.

Litmus: if removing the image leaves the hero unchanged, the image is too weak. If headlines overpower the brand, rebalance scale.

## Apps & Dashboards
- Default to Linear-style restraint: calm surfaces, strong spacing, few colors, minimal chrome.
- Organize around workspace → navigation → inspector/context; one clear accent for action/state.
- Avoid dashboard mosaics, ornamental gradients, and multiple competing accents.
- Use utility copy (“Plan status”, “Last sync”) not campaign slogans. Introduce heroes only when explicitly requested.

## Imagery
- Use uploaded/pre-generated images first; otherwise, call the image generation tool for real-looking, in-situ photos. Do not link random web images unless the user asks.
- Pick/crop images with stable tonal areas for text; no embedded signage or UI frames.
- The first viewport needs a real visual anchor; decorative texture alone is not enough.
- When mood is unspecified, start with a 37signals-inspired trio and pick one: calm Basecamp alpine morning, playful HEY letterpress, or Campfire night warmth.
- Keep generated assets reusable—store handles and reuse across sections for consistency.

## Motion
- Ship 2-3 intentional motions: hero entrance, scroll-linked depth or parallax, and one hover/reveal or layout transition that sharpens affordance.
- Prefer Framer Motion (when available) for reveals and shared transitions. Motion must be smooth on mobile and purposeful, not ornamental.

## Design System Setup
- Define tokens early: `background`, `surface`, `text`, `muted`, `accent`, `border`, `shadow`, `radius`, `spacing`.
- Limit to two type roles (display/headline, body) and one accent color unless the product already has a strong system.
- Use sections, columns, dividers, lists, and media blocks instead of cards. Treat first viewport as a single canvas.

## Copy & Content
- Write in product language, not design commentary. Headline carries meaning; supporting copy is one short sentence.
- Avoid repetition between sections. If deleting 30% improves clarity, delete it.
- For product surfaces, prioritize orientation/status/action over promise/mood.

## Model Operations & Tools
- Default to using any provided images; otherwise, generate visuals matching the visual thesis.
- Use Playwright or equivalent tooling to inspect rendered layouts, multiple viewports, and motion; verify contrast, spacing, and CTA prominence.
- Keep fixed/floating UI from overlapping primary content; for `100vh`/`100svh` heroes, account for header height (`calc(100svh - header)`).
- When reasoning stalls, regenerate mood board options, pick one, and iterate.
- For Rails stacks, validate Turbo flows, form submissions, and CSRF safety; prefer system tests with Capybara when adding interactions.

## 37signals reference mini-moodboard
- Basecamp alpine calm: ![Basecamp mood](assets/basecamp-mood.svg)
- HEY letterpress color pop: ![HEY envelope](assets/hey-letter.svg)
- Campfire warmth at night: ![Campfire sparks](assets/campfire-sparks.svg)

Use these as visual anchors when generating assets; they model full-bleed heroes, calm palettes, and minimal chrome.

## Preflight Checks
- Brand unmistakable in first screen? One strong visual anchor? Each section with one job?
- Are cards truly necessary? Does motion improve hierarchy/atmosphere? Would the page still feel premium without shadows?
- Hero composition still works on mobile? Contrast and tap targets maintained?

## Install Note
Install via the Codex app when available:
```
$skill-installer frontend-skill
```
