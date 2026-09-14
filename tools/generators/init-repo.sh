#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Initializing repository: Principal Engineer Accelerator Path"

REPO_NAME="principal-engineer-accelerator"

if [ -d "$REPO_NAME" ]; then
  echo "⚠️  Directory '$REPO_NAME' already exists. This script is idempotent:"
  echo "    it will only create what's missing, without overwriting existing content."
else
  mkdir -p "$REPO_NAME"
fi

cd "$REPO_NAME"

# ── Folder structure ─────────────────────────────────────────────────────
# NOTE ON LANGUAGE POLICY:
#   - Repo infrastructure (this script, README, roadmap, dashboard,
#     current-state, learning-journal) -> English.
#   - Session content in docs/ (Theory, Session, ADR files) -> Spanish
#     (generated per-session in its own conversation/script).
#   - Published site/ -> BILINGUAL. Every session page ships as both
#     <code>.es.html and <code>.en.html (e.g. S001.es.html / S001.en.html).
mkdir -p docs/roadmap
mkdir -p docs/theory
mkdir -p docs/sessions
mkdir -p docs/adrs
mkdir -p docs/exercises
mkdir -p site/theory
mkdir -p site/sessions
mkdir -p site/adrs
mkdir -p site/assets
mkdir -p .github/workflows

# ── README.md ────────────────────────────────────────────────────────────
if [ ! -f README.md ]; then
cat << 'EOF' > README.md
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
EOF
echo "  ✓ README.md created"
fi

# ── .gitignore ───────────────────────────────────────────────────────────
if [ ! -f .gitignore ]; then
cat << 'EOF' > .gitignore
.DS_Store
*.log
node_modules/
EOF
echo "  ✓ .gitignore created"
fi

# ── Initial dashboard ────────────────────────────────────────────────────
if [ ! -f docs/dashboard.md ]; then
cat << 'EOF' > docs/dashboard.md
# Principal Engineer Accelerator Path - Dashboard

## Total Progress
- **Total Sessions (unique, all tracks combined):** 126
- **Completed Sessions:** 0
- **Total ADRs:** 0
- **Overall Completion:** 0.00%

## Phase Breakdown (unique sessions per phase)
| Phase | Total Sessions | Completed | Progress |
| :--- | :---: | :---: | :---: |
| Phase 1: Engineering Foundations | 45 | 0 | 0.00% |
| Phase 2: Architecture & Distributed Systems | 24 | 0 | 0.00% |
| Phase 3: AI Engineering & AI Architecture | 26 | 0 | 0.00% |
| Phase 4: Product & Business Thinking | 15 | 0 | 0.00% |
| Phase 5: Technical Leadership & Strategy | 16 | 0 | 0.00% |

## Progress by Track (includes shared foundations, 69 sessions each)
| Track | Total Sessions | Completed | Progress |
| :--- | :---: | :---: | :---: |
| Staff Software Engineer | 82 | 0 | 0.00% |
| Architect | 77 | 0 | 0.00% |
| Product AI | 105 | 0 | 0.00% |
EOF
echo "  ✓ docs/dashboard.md created"
fi

# ── Initial current state ────────────────────────────────────────────────
if [ ! -f docs/current-state.md ]; then
cat << 'EOF' > docs/current-state.md
# Current State

- **Active Track:** (to be defined: Staff / Architect / Product AI)
- **Current Phase:** (not started)
- **Current Module:** (not started)
- **Current Session:** (not started)
- **Last Session Completed:** (none)
- **Next Session:** S001 - Monolithic Architecture Style

> This file is updated manually after each session and re-uploaded to the
> Claude Project's knowledge base to maintain continuity across
> conversations.
EOF
echo "  ✓ docs/current-state.md created"
fi

# ── Initial learning journal ─────────────────────────────────────────────
if [ ! -f docs/learning-journal.md ]; then
cat << 'EOF' > docs/learning-journal.md
# Learning Journal

Cumulative learning log. Each session appends here — never overwrites
previous entries. Log entries themselves may be written in Spanish
(matching the session content), while this header stays in English.
EOF
echo "  ✓ docs/learning-journal.md created"
fi

# ── site/assets/styles.css (MOBILE-FIRST) ────────────────────────────────
if [ ! -f site/assets/styles.css ]; then
cat << 'EOF' > site/assets/styles.css
/* Mobile-first base: no max-width, generous tap targets, single column */
* { box-sizing: border-box; }

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  line-height: 1.6;
  margin: 0;
  padding: 1rem;
  color: #1e293b;
  font-size: 16px; /* never smaller on mobile — avoids iOS auto-zoom on inputs */
}

h1 {
  color: #0f172a;
  border-bottom: 2px solid #e2e8f0;
  padding-bottom: 0.5rem;
  font-size: 1.4rem;
  line-height: 1.3;
}

