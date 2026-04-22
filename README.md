# 🎓 Moving to the States — Ananto's Relocation Registry

A personal gift registry for Nazmul Islam Ananto's move from Dhaka, Bangladesh to State College, PA to begin his PhD in Computer Science at Penn State (August 2026). Friends and family can browse items, contribute money via local/international payment methods, or purchase and ship gifts directly.

**Live site → [niananto.github.io/relocation-gift-registry](https://niananto.github.io/relocation-gift-registry/)**

---

## Features

### Public Registry

- **Browse & filter** — Items organised into four categories: Essentials, Kitchen, Tech, Furniture & Decor
- **Currency toggle** — Switch between USD ($) and BDT (৳) with a fixed 125 BDT/USD rate
- **Cash gift** — Open-ended contribution with no specific item attached
- **Group gifts** — Multiple people can contribute toward a shared item; a progress bar tracks the raised amount
- **Contribution flow** — Modal-driven, two paths:
  - *Buy & ship*: contributor enters name, email, and message; Bangladesh and US mailing addresses are shown
  - *Send money*: contributor enters name, email, amount, transaction ID/reference, and an optional screenshot
- **Payment methods** — Four copyable payment options with full account details:
  - bKash (BDT)
  - NPSB / Bank Transfer via BRAC Bank (BDT)
  - ACH / Wire via Regent Bank (USD)
  - SWIFT / Wire via BRAC Bank (USD)
- **Confirmation email** — Automatic EmailJS confirmation sent to the contributor on successful submission
- **Thank You Wall** — Displays all confirmed contributions with contributor name, item, method badge, amount, and personal message
- **Floating navigation** — Scroll-to-top and scroll-to-bottom buttons appear while scrolling
- **Responsive design** — Mobile-first; same HTML file serves both layouts

### Admin

| URL | Purpose |
|-----|---------|
| `/admin` | Session-aware entry point — redirects to login or dashboard |
| `/admin-login.html` | Email + password login via Supabase Auth |
| `/admin-dashboard.html` | Full admin panel |

**Dashboard tabs:**

- **Inventory** — Full CRUD for registry items; filter by type (individual / group gift)
- **Contributions** — Search and manage all contributions; update status (pending → confirmed → cancelled)
- **Add New / Edit** — Item form with all fields

**Item fields:** title, description, price (USD), category, image (URL or file upload), group gift toggle, sort order

**Stats tiles:** cash raised, registry funding progress (% of goal), items claimed

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Pure HTML + Tailwind CSS (CDN) — no build step |
| Database | Supabase (Postgres + PostgREST) |
| Auth | Supabase Auth (email + password) |
| Email | EmailJS SDK v4 |
| Hosting | GitHub Pages |
| CI/CD | GitHub Actions |

---

## Project Structure

```
├── index.html               # Public registry (browse, contribute, thank you wall)
├── admin.html               # Session-check redirect (→ dashboard or login)
├── admin-login.html         # Admin login page
├── admin-dashboard.html     # Unified admin panel (inventory + contributions)
├── admin-gifts.html         # Legacy URL — redirects to admin-dashboard.html
├── admin-transactions.html  # Legacy URL — redirects to admin-dashboard.html
├── config.js                # Runtime config (gitignored — injected by CI or created locally)
├── config.example.js        # Config template to copy for local development
├── setup.sql                # One-time DB schema reference (already applied)
└── .github/workflows/
    └── deploy.yml           # GitHub Actions: inject config + deploy to Pages
```

---

## Local Setup

```bash
git clone https://github.com/niananto/relocation-gift-registry.git
cd relocation-gift-registry
cp config.example.js config.js
# Fill in your values in config.js
# Open index.html in a browser or serve with any static file server
npx serve .
```

---

## GitHub Actions Setup

Push to `main` automatically deploys to GitHub Pages. The workflow injects `config.js` from repository-level variables and secrets.

**Required GitHub Variables** (`Settings → Secrets and variables → Actions → Variables`):

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `EMAILJS_PUBLIC_KEY` | EmailJS account public key |
| `EMAILJS_SERVICE_ID` | EmailJS service ID |
| `EMAILJS_TEMPLATE_ID` | EmailJS template ID |
| `BD_MAILING_ADDRESS` | Bangladesh shipping address (shown to contributors) |
| `US_MAILING_ADDRESS` | US shipping address (shown to contributors) |

**Required GitHub Secret** (`Settings → Secrets and variables → Actions → Secrets`):

| Secret | Description |
|--------|-------------|
| `SUPABASE_PUBLISHABLE_KEY` | Supabase publishable key (`sb_publishable_...`) |

Enable GitHub Pages under `Settings → Pages → Source: GitHub Actions` before the first deploy.

---

## Database

See `setup.sql` for the full schema. Two tables:

**`items`** — Registry items  
`id`, `title`, `description`, `category`, `price`, `image_url`, `status` (available / claimed / partial), `is_group_gift`, `goal_amount`, `raised_amount`, `sort_order`, `priority`, `notes`, `claimed_by`

**`contributions`** — Contribution records  
`id`, `contributor_name`, `contributor_email`, `item_id` (nullable for cash gifts), `amount`, `method` (gift / money), `transaction_ref`, `message`, `status` (pending / confirmed / cancelled)

RLS is enabled; anonymous users have full read/write access (acceptable for a personal site).

---

## Possible Extensions

### 1. Multi-claim items
Allow an item to be claimed by more than one person. The admin sets a `max_claims` integer on the item; the item's status only transitions to `claimed` once that count is reached. Requires a new `max_claims` column on `items` and a claim-count check in the contribution submission logic.

### 2. "Where to buy" links
Add a `buy_url` field to items — a link (or comma-separated list) to retailers where the item can be purchased. Displayed as a *"Buy it here"* button on the registry card and included in the confirmation email for contributors who choose the *buy & ship* path.

### 3. Admin notification emails
Trigger an EmailJS (or Supabase Edge Function) email to Ananto whenever a new contribution is submitted, so he can verify and confirm without manually checking the dashboard.

### 4. Automated thank-you emails on confirmation
When the admin marks a contribution as `confirmed` in the dashboard, automatically send a personalised thank-you email back to the contributor via a Supabase Database Webhook → Edge Function → EmailJS pipeline.

### 5. Gift reservation / hold
Add a *"Reserve for 24 hours"* button so a contributor can soft-lock an item while they complete the payment, preventing accidental double contributions. Requires a `reserved_until` timestamp column on `items` and a periodic cleanup job (Supabase Cron) to expire stale holds.

### 6. Priority badges on the public registry
Expose the existing `priority` field (high / medium / low, already in the DB) as a visual badge on registry cards — e.g. a ⭐ or coloured label — so contributors can quickly spot the most-needed items.

### 7. Image upload to Supabase Storage
Replace the URL-based image input with direct file upload to a Supabase Storage bucket, removing the dependency on external image hosting and making image management self-contained.
