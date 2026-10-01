# CLAUDE.md — agent-skills

Monorepo of self-written AI agent skills, shared across agents (Claude Code /
Codex / Gemini) and published to any machine via
`npx skills@latest add caanio/agent-skills -g`.

## Single Source of Truth (non-negotiable)

- **This repo is the only place self-written skills are edited.** Never
  hand-edit or hand-copy files in an install target (`~/.agents/skills/`,
  `~/.claude/skills/`) or keep a parallel copy in another repo (e.g.
  dotfiles) — a parallel copy is how the two silently drift apart.
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

## Open items (last updated 2026-10-01)

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
4. The old-Mac wheel-pin pitfall lives in `python-coding-standards`
   rule 6 as a ⚠️ paragraph; too rare for its own skill, too specific for
   the global rules file. Log: 2026-09-26.
5. `web-stack-selector`'s "maintained" bar is a push within ~6 months of
   the survey date, defined only in its `SKILL.md`; a pick below it stays
   but is flagged in place. Maintainer call, log: 2026-09-26.
6. `python-coding-standards` keeps `[NEVER VIOLATE]` on rules 1, 2 and the
   testing rule together: with only the testing rule tagged, a fresh reader
   ranked rules 1 and 2 as weaker. Log: 2026-09-26.
7. `haos-addon-deploy` §4 handles the options temp files like
   `haos-cloud-backup` §7: `chmod 600` before the POST, `opts.json` kept
   as the rollback copy until the re-GET check passes. Maintainer call,
   log: 2026-09-26.
8. `git-helper` Core Rule 7 falls back to the conversation's language
   when a repo has no history, and the draft says so; no hardcoded
   language in the public skill. Maintainer call, log: 2026-09-26.
9. `python-coding-standards` rule 7 declares a source encoding only when
   a file is not UTF-8 (PEP 3120 makes UTF-8 the default); an existing
   UTF-8 line stays. Maintainer call, log: 2026-09-27.
10. `git-helper`'s Step 4 draft is the literal command block Step 5 runs,
    trailers and any push line included; one ok covers the block, run as
    separate calls in order. Maintainer call, log: 2026-09-27.
11. `web-stack-selector` keeps `simple-datatables (LGPL)` as excluded;
    its survey line takes the license from the repo's `LICENSE` file and
    `package.json`, since the GitHub API reports `NOASSERTION`.
    Maintainer call, log: 2026-09-27.
12. `haos-https-tunnel` §4 branches on Core version at 2026.8: the UI
    path (Settings → System → Network, a user hand-off) above it, the
    `configuration.yaml` block below it. Confirmed against the official
    `http` integration page and the 2026.8 release post; the 2027.2
    cut-off date has only a community source and stays out.
    Maintainer call, log: 2026-10-01.

Open:

1. Evaluate running every self-written skill in `skills/` through the
   skill-authoring skills (`skill-creator`, `writing-for-agents`), one
   pass per skill, logging what each pass changed. Added 2026-10-01;
   scope and order not yet decided.

## Source Material

`haos-addon-deploy` was distilled from the verified deployment records of
two private RPi projects (2026-06).