h2 { font-size: 1.15rem; }
h3 { font-size: 1rem; }

.card {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
}

a {
  color: #2563eb;
  text-decoration: none;
  font-weight: 600;
  padding: 0.15rem 0; /* larger tap target on mobile */
}

.lang-toggle {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  font-size: 0.95rem;
  margin-bottom: 0.75rem;
}

/* Tables: wrap in a scrollable container instead of squishing on mobile */
.table-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  margin: 1rem 0;
  -ms-overflow-style: none;
}

table {
  border-collapse: collapse;
  width: 100%;
  min-width: 480px;
  font-size: 0.9rem;
}

th, td {
  padding: 0.6rem 0.75rem;
  border: 1px solid #d3d8de;
  text-align: left;
}

thead { background: #eef1f4; }

ul, ol { padding-left: 1.25rem; }

code {
  font-size: 0.9em;
  background: #f1f5f9;
  padding: 0.1rem 0.35rem;
  border-radius: 4px;
  word-break: break-word;
}

pre {
  overflow-x: auto;
  background: #334155;
  color: #f1f5f9;
  padding: 1rem;
  border-radius: 6px;
  font-size: 0.85rem;
}

/* Larger screens: apply the desktop layout on top of the mobile base */
@media (min-width: 640px) {
  body {
    max-width: 900px;
    margin: 0 auto;
    padding: 2rem;
    font-size: 15px;
  }
  h1 { font-size: 1.875rem; }
  h2 { font-size: 1.3rem; }
  table { font-size: 1rem; }
}
EOF
echo "  ✓ site/assets/styles.css created (mobile-first)"
fi

# ── site/index.en.html (English landing page) ────────────────────────────
if [ ! -f site/index.en.html ]; then
cat << 'EOF' > site/index.en.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Principal Engineer Accelerator Path</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
  <div class="lang-toggle"><a href="index.es.html">Español</a></div>
  <h1>Principal Engineer Accelerator Path</h1>
  <p>Progress dashboard. Will update as sessions are completed.</p>
  <ul id="session-list">
    <!-- Links to each session are added here as sessions are generated -->
  </ul>
</body>
</html>
EOF
echo "  ✓ site/index.en.html created"
fi

# ── site/index.es.html (Spanish landing page) ────────────────────────────
if [ ! -f site/index.es.html ]; then
cat << 'EOF' > site/index.es.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Principal Engineer Accelerator Path</title>
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body>
  <div class="lang-toggle"><a href="index.en.html">English</a></div>
  <h1>Principal Engineer Accelerator Path</h1>
  <p>Dashboard de progreso. Se actualizará a medida que se completen sesiones.</p>
  <ul id="session-list">
    <!-- Los links a cada sesión se agregan aquí a medida que se generan -->
  </ul>
</body>
</html>
EOF
echo "  ✓ site/index.es.html created"
fi

# ── site/index.html (redirect to English by default) ────────────────────
if [ ! -f site/index.html ]; then
cat << 'EOF' > site/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0; url=index.en.html">
  <title>Principal Engineer Accelerator Path</title>
</head>
<body>
  <p>Redirecting… / Redirigiendo… <a href="index.en.html">English</a> ·
  <a href="index.es.html">Español</a></p>
</body>
</html>
EOF
echo "  ✓ site/index.html (redirect) created"
fi

# ── GitHub Actions workflow for Pages ─────────────────────────────────────
if [ ! -f .github/workflows/pages-deploy.yml ]; then
cat << 'EOF' > .github/workflows/pages-deploy.yml
name: Deploy Site to GitHub Pages

on:
  push:
    branches: [main]
    paths:
      - 'site/**'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './site'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOF
echo "  ✓ .github/workflows/pages-deploy.yml created"
fi

# ── Roadmap placeholders (overwritten once real files are added) ────────
for f in roadmap-master track-staff track-architect track-product-ai; do
  if [ ! -f "docs/roadmap/${f}.md" ]; then
    echo "# ${f} (placeholder — replace with official content)" > "docs/roadmap/${f}.md"
    echo "  ✓ docs/roadmap/${f}.md (placeholder) created"
  fi
done

echo ""
echo "✅ '$REPO_NAME' structure generated successfully."
echo ""
echo "Manual next steps:"
echo "  1. Copy the real content of roadmap-master.md, track-staff.md,"
echo "     track-architect.md and track-product-ai.md into docs/roadmap/"
echo "     (the full files are generated separately, not by this script)."
echo "  2. cd $REPO_NAME && git init && git add . && git commit -m 'Initial structure'"
echo "  3. Create the repo on GitHub and push to 'main'."
echo "  4. On GitHub -> Settings -> Pages -> Source -> 'GitHub Actions'."
