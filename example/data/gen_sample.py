#!/usr/bin/env python3
"""Generate a tiny, generic sample dataset for the Vizpack example.
Deterministic, stdlib-only. Replace this (and sample.csv) with your own data."""
import csv, random, os
random.seed(7)

REGIONS = ["North", "South", "East", "West"]
CATEGORIES = ["Widgets", "Gadgets", "Gizmos", "Doohickeys"]
# give each region/category a flavour so the charts show real variation
REGION_W = {"North": 1.3, "South": 0.8, "East": 1.1, "West": 0.9}
CAT_BASE = {"Widgets": 120, "Gadgets": 240, "Gizmos": 90, "Doohickeys": 60}

rows = []
for month in range(1, 13):
    for _ in range(35):                       # ~35 orders/month → ~420 rows
        region = random.choice(REGIONS)
        cat = random.choice(CATEGORIES)
        units = max(1, int(random.gauss(8, 4)))
        price = CAT_BASE[cat] * random.uniform(0.7, 1.4) * REGION_W[region]
        rows.append({
            "date": f"2026-{month:02d}-{random.randint(1, 28):02d}",
            "region": region,
            "category": cat,
            "units": units,
            "revenue": round(units * price / 8, 2),
        })
random.shuffle(rows)

out = os.path.join(os.path.dirname(__file__), "sample.csv")
with open(out, "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["date", "region", "category", "units", "revenue"])
    w.writeheader(); w.writerows(rows)
print(f"wrote {out} — {len(rows)} rows, revenue ${sum(r['revenue'] for r in rows):,.0f}")
