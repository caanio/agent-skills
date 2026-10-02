# `web-stack-selector` trigger eval: three description baselines

Version: 1.0.0 | Date: 2026-10-02 | Status: decided 2026-10-02 (option A:
HEAD stands at 1.2.0, no `SKILL.md` edit; the description stage closes on
these numbers and the pass moves on to `completion-gate`)

The description run that plan §2 of
`2026-10-01-skill-authoring-pass-plan.md` schedules for this skill. Three
descriptions were scored with `skill-creator`'s `run_eval.py` (20 queries
× 3 runs, `opus`, 10 workers) in two configurations. All three saturate the
set; `run_loop.py` was not started because its loop exits on the first
iteration when every train query passes (`run_loop.py` lines 177–181,
`exit_reason = "all_passed"`), so a run from HEAD would return HEAD.

## 1. Results

Mean trigger rate over the 10 should-trigger queries / the 10 should-not
queries. `pass` counts queries whose rate is on the right side of 0.5.

| Description | Isolated (no other skills) | With 43 competitor skills (51 linked, 43 listed) |
|---|---|---|
| HEAD (1.2.0) | 20/20, 1.00 / 0.00 | 20/20, 1.00 / 0.00 |
| D2–D5 hand-applied | 20/20, 1.00 / 0.00 | 20/20, 1.00 / 0.00 |
| `4e033f3` widened text (reverted by `0aad280`) | 20/20, 1.00 / 0.00 | 19/20, 1.00 / 0.10 |

The one failure: the widened text fires 3/3 on the React Native map
question (`我要寫一個 React Native 的 app 顯示地圖,地圖套件要選哪個?`),
a should-not query, under competitors. That is the first number the
revert has had: `0aad280`'s body is only git's own "This reverts
commit" line, and it has no log entry.

The 2026-09-16 live miss that `4e033f3` was written for (a one-line
Traditional Chinese "which package for a Flask map" question never fired
the skill) is **not reproduced** here: the same question hits 3/3 under
HEAD in both configurations and in two single probes (`opus`, `sonnet`).
The live miss happened inside a long interactive session with the global
rules loaded, on a different model; this harness runs a fresh `claude -p`
with project-only setting sources, a command-file stand-in for the skill,
and `opus`. "Unreproduced under these conditions", not "fixed".

Limits of the measurement: 3 runs per query cannot see rate differences
below 1/3; the set discriminates only at the margin (one failure in 120
negative runs across the competitor configuration). D2–D5 tie HEAD
exactly, so plan §4.4 gives no evidence to land them.

## 2. Harness defects found on the way (installed `skill-creator`, 2026-10-02)

Three, each confirmed by a probe before the fix; each needs the same fix
again for the `completion-gate` and HAOS runs. All fixes were made on a
scratch copy of `scripts/`; the install directory was not edited.

1. **Worker collision.** `run_eval.py` writes every worker's test command
   into one shared `<project>/.claude/commands/`, so with `--num-workers
   10` each `claude -p` sees up to ten near-identical commands and the
   detector only counts its own suffix. A probe showed `sonnet` invoking
   a sibling worker's suffix. First HEAD run under this defect: 10/20,
   every should-trigger query at 0/3 or 1/3. Fix: one project root per
   call (`<root>/w/<uuid>/`), removed in `finally`.
2. **Project root resolves to `~`.** `find_project_root` walks up from
   cwd for a `.claude` directory; on a machine whose `~/.claude` is a
   real directory of symlinks it stops at `~`, so the command files and
   the `claude -p` cwd land in the home directory. Fix: run from a
   scratch directory that holds its own empty `.claude/`.
3. **The installed real skill absorbs the trigger.** By default
   `claude -p` lists the installed `web-stack-selector` beside the test
   command; at iteration 0 both carry the same description, so a hit on
   the real one reads as a miss. Fix: `--setting-sources project`, which
   drops user-level skills (and user hooks). To keep competitors without
   the real copy, the other installed skills are linked into each call
   root's `.claude/skills/` from a pool (`WSS_SKILL_POOL`); a probe listed
   43 skills with the real `web-stack-selector` absent.

