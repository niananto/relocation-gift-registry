-- ============================================================
-- Run this in the Supabase SQL Editor (one-shot setup)
-- Project: goodbye-ananto registry
-- ============================================================

-- 1. TABLES

CREATE TABLE IF NOT EXISTS items (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at    TIMESTAMPTZ DEFAULT now(),
  title         TEXT        NOT NULL,
  category      TEXT        NOT NULL,          -- essentials | kitchen | clothing | transport | tech
  price         NUMERIC,
  description   TEXT,
  image_url     TEXT,
  status        TEXT        DEFAULT 'available'
                            CHECK (status IN ('available','claimed','partial')),
  claimed_by    TEXT,
  goal_amount   NUMERIC,                       -- for group gifts
  raised_amount NUMERIC     DEFAULT 0,
  is_group_gift BOOLEAN     DEFAULT false,
  priority      TEXT        DEFAULT 'medium',
  notes         TEXT,                          -- admin-only notes
  sort_order    INT         DEFAULT 0
);

CREATE TABLE IF NOT EXISTS contributions (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at        TIMESTAMPTZ DEFAULT now(),
  contributor_name  TEXT        NOT NULL,
  contributor_email TEXT,
  item_id           UUID        REFERENCES items(id) ON DELETE SET NULL,
  amount            NUMERIC,
  transaction_ref   TEXT,
  message           TEXT,
  status            TEXT        DEFAULT 'pending'
                                CHECK (status IN ('pending','confirmed','cancelled'))
);

-- 2. ROW LEVEL SECURITY

ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;

-- Public can read items; nobody (anon) can write — service role bypasses RLS
CREATE POLICY "items_public_read" ON items
  FOR SELECT TO anon USING (true);

-- Public can submit contributions but not read others'
CREATE POLICY "contributions_public_insert" ON contributions
  FOR INSERT TO anon WITH CHECK (true);

-- 3. SEED DATA — items

INSERT INTO items
  (title, category, price, description, image_url,
   status, claimed_by, goal_amount, raised_amount, is_group_gift, priority, sort_order)
