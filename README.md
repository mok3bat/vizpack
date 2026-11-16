# 📦 Vizpack

**Build a Tableau data app from your sample data. It opens and works in Tableau Desktop — and,
once you approve it, packages into a single workbook you publish to your site.**

Vizpack is a **Claude Code plugin** (and a clone-and-build starter kit). Give an agent your
requirements and a sample CSV; it builds a worksheet **viz extension** that renders your data in
**plain JavaScript**, opens in **Tableau Desktop**, and — on your approval — becomes a
self-contained, site-publishable workbook. The agent *prepares*; **you** publish and point it at
your real data.

## The flow

1. **Build** — from your requirements + a **sample CSV**, the agent builds a data app that opens
   and works in **Tableau Desktop**.
2. **Approve** — you review it in Desktop and iterate until it's right.
3. **Site version** *(on request)* — the agent generates one self-contained `.twbx` (the app
   bundled inside the workbook).
4. **Publish + swap** — you publish it manually, then swap the embedded sample datasource for your
   **real** datasource (which must match the sample's field names and data types).

## How it works

The app is a viz extension on a worksheet. Its code is served from `localhost` on Desktop, or
bundled inside the workbook once packaged for a site; its data is your sample **bundled as a
JavaScript snapshot** loaded by a `<script>` tag, so it's available with no runtime file access.
All compute is **plain JavaScript**, and interactivity is **in-app** (chips, dropdowns, a slider),
never the Tableau filter shelf.

## Quickstart

```sh
cd example
./build.sh      # data/sample.csv → app/src/snapshot-data.js  +  build/*.twbx  (Desktop)
./serve.sh      # http://localhost:8750 — preview in a browser, or keep running for Desktop
./build-site.sh # → build-site/*.twbx — the site-publishable workbook (you publish it)
```

- **Preview:** open <http://localhost:8750>.
- **Desktop:** open `build/*.twbx` with `serve.sh` running.
- **Site:** publish `build-site/*.twbx` yourself (plain upload / overwrite). It's packaged inside
  the workbook — nothing to add to the extension safe list; just confirm the site's *sandboxed
  extensions* setting is on.

## Use it as a Claude Code plugin

Install the folder and an agent gains the **`vizpack`** skill (`skills/vizpack/SKILL.md`). Then:

> "Build a Tableau data app from this CSV with these KPIs and a region filter; make it work in Desktop."
> …then, once you've looked at it: "Now make the site version."

The agent follows the skill — scaffolds from `example/`, swaps in your data and aggregations, builds
the Desktop and site `.twbx`, and **guides** the publish + datasource swap. It never publishes for you.

## Publish, then point it at your real data

The site workbook embeds your **sample** as its datasource. To back it with real data:

1. Make sure the real datasource matches the sample's **field names and data types**.
2. Publish the workbook's embedded datasource as a **published datasource** (Desktop connected to
   the site, or web authoring).
3. **Replace Data Source** → the published one → **Close** the embedded one → Publish.
4. To show the real data's numbers in the app, re-export it to a CSV with the same columns, re-run
   `./build.sh` + `./build-site.sh`, and re-publish.

## Make it yours

1. Replace `example/data/sample.csv` with your data.
2. Edit `example/app/src/engine.js` — the aggregations your panels need.
3. Edit `example/app/src/app.js` + `index.html` — the panels and in-app controls.
4. To rename the extension id, update it in `vizpack-example.trex`, the `ID=` line in
   `build-site.sh`, and the host workbook (`host/*.twb`). The default `com.vizpack.example` works
   out of the box.
5. `./build.sh && ./build-site.sh` → hand over the two `.twbx` files.

## Layout

```
vizpack/
├── .claude-plugin/plugin.json    Claude Code plugin manifest
├── skills/vizpack/SKILL.md       the agent skill: build → Desktop → site → datasource swap
├── README.md · LICENSE · .gitignore
└── example/                      a runnable reference app the skill scaffolds from
    ├── app/{index.html, src/{app.js, engine.js, snapshot-data.js(built), styles.css, …}}
    ├── data/{gen_sample.py, sample.csv}
    ├── host/<App>.twb            pre-built host workbook (no compiler needed)
    ├── schema/                   Tableau XSD + validate.sh — verify any .twb offline
    ├── vizpack-example.trex · vizpack-example.twb.yml (optional authoring source)
    └── build.sh · build-site.sh · serve.sh
```

## License

MIT — see [`LICENSE`](LICENSE). Use it, fork it, ship your own.
