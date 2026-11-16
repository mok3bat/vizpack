---
name: vizpack
description: >
  Build a Tableau data app from a user's requirements and a sample dataset (CSV).
  The app is a worksheet viz extension that renders over the bundled sample in
  plain JavaScript and opens and works in Tableau Desktop. Once the user approves
  it, generate a site-friendly version (the app packaged inside the workbook) for
  the user to publish MANUALLY, and guide them to convert the workbook's embedded
  datasource into a published datasource and then replace it with their real
  datasource — which must match the sample's field names and data types. Use when
  asked to "build a Tableau data app / viz-extension dashboard from a sample
  dataset", "make it work on Tableau Desktop", or "prepare it to publish to a
  Tableau site". Scaffolds from this plugin's example/.
---

# Vizpack — build a Tableau data app from sample data

## The flow

1. **Build** — from the user's requirements + a **sample CSV**, build a data app that opens and
   works in **Tableau Desktop**.
2. **Approve** — the user opens it in Desktop and reviews. Iterate on the panels and interactions
   until they approve.
3. **Site version (on request only)** — generate a **site-friendly** workbook: the app packaged
   *inside* the workbook as one self-contained `.twbx`. **Prepare it; the user publishes it manually.**
4. **Datasource swap (guide the user)** — the site workbook embeds the sample as its datasource.
   Guide them to publish it as a **published datasource** and then **replace** it with their
   **real** datasource, which must match the sample's **field names and data types**.

## How the data app works

- A worksheet **viz extension** hosts the app on the Marks card. On Desktop the app's code is
  served from `localhost`; its data is the **sample, bundled as a JavaScript snapshot**
  (`app/src/snapshot-data.js`, loaded by a `<script>` tag) so it's available with no runtime file
  access.
- **All compute is plain JavaScript** over that snapshot — totals, group-bys, filtered views.
- **Interactivity lives in the app** (chips, dropdowns, a slider), never the Tableau filter shelf
  (a worksheet extension can't read the shelf on Desktop). In-app controls re-aggregate the
  in-memory rows and keep working in every tier.

## Part A — build the Desktop data app

Scaffold from this plugin's **`example/`** (a working data app) — copy and adapt, don't start empty.

1. **Requirements** — clarify the panels (KPIs, charts), the dimensions to slice by, and the
   interactions the user wants.
2. **Sample data** — put the user's CSV in `data/`. `build.sh` turns it into
   `app/src/snapshot-data.js` (compact parallel arrays). Adapt the small Python block in
   `build.sh` to the CSV's columns.
3. **Engine** (`app/src/engine.js`) — write the aggregations the panels need as loops over the
   snapshot arrays; expose a small `window.<NS>` API.
4. **Panels + controls** (`app/src/app.js`, `index.html`) — render KPIs/charts (hand-built SVG,
   theme-aware) and wire the in-app controls.
5. **Host workbook + identity** — `host/<App>.twb` is the Tableau workbook that hosts the
   extension; its datasource columns must match your CSV, and it carries the extension id. For a
   **new schema**, edit it (plain XML: the `<column>` definitions → your CSV's fields, and the
   extension `id`/`url`), or regenerate it from `*.twb.yml` if you have the external twb-as-code
   compiler. Set the **same** id (`com.<you>.<app>`) in the `.trex` and the `ID=` line in
   `build-site.sh`. Then **validate the host against the bundled Tableau XSD** — this is the one
   step a new schema can get wrong:
   ```
   ./schema/validate.sh host/<App>.twb      # must pass; build.sh runs it automatically too
   ```
6. **Build + open** — `./build.sh` (regenerates the snapshot, re-validates the host, writes
   `build/<App>.twbx`), `./serve.sh`, then open the `.twbx` in Desktop with the server running.
   Iterate until the user approves.

## Part B — on approval, the site-friendly version

`./build-site.sh` packages the whole app **inside the workbook** (`Packages/<id>/`, referenced by
`tableaulocalext:///<id>/content/index.html`) and embeds the sample data → one self-contained
`build-site/<App> (Site).twbx`.

**Prepare it; do not publish it.** The upload is the user's step (site credentials and the trust
prompts are theirs). Hand over the file and tell them: upload / overwrite via web authoring or
Desktop → Publish. The app is packaged inside the workbook — there is **no external URL to add to
the site's extension safe list**; just confirm the site's *sandboxed extensions* setting is on.
On download the site strips the packaged app, so keep the local `build-site/` as the source.

## Part C — guide the datasource swap

The site workbook embeds the **sample** as its datasource. To back the workbook with the user's
**real** data:

1. **Schema contract** — the real datasource must match the sample's **field names and data
   types** exactly. That is what the workbook (and the app) were built against.
2. **Publish the datasource** — in Desktop connected to the site (or in web authoring), publish
   the workbook's embedded datasource as a **published datasource**.
3. **Replace** — Data → **Replace Data Source** → pick the published one → **Close** the embedded
   one → Publish. Let Tableau author the connection itself — don't hand-edit the workbook's
   datasource XML; a hand-built link is rejected on upload.
4. **Refresh the app's values** (optional) — the app renders the bundled sample; to show the real
   data's numbers, re-export the real data to a CSV with the same columns, re-run `./build.sh` +
   `./build-site.sh`, and re-publish.

## Verify

- The host workbook passes `./schema/validate.sh host/<App>.twb` (valid against the bundled
  Tableau XSD). `build.sh` runs this automatically; you can run it on any `.twb` offline.
- Opens and renders in **Desktop** from the sample; in-app controls re-aggregate instantly.
- A grand total from the snapshot matches a known value in the sample CSV.
- The site `.twbx` is self-contained and uses the `tableaulocalext:///` URL (no `localhost`).
- The real datasource's field names and data types match the sample before the swap.

## Reference

`example/` is a complete, runnable data app (Regional Sales: KPIs + bar + region chips). Read its
`engine.js` / `app.js` / `build-site.sh` when a detail is unclear.
