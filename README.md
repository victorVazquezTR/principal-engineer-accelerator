# Principal Engineer Accelerator Path

Self-directed study program to reach Principal Engineer level, structured
in 3 parallel tracks (Staff Software Engineer, Architect, Product AI) on
top of a shared foundations base.

## Language policy

- Repo infrastructure (this README, scripts, roadmap docs, dashboard,
  current-state, learning journal) is in **English**.
- Session content under `docs/` (theory, exercises, ADRs) is authored in
  **Spanish** — that's the working language for study sessions.
- The published site (`site/`) is **bilingual**: every session page ships
  as both `<code>.es.html` (Spanish) and `<code>.en.html` (English), so
  the material is usable regardless of reading language.

## Structure

- `docs/` — source of truth in Markdown (roadmap, theory, sessions, ADRs, progress)
- `site/` — static HTML version published to GitHub Pages (bilingual)
- `generate-session-XXX.sh` — one idempotent script per session (added as
  each session is generated; not created by this initial script)

## Roadmap and progress

- Full roadmap (126 unique sessions, 5 phases, 15 modules):
  `docs/roadmap/roadmap-master.md`
- Track-filtered views: `docs/roadmap/track-staff.md`,
  `docs/roadmap/track-architect.md`, `docs/roadmap/track-product-ai.md`
- Current progress: `docs/current-state.md`
- Dashboard: `docs/dashboard.md`
- Learning journal: `docs/learning-journal.md`

## How to generate a session

Each session has its own script, generated in its corresponding
conversation inside the Claude Project:

    ./generate-session-XXX.sh

Each script is idempotent: it can run multiple times without duplicating
content, overwriting only that specific session's artifacts. It generates
Spanish content in `docs/` and both language versions in `site/`.

## Publishing

The contents of `site/` are automatically published to GitHub Pages via
`.github/workflows/pages-deploy.yml` on every push to `main`.

**IMPORTANT:** for publishing to actually work, go to GitHub →
Settings → Pages → Source and select "GitHub Actions" (not
"Deploy from branch"). This step is manual and cannot be automated from
this script.
