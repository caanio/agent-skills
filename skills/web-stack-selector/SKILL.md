---
name: web-stack-selector
description: "Pick the frontend library, CSS layer, JS utility, map or 2D/3D engine, chart or data-table library, and the MCP servers to install, for a web page on any backend (Flask/Django templates, PHP Laravel/Symfony, React). Use whenever the user asks which library, package, component kit, 套件, 元件庫 or 地圖套件 to use for a page, dashboard, admin UI, map, chart or 3D scene, even as a one-line question with no code yet; also when a page is about to be built and the library is not fixed, or when asked shadcn-or-X or which frontend MCP. Backend-only work (API, schema, auth) has no UI to route."
---

# web-stack-selector

Version: 1.1.0 | Date: 2026-09-16

Every pick below **meets the bar**: >= 1,000 GitHub stars, a permissive
license (MIT / BSD / ISC / Apache-2.0 / 0BSD), maintained.
Anything that misses the bar is flagged where it appears. Star counts and
last-commit dates live in `references/survey-2026-09-16.md`, a dated
snapshot.

## Step 1 — Identify the stack (ask one question if unclear)

| Stack | Typical signals | Go to |
|---|---|---|
| **A. Vanilla / server-rendered** | Flask + Jinja, Django templates, PHP Blade/Twig, Livewire, htmx, "no npm", "no build step" | Section A |
| **B. React** | Next.js, Vite + React, Laravel Inertia + React, "use shadcn" | Section B |
| **C. PHP full-stack** | Laravel or Symfony project — decide between A (Livewire/Blade) and B (Inertia + React) | Section C |
| Vue / Nuxt | Uncovered; say so, use Section A libraries (framework-agnostic), and check `references/` before naming anything Vue-specific | — |

## Step 2 — Hard constraints (check before any pick)

Inspect the project (CSP header, deploy pipeline, target hardware, existing
CSS) or ask. Each constraint that applies narrows the candidate set; the
step is done when all five have an explicit yes/no for this project:

1. **Strict CSP** (`default-src 'self'`, no `unsafe-inline` / `unsafe-eval`)
   → **vendor** every library as a file under the app's own static path,
   load it with `<script src>` / `<link>`, and put all handlers in that
   external file. Libraries that evaluate strings at runtime are out:
   Alpine.js by default; htmx stays in with `htmx.config.allowEval = false`
   and attribute-only usage (no `hx-on`).
   ⚠️ Seen in practice: an inline handler blocked by CSP fails **silently**
   — the button "does nothing" and the console stays empty until DevTools
   is open. A dead new button means "check the CSP header first".
2. **No build step** (no Node in the deploy pipeline) → pick single-file
   UMD / IIFE / ESM bundles. Tailwind stays only via its standalone CLI;
   daisyUI, shadcn, magicui, aceternity and React Three Fiber need a
   bundler and drop out.
3. **Low-power target** (Raspberry Pi, cheap VPS, many concurrent tabs) →
   prefer the lighter option in each row: uPlot over Chart.js, Leaflet
   over MapLibre / OpenLayers. Heavy visuals (particles, beams, 3D) live in
   the **hero block**, one Canvas per page; ECharts (~1 MB) and full 3D
   engines stay only when the page is *about* 3D.
4. **License bar** — permissive only. When one of these comes up, flag it
   and offer the permissive neighbour: react-bits (MIT + Commons Clause)
   → anime.js / motion; GSAP (custom, non-OSI) → anime.js;
   mapbox-gl-js v2+ (proprietary) → MapLibre; animate.css v4+
   (Hippocratic) → anime.js; simple-datatables (LGPL) → Tabulator;
   mary-ui (custom) → Filament.
5. **Existing design tokens** (a `:root` variable set already in place) →
   extend those tokens (Open Props pattern). A classless or utility
   framework layered on top fights them.

## Step 3 — Pick by scene

### Section A — Vanilla / server-rendered (Flask, Django, PHP Blade/Twig, Livewire, htmx)

| Scene | Primary | Alternative / notes |
|---|---|---|
| Admin dashboard, data-dense | Native `<dialog>` + `<table>` + own tokens; **tabulator-tables/tabulator** for sort/filter/paginate; **floating-ui/floating-ui** for tooltip/popover/dropdown positioning | Tabulator supports Ajax paging → drop hard row limits |
| Partial page updates without an SPA | **bigskysoftware/htmx** | Fixes "form validation redirect closes my dialog"; see CSP note in Step 2 |
| Charts, time series | **leeoniya/uPlot** (~50 KB, Canvas) | **chartjs/Chart.js** when you need donut/bar/mixed; pick one |
| Design tokens / CSS foundation | **argyleink/open-props** + **sindresorhus/modern-normalize** | **picocss/pico** only for classless throwaway/internal pages |
| Icons | **tabler/tabler-icons** or **lucide-icons/lucide** | Vendor the SVGs you use, as one sprite |
| Marketing micro-interactions (the *magicui* scene) | **juliangarnier/anime** (anime.js v4) | **motiondivision/motion** vanilla build; both replace GSAP |
| Futuristic hero / particles (the *aceternity* scene) | **tsparticles/tsparticles** for particle/confetti backgrounds; **mrdoob/three.js** for real 3D | — |
| Drag-and-drop ordering | **SortableJS/Sortable** | — |
| Date formatting / relative time in the browser | **iamkun/dayjs** (2 KB) | Server-side formatting is fine if the page reloads anyway |

### Section B — React (Next.js, Vite, Laravel Inertia + React)