VALUES
(
  'Cloud Comfort Sectional', 'essentials', 2800,
  'A place to rest and host friends in my new living room. This is my biggest priority for the home.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuA5b2JPH85oJxivMaut2bbF28qNeqOhHyn5tLHvA30lBtD7Ts7f7-PbxmvyBORXTGiGhhGLtHW8uGiyTCXHxY4Oq7l7Gza71U56n3xoU_6FmbI-_XmVpXGhtveMoDvaYXlgVdk5fk3rofHgfQTrV7j_wqfD9SuFf4biDN_C-XrQF8kFXA9GjRHM86C0RlYe4asBbegbeKgdGx25-jQ0TrWUX5QraET7rss4q8uOLsETw12nwo-kL0emHIFKKXxKOFvi74ZLdZDGVsE',
  'partial', NULL, 2800, 1250, true, 'high', 1
),(
  'Essential Kitchen Tool Set', 'kitchen', 85,
  'Wooden utensils and heat-resistant silicone tools for every meal I cook in my new kitchen.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuAMfpnXTz2mLxJ2mFbc_E78nTldRCoeMPnwAR2aqQpXXerQ7n0AaIOsu1TBZS6XCIfvrF1h9ATW3XP_rEX02zd4qz9XIhizxDTcTOPQqRFgJRPIM2GT9uPKB5xCwhIQ_dHhJl_I3CIep_oCLm2yDfuY_dbtDR3Cw-Cpz4fcwHrCeP5_LtEB73cs2ntHsFwj9eAK8JFSsMRk6LTudnRFW18r5GoV1sECpdITT6b8jx6MtlZ9fmqBOQLI3JP1GRiUZBYKOurwM6lptXg',
  'available', NULL, NULL, 0, false, 'medium', 2
),(
  'Morning Ritual Espresso', 'kitchen', NULL,
  'High-pressure extraction for the perfect start to my American mornings.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuCFkt_J588VgOmeY9sL198llcIIT91RmnbO_Y2oDnqqb5jXviyel9ocshD5j1c4hz3m_T3c74fDZWBe-mBBjbvDt7ubrvbb9fSyl4rkAAYy25rk6oFtdZVAvPf-Ai7KjPABE-Yz0etf7cMbOm_UOJZ_HmKX3KI-W8GWXXoL2XTEhsZ50qiDuk5A7R7iL9GT91jWIyrNrnhWlEfbLygjPmTuaTzNfrY8BsEQKKoL-sUIWooBsQ4ciWAqvUFVhB0iSB20C7HSqpdQMro',
  'claimed', 'Sarah', NULL, 0, false, 'medium', 3
),(
  'Organic Linen Bedding', 'essentials', 150,
  'Breathable, soft linen — Twin XL for the dorm room. Pennsylvania winters are cold.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuAHMgTXzrEYNSBfdO4WSxr2wcPhwRgkSmnFGOKQgUYbbAJwU5uHPtGDfsqb8zypB9pnuOrF8xOOyIYxndX-F7zslNLfZIq9__JQWEPmM4vxBEc0ITUxW1uedQ1wuNJVJr4w1UeCgKU3L4l4GyWX68OK-S8zDcr5q2In-s7bvxiP_XK_zFgC-gf9RJlV8L8',
  'available', NULL, NULL, 0, false, 'medium', 4
),(
  'Cloud-Touch Towel Set', 'essentials', 45,
  'Plush, high-absorbency organic cotton towels for a spa-like experience at home.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuA6gL66kjrYCCZqNoGL5qLlkpDanZecW9xhvAEXM2QvxTxYvPrWKUGCptCzuTD1prkfh1wygAKro5Q-cw37GiaxnrBN4ALZ8vPJ547Lz7lkvvOZ3DGNkat1aUjjbHXXo7l8t20HASt3qSGR_6MUnPJ5i936QkcTMX6-1jXe7PzmUued2yCj888FBP5orNllhXD7Ft-nhEZ6paal3KetMozQE-V1PNYFTgkSXkMzf0Ls0B5jr0q0s8c4h6TC7oY8Py_2eZU9TaVRSDA',
  'available', NULL, NULL, 0, false, 'medium', 5
),(
  'Winter Jacket', 'clothing', 120,
  'State College hits -10°C. I''ve never owned a real winter coat — this is the most critical item.',
  'https://lh3.googleusercontent.com/aida-public/AB6AXuAMfpnXTz2mLxJ2mFbc_E78nTldRCoeMPnwAR2aqQpXXerQ7n0AaIOsu1TBZS6XCIfvrF1h9ATW3XP_rEX02zd4qz9XIhizxDTcTOPQqRFgJRPIM2GT9uPKB5xCwhIQ_dHhJl_I3CIep_oCLm2yDfuY_dbtDR3Cw-Cpz4fcwHrCeP5_LtEB73cs2ntHsFwj9eAK8JFSsMRk6LTudnRFW18r5GoV1sECpdITT6b8jx6MtlZ9fmqBOQLI3JP1GRiUZBYKOurwM6lptXg',
  'available', NULL, NULL, 0, false, 'high', 6
);

-- 4. SEED DATA — sample contributions

INSERT INTO contributions
  (contributor_name, contributor_email, item_id, amount, transaction_ref, message, status)
SELECT
  'Sarah Jenkins', 'sarah@example.com',
  (SELECT id FROM items WHERE title = 'Cloud Comfort Sectional'),
  250, 'TXN-SJ-2026-001', 'Wishing you all the best in Pennsylvania!', 'confirmed'
UNION ALL SELECT
  'Michael Abed', 'michael@example.com',
  (SELECT id FROM items WHERE title = 'Essential Kitchen Tool Set'),
  NULL, 'TXN-MA-2026-002', 'Cook well, study harder!', 'confirmed'
UNION ALL SELECT
  'Emily Lawson', 'emily@example.com',
  NULL,
  50, 'TXN-EL-2026-003', 'A little something for the journey!', 'confirmed'
UNION ALL SELECT
  'David & Rose', 'davidrose@example.com',
  (SELECT id FROM items WHERE title = 'Organic Linen Bedding'),
  150, 'TXN-DR-2026-004', 'Sleep well in your new home!', 'pending';
