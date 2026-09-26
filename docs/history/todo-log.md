# TODO log (2026-07-03 – 2026-09-26)

Version: 1.0.2 | Moved verbatim from `CLAUDE.md`'s TODO section on
2026-09-26; entries unchanged, including their checkbox state at the time.
How to read: **a log, not current state** — later entries often supersede
earlier ones, and a `[ ]` here only means it was open when written.
What is still open, and which decisions are settled, lives in `CLAUDE.md`
§ Open items. Read this file when you need why a skill ended up the way it
did, or before reworking a skill, to see what was already tried.
Entries run oldest first; new entries are appended at the end.

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
- [x] `completion-gate`'s End-of-Session Wrap-Up restructured (2026-09-10):
      closed a real gap another session hit — the checklist had no step
      that actually asked whether to run `handover` between the
      continuation-notes step and commit, so finishing continuation notes
      reflexively rolled straight into commit. Added a step that requires
      asking (not running) `handover` every time, with a recommendation and
      reasoning attached (never a bare yes/no), and an explicit "Completing
      [the prior step] is not permission to skip straight to committing"
      line — a softer phrasing failed a prior read-back, so this one is
      written as a direct prohibition. Separately, on review with the
      maintainer: removed the commit-via-`git-helper` step and the
      unpushed-commits check from the list entirely — both belong to the
      outer wrap-up sequence (completion-gate → handover → git-helper), not
      to this skill's own checklist, matching the Scope boundary's existing
      commit-mechanics pointer. Added a new first step requiring code
      verification (tests run, code-review triage, a security skill for
      trust-boundary code) before any doc gets touched, since the checklist
      previously jumped straight to docs with no code-verification gate.
      Scope boundary gained a fifth bullet naming `security-and-hardening`
      and `security-audit` as the out-of-collection owners of security
      review — the Code row already covered tests/code-review but said
      nothing about security. Edited via the `writing-for-agents` skill
      (`mattpocock/skills`). Verified by `verifier` read-back (11/11 checks
      passed: step count and gist, cross-step references at every renumber
      point, the verbatim permission sentence, the ask-not-run requirement
      for handover, no leftover `git add`/`git commit`/`git-helper`
      strings, the security bullet's named skills — all consistent, no
      stale references found).
