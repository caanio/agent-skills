# `haos-https-tunnel` trigger eval: HEAD, D1–D4 and two splits

Version: 1.0.0 | Date: 2026-10-04 | Status: decided 2026-10-04 (D1–D4
lands, the first description change this pass has made; the four texts
tie at 19/20 in both configurations, so the pick rests on length; the
one shared failure, Q19, is text-independent and stays open; the pass
moves on to `haos-cloud-backup`)

The description run that plan §2 of
`2026-10-01-skill-authoring-pass-plan.md` schedules after the 2026-10-04
body pass. Four descriptions were scored with `skill-creator`'s
`run_eval.py` (20 queries × 3 runs, `opus`, 10 workers, `--timeout 90`)
in two configurations, eight runs of 3–4 minutes each (19:03–19:29). The
harness fixes of `2026-10-02-web-stack-selector-trigger-eval.md` §2 were
reapplied on a scratch copy (§2 below). `run_loop.py` was not started,
for the reason the `completion-gate` run recorded: HEAD's one failure is
a should-not query that every candidate shares, so the loop would
propose text against a hook (`cloudflared` in a non-HA query) that no
trigger clause in this set moves, and its 40 % hold-out can park that
one query on the test side and exit `all_passed` at iteration 0.

## 1. Results

Mean trigger rate over the 10 should-trigger queries / the 10 should-not
queries; `pass` counts queries whose rate is on the right side of 0.5.
Every text fails the same single query in both configurations.

| Description | Isolated | With 37 competitor skills | Q19 cloudflared QUIC on a Proxmox VM (should-not) |
|---|---|---|---|
| HEAD | 19/20, 1.00 / 0.07 | 19/20, 1.00 / 0.13 | 2/3, 3/3 |
| D1–D4 | 19/20, 1.00 / 0.10 | 19/20, 1.00 / 0.13 | 3/3, 3/3 |
| HEAD + D3 only | 19/20, 0.97 / 0.10 | 19/20, 1.00 / 0.17 | 2/3, 3/3 |
| D1 + D2 + D4 (D3 restored) | 19/20, 1.00 / 0.07 | 19/20, 1.00 / 0.13 | 2/3, 3/3 |

The mixed cells, none decisive: Q6 (`ssl_certificate` in the `http:`
block, should) HEAD + D3 isolated 2/3; Q11 (Nextcloud behind a tunnel,
should-not) HEAD + D3 1/3 in both configurations; Q14 (Tailscale add-on,
should-not) HEAD and HEAD + D3 1/3 under competitors; Q15 (Nabu Casa
Alexa, should-not) D1–D4 and D1 + D2 + D4 1/3 under competitors. Every
other cell is 3/3 on a should query or 0/3 on a should-not.

**D3 is safe.** The two Traditional Chinese queries written without the
description's own phrases (Q9 "在外面用手機想連回家", Q10 "不想暴露家裡的
IP,也不想每台手機裝 VPN") hit 3/3 on every text, and the two that carry
the phrases verbatim (Q7 "HA App 外部連線", Q8 "HA 走 https") hit 3/3 on
D1–D4, which lacks them. The phrases buy nothing this harness can see;
the collapsed list of two branches (HTTPS or remote access; cloudflared
or Cloudflare Tunnel) carries all ten should queries, the two redirects
(Q5 DuckDNS plus port 443, Q6 `ssl_certificate`) included. This closes
the body pass's F12 leftover: the description's "HA App" phrase goes
with the rest of the list.

**Q19 is text-independent.** The Proxmox `cloudflared` QUIC query fires
in 21 of 24 runs across the four texts, the three that say "for a HAOS
box" included. The hook is `cloudflared` itself; no trigger clause in
this set moves it, and a clause scoping the skill away from other hosts
would be a negation the body-pass reviewer's own levers advise against,
and an untested candidate. It stays open. The label is also arguable:
the skill's §6 ⚠️ is exactly the QUIC-to-http2 fallback the query asks
about, so a reader who labels Q19 should-trigger makes all eight runs
20/20. The decision does not turn on the label.

**The pick rests on length.** With accuracy tied at 3 runs per query,
the one measured difference between HEAD and D1–D4 is the context load
the body-pass reviewer's D5 named: 555 → 319 characters on every turn
of every session. D1–D4 lands (maintainer's pick, option A of three: A
D1–D4, B HEAD stands on the two earlier runs' tie precedent, C D1 + D2
+ D4 keeping the two phrases as unmeasured insurance). A confirmatory
re-run at 6 runs per query was offered and declined: it would move the
resolution from 1/3 to 1/6 without changing the decision.

