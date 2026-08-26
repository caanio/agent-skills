---
name: haos-addon-deploy
description: "Deploy a self-written app as a Home Assistant OS (HAOS) local add-on (now labelled 'app' in the HA UI/CLI) on a Raspberry Pi for 24/7 operation. Covers the full battle-tested procedure and every known pitfall: git archive delivery, ha CLI quirks (bash -lc, store reload, update vs rebuild), add-on options as config, /data persistence, and base-image (musl vs glibc) selection. Use when deploying, installing, updating or debugging a HAOS local add-on / HA app, or when the user mentions 部署到 RPi / HAOS / HA add-on / HA app."
---

# HAOS Local Add-on Deployment (RPi, 24/7)

Deploy a self-written long-running app (poller, monitor, etc.) as a Home Assistant OS
**local add-on**, running 24/7 on a Raspberry Pi instead of a workstation that sleeps.
Every step below has been verified on real hardware; all pitfalls are marked ⚠️.
In the examples, `<alias>` = your SSH alias for the HA box, `<slug>` = add-on slug (becomes
`local_<slug>` once installed), and `$C` = the Docker container name **resolved at runtime**
by the snippet in Scope below — never hardcoded, because its prefix differs between Supervisor
versions. Substitute your own values; nothing here is host-specific.

## Scope

- Applies to **Home Assistant OS** (or Supervised) installs only — Container/Core
  installs have no Supervisor, no `/addons`, no `ha` CLI; this skill does not apply.
- Battle-tested on a Raspberry Pi 4 (**aarch64**), HAOS **17.x–18.1** (Supervisor + Docker
  appliance; the container naming below was observed on Supervisor **2026.07.5**), with the
  **Advanced SSH & Web Terminal** add-on (Protection mode off — see §0, §8).
- ⚠️ Recent HAOS labels add-ons as **"Apps"** in the UI and CLI (`ha apps`), and the rename
  is **half-applied** — never assume which spelling a given surface uses, always check:
  - still `addon`: the `/addons` delivery path, the Supervisor REST API (`/addons/<slug>/…`),
    and the Docker **image** name (`local/<arch>-addon-<slug>:<version>`)
  - now `app`: the CLI (`ha apps`), the Supervisor's own store path (`/data/apps/local/…`),
    and the Docker **container** name (`app_local_<slug>`, seen on Supervisor 2026.07.5)
  - ⚠️ **Do not key this off the HAOS version.** The container name is produced by
    **Supervisor**, which auto-updates independently of the OS image, so "newer HAOS ⇒
    `app_`" is not a sound rule — and only one Supervisor version has actually been observed
    here. Never hardcode either prefix; resolve `$C` once and reuse it everywhere:
    ```bash
    # -a so a stopped add-on is still found — those are exactly the ones you need to inspect
    C=$(ssh <alias> "sudo docker ps -a --format '{{.Names}}' \
         | grep -E '^(app|addon)_local_<slug>$'") || true
    [ -n "$C" ] || { echo "no container for <slug> — installed under a different slug?" >&2; exit 1; }
    ```
    Without that guard an empty `$C` turns `docker exec $C python3 …` into
    `docker exec python3 …`, and Docker reports "no such container: python3" — a confusing
    error that sends you looking in the wrong place.

## 0. Global Rules (read first)

- ⚠️ **Every `ha` CLI / Supervisor API call needs a login shell**, which loads
  `SUPERVISOR_TOKEN`; without it the call fails with `unauthorized`. Plain
  `docker`/`ls`/`grep` are unaffected — only `ha` and direct `http://supervisor` calls
  need the token.
  - Single command: `ssh <alias> 'bash -lc "ha …"'`
  - Multi-step: **`ssh <alias> bash -l -s <<'EOF' … EOF`** — the `-l` is what makes a
    heredoc work; a bare `bash -s` heredoc is a *non-login* shell and every `ha` call inside
    it fails.
  - ⚠️ **How that failure looks matters.** `ha` writes
    `Error: unauthorized: missing or invalid API token` to **stderr** and exits **1**. So a
    pipeline that only consumes stdout (`ha apps info … | grep …`) shows an *empty result*,
    which reads exactly like "that field isn't set" rather than "the call failed". Check the
    exit code, or add `2>&1`, before concluding anything from an empty output.