Also: the default `--timeout 30` is close to a single `opus` call's wall
time (a probe took 31 s end to end, 17.7 s of it API time); the runs used
`--timeout 90`. `timeout(1)` is not installed on macOS; probes ran
without it.

### Scratch diff against the installed `run_eval.py`

```diff
--- ~/.agents/skills/skill-creator/scripts/run_eval.py	2026-07-13 10:06:12
+++ <scratchpad>/wss-eval/scripts/run_eval.py
@@ -9,6 +9,7 @@
 import json
 import os
 import select
+import shutil
 import subprocess
 import sys
 import time
@@ -50,11 +51,21 @@
     """
     unique_id = uuid.uuid4().hex[:8]
     clean_name = f"{skill_name}-skill-{unique_id}"
-    project_commands_dir = Path(project_root) / ".claude" / "commands"
+    # scratch patch: one project root per call so parallel workers never
+    # see each other's test commands (verified 2026-10-02: a worker's
+    # claude -p picked a sibling's suffix and was counted as a miss)
+    call_root = Path(project_root) / "w" / unique_id
+    project_commands_dir = call_root / ".claude" / "commands"
     command_file = project_commands_dir / f"{clean_name}.md"
 
     try:
         project_commands_dir.mkdir(parents=True, exist_ok=True)
+        # scratch patch: WSS_SKILL_POOL links the other installed skills in
+        # as project skills, so the test runs with competitors but without
+        # the installed real copy (verified 2026-10-02 via probe2)
+        pool = os.environ.get("WSS_SKILL_POOL")
+        if pool:
+            (call_root / ".claude" / "skills").symlink_to(pool)
         # Use YAML block scalar to avoid breaking on quotes in description
         indented_desc = "\n  ".join(skill_description.split("\n"))
         command_content = (
@@ -73,6 +84,9 @@
             "--output-format", "stream-json",
             "--verbose",
             "--include-partial-messages",
+            # scratch patch: drop user-level skills so the installed real
+            # web-stack-selector cannot absorb the trigger (verified 2026-10-02)
+            "--setting-sources", "project",
         ]
         if model:
             cmd.extend(["--model", model])
@@ -86,7 +100,7 @@
             cmd,
             stdout=subprocess.PIPE,
             stderr=subprocess.DEVNULL,
-            cwd=project_root,
+            cwd=call_root,
             env=env,
         )
 
@@ -179,6 +193,7 @@
     finally:
         if command_file.exists():
             command_file.unlink()
+        shutil.rmtree(call_root, ignore_errors=True)
 
 
 def run_eval(
```

### Run script (competitor configuration; the isolated one omits the `export`)

```zsh
#!/bin/zsh
cd "$(dirname "$0")"; export WSS_SKILL_POOL="$PWD/pool"
for v in head d2d5 widened-4e033f3; do
  echo "=== $v start $(date +%H:%M:%S)"
  ~/.pyenv/versions/3.13.12/bin/python -m scripts.run_eval \
    --eval-set eval_set.json \
    --skill-path <repo>/skills/web-stack-selector \
    --description "$(cat baselines-comp/$v.txt)" \
    --model opus --runs-per-query 3 --num-workers 10 --timeout 90 --verbose \
    > baselines-comp/$v.json 2> baselines-comp/$v.log
  echo "=== $v exit $? $(date +%H:%M:%S)"
done
echo ALL_DONE
```

The scratch copy lives at `<scratchpad>/wss-eval/` with `scripts/` copied
from `~/.agents/skills/skill-creator/scripts/`, the pool built by linking
every `~/.agents/skills/*/` that has a `SKILL.md` except
`web-stack-selector`, and `python` = the pyenv 3.13 interpreter (the
default `python3` lacks PyYAML).

## 3. Eval set (reviewed in `eval_review.html`, exported unchanged)

