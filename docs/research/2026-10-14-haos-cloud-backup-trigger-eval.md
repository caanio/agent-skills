# `haos-cloud-backup` trigger eval: HEAD and D1–D4

Version: 1.0.1 | Date: 2026-10-14 | Status: decided 2026-10-14 (HEAD
stands, no `SKILL.md` edit; D1–D4 scores one query worse in both
configurations, on Q20 isolated and Q16 under competitors; the one
shared failure, Q17, is text-independent; the pass moves on to
`haos-addon-deploy`)

The description run that plan §2 of
`2026-10-01-skill-authoring-pass-plan.md` schedules after the 2026-10-08
body pass. Two descriptions were scored with `skill-creator`'s
`run_eval.py` (20 queries × 3 runs, `opus`, 10 workers, `--timeout 90`)
in two configurations, four runs of 4–6 minutes each (15:08–15:28); no
log carries a timeout or an error. `run_loop.py` was not started, for the
reason the `completion-gate` and `haos-https-tunnel` runs recorded:
HEAD's one failure is a should-not query that both texts fail, so the
loop would propose text against a hook no trigger clause in this set
moves.

## 1. Results

Mean trigger rate over the 10 should-trigger queries / the 10 should-not
queries; `pass` counts queries whose rate is on the right side of 0.5.

| Description | Isolated | With 38 competitor skills | Q17 SMB share as backup location (should-not) | Q20 HA on Docker to Backblaze B2 (should-not) |
|---|---|---|---|---|
| HEAD (613 characters) | 19/20, 1.00 / 0.07 | 19/20, 1.00 / 0.07 | 2/3, 2/3 | 0/3, 0/3 |
| D1–D4 (587 characters) | 18/20, 1.00 / 0.17 | 18/20, 1.00 / 0.20 | 3/3, 3/3 | 2/3, 1/3 |

The one other mixed cell: Q16 (restore a backup onto a fresh card,
should-not) D1–D4 under competitors 2/3, a failure. Every other cell is
3/3 on a should query or 0/3 on a should-not. Failed queries per run:
HEAD Q17 in both configurations; D1–D4 Q17 and Q20 isolated, Q17 and
Q16 under competitors.

**The should side is saturated.** All ten should queries hit 3/3 on both
texts in both configurations, the two Traditional Chinese queries that
carry "異地備份" verbatim and the two that state the intent without it
included. D3's cut of the trigger sentence's "Google Drive" costs
nothing visible: Q4 (native Google Drive location) and Q8 (異地備份 to
Google Drive) hit 3/3 on D1–D4.

**D1–D4 loosens the should-not side.** Q20, a Docker-on-Ubuntu HA
install backing up its config folder to B2, never fires on HEAD and
fires 2/3 isolated (a failure) and 1/3 under competitors (a pass) on
D1–D4; Q16, the restore query, never fires on HEAD and fails 2/3 under
competitors on D1–D4. Which of the four edits does it is not measured;
the splits that would localise it were
offered and declined, since the 26 characters D1–D4 saves are too few
to pay for a regression. D1–D4 is refuted as a set; no single D is.

**Q17 is text-independent.** Saving automatic backups to a NAS share
instead of the SD card fires 2/3 or 3/3 on every run. The label is
arguable: the query asks to get backups off the SD card, the
description's own first clause, but to a LAN share rather than the
cloud. A reader who labels Q17 should-trigger makes HEAD 20/20 in both
configurations. The decision does not turn on the label.

HEAD stands (maintainer's pick, option A of three: A HEAD stands, B run
the splits D1–D3 and D1 + D3 + D4 to find Q20's cause, C land D1 + D3
after two confirming runs).

Limits of the measurement: 3 runs per query cannot see rate differences
below 1/3; the harness is a fresh `claude -p` with project-only setting
sources, a command-file stand-in and `opus`, as before. The 2026-10-08
body-pass reviewer's D1–D4 texts were not preserved (the log entry and
`87a34c0`'s message paraphrase them); §4 records the text scored here,
hand-applied from that paraphrase.

## 2. Harness (reapplied, not re-derived)

The scratch copy lived at `<scratchpad>/backup-eval/`: `scripts/` copied
fresh from the installed `~/.agents/skills/skill-creator/scripts/`, the
three fixes reapplied by a replacement script asserting one match each,
then `diff -u` against the installed `run_eval.py` compared byte for byte
with the diff recorded in `2026-10-02-web-stack-selector-trigger-eval.md`
§2 (identical); an empty `.claude/` at the scratch root; a fresh `pool/`
of 38 links, every `~/.agents/skills/*/` with a `SKILL.md` except
`haos-cloud-backup`. Probe before the runs: a `sonnet` `claude -p` from a
call root with the pool linked and a stand-in command file listed 49
entries with `haos-cloud-backup` absent and the stand-in,
`haos-addon-deploy`, `haos-https-tunnel`, `web-stack-selector` and
`git-helper` present. Interpreter: the plan §2 scratch venv (Python
3.15.0, PyYAML 6.0.3). After the runs no call root was left under `w/`
and `~/.claude/commands` held no stand-in.

## 3. Eval set (reviewed in `eval_review_haos-cloud-backup.html`, used as drafted)

Ten should-trigger queries covering the description's branches at least
once each: backups off the SD card to a named cloud, the SD card filling
with backup tars, a rate-limit request on a small uplink, the two
redirects where the user asks for a rejected alternative (the native
Google Drive location, the sabeechen add-on), the Rclone Backup add-on's
chicken-and-egg start failure, and GFS thinning on a remote that never
deletes. Four are Traditional Chinese: two carry the description's own
"異地備份" verbatim, two state the intent without it. Ten should-not
near-misses: the two HAOS siblings' territory (`haos-addon-deploy`,
`haos-https-tunnel`), rclone with `--bwlimit` for a non-HA NAS, Frigate
stream bitrate on a small uplink, an SD card filled by the recorder
database, restoring a backup onto a new card, a NAS share as HA's
backup location, a Google Drive API upload script, Synology Hyper Backup
with GFS-style retention, and HA on Docker backing up to Backblaze B2.
Every domain is `example.com`.