- ⚠️ **Disable Protection mode on the SSH add-on** (toggle on its info page), otherwise
  you can't reach the Supervisor API.
- ⚠️ CLI names: use **`ha apps`** (`ha addons` is deprecated); to re-detect local add-ons
  use **`ha store reload`** (`ha apps reload` doesn't exist).
- ⚠️ **Never run the same app on two machines at once** (workstation daemon + RPi add-on):
  it doubles the load on external APIs/sites, and anything with rotating tokens will have
  the two instances kicking each other out. Once migrated, stop the workstation copy and
  disable its autostart.
- A single-SD-card RPi has no redundancy: **take a full HA backup before touching anything**,
  and download it off the card. The web download is slow (HA streaming bottleneck);
  `scp <alias>:/backup/<file>.tar ~/backups/` is noticeably faster.

## 1. Repo Layout

Keep all HA-specific files in a `haos/` folder in the repo; flatten on delivery:

```
haos/
├── config.yaml      # add-on manifest (name/slug/version/arch/options/schema)
├── Dockerfile
├── run.sh           # entrypoint: create /data subdirs, then exec the main app
└── .dockerignore    # exclude .env, logs/, __pycache__, .git/
```

`config.yaml` essentials:

```yaml
name: My App
slug: my_app            # installed as local_my_app
version: "1.0.0"        # ⚠️ bump this to make HA detect a code update
arch: [aarch64, amd64]
startup: application
boot: auto
map:
  - data:rw             # /data = persistent volume, survives rebuild/update
init: false
options:                # user-editable settings (HA web UI "Configuration" tab)
  some_secret: ""
schema:
  some_secret: password # the password type masks the value in the UI
```

⚠️ **Base image choice (musl vs glibc)**: pure Python/requests → `python:3.12-alpine`
is fine (small); but anything depending on the **onnxruntime / opencv / numpy ecosystem**
(e.g. ddddocr) **must use `python:3.12-slim`** (Debian glibc) — those packages ship no
musllinux wheels, so on Alpine pip falls back to source builds (hangs or fails).
Non-headless opencv additionally needs `apt-get install libgl1 libglib2.0-0`.
Not using the HA official base image → **no bashio**; the app reads its own config
from `/data/options.json` instead.

Idiomatic config loading: if `/data/options.json` exists, upper-case each key into an
environment variable (parse list-typed fields, e.g. a watch list, directly); if it
doesn't (local development), fall back to `.env`.

## 2. Deliver the Code (run on the workstation, into /addons)

The device never clones (avoids credentials for private repos); the workstation pushes
a snapshot instead. Pick one:

**Project has git commits (preferred once it does):** ships exactly the committed tree,
so no stray local files (a half-finished edit, a debug script) ride along by accident —
that guarantee is the whole reason this is the default.

```bash
# /addons is owned by root; create the folder once to gain write access
ssh <alias> 'sudo mkdir -p /addons/<slug> && sudo chown $(whoami) /addons/<slug>'
git archive --format=tar HEAD | ssh <alias> 'tar -x -C /addons/<slug>'
git archive --format=tar HEAD haos | ssh <alias> 'tar -x --strip-components=1 -C /addons/<slug>'
ssh <alias> 'rm -rf /addons/<slug>/haos'   # remove the duplicate haos/ subfolder from line 1
```

**No git repo yet:** ship the working tree directly with `tar`, naming the paths this
add-on actually needs (same reasoning as §2's duplicate-slug fix below — never tar the
whole project root blindly):

```bash
ssh <alias> 'sudo mkdir -p /addons/<slug> && sudo chown $(whoami) /addons/<slug>'
tar -cf - <app files/dirs, e.g. main.py requirements.txt app/> | ssh <alias> 'tar -x -C /addons/<slug>'
tar -cf - -C haos . | ssh <alias> 'tar -x -C /addons/<slug>'
```

⚠️ `tar` doesn't read `.dockerignore` (that's a Docker-build-time mechanism, not a `tar`
one) — `__pycache__`, `.venv`, stray `.pyc` files, whatever's locally present rides along
if you don't exclude it explicitly. Clean it off the delivered directory afterward if it
slips through: `ssh <alias> "find /addons/<slug> -name __pycache__ -type d -exec rm -rf {} +"`.

