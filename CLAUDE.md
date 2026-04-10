# goodbye-ananto

Personal relocation registry site for Ananto's move from Dhaka, Bangladesh to Penn State (PhD in CS, August 2026). Friends and family can browse items and submit contributions.

## Stack
- Pure static HTML + Tailwind CSS (CDN) — no build step, no framework
- Supabase for data (project: `sngvyjzlwzvxjrxclflb`)
- Hosted on GitHub Pages, deployed via GitHub Actions

## Files
- `index.html` — public registry (browse items, submit contributions)
- `admin-gifts.html` — admin: add/edit/delete registry items
- `admin-transactions.html` — admin: view contributions
- `config.js` — **gitignored**, holds `SUPABASE_URL` and `SUPABASE_KEY`
- `config.example.js` — safe template committed to git
- `setup.sql` — one-time DB setup reference (already applied via MCP)
- `.github/workflows/deploy.yml` — injects secrets and deploys to GitHub Pages

## Supabase
- Tables: `items`, `contributions`
- RLS: anon has full access to both tables (acceptable for a personal site)
- Key: publishable key (`sb_publishable_...`) — one key used everywhere, no service role key in client code
- MCP server configured in `.mcp.json`

## Design system
- Colors: Material Design 3 tokens, primary `#93452d` (terracotta), surface `#fff8f5` (warm cream)
- Fonts: Noto Serif (headings), Plus Jakarta Sans (body)
- Icons: Material Symbols Outlined
- Responsive breakpoint: `md:` (768px) — mobile-first, same HTML file serves both layouts
- Mobile: fixed top header (56px) + fixed bottom nav + `pt-14 pb-24` on main
- Desktop: fixed left sidebar (w-64) + `md:ml-64` on main

## GitHub Actions secrets needed
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
