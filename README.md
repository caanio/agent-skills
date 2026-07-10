# agent-skills

A collection of self-written AI agent skills (portable across Claude Code /
Codex / Gemini: one folder per skill under `skills/`, each containing a
`SKILL.md`, following the mattpocock/skills layout).

## Install (new machine)

1. **Install the skills** (any machine with network access):

   ```bash
   npx skills@latest add caanio/agent-skills -g
   ```

   Pick skills and agents in the interactive menu; use `--all` to install
   everything without prompts.

2. **Make Claude Code see them**: ⚠️ `-g` installs into the skills CLI's
   global store `~/.agents/skills/`, but Claude Code only reads
   `~/.claude/skills/` — it won't pick them up by default. Bridge once with
   a symlink:

   ```bash
   ln -s ~/.agents/skills ~/.claude/skills
   # if ~/.claude/skills already exists, move its contents into ~/.agents/skills/ first
   ```

3. **Verify**:

   ```bash
   npx skills@latest ls -g          # CLI view: installed list
   ls ~/.claude/skills/             # Claude view: same folders visible = good
   ```

   Or open a Claude Code session and ask "what skills are available".

4. **Updating later** (when the source repo gets new commits — run manually
   on each machine, there is no auto-update):

   ```bash
   npx skills@latest update -g
   ```

## Skills

| Skill | Purpose |
|---|---|
| [git-helper](skills/git-helper/SKILL.md) | Git commit workflow: confirm staging → secrets scan → generate commit messages meeting Conventional Commits + Chris Beams standards |
| [haos-addon-deploy](skills/haos-addon-deploy/SKILL.md) | Deploy a self-written long-running app as a Home Assistant OS local add-on (RPi, 24/7), with every battle-tested pitfall |
| [haos-https-tunnel](skills/haos-https-tunnel/SKILL.md) | Give a HAOS instance a real HTTPS URL via a Cloudflare Tunnel (cloudflared add-on) — no port forwarding, no device-side install |
| [haos-cloud-backup](skills/haos-cloud-backup/SKILL.md) | Ship HAOS backups to cloud storage with rclone: upload bandwidth cap (bwlimit) and GFS-style daily/weekly/monthly retention |

## Conventions

- Content must be generic: no environment-specific information (hosts, IPs,
  accounts, slugs, secrets)
- Pitfalls are marked ⚠️ and must have been hit and verified on real
  hardware — no theoretical values
