# CLAUDE.md — agent-skills

Monorepo of self-written AI agent skills, shared across agents (Claude Code /
Codex / Gemini) and published to any machine via
`npx skills@latest add caanio/agent-skills -g`.

## Single Source of Truth (non-negotiable)

- **This repo is the only place self-written skills are edited.** Never
  hand-edit or hand-copy files in an install target (`~/.agents/skills/`,
  `~/.claude/skills/`) or keep a parallel copy in another repo (e.g.
  dotfiles) — that is how divergence happened before 2026-07-10.
- Update flow: edit here → commit → push → on each machine
  `npx skills@latest add caanio/agent-skills -g` to reinstall.
- Install targets are real directories managed by the skills CLI, not
  symlinks into any git repo.

## Inclusion Rules (non-negotiable)

- **Content must be generic**: no environment-specific information (hosts,
  IPs, accounts, real slugs, secrets) — placeholders only (`<slug>`, the `ha`
  alias). This repo is public.
- **Pitfalls must have been hit on real hardware**, marked ⚠️ — no
  theoretical values.
- Project-specific parameters (slugs, hosts, where tokens live) stay in each
  project's own CLAUDE.md/docs; skills only capture the generic procedure.

## Format

One folder per skill under `skills/`, each containing a `SKILL.md`
(YAML frontmatter: `name`, `description`; the description must include
trigger-scenario keywords). After adding a skill, update the list table in
the README.

## TODO (left when the repo was created, 2026-07-03)

- [x] Push the first commit to GitHub (done — turned out it was already
      pushed from another machine; confirmed in sync 2026-07-04)
- [ ] Test-install with
      `npx skills@latest add caanio/agent-skills -g` to verify the skills
      CLI accepts this structure (mattpocock/skills layout)
- [ ] Later candidates to distil: cross-project pitfalls like pinning wheel
      versions on the old Mac (macOS 12 Intel)

## Source Material

`haos-addon-deploy` was distilled from the verified deployment records of
two private RPi projects (2026-06).