Once the project has its first commit, switch to the git-archive route above — treat the
no-git path as a one-time bootstrap, not the standing method.

⚠️ The deploy directory must be **flat and self-contained**: config.yaml/Dockerfile/run.sh
all at the top level of `/addons/<slug>/`.

### ⚠️ Two directories must never declare the same slug (either delivery method above can cause this)

**Supervisor's local store walks the local add-on tree recursively** — the source does
`path.glob("**/config.*")` (`supervisor/store/data.py`), so it accepts `config.yaml`,
`config.yml` **and** `config.json`, at any depth. Line 3 above ships the *whole repo*, so if
the repo also holds a **second** add-on's folder (one repo, two add-ons — e.g. a poller and an
ingest service), that second manifest lands inside this add-on's deploy directory and now
**two directories declare that second slug**.

⚠️ **Which one wins is not deterministic.** Supervisor simply overwrites as it walks
(`apps[app_slug] = app`), so **the last one visited wins** — and `Path.glob` returns
filesystem `scandir` order, not sorted, not by mtime, and *not* by highest version. The
outcome can flip after a re-delivery or a reboot, so a single "looks fine on this box" check
proves nothing. The only safe state is: **never let two manifests declare the same slug.**

When the stale copy wins, for the *other* add-on:

- `version_latest` reports the stale copy's version, so `update_available` stays `false` and
  `ha apps update` is a no-op — no matter how many times you re-deliver the real directory
- the **Docker build context** is that stale directory too, so a successful-looking
  `ha apps rebuild` bakes old code into the image
- `ha store reload`, `ha supervisor restart`, `docker builder prune -a`, a full HAOS reboot,
  and even `ha apps uninstall` + `install` all change nothing — Supervisor isn't stale, the
  winning directory genuinely *is* old. (Real case: a whole day lost to this, misdiagnosed as
  a Supervisor version-tracking bug.)

**Best fix: don't ship the whole repo.** Send only the paths this add-on needs, so the
collision never exists:

```bash
git archive --format=tar HEAD -- <app-dir> <shared-dir> | ssh <alias> 'tar -x -C /addons/<slug>'
```

