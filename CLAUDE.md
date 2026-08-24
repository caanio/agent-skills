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

## TODO (left when the repo was created, 2026-07-03)

- [x] Push the first commit to GitHub (done — turned out it was already
      pushed from another machine; confirmed in sync 2026-07-04)
- [x] Test-install with
      `npx skills@latest add caanio/agent-skills -g` to verify the skills
      CLI accepts this structure (mattpocock/skills layout) — confirmed
      2026-08-22: all 7 skills installed and symlinked into Claude Code's
      skill path, content matches the repo. (The same run reported 7
      failures for a "PromptScript" target — that target doesn't support
      `-g` global installs at all, unrelated to this repo's structure.)
- [ ] Later candidates to distil: cross-project pitfalls like pinning wheel
      versions on the old Mac (macOS 12 Intel)
- [x] `python-coding-standards` skill added 2026-08-19 (type hints, no
      globals, logging, I/O try/except, WHY-only comments, pytest
      preference, design docs) — went through 4 deep-reviewer rounds and a
      description-optimization pass; commits `c652c79`, `ba72c85`.
- [ ] Docs baseline still missing: `docs/CONTEXT.md`, `docs/adr/` —
      flagged by the docs-baseline hook 2026-08-19, deferred to next
      session by explicit user call.
- [x] `completion-gate` and `delegation-protocol` trigger audit
      (2026-08-21): near-zero real invocation traced via session
      transcripts, findings and decisions logged in
      `docs/trigger-audit-notes.md`. Sharpened both skills' triggers for
      the specific recognition-failure moments found (a self-graded risky
      confirmation question; a repeated same-target search) — framed as
      portability fixes, not expected to change this maintainer's own
      behaviour since equivalent rules already live in their personal
      always-loaded config. Verified by `verifier` read-back both times;
      commit `6f78073`.
- [x] `python-coding-standards` gained a Tooling rule (`.venv` +
      requirements.txt, PEP 8, Black) and `completion-gate`'s wrap-up order
      gained an explicit step for deciding whether a change also needs an
      adversarial second opinion (with a note that this decision blocks
      only the "verified/PASS" claim, not the remaining wrap-up steps) plus
      a scope note distinguishing the per-round doc check from the
      whole-session continuation-notes check — 2026-08-22. Landed alongside
      an unrelated upstream merge that touched the same
      `completion-gate` description line (commits `6f78073`, `f09a25d`);
      reconciled in commit `dbe7e45`.
- [x] `delegation-protocol` retired (2026-08-24), superseding the
      2026-08-21 "left unchanged" call above. Confirmed with the
      maintainer that nobody else installs this repo, which removed the
      "must stand on its own for other installers" reason that call relied
      on. Content split: the one genuinely-unique rule (Finding 2.1's
      no-evidence spot-check) plus two smaller unique bits (no-subagent
      fallback, don't-switch-model cache-cost warning) folded into the
      maintainer's personal always-loaded rules; everything else was
      already-duplicated threshold/reporting-contract text, deleted with
      no replacement. Updated the two live cross-references in
      `completion-gate/SKILL.md` (Scope boundary, delegating-a-check note)
      and the README skills table. Details in
      `docs/trigger-audit-notes.md`. Verified by `verifier` read-back.

## Source Material

`haos-addon-deploy` was distilled from the verified deployment records of
two private RPi projects (2026-06).
