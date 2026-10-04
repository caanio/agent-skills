# Survey snapshot — 2026-10-04 (Vue / Nuxt)

Version: 1.0.0 | Date: 2026-10-04

Star counts, license and last push date were read from the GitHub REST API
(`repos/<owner>/<repo>`) on 2026-10-04 and copied verbatim. The bar,
including what "maintained" means, is defined in `SKILL.md` and measured
against the snapshot date. Framework-agnostic libraries the Vue section
reuses (Leaflet, MapLibre, uPlot, SortableJS, Tabulator, three.js) are in
`survey-2026-09-16.md`.

## Core

| owner/repo | stars | license | pushed | Note |
|---|---|---|---|---|
| nuxt/nuxt | 60,917 | MIT | 2026-10-03 | |
| vuejs/core | 54,499 | MIT | 2026-10-04 | |

## UI foundations and admin

| owner/repo | stars | license | pushed | Note |
|---|---|---|---|---|
| vuetifyjs/vuetify | 41,035 | MIT | 2026-10-02 | API reports `NOASSERTION`; MIT from `LICENSE.md` and `packages/vuetify/package.json` |
| element-plus/element-plus | 27,795 | MIT | 2026-10-03 | |
| quasarframework/quasar | 27,208 | MIT | 2026-09-30 | |
| tusen-ai/naive-ui | 18,567 | MIT | 2026-08-27 | |
| primefaces/primevue | 14,456 | MIT | 2026-09-24 | Ships `@primevue/mcp` in `packages/mcp` |
| unovue/shadcn-vue | 10,662 | MIT | 2026-10-04 | Copy-paste components on reka-ui; CLI has an `mcp` command |
| nuxt/ui | 6,983 | MIT | 2026-10-04 | Ships an MCP server in `docs/server/mcp` |
| unovue/reka-ui | 6,855 | MIT | 2026-10-02 | Formerly radix-vue; shadcn-vue's primitives |
| vbenjs/vue-vben-admin | 33,551 | MIT | 2026-10-02 | Admin template, not a CRUD framework |
| TanStack/table | 28,474 | MIT | 2026-10-04 | Headless; Vue adapter `@tanstack/vue-table` |
| vueuse/vueuse | 22,386 | MIT | 2026-09-23 | Composition utilities |

No Vue-native CRUD framework on the refine / react-admin model surfaced;
the top "vue admin" results are templates. Below the bar:
logaretm/vee-validate 11,263 (last push 2026-03-04);
PanJiaChen/vue-element-admin 90,165 (Vue 2, last push 2024-10-24).

## Charts, motion, 3D

| owner/repo | stars | license | pushed | Note |
|---|---|---|---|---|
| ecomfe/vue-echarts | 10,758 | MIT | 2026-10-03 | Wraps apache/echarts (~1 MB) |
| apertureless/vue-chartjs | 5,718 | MIT | 2026-10-03 | Wraps Chart.js |
| unovue/inspira-ui | 5,015 | MIT | 2026-09-18 | Vue port of the Aceternity / magicui scene |
| Tresjs/tres | 3,749 | MIT | 2026-10-02 | three.js for Vue |
| motiondivision/motion-vue | 2,215 | MIT | 2026-10-02 | |

Below the bar: vueuse/motion 2,765 (last push 2025-03-11);
skalinichev/uplot-wrappers 134 (best uPlot Vue wrapper found).

## Drag and drop, maps

Every Vue wrapper found is below the bar:
SortableJS/vue.draggable.next 4,501 (last push 2023-09-27);
vue-leaflet/vue-leaflet 859 (last push 2024-07-10);
indoorequal/vue-maplibre-gl 166.

## MCP servers

| Server | Lives in | Bar |
|---|---|---|
| `@primevue/mcp` (official) | primefaces/primevue `packages/mcp` | Parent repo meets it |
| Nuxt UI MCP (official) | nuxt/ui `docs/server/mcp` | Parent repo meets it |
| shadcn-vue CLI `mcp` command (official) | unovue/shadcn-vue | Parent repo meets it; whether it serves the shadcn-vue registry is [unconfirmed] |
| vuetifyjs/mcp (official) | standalone, 114 stars | Below |
| Nuxt docs MCP (official) | nuxt/nuxt.com, 459 stars | Below |

No vuejs-org MCP server found. Community Vue/Nuxt MCPs found were all
below the bar (largest: antfu/nuxt-mcp-dev 912, last push 2026-03-01).
