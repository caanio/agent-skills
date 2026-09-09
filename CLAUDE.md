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
- [x] `handover` skill added (2026-09-08): user-invoked (mirrors
      `mattpocock/skills`' own `handoff`, which targets the next agent turn
      — this one targets the next human maintainer instead). Backfills
      ADRs, checks README/CONTEXT.md against reality, records production
      facts and the deploy path, writes a prioritized `docs/TODO.md` (never
      the repo root, by explicit instruction after review). Scope boundary
      declared against `completion-gate` (gate vs. this skill),
      `domain-modeling` (ADR mechanics live there, this skill only decides
      whether one is owed), and `git-helper` (this skill writes docs, never
      commits them). Written with `writing-for-agents`' invocation and
      information-hierarchy guidance. Verified by `verifier` read-back
      (7/7 checks passed: frontmatter, 5-step process with completion
      criteria, docs/-only file placement, scope boundary, no PII, README
      table row, this TODO entry itself).
- [x] `completion-gate`'s Scope boundary gained a pointer to `handover`
      (2026-09-08): clarifies the two compose in sequence (completion-gate
      runs every wrap-up regardless of size; `handover` is an additional
      pass run only after completion-gate passes, never in place of it) —
      deliberately left cadence (every wrap-up vs. milestone-only) as the
      user's call rather than asserting one; `handover`'s own "When to
      invoke" section gained the same neutral framing. Verified by
      `verifier` read-back (8/8 checks passed alongside the code-review
      entry below).
- [x] `completion-gate`'s Code verification row and Scope boundary now
      point to a code-review skill (2026-09-08), naming
      `code-review-and-quality` (source: `addyosmani/agent-skills`, not
      shipped by this collection) as the reference implementation for the
      judgement-call cases in that row — with an explicit "none installed"
      fallback to this skill's own fresh-context judgement, so the row
      never hard-depends on a third-party skill being present. Verified by
      `verifier` read-back (8/8 checks passed: neutral cadence wording x2,
      code-review pointer + fallback, updated Code row, proportionality
      clause intact, no contradictions, both TODO entries correctly
      pending at read-back time, no PII).
- [x] `writing-for-agents` audit of `completion-gate` and `handover`
      (2026-09-09): found and fixed one real duplication — the Code row's
      code-review fallback procedure was restated in the Scope boundary
      bullet too; trimmed the bullet to a bare ownership pointer, kept the
      procedure only in the Code row. Also reworded `handover`'s "unpushed
      commits" check to name what it actually covers (this skill's own new
      files, not a re-check of completion-gate's step 6) and tightened one
      completion criterion to reuse the `maintainer-ready` leading word
      instead of re-describing it. Same session: split this file — moved
      Single Source of Truth / Inclusion Rules / Format into a new
      `AGENTS.md` (the agent-facing rules, tool-agnostic); this file keeps
      only the TODO log and Source Material, with a pointer at the top.
      Verified by `verifier` read-back (9/9 checks passed: both fixed
      duplications confirmed removed from their old spot and intact in
      their new one, leading-word reuse, AGENTS.md holds all three moved
      sections, CLAUDE.md no longer duplicates them and keeps its pointer
      plus TODO/Source Material intact, no PII, no further duplication
      found beyond the expected bidirectional completion-gate/handover
      cross-reference).
- [x] AGENTS.md/CLAUDE.md split reverted (2026-09-09), same day it landed.
      `mattpocock/skills`' own `setup-matt-pocock-skills` documents the
      opposite convention explicitly: "Never create `AGENTS.md` when
      `CLAUDE.md` already exists (or vice versa); always edit the one
      that's already there." Merged Single Source of Truth / Inclusion
      Rules / Format back into this file and deleted `AGENTS.md`. Verified
      by `verifier` read-back (7/7 checks passed: AGENTS.md gone, all five
      sections present exactly once with no lost content, pointer text
      removed, this TODO entry itself present, no duplication, no PII).

## Source Material

`haos-addon-deploy` was distilled from the verified deployment records of
two private RPi projects (2026-06).
