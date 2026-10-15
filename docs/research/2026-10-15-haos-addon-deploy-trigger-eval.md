# `haos-addon-deploy` trigger eval: HEAD, D2, D3 + D4 and D1 + D3 + D4 + D5

Version: 1.0.0 | Date: 2026-10-15 | Status: decided 2026-10-15
(D1 + D3 + D4 + D5 lands by the tiebreak rule registered before the
runs: the only text at the top score in both configurations, 20/20
under competitors; 524 → 499 characters; the last of the five
description runs plan §2 schedules)

The description run that plan §2 of
`2026-10-01-skill-authoring-pass-plan.md` schedules after the 2026-10-14
body pass. Four descriptions were scored with `skill-creator`'s
`run_eval.py` (20 queries × 3 runs, `opus`, 10 workers, `--timeout 90`)
in two configurations, eight runs of 2:58–3:28 minutes each
(2026-10-15 12:47–13:14); every run exited 0 and no log carries a timeout or an
error. `run_loop.py` was not started: the should side is saturated on
every text, and the only should-not failures are queries no description
wording in this set moves (§1).

The candidate texts are the body-pass reviewer's own D1–D5, copied
verbatim from its report (kept in that session's scratchpad); the log
entry of 2026-10-14 paraphrases them.

## 1. Results

Mean trigger rate over the 10 should-trigger queries / the 10 should-not
queries; `pass` counts queries whose rate is on the right side of 0.5.
Every cell was recomputed from the raw `run_eval.py` json.

| Description | Isolated | With 38 competitor skills | Q11 HAOS backups to Google Drive (should-not) | Q12 cloudflared HTTPS (should-not) | Q15 store Mosquitto add-on (should-not) | Q20 `ha os update` failing (should-not) |
|---|---|---|---|---|---|---|
| HEAD (524 characters) | 17/20, 1.00 / 0.27 | 19/20, 1.00 / 0.10 | 3/3, 0/3 | 2/3, 0/3 | 3/3, 3/3 | 0/3, 0/3 |
| D2 (383 characters) | 17/20, 1.00 / 0.30 | 19/20, 1.00 / 0.10 | 3/3, 0/3 | 3/3, 0/3 | 3/3, 3/3 | 0/3, 0/3 |
| D3 + D4 (744 characters) | 17/20, 1.00 / 0.23 | 19/20, 1.00 / 0.07 | 2/3, 0/3 | 2/3, 0/3 | 3/3, 2/3 | 0/3, 0/3 |
| D1 + D3 + D4 + D5 (499 characters) | 17/20, 1.00 / 0.33 | 20/20, 1.00 / 0.03 | 3/3, 0/3 | 3/3, 0/3 | 3/3, 1/3 | 1/3, 0/3 |

The four query columns read isolated, then competitors. Every cell
outside them is 3/3 on a should query or 0/3 on a should-not. Failed
queries per run: every text Q11, Q12 and Q15 isolated; HEAD, D2 and
D3 + D4 Q15 under competitors; D1 + D3 + D4 + D5 none under competitors.

**The should side is saturated.** All ten should queries hit 3/3 on all
four texts in both configurations. That includes Q5–Q8, built around
the four trigger words only the "Covers…" sentence carries (`musl`,
`/data`, `git archive`, `bash -lc`): D1 and D2 drop that sentence and
lose nothing visible. D3's symptom queries (Q3, Q4) and D4's
sleeping-workstation query (Q2) are 3/3 on HEAD too, so neither add has
a gain to show on the should side.

**Isolated, the siblings' queries go to whatever HAOS skill is listed.**
Q11 (`haos-cloud-backup`'s territory) and Q12 (`haos-https-tunnel`'s)
fire 2/3 or 3/3 on every text when the stand-in is the only skill
listed; under competitors, with both siblings listed, no text fires on
them. The isolated score is the same 17/20 for all four, so this
configuration does not separate the texts. D4's over-trigger probe, Q13
(a poller moved to a Pi running Raspberry Pi OS with systemd, no HA), is
0/3 on every run.

**Q15 is where the texts differ.** Installing the official Mosquitto
add-on from the store fires 3/3 isolated on every text and, under
competitors, 3/3 on HEAD and D2, 2/3 on D3 + D4 and 1/3 on D1 + D3 +
D4 + D5, the one pass. D5's removal of "installing" is the plausible
cause [unconfirmed: no text isolates D5, and the same text fires 3/3
isolated]. The label is arguable: the add-on is not self-written, but
the query is an add-on install on HAOS. A reader who labels Q15
should-trigger makes all four 18/20 isolated, HEAD, D2 and D3 + D4
20/20 under competitors and D1 + D3 + D4 + D5 19/20 there (1/3, a
fail); the same rule would then land D2, the shortest of the three. The
label was registered as arguable before the runs and kept as
should-not.

**Decision rule, registered before the runs (2026-10-14 23:15):** among
texts with the top score in both configurations and no query flipped to
fail against HEAD, the shortest wins; otherwise HEAD stands. Isolated,
all four tie at 17/20 with the same failed set; under competitors only
D1 + D3 + D4 + D5 has the top score, and its failed set (none) is a
subset of HEAD's (Q15). It is the only qualifier, so it lands
(maintainer's pick, option A of three: A land it by the rule, B rerun
HEAD and D1 + D3 + D4 + D5 isolated, C keep HEAD against the rule).

Limits of the measurement: 3 runs per query cannot see rate differences
below 1/3, and the decision rests on one query's 3/3 → 1/3 under
competitors; the harness is a fresh `claude -p` with project-only
setting sources, a command-file stand-in and `opus`, as before. The
isolated configuration lists no other skill at all, which is the case
of this skill installed without its siblings.

## 2. Harness (reapplied, not re-derived)

The scratch copy lived at `<scratchpad>/deploy-eval/`: `scripts/` copied
fresh from the installed `~/.agents/skills/skill-creator/scripts/`, the
three fixes reapplied by a replacement script asserting one match each,
then `diff -u` against the installed `run_eval.py` compared byte for byte
with the diff recorded in `2026-10-02-web-stack-selector-trigger-eval.md`
§2 (identical, 58 lines); an empty `.claude/` at the scratch root; a
fresh `pool/` of 38 links, every `~/.agents/skills/*/` with a `SKILL.md`
except `haos-addon-deploy`. Probe before the runs: a `sonnet` `claude -p`
from a call root with the pool linked and a stand-in command file listed
49 entries with the real `haos-addon-deploy` absent and the stand-in,
`haos-cloud-backup`, `haos-https-tunnel`, `web-stack-selector` and
`git-helper` present. Interpreter: the plan §2 scratch venv (Python
3.15.0, PyYAML 6.0.3). After the runs no call root was left under `w/`
and `~/.claude/commands` held no stand-in.

## 3. Eval set (reviewed in `eval_review_haos-addon-deploy.html`)

Ten should-trigger queries: a poller packaged and installed as a local
add-on (the literal "install" D5 removes), a poller moved off a sleeping
Mac onto the HA Pi (D4), the two update symptoms D3 names (Q3 the stale
`version_latest`, Q4 a rebuild running old code), and one query per
"Covers…" trigger word (Q5 a pip wheel failing on the Alpine base, Q6
state wiped on update, Q7 delivering one repo subdirectory to
`/addons`, Q8 `ha: command not found` over non-interactive SSH). Two are
Traditional Chinese: Q9 carries "部署到 RPi" verbatim, Q10 states the
intent and asks for options editable in the HA UI. Ten should-not
near-misses: the two HAOS siblings' territory (Q11, Q12), the same
poller on Raspberry Pi OS with systemd (Q13, D4's over-trigger probe),
HA Container with a compose service, the store Mosquitto add-on, a HACS
custom integration, a musl wheel failure with no HA, an HA automation,
and two Traditional Chinese HAOS questions (SD to SSD boot, `ha os
update` failing). Labels registered as arguable before the runs: Q14 (HA
Container, not HAOS) and Q15 (an add-on, but not self-written). Every
domain is `example.com`.

```json
[
  {
    "query": "I wrote a python script that polls my solar inverter's modbus every 30 s and pushes to mqtt. package it as a local add-on and install it on my home assistant OS raspberry pi so it runs all the time",
    "should_trigger": true
  },
  {
    "query": "my mac runs a node script every 5 minutes that checks a few online shops for price drops, but the mac sleeps at night and misses runs. there's a pi 4 running home assistant that's always on — can the script live on that instead?",
    "should_trigger": true
  },
  {
    "query": "bumped version to 1.3.0 in my local add-on's config.yaml and ran ha store reload, but update_available stays false and version_latest still says 1.2.0. HAOS on a pi",
    "should_trigger": true
  },
  {
    "query": "I copied the new main.py into /addons/poller and rebuilt my homemade HA app, but the log shows it's still running the old code",
    "should_trigger": true
  },
  {
    "query": "pip install pandas fails building wheels inside the Dockerfile of my custom home assistant add-on, it uses the alpine base image. which base image should I use instead?",
    "should_trigger": true
  },
  {
    "query": "every time I update my own home assistant add-on its sqlite database and saved settings are wiped. HAOS 2026.10 on an rpi 5",
    "should_trigger": true
  },
  {
    "query": "what's the cleanest way to get one subdirectory of my git repo onto /addons on the HAOS box? scp of the working tree keeps dragging .venv and .git along",
    "should_trigger": true
  },
  {
    "query": "ssh ha 'ha apps update local_poller' fails with 'ha: command not found', but the same command works when I log into the HAOS ssh add-on interactively",
    "should_trigger": true
  },
  {
    "query": "幫我把這個 python 監控程式部署到 RPi 上的 HAOS,做成 add-on 24 小時跑",
    "should_trigger": true
  },
  {
    "query": "我寫了一個爬蟲要一直跑,家裡樹莓派裝的是 Home Assistant OS,要怎麼讓它在上面常駐,而且 API key 這些設定想在 HA 介面裡改",
    "should_trigger": true
  },
  {
    "query": "upload my HAOS backups to google drive every night, capped at 5 Mbps so my upstream isn't saturated, and keep 7 dailies",
    "should_trigger": false
  },
  {
    "query": "set up cloudflared on my HAOS box so ha.example.com reaches home assistant over https without opening router ports",
    "should_trigger": false
  },
  {
    "query": "move my python poller off my laptop (it sleeps) onto a raspberry pi running raspberry pi OS lite — write a systemd service that restarts it on failure and starts at boot",
    "should_trigger": false
  },
  {
    "query": "home assistant runs with docker compose on ubuntu (not HAOS). add my python script as another service in the same compose file so it starts with HA",
    "should_trigger": false
  },
  {
    "query": "install the official Mosquitto broker add-on on HAOS from the add-on store and create an mqtt user for my zigbee2mqtt",
    "should_trigger": false
  },
  {
    "query": "write a custom_components integration for my inverter that exposes power and energy sensors in home assistant, installable through HACS",
    "should_trigger": false
  },
  {
    "query": "my alpine-based docker image fails pip install numpy with musl wheel errors in CI. should I switch to python:3.12-slim?",
    "should_trigger": false
  },
  {
    "query": "write a home assistant automation that turns off the porch light at sunrise and on at sunset",
    "should_trigger": false
  },
  {
    "query": "樹莓派 4 上的 HAOS 想從 SD 卡改成 USB SSD 開機,資料要怎麼搬過去",
    "should_trigger": false
  },
  {
    "query": "HAOS 的 ha os update 一直失敗,說空間不足,樹莓派 4,要怎麼升級到 2026.10",
    "should_trigger": false
  }
]
```

## 4. Candidate descriptions scored

HEAD is the frontmatter at 2026-10-14 (`9b74d4d`):

> Deploy a self-written app as a Home Assistant OS (HAOS) local add-on (now labelled 'app' in the HA UI/CLI) on a Raspberry Pi for 24/7 operation. Covers the full battle-tested procedure and every known pitfall: git archive delivery, ha CLI quirks (bash -lc, store reload, update vs rebuild), add-on options as config, /data persistence, and base-image (musl vs glibc) selection. Use when deploying, installing, updating or debugging a HAOS local add-on / HA app, or when the user mentions 部署到 RPi / HAOS / HA add-on / HA app.

D2, the reviewer's full rewrite, verbatim:

> Deploy, update or debug a self-written app running 24/7 as a Home Assistant OS (HAOS) local add-on (labelled 'app' in newer HA UI/CLI) on a Raspberry Pi. Use when delivering code to /addons, installing or updating a local add-on / HA app, setting its options, picking its base image, when ha CLI calls fail unauthorized, or when the user mentions 部署到 RPi / HAOS / HA add-on / HA app.

D3 + D4, the two adds applied to HEAD verbatim: D4 replaces "for 24/7
operation" with "for 24/7 operation, e.g. moving a poller or monitor off
a workstation that sleeps"; D3 appends the "Also consult when…"
sentence:

> Deploy a self-written app as a Home Assistant OS (HAOS) local add-on (now labelled 'app' in the HA UI/CLI) on a Raspberry Pi for 24/7 operation, e.g. moving a poller or monitor off a workstation that sleeps. Covers the full battle-tested procedure and every known pitfall: git archive delivery, ha CLI quirks (bash -lc, store reload, update vs rebuild), add-on options as config, /data persistence, and base-image (musl vs glibc) selection. Use when deploying, installing, updating or debugging a HAOS local add-on / HA app, or when the user mentions 部署到 RPi / HAOS / HA add-on / HA app. Also consult when an add-on update is not detected (update_available stays false, version_latest shows the old version) or a rebuild keeps running old code.

D1 + D3 + D4 + D5, the text that landed: D3 + D4 plus D1, which deletes
the "Covers…" sentence, and D5, which replaces "deploying, installing,
updating or debugging" with "deploying, updating or debugging". It has
no `: `, so YAML would accept it bare; the frontmatter keeps the double
quotes HEAD had, a one-line diff:

> Deploy a self-written app as a Home Assistant OS (HAOS) local add-on (now labelled 'app' in the HA UI/CLI) on a Raspberry Pi for 24/7 operation, e.g. moving a poller or monitor off a workstation that sleeps. Use when deploying, updating or debugging a HAOS local add-on / HA app, or when the user mentions 部署到 RPi / HAOS / HA add-on / HA app. Also consult when an add-on update is not detected (update_available stays false, version_latest shows the old version) or a rebuild keeps running old code.