(`.gitattributes` with `export-ignore` on the other add-on's directory achieves the same.)

If you must ship everything, delete the other add-on's directory afterwards — **with the
delete guarded**, because an unset variable here expands to `rm -rf /addons//` and takes out
every add-on on the box:

```bash
ssh <alias> bash -l -s <<'EOF'
set -euo pipefail
SLUG=<slug>; OTHER=<other-addon-dir>
ls -la -- "/addons/${SLUG:?}/${OTHER:?}"      # look before you delete
rm -rf -- "/addons/${SLUG:?}/${OTHER:?}"
EOF
```

Then verify — as a **mechanical** check, not an eyeball one (exits non-zero on a duplicate):

```bash
ssh <alias> bash -l -s <<'EOF'
find /addons -name 'config.*' ! -name '.*' -not -path '*/rootfs/*' \
  -exec sh -c 'printf "%s → " "$1"; grep "^slug:" "$1"' _ {} \;
find /addons -name 'config.*' ! -name '.*' -not -path '*/rootfs/*' \
  -exec grep -h "^slug:" {} \; | sort | uniq -d > /tmp/dupe_slugs
[ ! -s /tmp/dupe_slugs ] || { echo "DUPLICATE SLUG:"; cat /tmp/dupe_slugs; exit 1; }
EOF
```

**Diagnosing it when already deployed** — compare a source file's byte count inside the
container against the same file on disk; if they differ, the build context is not the directory
you delivered to, so go find the other copy (`$C` from §Scope):

```bash
# WORKDIR is whatever this add-on's Dockerfile sets, so resolve it rather than hardcoding
ssh <alias> "sudo docker exec $C sh -c 'wc -c \"\$(pwd)/<file>.py\"'"
ssh <alias> 'wc -c /addons/<slug>/<file>.py'   # what you delivered

# every manifest on the box, wherever the local store actually lives on this install
ssh <alias> "sudo docker inspect $C --format '{{range .Mounts}}{{.Source}}{{\"\n\"}}{{end}}'"
```

"Supervisor can read the correct version off disk" and "Supervisor is using that copy" are
**two different claims** — verifying only the first is what makes this bug look unsolvable.

## 3. Install

```bash
ssh <alias> 'bash -lc "ha store reload && ha apps install local_<slug>"'
# First build takes minutes (longer with heavy deps like onnxruntime/opencv);
# the build runs in the Supervisor background, so a dropped SSH session doesn't matter
ssh <alias> 'bash -lc "ha apps info local_<slug> | grep -E \"state:|version:\""'   # a version line = installed
```

## 4. Configuration (add-on options)

⚠️ **`ha apps` has no `options` subcommand** — pick one of two routes:

- **HA web UI** (most reliable): add-on → Configuration tab → fill in and save.
  Secrets (tokens, push topics) always go here — never `.env`, never the repo.
- **Supervisor REST API** (scriptable):
  ```bash
  echo '{"options":{...complete object...}}' \
    | ssh <alias> 'bash -lc "curl -sS -X POST -H \"Authorization: Bearer \$SUPERVISOR_TOKEN\" \
              -H \"Content-Type: application/json\" -d @- http://supervisor/addons/local_<slug>/options"'
  ```

⚠️ **This POST replaces the whole `options` object — it is not a patch.** Sending only the
one field you want to change (e.g. `{"options":{"some_token":"..."}}`) drops every other
option, and Supervisor rejects the result if any *required* field is now missing:
`"App local_<slug> has invalid options: Missing option 'tesla_client_id' in root..."`.
To add or change a single field, **GET the current full object first, merge in your one
change locally, then POST the complete merged object back** — never hand-write a partial
one:
```bash
ssh <alias> 'bash -lc "curl -sS -H \"Authorization: Bearer \$SUPERVISOR_TOKEN\" \
    http://supervisor/addons/local_<slug>/info"' > /tmp/opts.json   # full current options
python3 -c "
import json
d = json.load(open('/tmp/opts.json'))['data']['options']
d['some_token'] = 'new-value'
json.dump({'options': d}, open('/tmp/opts_new.json', 'w'))
"
cat /tmp/opts_new.json | ssh <alias> 'bash -lc "curl -sS -X POST -H \"Authorization: Bearer \$SUPERVISOR_TOKEN\" \
    -H \"Content-Type: application/json\" -d @- http://supervisor/addons/local_<slug>/options"'
rm -f /tmp/opts.json /tmp/opts_new.json   # both contain secrets in plaintext
```
Note: the `info` endpoint returns `password`-typed schema fields in **plaintext**, unmasked
— that's exactly what makes this merge possible, but also why the temp files must be deleted
right after, and why this whole exchange should be treated as touching real secrets (don't
echo the merged object to a log or chat transcript). After POSTing, re-`GET info` and check the
field you *didn't* intend to touch (e.g. a refresh token) is still non-empty — a wrong merge
silently wiping a rotating credential is a much worse failure than a rejected POST.

The schema supports a **list of dicts** (lets the user add/remove entries in the UI,
e.g. monitoring targets):

```yaml
options:
  targets:
    - name: example
      date: "2026-01-01"
schema:
  targets:
    - name: str
      date: str
```

⚠️ The schema only declares types — **format validation is the app's job at startup**;
report which entry is wrong and why, then fail the start (so the user sees it in the
log immediately).

## 5. Start and Verify

```bash
ssh <alias> 'bash -lc "ha apps start local_<slug>"'
ssh <alias> 'bash -lc "ha apps logs local_<slug>"'
```

Testing inside the container (e.g. manually trigger one push notification):

```bash
ssh <alias> "sudo docker exec $C python3 -c '…'"
# ⚠️ the SSH add-on user has no docker socket permission — sudo required
# ⚠️ $C must come from the resolver in §Scope — never hardcode app_local_/addon_local_,
#    and never skip its empty check (an empty $C makes docker read the next arg as the
#    container name, giving a "no such container: python3" that looks unrelated)
```

⚠️ **`docker exec` needs Protection mode *off* on the SSH add-on (§0); if it's on, this whole
byte-fingerprint/exec-based verification path may be unavailable to you.** If you're an
autonomous coding agent, don't assume you can just flip the toggle yourself — turning
Protection mode off is a Supervisor **security-setting** change (via the same options API as
§4), and a permission-conscious agent harness may (correctly) refuse to let you toggle it
without the user watching. Don't fight this by finding a workaround; treat it as a real
boundary. Fall back to **log-based verification** instead — it's usually sufficient:
`ha apps logs local_<slug>` after start/update should show the new version's log strings
(a line, a phrase, a startup banner) that only exist in the code you just delivered, plus a
`grep -iE "error|traceback|exception|Errno|Fatal"` with no hits. If the deploy also added a
reachable endpoint, hitting it for real (see §6's version-check philosophy — trust behavior
you can observe over inference) is stronger evidence than a static byte count anyway.

## 6. Update (⚠️ pick one of three — the wrong one gets rejected)

| What changed | Command |
|---|---|
| Options only (no code change) | `ha apps restart local_<slug>` |
| Code changed, config.yaml version **not bumped** | redo §2 delivery → `ha apps rebuild local_<slug>` |
| Code changed, **version bumped** | redo §2 delivery → `ha store reload` → **`ha apps update local_<slug>`** (rebuild is rejected here: "Local and store versions differ, use Update instead of Rebuild") |

⚠️ **For code updates, always bump `version` and take the update route.** Rebuild
leaves the device reporting the old version while running new code — `ha apps info`
can no longer tell which code the box is actually running, which hurts later
debugging. Reserve rebuild for rapid iterate-and-test cycles where the version
trail doesn't matter yet.

⚠️ **Always confirm the store actually saw the bump before running update** — this is the
one check that turns a day-long mystery into a two-minute fix:

```bash
ssh <alias> 'bash -lc "ha apps info local_<slug> | grep -E \"^(version|version_latest|update_available):\""'
```

`version_latest` must equal the version you just delivered. If it still shows the old one after
`ha store reload`, **stop — do not start rebuilding or reinstalling.** Supervisor is reading a
*different* directory that declares your slug: go to §2's "Two directories must never declare
the same slug".

## 7. Persistence and Logs

- **`/data/` is the persistent volume** (host side: `/data/apps/data/local_<slug>/`):
  DB, logs and tokens all live here and survive rebuild/update.
- Log to both stdout (for `ha apps logs`) and `/data/logs/` (rotating files).
- ⚠️ **Never print secrets in the startup log** (`ha apps logs` is visible to anyone
  who can open HA) — print on/off status only.

## 8. SSH Prerequisites (only when touching a new HA host for the first time)

Set an alias in the workstation's `~/.ssh/config` (HostName, User, IdentityFile);
add the public key to the **Advanced SSH & Web Terminal** add-on config (YAML mode):

```yaml
ssh:
  username: <account>
  authorized_keys:
    - >-
      ssh-ed25519 AAAA... public key
```

⚠️ If the saved config keeps reverting, the usual causes are **private key file
permissions too loose** (`chmod 600`) or the YAML nested at the wrong level.
Your SSH lands in the **SSH add-on container** (not the HAOS host, not the HA core
container); `sudo` works there.