Layered use on one page: **shadcn** for every control and layout
skeleton, **magicui** for feature Bento grids / marquees / border beams,
**aceternity** for the hero block.

| Scene | Primary | Alternative / notes | MCP |
|---|---|---|---|
| Admin dashboard, forms (Zod), data tables, dialogs, a11y | **shadcn-ui/ui** (Radix primitives underneath) | **refinedev/refine** or **marmelab/react-admin** when you want a full CRUD framework around the components | See Step 4 |
| Charts inside a shadcn dashboard | **tremorlabs/tremor** (copy-paste v2) | uPlot/Chart.js still work in React | — |
| SaaS landing page, pricing, Bento grid, marquee, number ticker, shimmer/beam buttons | **magicuidesign/magicui** | **motiondivision/motion** for custom animation | None found as of the survey date; say so when asked |
| AI / futuristic hero: background beams, lamp, sparkles, 3D tilt cards, text-generate | **Aceternity UI** — paid registry, **no open-source repo, no star count** | **pmndrs/react-three-fiber** + **tsparticles** React wrapper for an open alternative | Community `aceternityui-mcp` is below the bar |
| "Generate me a component from a prompt" | **21st-dev/magic-mcp** | — | Is itself an MCP |

### Section C — PHP full-stack (Laravel, Symfony)

| Scene | Pick | Then |
|---|---|---|
| Admin panel fast, minimal JS | **filamentphp/filament** (built on **livewire/livewire**, Tailwind) | Filament's own table/form/widget system replaces Section A picks for the admin area |
| Interactive pages without writing JS | **livewire/livewire** alone (Laravel) / **symfony/ux** Live Components (Symfony) | Section A libraries for charts, maps, icons |
| You want shadcn / magicui on a PHP backend | **inertiajs/inertia** + React | Then follow Section B; on PHP those three reach the page only through Inertia |
| CSS baseline | **tailwindlabs/tailwindcss** (v4 standalone CLI needs no Node) | Keep **twbs/bootstrap** where it already runs |
| Google Maps / Leaflet / 3D | Framework-agnostic → Section D / E | — |

### Section D — Maps

| Scene | Pick | Notes |
|---|---|---|
| 2D raster tiles, light, no build | **Leaflet/Leaflet** | Default for "just show pins on a map" |
| Vector tiles, WebGL, 3D terrain, custom styling | **maplibre/maplibre-gl-js** | Open fork of Mapbox GL v1 — use instead of mapbox-gl-js v2+ (proprietary) |
| GIS-grade: projections, WMS/WFS, feature editing | **openlayers/openlayers** | Heavier than Leaflet |
| Huge point sets, heatmaps, 3D layers on top of a base map | **visgl/deck.gl** | Overlays on Google Maps or MapLibre |
| Geometry math (distance, buffer, point-in-polygon) | **Turfjs/turf** | Pairs with any of the above |
| Marker clustering | **mapbox/supercluster** | Works with Leaflet, MapLibre and Google Maps; `Leaflet.markercluster` is below the bar |
| Google Maps JS API | Closed source; its official GitHub helpers are below the bar | — |

### Section E — 2D / 3D rendering

| Scene | Pick | Notes |
|---|---|---|
| 3D scenes, model viewers, hero effects | **mrdoob/three.js** | ESM build vendors without a bundler; React → **pmndrs/react-three-fiber** |
| Batteries-included 3D (physics, GUI, inspector) | **BabylonJS/Babylon.js** | Bigger download than three.js |
| 3D globe / geospatial 3D tiles | **CesiumGS/cesium** | When Section D and 3D overlap |
| High-performance 2D (particles, thousands of sprites) | **pixijs/pixijs** | Rendering engine; pair with your own UI layer |
| 2D interactive editor (drag, select, transform) | **konvajs/konva** | **fabricjs/fabric.js** when it is an image/graphics editor |
| Data-viz primitives | **d3/d3** | Primitives you compose, rather than ready-made charts |

## Step 4 — MCP servers worth installing (into the coding agent)

| MCP | Use it for | Skip when |
|---|---|---|
| **upstash/context7** | Current docs for *every* library above (Flask, Laravel, Leaflet, three.js, Chart.js, …); the only MCP the map and 3D libraries have | Nothing skips it; install first |
| **laravel/boost** | Official Laravel MCP: project structure, Eloquent, routes, Artisan, docs search | Not a Laravel project |
| **ChromeDevTools/chrome-devtools-mcp** | Console (CSP blocks show up here), performance traces on heavy map/3D pages, screenshots of light/dark themes | You already run playwright-mcp — pick one |
| **microsoft/playwright-mcp** | Scripted end-to-end clicks through dialogs and forms | Same as above |
| **Jpisnice/shadcn-ui-mcp-server** | Section B only | Vanilla or PHP-Livewire stack |

Below the bar as of the survey date, so route these needs elsewhere:
Google Maps (every MCP, official included) → Context7 for the docs;
Figma MCP → only once real design files exist; a11y MCPs →
`dequelabs/axe-core` inside Playwright tests.

## Done when

The answer to the user contains, in this order: **stack detected →
constraints that applied and which candidates each removed → one primary
pick per scene the user named, each with a one-line reason → MCPs to
install**. Every scene the user named has a pick; every removed candidate
names the constraint that removed it; every quoted star count comes from
`references/` with the snapshot date beside it, or from a fresh API read
when the user needs today's number. The alternative column is spoken only
when the primary conflicts with a Step 2 constraint.