```json
[
  {"query": "HA 的備份現在只存在樹莓派的記憶卡上,卡壞了就全沒了。HAOS 每天會自動備份,想讓它每天自動放一份到 Dropbox", "should_trigger": true},
  {"query": "the SD card in my home assistant OS raspberry pi is almost full and it's all the backup tars piling up in /backup. get them offloaded to google drive and pruned automatically", "should_trigger": true},
  {"query": "when HAOS uploads its nightly backup my 10 Mbps upstream gets pinned and VoIP calls drop. how do I rate-limit the backup upload?", "should_trigger": true},
  {"query": "turn on Home Assistant's built-in Google Drive backup location on my HAOS pi 4, the google account is ready", "should_trigger": true},
  {"query": "install sabeechen's Home Assistant Google Drive Backup add-on on my HAOS rpi and set it to keep 10 backups in drive", "should_trigger": true},
  {"query": "the jcwillox rclone backup add-on on HAOS won't start, the log says the remote 'gdrive' isn't in the config. the jobs are already in the options. what's wrong", "should_trigger": true},
  {"query": "my HA backups already go to dropbox via rclone but nothing ever gets deleted. I want 7 dailies, 4 sunday weeklies and 12 monthlies kept and the rest thinned automatically. HAOS on a pi 4", "should_trigger": true},
  {"query": "Home Assistant 想做異地備份,HAOS 跑在樹莓派上,要傳到 Google Drive,幫我規劃怎麼做", "should_trigger": true},
  {"query": "HA 的異地備份每天上傳的時候家裡網路就卡住,上傳頻寬只有 20M,可以限速嗎?系統是 HAOS", "should_trigger": true},
  {"query": "樹莓派上的 HAOS 每天自動備份都堆在 SD 卡裡快滿了,想自動丟一份到雲端硬碟,舊的自動清掉,而且上傳不要把家裡頻寬吃光", "should_trigger": true},
  {"query": "deploy my python flask dashboard as a local add-on on my HAOS raspberry pi — write the Dockerfile and config.yaml and install it with the ha CLI", "should_trigger": false},
  {"query": "set up cloudflared on my HAOS box so ha.example.com reaches home assistant over https without opening router ports", "should_trigger": false},
  {"query": "on my ubuntu NAS, write an rclone cron job that syncs /srv/photos to google drive with --bwlimit 2M and keeps 30 days of deleted-file versions", "should_trigger": false},
  {"query": "watching my frigate cameras remotely through home assistant eats all my upstream. how do I lower the stream bitrate for remote viewing", "should_trigger": false},
  {"query": "HAOS SD card is almost full and home-assistant_v2.db is 9 GB. how do I shrink the recorder database and purge old history", "should_trigger": false},
  {"query": "my pi's SD card died. I have a home assistant backup .tar downloaded on my laptop — how do I restore it onto a fresh HAOS install on a new card", "should_trigger": false},
  {"query": "add my synology SMB share as a network storage backup location in HAOS so the automatic backups land on the NAS instead of the SD card", "should_trigger": false},
  {"query": "write a python script that uploads a daily CSV report to a shared google drive folder using a service account", "should_trigger": false},
  {"query": "Synology NAS 的 Hyper Backup 要備份到 Google Drive,想限制上傳速度,並保留 7 天、4 週、12 個月的版本,怎麼設定", "should_trigger": false},
  {"query": "Home Assistant 是用 docker compose 跑在 Ubuntu 上(不是 HAOS),想把 config 資料夾每天備份到 Backblaze B2", "should_trigger": false}
]
```

## 4. Candidate descriptions scored

HEAD is the frontmatter at 2026-10-14 (`87a34c0`):

> Ship Home Assistant OS (HAOS) backups off the SD card to cloud storage (Google Drive or any rclone remote) with an upload bandwidth cap and a GFS-style retention policy (daily/weekly/monthly thinning), using the Rclone Backup add-on. Use when the user wants HA backups uploaded to Google Drive / Dropbox / cloud, complains the SD card is filling up with backups, needs 異地備份 for Home Assistant, or asks to rate-limit / throttle backup uploads because home upstream bandwidth is scarce. Also consult before suggesting the native google_drive backup agent or the sabeechen add-on — neither can throttle upload speed.

D1–D4 hand-applied from the body-pass log entry's paraphrase (2026-10-08):
D1 collapses "rate-limit / throttle" to "throttle", D2 drops "— neither
can throttle upload speed", D3 drops the trigger sentence's "Google Drive
/ " (the second of the two; the first, in the opening's parenthesis,
stays), D4 adds "(now labelled 'app' in the HA UI/CLI)" after "the Rclone
Backup add-on", the phrase `haos-addon-deploy`'s description already
uses. 613 → 587 characters; neither text contains `: `, so either is
valid as a bare YAML value:

> Ship Home Assistant OS (HAOS) backups off the SD card to cloud storage (Google Drive or any rclone remote) with an upload bandwidth cap and a GFS-style retention policy (daily/weekly/monthly thinning), using the Rclone Backup add-on (now labelled 'app' in the HA UI/CLI). Use when the user wants HA backups uploaded to Dropbox / cloud, complains the SD card is filling up with backups, needs 異地備份 for Home Assistant, or asks to throttle backup uploads because home upstream bandwidth is scarce. Also consult before suggesting the native google_drive backup agent or the sabeechen add-on.