Limits of the measurement: 3 runs per query cannot see rate differences
below 1/3, and the mixed cells were not re-run at a higher count because
no decision turned on them. The harness is a fresh `claude -p` with
project-only setting sources, a command-file stand-in and `opus`, as
before; the stand-in writes the description as a YAML block scalar, so
it did not see the colon in D1's opening ("(HAOS): give"), which makes
the text invalid as a bare YAML value. The landed frontmatter wraps the
description in double quotes, as six other skills in this repo already
do; the text itself is byte-identical to the one scored.

## 2. Harness (reapplied, not re-derived)

The scratch copy lives at `<scratchpad>/tunnel-eval/`: `scripts/` copied
fresh from the installed `~/.agents/skills/skill-creator/scripts/`, the
three fixes reapplied by a replacement script asserting one match each,
then `diff -u` against the installed `run_eval.py` compared byte for byte
with the diff recorded in `2026-10-02-web-stack-selector-trigger-eval.md`
§2 (identical, five hunks); an empty `.claude/` at the scratch root; a
fresh `pool/` of 37 links, every `~/.agents/skills/*/` with a `SKILL.md`
except `haos-https-tunnel` (the previous runs' pools held 51; skills were
uninstalled in between). Probe before the runs: a `claude -p` from a call
root with the pool linked and a stand-in command file listed 47 entries
with `haos-https-tunnel` absent and `haos-addon-deploy`,
`haos-cloud-backup`, `web-stack-selector` and `git-helper` present. The
recorded run script named a pyenv 3.13 interpreter that no longer exists
on this machine; the runs used the plan §2 scratch venv
(`venv/bin/python`, Python 3.14, PyYAML 6.0.3) and are otherwise the
recorded script with the skill path and baseline names swapped. The env
name `WSS_SKILL_POOL` is unchanged so the recorded diff stays current.

## 3. Eval set (reviewed in `eval_review_haos-https-tunnel.html`, used as drafted)

Ten should-trigger queries covering the description's branches at least
once each: the HTTPS/remote-access intent with no tool named, an explicit
`cloudflared` add-on in trouble, "no ports, no home IP in DNS", the
Companion app external URL, and two redirects where the user asks for a
rejected alternative (DuckDNS plus port 443, `ssl_certificate` in the
`http:` block). Four are Traditional Chinese: two carry the description's
own phrases verbatim ("HA App 外部連線", "HA 走 https"), two state the same
intent without them, so D3's synonym cut has a measurement. Ten
should-not near-misses: a Cloudflare Tunnel for a non-HA service, the two
HAOS siblings' territory (`haos-addon-deploy`, `haos-cloud-backup`), a
user already on Tailscale, a Nabu Casa user with an Alexa problem, a plain
Cloudflare DNS task, HA on Docker behind nginx, HA Core's `trusted_proxies`
for a Caddy box, `cloudflared` QUIC fallback on a Proxmox VM, and the
Companion app's internal-URL switching for a Nabu Casa user. Every domain
is `example.com`.

