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
  `npx skills@latest update <skill> -g` (or `update -g` for every installed
  skill); `npx skills@latest add caanio/agent-skills -g` only when a skill
  is new to that machine.
- Install targets are real directories managed by the skills CLI, not
  symlinks into any git repo.

## Inclusion Rules (non-negotiable)

- **Content must be generic**: no environment-specific information (hosts,
  IPs, accounts, real slugs, secrets) — placeholders only (`<slug>`, the `ha`
  alias). This repo is public.
- **Skills must stand on their own**: no dependency on any single user's
  personal global config (e.g. `~/.claude/CLAUDE.md` conventions, personal
  aliases) to function correctly — a skill installed on a fresh machine with
  no personal dotfiles must still work as documented.
- **No personally identifiable information**: no real names, emails, or
  other PII in skill content, examples, or commit-authored text — this is
  broader than "environment-specific" above and applies even to the
  author's own identity.
- **Pitfalls must have been hit in practice**, marked ⚠️ — on real hardware for
  the infrastructure skills, or in a recorded real session for the process
  skills. No theoretical values, and no ⚠️ on general advice (bold it instead).
  This governs `skills/` content; install warnings in the README are not bound
  by it.
- Project-specific parameters (slugs, hosts, where tokens live) stay in each
  project's own CLAUDE.md/docs; skills only capture the generic procedure.

## Format

One folder per skill under `skills/`, each containing a `SKILL.md`
(YAML frontmatter: `name`, `description`; the description must include
trigger-scenario keywords). After adding a skill, update the list table in
the README.

## Agent skills

### Issue tracker

Issues live as GitHub issues in `caanio/agent-skills`, via the `gh` CLI.
See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical roles, each label string equal to its name.
See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at the root, ADRs under `docs/adr/`.
See `docs/agents/domain.md`.

## Open items (last updated 2026-09-26)

The only live list. The per-change log — what each change did, why, and how
it was verified — is `docs/history/todo-log.md`; read it before reworking a
skill, to see what was already tried. When a change lands or an item closes,
append its entry to that log and keep only the live residue here.

Settled — reopen only on new evidence:

1. `completion-gate`'s authoring-standard rule lives on the artifact-type
   table, never as a wrap-up step: the step-shaped version failed
   structurally across three `deep-reviewer` rounds (position, re-entry
   routing, rounds). Log: 2026-09-15.
2. `CONTEXT.md` and ADRs are created lazily by `/domain-modeling` once a
   term or decision resolves; `docs/adr/` is not pre-created, and the local
   docs-baseline hook accepts that. Log: 2026-09-15 (supersedes the
   2026-08-19 "docs baseline missing" item).
3. The PII read-back question sits only in `completion-gate`'s Docs row;
   placeholder swaps in code files are covered by `git-helper` step 2b
   scanning every staged file. Maintainer call, log: 2026-09-26.

Open:

4. Candidate to distil: cross-project pitfalls like pinning wheel versions
   on the old Mac (macOS 12 Intel). Log: 2026-07-03.

## Source Material

`haos-addon-deploy` was distilled from the verified deployment records of
two private RPi projects (2026-06).
