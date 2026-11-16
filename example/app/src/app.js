/* app.js — orchestrator: boot the snapshot, render panels, wire in-app controls.
   Interactivity lives here (region chips), never on the Tableau filter shelf — that's
   what keeps the app portable across all three tiers. */
(function () {
  const $ = id => document.getElementById(id);
  const money = v => "$" + Math.round(v).toLocaleString("en-US");
  const SVGNS = "http://www.w3.org/2000/svg";
  const el = (t, a, p) => { const n = document.createElementNS(SVGNS, t); for (const k in a) n.setAttribute(k, a[k]); if (p) p.appendChild(n); return n; };

  let META = {}, region = null;

  // honest tier badge: are we inside Tableau, or a browser preview?
  function badge() {
    try {
      if (window.tableau && tableau.extensions && tableau.extensions.initializeAsync) {
        tableau.extensions.initializeAsync().then(() => {
          let ctx = ""; try { ctx = tableau.extensions.environment.context; } catch (e) {}
          $("tier").textContent = ctx === "server" ? "ON SITE" : "ON DESKTOP";
        }).catch(() => { $("tier").textContent = "PREVIEW"; });
      } else { $("tier").textContent = "PREVIEW"; }
    } catch (e) { $("tier").textContent = "PREVIEW"; }
  }

  function renderChips() {
    const all = ["All", ...META.regions];
    $("chips").innerHTML = all.map(r => {
      const pressed = (r === "All" && region == null) || r === region;
      return `<button data-r="${r}" aria-pressed="${pressed}">${r}</button>`;
    }).join("");
  }

  function renderKPIs() {
    const t = VP.totals(region);
    $("kRev").textContent = money(t.revenue);
    $("kOrders").textContent = t.orders.toLocaleString();
    $("kUnits").textContent = t.units.toLocaleString();
    $("kAvg").textContent = money(t.avgOrder);
  }

  function renderBar() {
    const data = VP.byCategory(region);
    const W = 640, H = 240, L = 110, R = 24, T = 12, B = 28;
    const max = Math.max(1, ...data.map(d => d.revenue));
    const bw = (H - T - B) / data.length;
    const svg = $("bar"); svg.innerHTML = "";
    const x = v => L + v / max * (W - L - R);
    [0, 0.25, 0.5, 0.75, 1].forEach(f => {
      el("line", { x1: x(max * f), y1: T, x2: x(max * f), y2: H - B, class: "grid" }, svg);
      el("text", { x: x(max * f), y: H - B + 16, "text-anchor": "middle", "font-size": 10, class: "ax" }, svg).textContent = "$" + Math.round(max * f / 1000) + "k";
    });
    data.forEach((d, i) => {
      const y = T + i * bw + 4;
      el("rect", { x: L, y, width: Math.max(2, x(d.revenue) - L), height: bw - 8, rx: 3, fill: "var(--accent)" }, svg);
      el("text", { x: L - 10, y: y + (bw - 8) / 2 + 4, "text-anchor": "end", "font-size": 12, class: "lbl" }, svg).textContent = d.category;
      el("text", { x: x(d.revenue) + 6, y: y + (bw - 8) / 2 + 4, "font-size": 11, class: "ax" }, svg).textContent = money(d.revenue);
    });
  }

  function render() { renderChips(); renderKPIs(); renderBar(); }

  function boot() {
    badge();
    META = VP.boot();
    $("ctx").textContent = META.rows.toLocaleString() + " rows · " + META.regions.length + " regions · " + META.categories.length + " categories";
    render();
    $("chips").addEventListener("click", e => {
      const b = e.target.closest("button"); if (!b) return;
      region = b.dataset.r === "All" ? null : b.dataset.r;
      render();
    });
  }

  try { boot(); } catch (e) { $("boot").textContent = "Failed to start: " + e.message; console.error(e); }
})();