```json
[
  {
    "query": "Flask 的地圖要用哪個套件?",
    "should_trigger": true
  },
  {
    "query": "我有一個 Django 的後台頁面要做,表格要能排序跟搜尋,元件庫要選哪一個?專案不能跑 npm build",
    "should_trigger": true
  },
  {
    "query": "ok so im adding a dashboard page to our laravel app (routes/web.php, blade templates, no vite yet). need charts + a couple of filter dropdowns. what should i pull in? boss doesnt want to add a react build step",
    "should_trigger": true
  },
  {
    "query": "shadcn 跟 daisyUI 我該選哪個?Next.js 專案,要做一個設定頁面",
    "should_trigger": true
  },
  {
    "query": "we're starting the admin UI for the inventory service next sprint (React 18, Vite). not decided on a component kit or table lib yet - what would you go with and is there an MCP server I should install for it?",
    "should_trigger": true
  },
  {
    "query": "想在網頁上顯示無人機飛行軌跡的 3D 場景,大概幾千個點,用純 HTML + 一支 JS 檔就好,引擎要用哪個?",
    "should_trigger": true
  },
  {
    "query": "page needs a donut chart and a sortable table of ~5k rows, served by a Flask template. CSP is strict (no inline, no cdn). which libs?",
    "should_trigger": true
  },
  {
    "query": "which frontend MCP should I install for a symfony twig project? I keep hearing about the shadcn one but we're not on react",
    "should_trigger": true
  },
  {
    "query": "要做一個給 RPi 上 kiosk 瀏覽器看的即時監控頁,機器很弱,圖表套件挑輕一點的,你推薦哪個?",
    "should_trigger": true
  },
  {
    "query": "new marketing site, plain html, want some scroll animations and a tiny slider. dont want jquery. what do people use now",
    "should_trigger": true
  },
  {
    "query": "we already use Chart.js on the stats page, make the bar chart in templates/stats.html a donut and put the legend on the right",
    "should_trigger": false
  },
  {
    "query": "Flask 的 API 要加 JWT 驗證,用哪個套件?",
    "should_trigger": false
  },
  {
    "query": "the dashboard at src/pages/Dashboard.tsx looks cramped, can you redesign the layout so the KPI tiles sit in a row and the chart gets more height? we're on MUI already",
    "should_trigger": false
  },
  {
    "query": "設計一下訂單系統的 PostgreSQL schema,要有 orders、order_items、customers 三張表",
    "should_trigger": false
  },
  {
    "query": "which MCP server do I install to let claude manage my firebase project from the cli",
    "should_trigger": false
  },
  {
    "query": "寫個 python script 把 sensors.csv 畫成折線圖存成 png,x 軸是時間",
    "should_trigger": false
  },
  {
    "query": "Tailwind classes aren't applying on the new /settings page in our Laravel app, build runs clean but the page is unstyled. can you figure out why",
    "should_trigger": false
  },
  {
    "query": "我要寫一個 React Native 的 app 顯示地圖,地圖套件要選哪個?",
    "should_trigger": false
  },
  {
    "query": "bump leaflet from 1.9 to the latest in package.json and fix whatever breaks in src/map/",
    "should_trigger": false
  },
  {
    "query": "Flask 跟 FastAPI 新專案該選哪個?主要是給 HA 的 add-on 用",
    "should_trigger": false
  }
]
```

## 4. Candidate descriptions scored

HEAD is the frontmatter at 1.2.0. The D2–D5 text folds the four
description findings of the 2026-10-02 body pass (one MCP mention, a
direct "Not for" exclusion, a shorter enumeration, the three Step 2
constraint branches):

> Pick the frontend library (component kit, CSS layer, JS utility, map or
> 2D/3D engine, chart or data table) and its MCP server for a web page on
> any stack (Flask/Django templates, PHP Laravel/Symfony, React). Use when
> a page, dashboard, admin UI, map, chart or 3D scene is about to be built
> and the library is not fixed yet, even as a one-line question with no
> code, when asked shadcn-or-X, or when the page must run under a strict
> CSP, without a build step, or on a low-power device. Not for backend-only
> work (API, schema, auth).

The widened text is `4e033f3`'s description verbatim.
