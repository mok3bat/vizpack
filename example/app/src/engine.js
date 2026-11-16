/* engine.js — the plain-JS compute layer over the bundled snapshot (window.VP_DATA).
   All aggregations are loops over the snapshot arrays; no runtime fetch, works in every tier.
   This is the file you adapt to your data's aggregations. Exposes window.VP. */
(function () {
  let D = null;

  function boot() {
    D = window.VP_DATA;
    if (!D) throw new Error("snapshot-data.js not loaded");
    return { rows: D.revenue.length, regions: D.regions.slice(), categories: D.categories.slice() };
  }

  // region = null (all) or a region name
  function match(i, region) { return region == null || D.regions[D.region[i]] === region; }

  function totals(region) {
    let rev = 0, units = 0, orders = 0;
    for (let i = 0; i < D.revenue.length; i++) if (match(i, region)) { rev += D.revenue[i]; units += D.units[i]; orders++; }
    return { revenue: rev, units, orders, avgOrder: orders ? rev / orders : 0 };
  }

  function byCategory(region) {
    const sum = {};
    D.categories.forEach(c => sum[c] = 0);
    for (let i = 0; i < D.revenue.length; i++) if (match(i, region)) sum[D.categories[D.cat[i]]] += D.revenue[i];
    return D.categories.map(c => ({ category: c, revenue: sum[c] })).sort((a, b) => b.revenue - a.revenue);
  }

  function regionTotals() {
    return D.regions.map(r => ({ region: r, revenue: totals(r).revenue }))
      .sort((a, b) => b.revenue - a.revenue);
  }

  window.VP = { boot, totals, byCategory, regionTotals };
})();