```json
[
  {"query": "my home assistant runs on a raspberry pi 4 with HAOS, i want to open the dashboard from my phone when im not home, over https. router is a cheap ISP box. how should i set this up?", "should_trigger": true},
  {"query": "I've got the brenner-tobias cloudflared add-on installed on my HAOS box but the log just loops on 'Please open the following URL' — walk me through finishing the setup so ha.example.com actually resolves", "should_trigger": true},
  {"query": "want remote access to HA (HAOS on a pi) but I'm not opening ports on my router or putting my home IP in DNS. I own example.com on cloudflare already. what's the plan", "should_trigger": true},
  {"query": "the home assistant companion app on my iphone only works on wifi. I need an external URL for it that's https. the box is HAOS 18 on an rpi. set it up for me", "should_trigger": true},
  {"query": "set up duckdns + letsencrypt on my HAOS raspberry pi so I can get in from outside, I'll forward 443 on the router", "should_trigger": true},
  {"query": "add ssl_certificate and ssl_key to the http: block in my HAOS configuration.yaml so HA is on https, I have a cert for my domain already", "should_trigger": true},
  {"query": "我家的 Home Assistant 是 HAOS 裝在樹莓派上,想讓 HA App 外部連線可以用,出門也能開,網域在 Cloudflare 上,幫我設", "should_trigger": true},
  {"query": "想讓 HA 走 https,不想在路由器開 port,HAOS 跑在 RPi 4,網域 example.com 已經在 Cloudflare,下一步怎麼做", "should_trigger": true},
  {"query": "樹莓派上的 Home Assistant OS,在外面用手機想連回家看攝影機跟開冷氣,家裡是浮動 IP,有什麼安全的做法?", "should_trigger": true},
  {"query": "幫我把 HAOS 的登入頁弄到網路上可以用,不想暴露家裡的 IP,也不想每台手機裝 VPN", "should_trigger": true},
  {"query": "I run a nextcloud docker container on my NAS and want to expose it via cloudflare tunnel with cloudflared in the same docker compose. write the compose service and the ingress config", "should_trigger": false},
  {"query": "deploy my python flight price monitor as a local add-on on my HAOS raspberry pi — build the Dockerfile and config.yaml and install it with the ha CLI", "should_trigger": false},
  {"query": "HAOS backups are filling up my SD card, I want them going to Google Drive nightly but capped at 2 MB/s upload so my video calls survive", "should_trigger": false},
  {"query": "I already use tailscale on all my devices. install the tailscale add-on on my HAOS box and get it joined to my tailnet so I can hit it by its 100.x address", "should_trigger": false},
  {"query": "I pay for Nabu Casa. the remote UI toggle is on but alexa skill linking keeps failing with 'unable to link', help me debug it", "should_trigger": false},
  {"query": "add an MX record and a TXT spf record for example.com in cloudflare via the API, zone id and token are in .env", "should_trigger": false},
  {"query": "home assistant container (docker compose on ubuntu) behind nginx proxy manager with letsencrypt. getting 400 bad request after turning on the proxy host. fix my nginx config", "should_trigger": false},
  {"query": "home assistant core (venv install on debian) logs 'received X-Forwarded-For header from an untrusted proxy 192.168.1.5' — that's my caddy box. how do I fix the http: block", "should_trigger": false},
  {"query": "cloudflared on my proxmox VM keeps logging 'QUIC connection failed' and falls back to http2, is that a problem and how do I force quic", "should_trigger": false},
  {"query": "my home assistant companion app keeps switching to the internal url and dropping when i leave wifi — remote is via nabu casa. fix the app's url settings", "should_trigger": false}
]
```

## 4. Candidate descriptions scored

HEAD is the frontmatter at 2026-10-04 (`e279647`):

> Give a Home Assistant OS (HAOS) instance a real HTTPS URL — inside and outside the LAN — via a Cloudflare Tunnel (cloudflared add-on), with no port forwarding and no device-side install. Use when the user wants HTTPS / remote access / external access for Home Assistant, mentions cloudflared, Cloudflare Tunnel, HA App 外部連線, HA 走 https, or asks how to reach HA from outside without exposing their home IP. Also consult it before ever suggesting DuckDNS, port forwarding, or HA-native SSL for a HAOS box — this route beats those on safety and side effects.

D1–D4 hand-applied from the body-pass reviewer's description findings (log
entry 2026-10-04): D1 front-loads "Cloudflare Tunnel (cloudflared
add-on)" and drops the later "via a Cloudflare Tunnel (cloudflared
add-on)", D2 deletes "— inside and outside the LAN —" and "with no port
forwarding and no device-side install", D3 collapses the synonym list to
two branches (HTTPS or remote access; cloudflared or Cloudflare Tunnel),
D4 drops "ever" and "— this route beats those on safety and side
effects". D5 (length) is the consequence, 555 → 319 characters, not a
separate edit:

> Cloudflare Tunnel (cloudflared add-on) HTTPS for Home Assistant OS (HAOS): give a HAOS instance a real HTTPS URL. Use when the user wants HTTPS or remote access for Home Assistant, or mentions cloudflared or Cloudflare Tunnel. Also consult it before suggesting DuckDNS, port forwarding, or HA-native SSL for a HAOS box.

HEAD + D3 only: HEAD with the trigger sentence collapsed, nothing else
changed (449 characters):

> Give a Home Assistant OS (HAOS) instance a real HTTPS URL — inside and outside the LAN — via a Cloudflare Tunnel (cloudflared add-on), with no port forwarding and no device-side install. Use when the user wants HTTPS or remote access for Home Assistant, or mentions cloudflared or Cloudflare Tunnel. Also consult it before ever suggesting DuckDNS, port forwarding, or HA-native SSL for a HAOS box — this route beats those on safety and side effects.

D1 + D2 + D4 (D3 restored): the D1–D4 text with HEAD's full trigger
sentence kept (425 characters):

> Cloudflare Tunnel (cloudflared add-on) HTTPS for Home Assistant OS (HAOS): give a HAOS instance a real HTTPS URL. Use when the user wants HTTPS / remote access / external access for Home Assistant, mentions cloudflared, Cloudflare Tunnel, HA App 外部連線, HA 走 https, or asks how to reach HA from outside without exposing their home IP. Also consult it before suggesting DuckDNS, port forwarding, or HA-native SSL for a HAOS box.