- [x] `handover`'s Scope boundary fixed two wrong attributions (2026-09-10,
      same session as the `completion-gate` entry above): the ADR/`CONTEXT.md`
      bullet claimed "this collection's family ships `domain-modeling`" and
      the conversation-handoff bullet claimed "this collection's `handoff`"
      — both false. Checked `~/.agents/.skill-lock.json`: both
      `domain-modeling` and `handoff` install from `mattpocock/skills`, not
      from this repo (`skills/` here only holds `completion-gate`,
      `git-helper`, `handover`, the three `haos-*` skills, and
      `python-coding-standards`). Rewrote both bullets to the same pattern
      already used for the security bullet above (`your X skill, entirely —
      this collection doesn't ship one (e.g. ...)`), naming
      `mattpocock/skills` explicitly. The other two bullets in the same list
      (`completion-gate`, `git-helper`) were already correct — this repo
      really does ship those two. Verified by `verifier` read-back (7/7
      checks passed: both corrected bullets quote-matched as NOT claiming
      this collection ships them and naming `mattpocock/skills`, the two
      correct "ships" bullets unchanged, no leftover "this collection's
      family" phrasing, no contradiction between bullets).
- [x] `completion-gate`'s step 5 (continuation notes / TODO index) gained a
      mechanical check (2026-09-10, same session): the maintainer caught the
      model claiming step 5 done by seeing one existing TODO entry, without
      diffing against everything the session actually touched — the exact
      staleness step 5's own ⚠️ already warned about. Added a concrete command
      to check against (`git diff HEAD --stat` for the whole session) and a
      ⚠️ recording the miss as it happened. Dogfooding that same check then
      caught a second, real gotcha in the same minute: `git diff --stat`
      (no `HEAD`) compares working tree to the index only, so a fully-staged
      file (`skills/handover/SKILL.md`, staged by the IDE, not by the model)
      showed zero diff and was nearly left out of the TODO update entirely —
      `git status` alone did catch it, but the first drafted ⚠️ wrongly
      claimed `git status` under-reports too and had to be corrected before
      it shipped. Added a second ⚠️ pinned on `git diff --stat` specifically
      (not `git status`), with the working-tree/index/last-commit mechanics
      spelled out. Verified by `verifier` read-back, twice (once per ⚠️ add):
      first pass 5/5 checks passed (command name, observed-in-session
      framing, no stale cross-references); second pass 5/5 checks passed
      (exact command quoted, confirmed no false claim about `git status`
      anywhere in the file, the `git diff --stat` mechanics explained
      correctly, all step cross-references still resolve).
- [x] `completion-gate`'s step 5 trimmed (2026-09-10, same session): the
      case-study narrative and the `git diff --stat` internals explanation
      logged above were cut on the maintainer's call — the step now just
      states the hard requirement ("you must have actually run `git diff
      HEAD --stat` ... before this step counts as done") without the story
      or the reasoning behind it. Verified by `verifier` read-back (5/5
      checks passed: hard-requirement clause and command name confirmed
      present, narrative/internals confirmed absent, no `git status`
      mention anywhere, step numbering and all cross-references intact).

- [x] `completion-gate` gained an authoring-standard clause (2026-09-15):
      a change's artifact type may have a standard of its own (a Python
      standards skill, a skill-writing skill), and nothing in the file said
      whether following it counted as verification — so a round could pass the
      gate having never been checked against the standard it was written under.
      Landed as 13 lines appended to the artifact-type table, with the
      wrap-up checklist untouched. Rules split mechanical (settle yourself)
      from judgement (route to the table's judgement-call row, whichever way
      you think it came out), anything unsortable counts as judgement, and
      both "nothing governs this file" and "its standard already ran" carry
      the same burden of evidence as any other finding. Verified by `verifier`
      read-back (16/16 checks passed: placement inside the verification
      section, every cross-reference resolved, no duplication against Core
      Rule 1, wrap-up numbering confirmed untouched, 5 read-back questions
      answered from the file alone).
- [ ] **Do not re-attempt this as a wrap-up step** (recorded 2026-09-15, the
      same session): the clause above was first built as a new step 4 in the
      End-of-Session Wrap-Up, grew to 55 added lines over two rounds, and was
      reverted in full. Three rounds of `deep-reviewer` established that the
      failure was structural, not verbal — anything shaped as a step inherits
      three costs. It has a *position*, so content written after it escapes it
      (the continuation-notes step and anything a later pass writes). It needs
      *re-entry routing*, which has to enumerate every earlier step and leaks
      through whichever one it misses. It needs *rounds*, which then have to be
      reconciled with Failure Counting. Round 2 closed two attack surfaces and
      left four open; round 3 closed another and left three, two of which
      predate the work. Attaching the rule to the artifact-type table instead
      costs none of the three, because the table is consulted rather than
      executed in sequence. That discarded draft — 261 lines in full, 55 of them
      new — is not kept anywhere in the repo. Deliberately not written up as an
      ADR: `docs/adr/` does not exist here yet and creating it is gated on a
      separate docs-baseline decision, so this entry is the record.
- [ ] Two gaps this session surfaced but did not close, both pre-existing:
      the wrap-up has no step that runs the Docs-row read-back against a doc it
      just wrote (step 3 only proves the edit landed, and deliberately anchors
      its reader, so it cannot also ask the open question) — **closed
      2026-09-24, see below**; and the Scope boundary hands security review to
      an external skill without the "with none installed" fallback the Code row
      gives. On a machine with no security skill, the wrap-up's first step
      cannot be satisfied or downgraded — still open.
- [x] `completion-gate`'s wrap-up step 1 widened from "every code change
      passed its Code-row verification" to "every artifact this round produced
      passed its own row in the table" (2026-09-24), closing the first gap
      above: Core Rule 1 already said the Docs row has no size exemption, but
      no wrap-up step ever triggered it, so a rules-file edit could pass the
      whole checklist having only had step 3's narrow "did the edit land"
      quotation check. Step 3 gained one sentence sending a doc edited in
      step 2 back through the Docs row before step 4. Deliberately not a new
      step, per the 2026-09-15 record above. Edited via `writing-for-agents`.
      Verified by `verifier` read-back (10/10 checks passed: both edited
      sentences quoted, all six wrap-up steps' cross-references resolve, the
      Docs-row procedure stated in full exactly once, Core Rule 1's
      no-size-exemption line unchanged, no PII in either diff, 3 read-back
      questions answered from the file alone); the two non-existence claims
      re-checked by grep on the main thread.

- [x] `/setup-matt-pocock-skills` run on this repo (2026-09-15, same session):
      wrote `docs/agents/issue-tracker.md` (GitHub Issues via the `gh` CLI,
      PRs-as-request-surface left off), `docs/agents/triage-labels.md` (the
      five canonical roles, label strings equal to their names), and
      `docs/agents/domain.md` (single-context), plus an `## Agent skills`
      section in this file pointing at all three. All three doc files are
      verbatim copies of the skill's seed templates — no field needed
      overriding, since every choice landed on a template default. Verified by
      `verifier` read-back (24/24 checks passed: completeness, every
      cross-reference resolved, the label table, the PR flag's value, section
      placement between Format and TODO, and 4 read-back questions answered
      from the files alone).
- [x] Baseline-hook alignment, in `dotfiles-ai` not here (2026-09-15, same
      session): running the setup skill surfaced that its `domain.md` puts
      `CONTEXT.md` at the repo root while the local docs-baseline hook looked
      only under `docs/`, so a repo that followed the skill would be reported
      as missing a file it actually had. The same hook also had no lazy-ADR
      exemption for `docs/adr/`, though it already had one for `CONTEXT.md`.
      Fixed on the hook side rather than by editing this repo's docs, keeping
      `docs/agents/*.md` identical to upstream: `doc-baseline-check.sh` now
      accepts either `CONTEXT.md` location and skips `docs/adr/` when
      `docs/agents/domain.md` exists (v1.2.0 → v1.3.0). Verified by running
      the hook across four scenarios, not by reading it.
- [ ] ADR placement, settled 2026-09-15: ADRs are not pre-created here. The
      setup skill's `domain.md` states the position — `/domain-modeling`
      creates `CONTEXT.md` and ADRs lazily, once a term or decision actually
      resolves — and the baseline hook now matches it. An empty `docs/adr/`
      was created and removed again in the same session; git never tracked it.
      The design decision recorded two entries above stays in this TODO rather
      than an ADR for that reason.

- [x] `completion-gate`'s Code row now requires the code review to run in a
      fresh context (2026-09-20). Surfaced by a real session in another repo:
      a 14-file rewrite got fifteen `deep-reviewer` rounds on one class and
      that was taken as the Code row's code review, until the maintainer asked
      which code-review skill had run — none had. A fresh-context `/code-review`
      on the same diff then found two real crash paths outside that class. Two
      distinct gaps: the row said "your code-review skill" without saying the
      reviewer must be a fresh context, so a same-context checklist
      (`code-review-and-quality`) could pass for it despite Core Rule 1; and
      nothing said an adversarial second opinion (the judgement-call row) does
      not substitute for the Code row, nor that it only reviews the scope it
      was handed. Landed as a fresh-context requirement in the Code row plus a
      ⚠️ recording the case, the Scope boundary's code-review examples
      replaced with fresh-context ones (`/code-review`, or any review agent
      dispatched with only the diff), and the authoring-standard clause
      gaining `test-driven-development` and `code-review-and-quality` (as a
      same-context checklist) as examples. Every skill name stays an `e.g.`
      with the existing "with none installed" fallback untouched, per the
      Inclusion Rules. The other session confirmed the failure mode on
      request: it had loaded the skill via the Skill tool, read the Scope
      boundary, and still filled the Code row with the adversarial review —
      a substitution, not a missed pointer. A `writing-for-agents` pass then
      cut one duplication (the same-context routing had landed in three
      places; now the rule lives in the Code row and the name in the
      authoring clause only) and unified the leading word to `same-context`.
      Deliberately not added: a mechanical security trigger keyed on paths
      like webui/auth/parser (project-specific, and the Scope boundary already
      says this skill makes no security judgement of its own); a
      delivery-message rule naming which row each check satisfied (not
      approved); trimming the ⚠️'s numbers (left as written). The Scope
      boundary's security bullet gained a built-in `/security-review` of the
      pending diff as a before-merge example — deliberately without a
      fresh-context claim: the official docs state its scope (changes on the
      current branch) but not its execution model, unlike `/code-review`,
      which is documented as a background subagent. Verified by
      `verifier` read-back, three times: 10/10 after the first pass (one
      check self-corrected mid-report), 8/8 after the trim, 7/7 after the
      `/security-review` example, with the read-back questions answered from
      the file alone each time.

- [x] `git-helper` gained a personal-data (PII) scan and `completion-gate`'s
      Docs row a fixed read-back question (2026-09-26). Surfaced by a real
      session in another repo: a note recording that a value had been
      swapped for a placeholder is itself a leak, because it tells anyone
      reading the history where the original lives. Core Rule 6 now
      requires both scans with raw output shown; Step 2 split into 2a
      (secrets, pattern unchanged) and 2b (PII: decimal-degree coordinates
      plus origin-label words, added lines only; names and device names
      checked by eye and said so in "Rules applied"). The mechanical scan
      lives in `git-helper`, per `completion-gate`'s Scope boundary, which
      already hands the secrets scan to the commit-workflow skill;
      `completion-gate` only gained the question. README's `git-helper`
      row updated to match. Verified by `verifier` read-back: `git-helper`
      8/8, `completion-gate` 5/5, README 5/5.
- [ ] Two open points from the same change: (1) the fixed question sits
      only in the Docs row, so a placeholder swap inside a code file (a
      test fixture) is not asked about there — left as is by explicit
      maintainer call, since 2b scans every staged file regardless of type;
      (2) 2b matches its own rule text, so any commit that edits text
      quoting its pattern words (this skill's Step 2, a rules file stating
      the same policy) stops for per-line confirmation — already hit while
      landing this change. Revisit the pattern if confirmation
      fatigue shows up in practice.

- [x] `CLAUDE.md` slimmed (2026-09-26): the TODO section moved verbatim
      into this file, leaving an "Open items" section in `CLAUDE.md` that
      holds only settled decisions and still-open items, plus the rule that
      finished entries are appended here. Every `[ ]` entry above is either
      carried there or closed by a later entry. Reproducible check:
      `diff <(sed -n '12,351p' docs/history/todo-log.md) <(git show <pre-slim commit>:CLAUDE.md | sed -n '67,406p')`
      prints nothing. Verified by `verifier` read-back (all criteria passed:
      verbatim move, untouched sections, every open entry traced, every Open
      items claim sourced, paths exist, no PII, 4 read-back questions
      answered from `CLAUDE.md` alone).

- [x] `completion-gate`'s Scope boundary gained the missing "no security
      skill" fallback (2026-09-26), closing the second gap recorded under
      2026-09-15 above. The security bullet now says: with none you can run
      yourself, at minimum hand a fresh context the diff and ask where it
      takes anything from outside the program's control and what that can
      make the code do or expose; that is a stand-in, not the review — its
      output goes under delivery part 2 without being called a security
      review or a pass, and the security review is listed under part 3 as
      not done; no fresh context either → the existing downgrade, naming the
      security review as the gate that did not run. Wrap-up step 1 gained a
      pointer to that stand-in so a literal reader who ran it can still pass
      step 1; the reporting rule stays in the bullet only (a first draft
      restated it in step 1; cut as duplication under `writing-for-agents`).
      Placed in the Scope boundary bullet rather than as a new
      table row, mirroring where the Code row keeps its own "with none
      installed" path. A `deep-reviewer` round (opus) rejected the first
      draft on three points, all taken: the question named "the boundary it
      crosses", which hands the author's own judgement to the reviewer
      against the skill's anti-anchoring rule, and asked only about inputs,
      missing exposure changes with no input path (bind address, CORS,
      leaked error detail); "part 3 says so" was descriptive and skippable;
      and the test "none installed" never fires on a host whose built-in
      security command is always present but not launchable by the agent
      (whether the agent can launch it is [unconfirmed]), so it became
      "none you can run yourself" — accepted knowing it hands a lazy model
      a "couldn't run it" excuse, since that path costs more work (the
      stand-in plus a part-3 disclosure), not less. Edited via
      `writing-for-agents`. Verified by `verifier` read-back twice: 7/7 on
      the first draft, 9/9 after the rewrites (fallback and downgrade path
      readable from the file alone, step 1 routes to a place that now has
      one, no passage calls the stand-in a review, added lines ≤ 80 chars,
      no PII in the diff); the not-found claims re-checked by grep in the
      main session. README row unchanged (it does not mention security).

- [x] `git-helper` step 2b pattern narrowed (2026-09-26), closing point
      (2) of the 2026-09-26 PII entry above. Evidence of confirmation
      fatigue: 3 of the 8 commits before this one in this repo and 1 of the
      last 10 in the dotfiles repo tripped the scan, every hit a false
      positive, and every hit outside the rule text itself came from the two
      everyday words `placeholder` and `replaced with` ("placeholder swaps
      in code files", "replaced with fresh-context ones"). Those two words
      left the pattern; the origin-tag words (the four "real + place"
      phrases, the invented-value word, the four Chinese tags) and the
      coordinate regex stay, and a "real + name" phrase joined them. A
      `grep -v 'grep -iE'` stage now drops lines quoting the scan command,
      so editing step 2b itself no longer stops the commit. Cost accepted:
      a bare "placeholder"/"replaced" note with no origin word beside it is
      no longer caught mechanically; the eye-read clause names it
      explicitly. The prose around the command was reworded to avoid the
      remaining pattern words, so this change's own diff scans clean.
      Core Rule 6 and the README row are unchanged (neither quotes the
      pattern). Edited via `writing-for-agents`. Verified by `verifier`
      read-back 10/10: new pipeline scans this diff clean, a four-line
      fixture matches the two leak lines and skips the self-quote and the
      `+++` header, old-pattern replay on the prior 8 commits reproduces
      the 3-of-8 count, README and Core Rule 6 untouched, no PII, and the
      read-back answered that a bare "placeholder" note is an eye check.
      The dotfiles count was measured in the main session, not by the
      verifier.
- [x] Open item 4 (old-Mac wheel pins, 2026-07-03) closed 2026-09-26 by
      folding it into `python-coding-standards` rule 6 as a ⚠️ paragraph,
      not a new skill. Inventory of the two source projects found one real
      old-Mac pitfall (compiled packages whose newer wheels are macOS 13+
      only, so pip on macOS 12 Intel silently builds from source and looks
      hung) plus the same root cause in an Alpine container (no musllinux
      wheel, already covered by `haos-addon-deploy`); the brew/gcloud
      Tier 3 warning was dropped as not a pip issue. A standalone skill was
      rejected for trigger frequency (a few hits a year, two recorded
      cases) and the global rules file for being always-loaded. The
      machine-specific version bounds stay in the project README; the
      skill carries only the generic fail-fast (`--only-binary :all:`), the
      error string, and the per-environment fix. The error string was
      reproduced on the maintainer's macOS 12 Intel machine on 2026-09-26.
      Edited via `writing-for-agents`. Verified by `verifier` read-back
      7/7: files complete, code fence closed, numbering 6→7 intact, diff
      scans clean for PII, and the read-back answered the four questions
      (default pip behaviour, fail-fast command, per-environment fix,
      shared requirements untouched) from the paragraph text.
- [x] Prompt audit (`/claude-api prompt-audit`, target Claude Opus 5.5)
      run 2026-09-26 over every skill, `CLAUDE.md` and `docs/agents/`:
      38 findings, 33 of them stale facts or cross-file conflicts; the
      report stayed session-local. First batch landed the same day, the
      mechanical fixes only: `haos-addon-deploy` §2's "line 1" / "Line 3
      above" pointers now name the command (a second snippet had shifted
      the count), its pointer to a skill this collection doesn't ship is
      gone, `haos-cloud-backup`'s `ha store add` cross-reference now
      points at `haos-https-tunnel` §2 where the trap is written, example
      placeholders updated in `haos-addon-deploy` and `haos-https-tunnel`,
      and `python-coding-standards`' description no longer excludes
      package-install help, so the no-wheel pitfall in rule 6 can route.
      Still open from the audit, awaiting a maintainer call: git-helper's
      "analysis uses only status/diff" line vs its own `git fetch` /
      `git log` steps; `haos-cloud-backup`'s hardcoded container name;
      `haos-addon-deploy` §0 vs §5 on who toggles Protection mode;
      `haos-cloud-backup` keeping `opts.json`; `web-stack-selector`'s
      "maintained" bar vs its own picks. Verified by `verifier` 9/9.
- [x] Prompt audit second batch (the five maintainer calls) closed
      2026-09-26. `git-helper` Core Rule 2 now names the analysis phase by
      effect (leaves index and working tree untouched) and lists
      `git log` / `git fetch` beside status/diff, since Steps 0 and 3
      already ran them. `haos-cloud-backup` resolves the container name
      once as `$C` in §2 (`^(app|addon)_19a172aa_rclone_backup$` plus an
      empty guard, same shape as `haos-addon-deploy` § Scope) and reuses
      it in §4 and §6; the ssh strings moved to double quotes so `$C`
      expands locally. `haos-addon-deploy` §0 now says the user flips
      Protection mode and an agent falls back to log-based verification,
      matching §5. `haos-cloud-backup` §7 runs `chmod 600` on both temp
      files inside the code block, before the POST, keeps `opts.json` as
      the rollback copy while verifying, then deletes both. The check sat
      in prose after the block in two earlier drafts; two fresh readers
      each misplaced it, so it moved into the block. A name-based
      `grep 'password|token|secret'` gate before the chmod was dropped:
      a `password`-typed field named e.g. `api_key` slips past it, and an
      unconditional chmod costs nothing. `web-stack-selector`'s
      "maintained" bar widened from ~3 to ~6 months and moved into
      `SKILL.md` as its only definition: at 3 months five picks failed
      (tremor, SortableJS, pico, shadcn-ui-mcp-server, d3); at 6 months
      only tremor (last push 2025-10-10) fails and is flagged in place,
      wireui moved from excluded to "within the bar but not picked", and
      the shadcn-ui-mcp-server "stale" note was dropped. Rejected:
      tightening the picks (a fresh survey for libraries that are mature,
      not abandoned). Edited via `writing-for-agents`. Resolver quoting and
      regex tested locally in bash and zsh; the §7 block passes `bash -n`.
      Verified by `verifier`: mechanical check 7/8 PASS (the one FAIL was
      a 199-char prose line in `git-helper`, kept because that file writes
      one line per bullet — 32 such lines at HEAD); an open read-back over
      every touched passage answered all nine questions from the files;
      the §7 order question passed on the third draft and again after the
      grep gate was dropped. `deep-reviewer` skipped by maintainer call.
- [x] Prompt audit third pass (`/claude-api prompt-audit`, target Claude
      Opus 5.5) closed 2026-09-26. One hunk kept: `CLAUDE.md`'s
      single-source rule dropped its dated incident clause and keeps the
      reason (a parallel copy silently drifts apart). One hunk tried and
      reverted: dropping `[NEVER VIOLATE]` from `python-coding-standards`
      rules 1 and 2 (`git blame` puts all three tags in the first commit
      `c652c79c`). With only the testing rule (`:107`) still tagged, a
      fresh reader ranked rules 1 and 2 below it and said a reader "could
      … misread 'optional by omission'", so all three tags stay. The
      `[NEVER VIOLATE]` tags in `completion-gate` and `git-helper` stay
      because they guard
      self-certification, destructive confirmation, staging and the
      secrets/PII scan, not because each traces to an incident.
      Still open, awaiting a maintainer call: `haos-addon-deploy` §4 still
      deletes the options temp files right after the POST with no
      `chmod 600` or rollback copy, unlike `haos-cloud-backup` §7 (flagged,
      not rewritten: the newer passage adds a command to run);
      `git-helper` defaulting to Traditional Chinese when there is no
      history, in a public generic skill; `python-coding-standards`
      rule 7 calling the PEP 263 line functional, redundant for UTF-8
      files under PEP 3120; `web-stack-selector` listing
      `simple-datatables (LGPL)` as excluded with no survey row behind it.
      writing-for-agents was run after the edits, not before. Checked by
      `verifier`: citation check 4/4 PASS before applying; `CLAUDE.md`
      read-back PASS; the `python-coding-standards` open read-back failed
      question 5 (above), which is why that hunk was reverted.
