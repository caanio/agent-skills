# TODO log (2026-07-03 – 2026-09-26)

Version: 1.0.3 | Moved verbatim from `CLAUDE.md`'s TODO section on
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
- [x] `haos-addon-deploy` §4 options temp files closed 2026-09-26
      (maintainer call: port `haos-cloud-backup` §7's handling). §4 said
      a wrong merge wiping a rotating credential is the worst failure and
      asked for a re-GET check, yet deleted the pre-change copy before
      that check, so a failed check had no old value to restore. The
      block now writes `opts.json` / `payload.json` in the working
      directory instead of `/tmp`, runs `chmod 600` on both before the
      POST, keeps `opts.json` as the rollback copy through the re-GET
      check (POST its `data.options` back if the untouched field was
      wiped), and deletes both only once the check passes. No ⚠️ added:
      a procedure fix, not a newly hit pitfall. `/tmp/dupe_slugs` in §2
      stays (no secrets). Edited via `writing-for-agents`. The block
      passes `bash -n` and `zsh -n`; the merge step run against a fake
      options file kept the untouched fields and left both files
      `-rw-------`. Verified by `verifier`: mechanical checks 5/5 PASS
      (fences balanced, no `/tmp/opts` or `opts_new.json` left, filenames
      consistent, placeholders only, ⚠️ count 3 before and after); open
      read-back Q1–Q5 all answered from the file, no statement left that
      deletes right after the POST.
- [x] `git-helper` Core Rule 7 no-history fallback closed 2026-09-26
      (maintainer call: fall back to the conversation's language). The
      rule hardcoded Traditional Chinese for a repo with no commits, the
      author's preference inside a public generic skill. The no-history
      branch now uses the conversation's language and the draft states
      "no history — using the conversation's language", so the user can
      switch it at the existing ok gate; the "never assume from the chat
      language" clause is scoped to when history exists. Rejected: keep
      (not generic); ask before drafting (an extra round-trip the ok gate
      already covers). Edited via `writing-for-agents`.
- [x] `python-coding-standards` rule 7 encoding line closed 2026-09-27
      (maintainer call: invert the rule). Rule 7 required
      `# -*- coding: utf-8 -*-` in every run `.py` file and called it
      functional; the interpreter does parse it, but Python 3 already
      decodes source as UTF-8 (PEP 3120), so a UTF-8 declaration changes
      nothing. Commit `a687132` had moved the rule here from the global
      rules file on that "Python still needs it" premise. Rule 7 now says
      save as UTF-8 with no encoding line in the header, declare a
      PEP 263 encoding (line 1 or 2) only for a file that must use another
      encoding, and leave an existing UTF-8 line in place (removing it is
      diff noise). Rejected: keep the wording (false premise in a public
      skill); keep the rule as a "convention" (no reason survives); delete
      rule 7 outright (leaves the habitual cookie unaddressed). Sources,
      quoted verbatim by a subagent and spot-checked with `curl`: PEP 3120,
      PEP 263, PEP 8 "Source File Encoding" (scoped to the core
      distribution, so not cited in the skill), Ruff `UP009`. Edited via
      `writing-for-agents`. Verified by `verifier`: file intact (rules
      1–7, Testing, Design Docs, numbering); open read-back Q1–Q3
      answered from the file (no UTF-8 line in a new file, keep an
      existing one, non-UTF-8 declared on line 1 or 2), Q4 found no
      conflict with rule 6; facts matched PEP 3120, PEP 263 and Ruff
      `UP009`; no old wording left outside `docs/history/`.
      A fresh-context review against `writing-for-agents` then flagged
      "start the header at the shebang or module docstring" as ambiguous;
      it also barred a license or version comment from line 1. Reworded
      to "no encoding line in the header"; its proposed "nothing precedes
      it" was rejected (it would bar a non-UTF-8 declaration on line 1).
      The re-read-back then flagged the rule's title ("declared only when
      a file differs": differs from what?); retitled "declared only for a
      non-UTF-8 file". A license comment on line 1 is now unconstrained,
      which the reader confirmed by finding no rule against it.
      Final read-back by `verifier`: title read as "declare only for a
      non-UTF-8 file", no double reading found, title and body agree.
- [x] `git-helper` Steps 4–5 draft-equals-execution closed 2026-09-27
      (maintainer call). The draft showed the commit message alone, and
      the commit that ran carried a `Co-Authored-By:` trailer the
      environment appended, so the approved text and the logged text
      differed. Step 4 now shows the literal command block: the full
      heredoc with every trailer, plus a push line when the user asked
      for one. Step 5 runs that block unchanged, one command per call,
      pushes only after the commit succeeds, and needs a new draft for
      any differing character. One ok covers the whole block. Rejected:
      one chained commit-and-push command (a local safety hook blocks
      that chain, and removing the hook buys nothing the per-call run
      lacks). Edited via `writing-for-agents`. Verified by `verifier`:
      file intact (Core Rules 1–7, Steps 0–5, fences paired); open
      read-back Q1–Q7 answered from the file (trailer shown in the
      draft, two calls for commit plus push, failed commit pushes
      nothing, a typo fix needs a new ok, no push unless asked), no
      leftover message-only wording; `CLAUDE.md` Settled 10 matches.
      A fresh-context `writing-for-agents` review then flagged Step 5
      saying "push nothing" twice; the closing sentence now only says
      to report the error. Final read-back: failed commit pushes
      nothing, no push outside the block, no character changed, no
      double reading in Step 5.
- [x] `web-stack-selector` simple-datatables exclusion closed 2026-09-27
      (maintainer call: add the survey line now, not on the next
      re-survey). `SKILL.md` Step 2 rule 4 flagged `simple-datatables
      (LGPL)` → Tabulator with no survey line behind it. Checked via
      `gh api` on 2026-09-27: `fiduswriter/simple-datatables`, 1,608
      stars, last push 2026-07-30, not archived; the API license field is
      `NOASSERTION`, while the `LICENSE` file is LGPL v3 and
      `package.json` says `"license": "LGPL-3.0"`. The survey file
      (1.1.1) now carries an "Excluded on license" line under UI
      foundations and admin, noting its 2026-09-27 read date and why a
      re-survey must read the `LICENSE` file rather than the API field.
      Rejected: dropping the name (a common data-table pick, so the flag
      earns its place); waiting for the re-survey (a verbatim API copy
      would record `NOASSERTION` and leave the gap). Edited via
      `writing-for-agents`. Verified by `verifier`: three files intact,
      Settled 1–11 contiguous, live `gh api` values match the survey
      line verbatim (1,608 / NOASSERTION / 2026-07-30), all five rule-4
      exclusions have survey lines, read-back found no ambiguity.
- [x] Official-source research note landed 2026-09-30:
      `docs/research/2026-09-30-official-claude-prompt-sources.md`
      (1.1.0). Scope is guidance for model-read files only (rules
      files, `SKILL.md`, agent definitions); end-user chat-prompting
      tips are excluded by design. 27 entries from official domains
      (platform/code docs, anthropic.com engineering, anthropics
      GitHub), each tagged full-text or summary-only fetch, plus a
      ranked "Top 5 actionable changes". Open conflict recorded, not
      resolved: the Opus 5 page says to drop explicit verification and
      "do not use subagents to verify", while the Fable 5 page favours
      fresh-context verifiers; the Opus 5.5 / Fable 5.1 pages restate
      neither. A follow-up `/claude-api prompt-audit` over this repo's
      skills applied no edit here: the git-helper Rule 7 tag and
      commit-body cap stay as they are, and one flag moved to Open
      (`haos-https-tunnel` HTTP block). Verified by `verifier`:
      header, five sections, entry fields, official-domain URLs,
      read-back Q&A.
- [x] `completion-gate`'s Scope boundary security example re-aligned
      2026-10-01 to the maintainer's own rules, which had split the three
      security skills into tiers. The old "at a milestone or before
      merge" never fired in practice: merges are rare and a milestone is
      hard to judge. The example now reads: `security-and-hardening`
      while writing; `/security-review` of the pending diff after every
      code change; `security-audit` as a focused review when the change
      crosses a trust boundary, and in full before a first production
      deploy. Still an `e.g.`; the stand-in, downgrade and wrap-up step 1
      pointer are unchanged. A first draft carried the rules' full
      objective trigger list (7 lines); a fresh-context
      `writing-for-agents` review flagged it as sprawl that buried the
      stand-in, and the maintainer chose this 4-line version. Not taken
      from that review: dropping "after every code change" (an agent does
      not run `/security-review` unprompted, so the clause is not a no-op) and
      leaning on the reader's global config (a skill stands on its own).
      Deliberately left out: any execution-model claim for
      `/security-review` (fresh context, sub-tasks) and its exclusion
      list, for the same reason as the 2026-09-20 entry above (the
      built-in command's internals are [unconfirmed]); the missing
      `origin/HEAD` recovery, which is per-machine procedure. Edited via
      `writing-for-agents`. Verified by `verifier` read-back 7/7
      (each skill tied to its timing, no milestone/merge wording, no
      execution or exclusion claim, no personal-config references,
      stand-in unchanged versus HEAD, lines ≤ 80 chars, 3 read-back
      questions answered from the file alone); the not-found claims
      re-checked by grep in the main session.
- [x] `haos-https-tunnel` §4 split on Core version 2026-10-01, closing
      the 2026-09-30 Open item. The private device record (YAML `http:`
      block ignored after the 2026-08-15 upgrade to Core 2026.8.1) was
      checked against the official `http` integration page and the
      2026.8 release post: the block is imported into `.storage/http`
      on the first start after upgrading, managed under Settings →
      System → Network from then on, and a repair "HTTP YAML
      configuration is ignored after migration" fires if it stays in
      the file. §4 now carries two branches, boundary 2026.8 (the
      change shipped in the .0 release, so .1 would misdescribe .0
      boxes): ≥ 2026.8 is a user hand-off to the UI (Trust
      X-Forwarded-For, Trusted proxies `172.30.33.0/24`, Enable IP
      banning, Login attempts before ban 3; saving restarts HA), with
      ⚠️ only on the observed YAML-ignored pitfall; < 2026.8 keeps the
      YAML block and its three bullets byte-identical. The §1 hand-off
      bullet now lists two user steps, the header dates the ≥ 2026.8
      observation, and §7 names the settings without YAML keys. Left
      out: the 2027.2 cut-off (community source only; the official page
      has no such date) and any `.storage/http` edit over SSH (no
      official route). Whether a fresh ≥ 2026.8 install imports a YAML
      block is undocumented, so the skill sends every ≥ 2026.8 box to
      the UI. Rejected: UI-only rewrite (drops the 2026-07-10 tested
      path); YAML-first with a note (leaves ≥ 2026.8 readers a dead
      step). Edited via `writing-for-agents`. Verified by `verifier`
      9/9: frontmatter and sections 0–7 intact, two branch headings at
      "2026.8", YAML bullets unchanged versus HEAD, ⚠️ only at the two
      §4 pitfalls, `grep -c 2027` = 0, cross-references resolve, diff
      confined to the four touched spots, read-back 3/3; the
      not-found claims re-checked by grep in the main session.
- [x] Open item added 2026-10-01: evaluate running every skill in
      `skills/` through the skill-authoring skills (`skill-creator`,
      `writing-for-agents`), one pass per skill with its changes
      logged. Scope and order undecided; no work started.
- [x] Skill-authoring pass scoped 2026-10-01, answering the Open item
      above: `docs/research/2026-10-01-skill-authoring-pass-plan.md`
      (1.0.0). Findings: every skill already had `writing-for-agents`
      applied, but scoped to the change in hand (the two logged
      whole-file uses are `handover`'s 2026-09-08 creation and the
      2026-09-09 audit of `completion-gate` and `handover`), so the new
      value is the whole-file Pruning and hierarchy check;
      `quick_validate.py` passes
      7 of 8, flagging `handover`'s `argument-hint` and
      `disable-model-invocation` as unknown keys (Claude Code frontmatter,
      kept; whether Codex/Gemini ignore unknown keys is [unconfirmed]).
      Decided: option A, pilot on `handover` (untouched since
      2026-09-10, 108 lines, zero ⚠️), then the rest by ⚠️ count
      ascending; `skill-creator` limited to validation plus description
      optimization on completion-gate, the three HAOS skills and
      web-stack-selector (`handover` is `disable-model-invocation`,
      `git-helper` is asked-first by policy, `python-coding-standards`
      had its pass 2026-08-19); the with/without-skill eval loop dropped
      (HAOS skills need hardware, process skills are subjective). Guardrails
      written into the plan: Settled 1–12 off-limits, ⚠️ paragraphs and
      tested procedures not prunable, reviewer gets skill + criteria only.
      Verification per pass fixed in plan §5. No skill edited. The
      `CLAUDE.md` Open 1 rewrite edited via `writing-for-agents`:
      pointer plus next step only, details left to the plan file.
      Verified by `verifier` 8/8: header and §1–§6 intact, lines ≤ 80
      chars, table counts and dates match `wc`/`grep`/log, validator
      7 valid + handover unknown keys, Settled 1–12 contiguous, plan
      path resolves, log diff insert-only, read-back 3/3;
      the not-found claims re-checked by grep in the main session.
- [x] Skill-authoring pass pilot on `handover` (2026-10-01), per the plan
      above. Spec lookup for plan §3 first: Codex (`parser.rs`, no
      `deny_unknown_fields`) and Gemini (`skillLoader.ts`, reads only
      `name`/`description`) both ignore unknown frontmatter keys, the
      Agent Skills spec text says nothing about extras, so
      `argument-hint` and `disable-model-invocation` stay and §3 is now
      resolved from source. Whole-file `writing-for-agents` review by a
      fresh-context `opus` reviewer given the skill, the reference and
      the plan's guardrails only: 11 findings, 11 not-found levers.
      Landed (maintainer's pick): F1 Scope boundary bullet 2 no longer
      says "entirely / never how" while step 2 says "write it directly"
      — one rule, fallback unchanged; F2 step 3 gains the
      no-`CONTEXT.md` branch (lazy creation belongs to domain-modeling,
      matching Settled 2) and routes `CONTEXT.md` edits to that skill;
      F3 step 1's candidate list is exhaustive and tagged
      (*architecture decision* / *top-level docs* / *production* /
      *follow-up*), which step 2's Done when already presumed; F4 the
      TODO-vs-issue-tracker question moves from "Also worth checking"
      into step 5 as a *follow-up* consumer; F6 "Test/CI drift" bullet
      deleted (ship-readiness is the gate's, per Scope bullet 1);
      F8 step 4's "don't skip it on the assumption…" becomes the
      positive "open that doc and compare it with this session's
      change"; F9 the repo-root rule is stated once, positively, under
      `## Process` (covers ADRs too; the 2026-09-08 "never the repo
      root" decision kept in meaning); F10 only the cadence paragraph
      (2026-09-08) deleted as a duplicate of `completion-gate`'s Scope
      boundary — the three "When to invoke" bullets stay, because
      `completion-gate` step 6's recommendation may read this file.
      Rejected: F5 (merge the commit reminder into Scope bullet 3 —
      keeps the 2026-09-09 wording at the end of the file), F7 (the
      "Skip whatever didn't clear that bar" sentence), F11 (the two
      maintainer-ready restatements), and the reviewer's whole-section
      F10. Frontmatter untouched. Verified: `quick_validate.py` still
      the same two unknown keys only; `grep -c '⚠️'` 0 → 0; `repo root`
      once, `never at the repo root` 0; the three kept sentences
      present verbatim; no line over 80 chars besides `description:`;
      `completion-gate` Scope bullet and README row 50 still map to
      steps 2–5; `verifier` read-back 9/9 (Q&A: missing `CONTEXT.md`
      counts as done, step 4 opens and compares, no skill is named for
      the write-it-directly case — by design); the not-found claims
      re-checked by grep in the main session. Diff: 28+/28−, 108 lines
      before and after. Plan bumped to 1.1.0 (status, §3, table row);
      `CLAUDE.md` Open 1 now points at `git-helper`. Docs `verifier`
      8/8: log diff insert-only +43, plan 1.1.0 with both loader paths
      and commits in §3, Settled 1–12 contiguous, no added line over 80
      chars, no PII; the not-found claims re-checked by grep in the main
      session.
- [x] Skill-authoring pass on `git-helper` (2026-10-01), second pass per
      the plan. Plan §5 first gained the log cross-check the `handover`
      pilot did by hand (plan 1.2.0): each finding under consideration is
      traced via `git blame` to its commit and that commit's log entry
      and tagged with any recorded rejection; a re-proposal lands only on
      new evidence; the mapping stays maintainer-side. Whole-file
      `writing-for-agents` review by a fresh-context `opus` reviewer
      given the skill, the reference and the guardrails plus frozen
      numbering (Core Rules 1–7 and Steps 0–5 are named from outside the
      repo): 20 findings, 6 levers not found. Cross-check: the 2026-07
      commits have no log entries, so their commit bodies served; four
      bore on findings. Landed (maintainer's pick, 17): F1 the
      description carries the trigger branches and says "push when
      asked", matching Step 4 (hand-written, no `run_loop`; a departure
      from plan §2's exclusion of `git-helper`,
      which rested on one maintainer's ask-first policy, not the skill);
      F2 line 8 and "When to Invoke" deleted (the description carries
      them); F3 the Commit Message Quality Standard moved after Step 5 so
      Steps 0–5 lead, Step 4 points "below"; F4 PII hit handling (the
      landmark test, the origin-label sentence) moved from Core Rule 6
      into Step 2b, Rule 6 keeping the mandate plus "Any hit stops the
      run until resolved as Step 2 describes"; F6 the Step 4 example's
      "Rules applied" line no longer models the bare "secrets scan clean
      · PII clean" claim Rule 6 forbids (a15efab promoted Rule 6 for
      exactly that gap) and shows the eye-read; Rule 5's list and 2b's
      "every added line" match it; F7 a subject over 50 is rewritten to
      the core intent and flagged if it still cannot fit (was
      "truncate"); F8 Beams 7 is "Body is why-only" and the Linus
      motivation bullet lost "(not a how-to)"; F9 Rule 7's title no
      longer contradicts its own no-history fallback, its first bullet is
      "When history exists, the log decides" (Settled 8 line unchanged);
      F10–F13 positive phrasing for the empty-staged branch, the chaining
      bullet (the third `git add .` copy gone), Step 0's skip guard and
      "Be specific"; F14 Steps 1–3 no longer restate Core Rules 1/6/7
      (6aa8e4e set the principle: each step lives only in Workflow), the
      Step 2/3 headings keep "(Core Rule 6)" / "(Core Rule 7)" without
      the repeated tag; F15 "Kernel-specific conventions NOT adopted"
      deleted (it conflicted with Step 4's "every trailer your
      environment appends"); F16 "message is documentation" keeps only
      its rationale; F17 2b's change-history parenthetical deleted (the
      2026-09-26 entry holds it); F18 Rule 3's type list deleted; F19
      "Summarise the core purpose" deleted. Rejected: F5 (a push-failure
      branch plus two done-state commands in Step 5: new behaviour, not
      pruning, and Settled 10 makes the Step 4 block what Step 5 runs);
      F20 (Rule 6's inference ban: ba1fff0 kept it salient on purpose,
      and it already pairs with the positive sentence); F8's line 63
      (the "not what code changed" clause was 7a8c66e's fix for a
      read-back that took "describe the problem" as a what-instruction).
      Cost accepted: 2b's moved origin-label sentence is an added line,
      so the landing commit stops once for per-line PII confirmation
      (2026-09-26 precedent). Verified: `quick_validate.py` valid;
      `grep -c '⚠️'` 0 → 0; `[NEVER VIOLATE]` on Rules 1, 6, 7 only
      (5 → 3 occurrences, the two heading repeats); both scan command
      lines byte-identical versus HEAD; the Settled 8 and 10 sentences
      present verbatim; lines over 80 chars 51 → 46; README row and the
      `completion-gate` reference still map (neither names a step
      number); the global rules name step 2b, Core Rule 7 and Steps 4–5,
      all unchanged in number; `verifier` 10/10 (its one FAIL was the
      criterion's literal-heading wording; the headings carry the same
      parenthetical suffixes as HEAD) with read-back 5/5 (landmark test
      at 2b, over-50 subject rewritten, `git log --oneline -10` named
      once at Step 3, push failure not covered — by design, no-history
      draft says so); the not-found claims re-checked by grep in the
      main session. Diff: 40+/53−, 184 → 171 lines. Plan 1.2.0 (§5 step,
      status, table row); `CLAUDE.md` Open 1 now points at
      `python-coding-standards`.
- [x] Skill-authoring pass on `python-coding-standards` (2026-10-02),
      third pass per the plan. Cross-check map first (plan §5): nine
      blame commits; `12edec6` (PEP 440 pins, 2026-08-29) and `fe866b4`
      (pytest pitfalls, 2026-08-30) have no log entry, so their commit
      bodies served; the 2026-08-19 entry records four `deep-reviewer`
      rounds with no detail. Whole-file `writing-for-agents` review by a
      fresh-context `opus` reviewer given the skill, the reference, the
      guardrails, Settled 4/6/9 verbatim and frozen Core Rules 1–7
      (named from the global rules file): 26 findings (20 body, 6
      description), 11 levers found, 6 not found. Landed (maintainer's
      pick, 12): F1 intro opens "Standards for" (was "Defaults for",
      which primed overridable against three `[NEVER VIOLATE]` rules);
      F2 the scope paragraph states the applies-to case first and the
      illustrative-snippet exemption second, "assume it does" kept; F3
      the chat copy-paste case moves from rule 1 into that paragraph,
      so the whole real-code test sits under one heading; F4 "When to
      Invoke" deleted (the description carries it; `git-helper` F2
      precedent); F5 rule 1's "don't backfill" is "the rest of the file
      keeps its signatures as they are unless asked"; F6 rule 2's
      constant clause no longer restates the smell definition, both
      examples and the `logger` case kept; F7 rule 3's three dash-joined
      clauses split, "leaves `basicConfig` to its importer"; F9 rule 5's
      third sentence (the WHAT half spelled out again) deleted; F14 the
      "de facto standard" rationale deleted; F15 "not just that it ran
      without crashing" deleted from bullet 4 (the frozen bullet 1
      carries it); F16 "The probe satisfies this rule…" deleted (bullet
      1's "applies to a probe just as much" carries it); F17 the
      hand-rolled-setup bullet is "write the test in it. If switching
      to `pytest` looks worth the churn, suggest it to the user".
      Rejected: F8 (stdout/stderr aside), F12 (`^=` rejected by pip),
      F19 (`_doc/` example) — each reads as a reader-confusion or
      incident fix the log never detailed, and no-op status is
      model-relative, unproven without a run; F10 (add "format with
      Black": new behaviour, `git-helper` F5 precedent) and F18 (widen
      the run-it check to every entry point: same reason); F11 (fold
      `==`/`>=` into the `~=` sentence: `12edec6`'s body names `==` as
      the rejected alternative on purpose, and `pip freeze` makes it the
      default); F13 (drop Ruff `UP009`: the 2026-09-27 entry lists it
      among the verified sources, so it is the in-file trace); F20
      (delete Design Docs: founding scope in `c652c79`'s body and the
      README row). Description F21–F26 not applied: plan §2 keeps this
      skill out of description optimisation because the 2026-08-19
      `run_loop` pass already tuned the string, and a hand edit would
      override eval-tuned text without re-running the eval; the six
      findings (front-load the leading word, the "Applies whether…"
      sentence re-renames branch A, three synonyms for the
      quick-script case, the rule list is identity, four examples of
      one exclusion, "non-Python languages" is a no-op) are kept in this
      entry for the day `run_loop` is re-run. Verified:
      `quick_validate.py` valid; `grep -c '⚠️'` 1 → 1; `[NEVER VIOLATE]`
      3 → 3 (rules 1, 2, Testing bullet 1); Core Rules 1–7 headings in
      order; the ⚠️ fenced command, error string and rule 7's "existing
      … UTF-8 line keeps it" sentence present; description line
      byte-identical to HEAD; eight hunks, none in rules 4, 6, 7,
      Testing bullets 1–2 or 6–8, or Design Docs; lines over 80 chars
      6 → 6 (description and rule 7, all pre-existing); README row 54
      still maps (every named topic present); `verifier` 8/8 with
      read-back 7/7 (chat code is real code, other signatures stay,
      never-mutated container is a constant, importer calls
      `basicConfig`, hand-rolled setup is used, probe is the minimum and
      the `[NEVER VIOLATE]` bullet binds it, unsure means the rules
      apply); the not-found claims re-checked by grep in the main
      session. Diff: 22+/38−, 149 → 133 lines. Plan 1.3.0 (status,
      table row); `CLAUDE.md` Open 1 now points at `web-stack-selector`.
- [x] Skill-authoring pass on `web-stack-selector` (2026-10-02), fourth
      pass per the plan. Cross-check map first (plan §5): 140 of 147
      lines from the founding `e6d7558` (no log entry, commit body
      serves), 6 from `bf803ea` (the bar paragraph and the tremor flag,
      2026-09-26 entry: rejected "tightening the picks"), the
      description from `0aad280`, a revert with no body and no log
      entry of `4e033f3`, which had widened the description 67 minutes
      earlier on live-test evidence (a Traditional Chinese "which
      package for a Flask map" question never fired the skill); the
      survey's `26e0651` entry rejects dropping the simple-datatables
      name or waiting for the re-survey. Whole-file `writing-for-agents`
      review by a fresh-context `opus` reviewer given the skill, the
      survey, the guardrails, Settled 5/11 verbatim and a frozen list
      (the ⚠️ paragraph, the five rule-4 exclusions, the bar definition,
      the tremor flag, every survey-backed number): 26 body findings, 5
      description, 12 levers found, 6 not found, plus a 45-row body ↔
      survey consistency table; every not-found and consistency claim
      re-grepped in the main session. Landed (maintainer's pick, 21 of
      26, in two tiers). Consistency: F1 "last-commit" → "last-push"
      (the survey column); F5 the Vue row says the survey holds no
      Vue pick that meets the bar (it held only a 189-star port); F6
      Step 2 is done when constraints 1, 2, 3 and 5 have a yes/no and
      rule 4 applies on every run; F9 ECharts is removed on low-power
      targets (the survey note), no longer tied to "about 3D"; F11
      `robsontenorio/mary` slug added beside mary-ui; F15 dayjs "(2 KB)"
      dropped, the one size the survey did not back; F16 the magicui
      MCP cell says "No official public MCP found", the survey's own
      width; F17 "shadcn / magicui / aceternity" so "those three" has
      three; F23 Figma MCP (15,864 / MIT / 2026-09-15, within the bar)
      moved out of the below-bar sentence into its own paragraph, no
      Step 4 row (minimal shape; the 2026-09-26 bar review never counted
      it as a pick); F24 axe-core flagged in place "(MPL-2.0, outside
      the permissive list)", as the intro promises for a pick outside
      the bar; F26 the alternative rule leaves Done when for
      the Step 3 head and now also fires on the alternative's own
      condition (donut → Chart.js, CRUD → refine, editor → fabric.js)
      and speaks notes. Pruning and routing: F2 the citation rule sits
      beside the `references/` pointer, Done when keeps "carries its
      source and date"; F4 row C wins over row A's PHP signals and
      "routes on to A or B"; F7 "removed" at both Step 2 removal sites,
      the token Done when checks; F10 rule 4 points at the intro's
      permissive list; F13 section headers drop the Step 1 signal
      parentheticals; F14 "; both replace GSAP" dropped (rule 4 is the
      source); F18 "Sections D and E are framework-agnostic" at the
      Step 3 head, Section C's row deleted; F20 the Google Maps JS API
      row gets a positive route (supercluster, deck.gl), no loading
      method asserted since the survey records none; F22 the shadcn
      MCP row says what the server does and "Any non-React stack"; F25
      the inverse "every removed candidate names the constraint" clause
      dropped. Rejected: F3 (delete the BaaS and AI-generation survey
      sections) and F19 (delete survey Note cells) — disclosed
      reference costs no context load and the snapshot is a record; F8
      (Tailwind note → pointer: six words beside the pick); F12 (split
      Sections A/B/C into three files: 35 lines, and a PHP run would
      read two of them); F21 (pixi note as a no-op: model-relative,
      unproven without a run). Description: D1 "any backend" → "any
      stack" landed by hand (React is not a backend); D2–D5 (duplicate
      MCP trigger, the negated exclusion sentence, the enumeration, the
      three Step 2 constraint branches) are carried as candidate edits
      into the `run_loop.py` stage, which plan §2 schedules for this
      skill and which is still open: `run_eval.py` fires each query via
      `claude -p --model`, ~20 user-reviewed queries × 3 runs × up to 6
      rounds ≈ 360 checks; the eval set must carry Traditional Chinese
      one-line queries of the `4e033f3` kind; the model for the run is
      a maintainer call (`skill-creator` says the session model;
      `30-ops.md §12` gate ① does not hold). Verified:
      `quick_validate.py` valid (run with the pyenv 3.13 interpreter,
      the default `python3` lacks PyYAML); `grep -c '⚠️'` 1 → 1, the
      paragraph unchanged; Settled 5 and 11 sentences and the tremor
      flag present verbatim; six rule-4 arrows; all 46 bold slugs in the
      survey; Section D/E tables untouched except the Google Maps row;
      description differs from HEAD at one word; rule-4 lines 51–52
      rewrapped for F10, content unchanged; 21 hunks; lines over
      80 chars 42 → 41; `verifier` 8/8 with read-back 9/9 (row C wins,
      rule 4 needs no yes/no, ECharts removed, D/E reach Section A,
      source and date beside a star count, donut speaks Chart.js, Figma
      within the bar, axe-core flagged, Google Maps clusters with
      supercluster); the first read-back's Q7 showed the Figma sentence
      still read as below the bar inside that paragraph, so it became
      its own paragraph and Q7 was re-asked (PASS). Diff: 38+/33−,
      147 → 152 lines. Plan 1.4.0 (status, table row); `CLAUDE.md`
      Open 1 now records the body pass and points at the description
      run, then `completion-gate`.
- [x] `web-stack-selector` description run (2026-10-02), the `run_loop.py`
      stage plan §2 scheduled after the body pass; closed with HEAD
      standing, no `SKILL.md` edit. Eval set: 20 queries (10/10),
      four of them Traditional Chinese one-liners including the
      `4e033f3` Flask-map question, reviewed in `eval_review.html` and
      exported unchanged. Three descriptions scored with `run_eval.py`
      (3 runs per query, `opus`, 10 workers, `--timeout 90`), each in
      two configurations: isolated (`--setting-sources project`, no
      other skill listed) and with competitors (51 skills linked in,
      43 listed by `claude -p`).
      HEAD 20/20 and 20/20 (mean rate 1.00 / 0.00); D2–D5 hand-applied
      20/20 and 20/20, identical; the reverted `4e033f3` widened text
      20/20 and 19/20, firing 3/3 on the should-not React Native map
      question under competitors. `run_loop.py` not started: it exits
      on iteration 1 when every train query passes (`all_passed`), so
      a run from HEAD returns HEAD. Decided (maintainer, option A of
      three: A close on these numbers, B a diagnostic `sonnet` run, C a
      harder set): D2–D5 stay candidates (plan §4.4, no evidence);
      the `0aad280` revert now has a number. The 2026-09-16 live miss
      is unreproduced under these conditions (the same question hits
      3/3 under HEAD in both configurations and in two single probes),
      not "fixed": the harness is a fresh `claude -p` without the
      global rules, a command-file stand-in, `opus`. Three defects in
      the installed `skill-creator` scripts, each confirmed by a probe
      and fixed on a scratch copy only (install directory untouched):
      workers share one `.claude/commands/` so a `claude -p` picks a
      sibling's suffix and counts as a miss (first HEAD run 10/20
      before the fix, every should-trigger at 0/3 or 1/3); the
      project root resolves to `~` through a real `~/.claude`; the
      installed real skill is listed beside the test command and
      absorbs the trigger. Full record, scratch diff, run script, eval
      set and the candidate texts:
      `docs/research/2026-10-02-web-stack-selector-trigger-eval.md`,
      the harness fixes the remaining four runs need again. Verified:
      `SKILL.md` byte-identical to HEAD (`git status` clean for
      `skills/`); json block of the note re-parsed, 20 items, 10 true;
      `verifier` read-back on the note 5/6 with Q1–Q5 PASS, the two
      findings fixed (json closing fence on its own line; "no body"
      → git's own "This reverts commit" line, checked with `od`);
      second `verifier` round on the four touched files 5/5 with
      Q1–Q4 PASS and no full model ID anywhere. Plan 1.5.0 (status,
      table row, harness pointer in §2);
      `CLAUDE.md` Open 1 now points at `completion-gate`.
- [x] Skill-authoring pass on `completion-gate` (2026-10-02), fifth pass
      per the plan. Cross-check map first (plan §5): twelve blame
      commits; 140 of 249 lines from the founding `59fcf47` (no log
      entry, commit body serves), the rest from eleven logged edits
      between 2026-08-21 and 2026-10-01, each tagged with what its entry
      records (rejections: the step-6 softer phrasing, trimming the Code
      row's ⚠️ numbers, restating the stand-in reporting rule in step 1,
      dropping "after every code change"; costs accepted: cadence left as
      the user's call, the stand-in placed in the Scope bullet, step 1's
      pointer so a literal reader can pass it). Whole-file
      `writing-for-agents` review by a fresh-context `opus` reviewer given
      the skill, the two reference files, plan §4–§5, Settled 1 and 3
      verbatim and a frozen list (the six ⚠️, the three `[NEVER VIOLATE]`
      tags, the authoring clause on the table, the Docs-row PII question,
      `git diff HEAD --stat`, the four-line security example): 17 body
      findings, 7 description, 12 levers found, 5 not found; the
      reviewer caught the frozen list's off-by-one (the security example
      is lines 24–27, not 25–28) and froze 24–28. Every line number and
      quote re-grepped in the main session; the five not-found levers
      accepted (no `disable-model-invocation`, so invocation, router and
      split-by-invocation do not apply; no environment lookup restated).
      Landed (maintainer's pick, 15 of 17, two tiers). Tier 1: F2 Scope
      bullet 2 no longer hands anti-anchoring and tier choice outside
      (the file owns both); F6 "When to Invoke" deleted (the description
      carries all five branches; `python-coding-standards` F4 precedent);
      F7 the hand-the-artifact-only rule single-sourced into Core Rule 1,
      the standalone paragraph after the table deleted; F10 "the
      *downgrade*" named where it is defined (no-subagent step 2), so the
      three pointers to it have an anchor; F12 the wrap-up heading reads
      "(run in this order)"; F16 step 4 drops "same as Core Rule 1",
      which limits proportionality to code while step 4 applies it to
      rules/config too. Tier 2: F1 the intro's cost sentence deleted
      (meaning lives in "You economise on the unit price"); F3 "it never
      replaces the commit workflow itself" dropped; F4 the no-security-
      skill stand-in moved from the Scope bullet into a table row ("Security
      review of code crossing a trust boundary", so "the security row"
      reuses a label word like every other row pointer) after the Code
      row, the bullet keeping
      the frozen example plus a pointer mirroring the code-review
      bullet's, step 1 now naming "the security row's stand-in" — this
      overrides the 2026-09-26 placement on evidence that entry did not
      weigh: the Code row's own fallback is in the table, so the mirror
      argument supports the row; the "Code row … makes no security
      judgement of its own" sentence kept as the row's last line, since
      the 2026-09-20 entry leans on it; F5 handover cadence
      single-sourced in step 6, the Scope bullet keeping "Run it only
      after this gate passes, never in place of it; wrap-up step 6 says
      when to ask" (`handover`'s 2026-10-01 F10 deleted its own copy as a
      duplicate of this bullet; the surviving source is step 6); F8 "but
      a one-character code fix does not summon a panel" dropped (the Code
      row's typo-fix sentence draws the line); F9 Core Rule 5 deleted
      (delivery part 3 binds it); F14 step 2 walks "each doc the repo
      tracks"; F15 step 4 points at the judgement-call row instead of
      re-listing its members, "a rules/config file whose failure mode is
      silent" kept; F17 partial: "(see Scope boundary)" dropped from step
      6 after F5. Rejected: F11 (wrap-up to a sibling `WRAP-UP.md`: the
      reviewer's own verdict was last-to-land, six back-references, and
      the step-6 ⚠️ records the sequence being skipped while inline);
      F13 (delete step 1's "For code … (Core Rule 1)" span: re-proposes
      the 2026-09-10 code list, the 2026-09-24 no-size-exemption clause
      added because no step triggered it, and the 2026-09-26 literal-
      reader pointer, with no new evidence); F17's main part (delete
      "Completing step 5 is not permission to skip straight to
      committing" and "never a bare yes/no": 2026-09-10 kept the direct
      prohibition after a softer phrasing failed read-back, and the ⚠️ is
      a record, not the rule). Description D1–D7 not applied: plan §2
      schedules this skill's `run_loop.py` stage next, and all seven
      (five synonyms for the done branch, three tokens for Core Rule 3,
      "calling it a day", "picking work back up tomorrow" — tagged a
      factual error by the reviewer, read here as an ambiguous wrap-up
      phrase rather than a claim the body contradicts —, "after any
      failure" unscoped to own work, the table-of-contents sentence,
      "Decides whether work may be called done" not front-loaded) go in
      as candidate texts; D6 is the largest context-load saving. Verified:
      `quick_validate.py` valid; `grep -c '⚠️'` 6 → 6; `[NEVER VIOLATE]`
      3 → 3; security example lines 24–27 byte-identical to HEAD; `git
      diff HEAD --stat`, the step-6 prohibition, "never a bare yes/no"
      and the PII question each present once; description byte-identical
      to HEAD; authoring clause still directly after the table (five
      rows); 17 hunks, none in the ⚠️ paragraphs; lines over 80 chars
      10 → 11 (the new table row); `verifier` M1–M6 6/6 and read-back 10/10
      (stand-in and its reporting from the security row, Code row makes no
      security judgement, artifact and criteria only, cadence is the user's
      call in step 6, the downgrade defined in no-subagent step 2,
      rules/config file in step 4, docs the repo tracks, "run in this order",
      the typo-fix line, gaps in part 3), contradictions none found;
      `handover`'s Scope bullet re-grepped (it points at the gate, not at
      the cadence rule, so F5 strands no pointer); no live `Core Rule 5`
      / `When to Invoke` reference outside `docs/trigger-audit-notes.md`'s
      2026-08-21 record; `deep-reviewer` second opinion on F4's
      relocation skipped on the maintainer's call (verbatim text moved,
      every pointer resolved by the read-back). Diff: 31+/54−,
      249 → 226 lines. Plan 1.6.0 (status, table row); `CLAUDE.md` Open
      1 now records the body pass and points at the description run.
- [x] `completion-gate` description run (2026-10-02), the stage plan §2
      schedules after the body pass; closed with HEAD standing, no
      `SKILL.md` edit. Eval set: 20 queries (10/10), four Traditional
      Chinese one-liners, seven should-not in pool siblings' territory,
      reviewed in `eval_review_completion-gate.html` and used as
      drafted. Harness: the three §2 fixes reapplied on a scratch copy
      (diff identical hunk for hunk to the recorded one), a fresh pool
      of 51 skills without `completion-gate`, probe listing 43 with it
      absent. Four descriptions × two configurations (isolated / 43
      competitors), `opus`, 3 runs, 10 workers, `--timeout 90`, eight
      runs in all. HEAD 19/20 and 19/20 (1.00 / 0.10), its one miss a
      3/3 false trigger on a delegated-subagent failure; D1–D7
      hand-applied 19/20 and 19/20 (0.90 / 0.00, 0.87 / 0.00), its one
      miss a 0/3 on the Traditional Chinese own-work deploy failure. Two
      hybrids run on the maintainer's first pick (option A of three: A
      the two hybrids, B `run_loop.py`, C close on the first four): HEAD
      + D5 only 18/20 twice (loses the deploy query 0/3, still fires 3/3
      on the delegated one); D1–D7 with D6 restored 18/20 twice (deploy
      still 0/3, delegated back to 2/3). Decided (maintainer's second
      pick, option A of three: A HEAD stands, B 10-run re-measure of the
      mixed cells, C `run_loop.py`): D5 refuted — its clause is what the
      three failing texts share, 0/18 on the own-work query it was
      written to keep, and it buys nothing on the delegated one; D6
      double-edged — the table-of-contents sentence drives most of the
      delegated false trigger and holds the delivery-message query at
      3/3 under competitors, so it carries two branch triggers, not pure
      context load; D1–D4 and D7 untested alone, still candidates. The
      delegated-failure label was written with D5 in hand and is
      arguable (the failure table's second row says "escalate to a
      stronger model"); relabelled, HEAD is 20/20 and the verdict does
      not move. `run_loop.py` not started: the hybrids answer the
      attribution its proposals would re-ask, and its hold-out can park
      the one failing query on the test side. Full record, eval set, the
      four texts, harness notes:
      `docs/research/2026-10-02-completion-gate-trigger-eval.md`.
      Verified: `SKILL.md` byte-identical to HEAD (`git status` clean
      for `skills/`); json block of the note re-parsed, 20 items, 10
      true; the four texts in the note byte-equal to the scratch
      baselines; `verifier` read-back first round M1–M6 6/6, Q1–Q7 6/7
      with three findings fixed (one competitor-config rate in this
      entry, the two option menus named as first and second pick, the
      pool change spelled out in the note's §2); second round on the
      three fixed passages Q1–Q4 and M1–M2 6/6. Plan 1.7.0 (status,
      table row, §2 In list); `CLAUDE.md` Open 1 now records both
      `completion-gate` passes and points at `haos-https-tunnel`.
- [x] Skill-authoring pass on `haos-https-tunnel` (2026-10-04), sixth pass
      per the plan, first of the HAOS three. Cross-check map first (plan
      §5): three blame commits; 115 of 143 lines from the founding
      `abec32d` (no log entry, commit body serves: store-add trap,
      trusted_proxies, auth hand-off, QUIC fallback, backup hygiene), 27
      from the 2026-10-01 §4 split (entry records two rejections, UI-only
      and YAML-first-with-a-note, and two deliberate omissions, 2027.2 and
      `.storage/http` over SSH), one placeholder line from 2026-09-26.
      Whole-file `writing-for-agents` review by a fresh-context `opus`
      reviewer given the skill, the two reference files, plan §4–§5, the
      repo's inclusion rules, Settled 12 verbatim and a frozen list (the
      seven ⚠️ passages, the five fenced blocks, the §4 YAML bullets, the
      `<iata>01` placeholder, §2's number as `haos-cloud-backup`'s
      inbound target, the ~90-char wrap): 13 body findings, 5
      description, 8 levers found, 7 not found; two candidates withdrawn
      by the reviewer on scope. Every line number and quote re-grepped in
      the main session; the not-found claims re-checked (no disclosure
      candidate, no buried steps, versions dated but uncontradicted).
      Landed (maintainer's pick, option A of four: A tiers 1+2, B tier 1
      only, C tiers 1+2 plus F3, D nothing), 11 of 13: F2 the `ha` alias
      and Protection-mode-off moved from the header into a §1 bullet
      beside the SSH pointer; F4 "re-suggest one only on new facts"; F7
      §3's other-options sentence replaced by "Leave `tunnel_token`
      unset: §5's login flow creates the tunnel"; F8, F10 done signals
      for the two user hand-offs (UI values saved and HA back; user
      reports the authorisation, §6 confirms); F9 the "Either branch"
      paragraph deleted, its LAN-URL fact folded into §7; F12 "HA App" →
      "Companion app" in the body (this file's `ha apps` means add-ons;
      the description's "HA App 外部連線" waits for the description run);
      F1 the header drops the observation date the §4 ⚠️ already
      carries; F11 "— no manual DNS work" dropped; F13 the git-track
      sentence reworded positive ("If the user versions `/config`,
      exclude `.storage/` (auth tokens) and `secrets.yaml`"), keeping
      the founding commit's hygiene point. F6 landed as a variant: the
      reviewer's `"result": "ok"` done signal was unconfirmed, so §3's
      criterion is the re-`GET info` check `haos-addon-deploy` §4 already
      tests, "shows `external_hostname` set". Rejected: F3 (delete §0's
      tunnel-mechanics paragraph: it is the positive the four rejections
      contrast against, so deleting it leaves §0 as pure negation); F5
      (delete "Real-world regret.": the in-file practice-hit marker the
      inclusion rules ask for on bold, non-⚠️ advice). Description D1–D5
      not applied: plan §2 schedules this skill's description run next,
      so all five (front-load "Cloudflare Tunnel (cloudflared add-on)",
      drop the two body-carried clauses, collapse the synonym list to
      three branches, drop "beats those on safety and side effects",
      length ~555 → ~300 chars) go in as candidate texts. Verified:
      `quick_validate.py` valid (scratch venv, this machine has no
      PyYAML); `grep -c '⚠️'` 7 → 7; the five fenced blocks, the five ⚠️
      bullets, the §4 YAML bullets and the header's ⚠️ sentence
      byte-identical to HEAD; two §4 branch headings at "2026.8" in
      order, `grep -c 2027` = 0; description byte-identical to HEAD;
      "HA App" only on line 3; `haos-cloud-backup`'s pointer still lands
      on §2; outbound pointers to `haos-addon-deploy` §0/§8 and §4
      resolve; 8 hunks, none in a frozen passage; lines over 80 chars
      47 → 47; `verifier` read-back M1–M7 7/7 and Q1–Q8 8/8 (alias and
      Protection mode in §1, `tunnel_token` unset, the three done
      signals, LAN URL in §7, the four rejections and their re-suggest
      rule); the not-found claims re-checked by grep in the main
      session; `deep-reviewer` second opinion skipped on the
      maintainer's call (no frozen passage touched, every edit read
      back). Diff: 14+/17−, 143 → 140 lines. Plan 1.8.0 (status, table
      row); `CLAUDE.md` Open 1 now records the body pass and points at
      the description run.
- [x] `haos-https-tunnel` description run (2026-10-04), the one plan §2
      schedules after the body pass; the first description change this
      pass has made. Harness: scratch copy of `skill-creator`'s scripts
      with the three recorded fixes reapplied (diff identical hunk for
      hunk to the recorded one), scratch venv (Python 3.14, PyYAML
      6.0.3; the recorded pyenv 3.13 interpreter is gone from this
      machine), pool of 37 links excluding `haos-https-tunnel`, probe
      listed 47 entries with the real skill absent and both HAOS
      siblings present. Eval set 10/10, four zh-TW should queries split
      two with the description's own phrases and two without, so D3's
      synonym cut had a measurement; ten near-miss should-nots covering
      both HAOS siblings, Tailscale, Nabu Casa, plain Cloudflare DNS,
      HA on Docker and HA Core; reviewed in `eval_review.html`, used as
      drafted. Four texts × two configurations (isolated, 37
      competitors), `opus`, 3 runs per query: HEAD, D1–D4, HEAD + D3
      only, D1 + D2 + D4, all 19/20 in both; the one shared failure is
      Q19 (`cloudflared` QUIC fallback on a Proxmox VM, should-not), 21
      of 24 runs firing across the four texts, "for a HAOS box" or not,
      so the hook is `cloudflared` itself and no clause in the set moves
      it; stays open, a scoping negation untested. D3 safe: the no-phrase
      zh-TW queries 3/3 on every text, the verbatim-phrase ones 3/3 on
      D1–D4 without them; closes the body pass's F12 leftover ("HA App"
      in the description). Landed: D1–D4 (maintainer's pick, option A of
      three: A D1–D4, B HEAD stands on the tie precedent, C D1 + D2 + D4
      keeping the phrases), on length alone: accuracy tied, 555 → 319
      always-loaded characters. The 6-runs-per-query confirmatory re-run
      offered and declined (resolution 1/3 → 1/6, decision unchanged).
      `run_loop.py` not started: HEAD's one failure is a should-not every
      candidate shares. Frontmatter wraps the description in double
      quotes: D1's "(HAOS): give" is invalid as a bare YAML value
      (`quick_validate.py` "mapping values are not allowed here"); the
      harness's block-scalar stand-in could not see it; six repo skills
      already quote. README table line unchanged: it was its own summary,
      never a copy of the description. Full record, eval set, the four
      texts, harness notes:
      `docs/research/2026-10-04-haos-https-tunnel-trigger-eval.md`.
      Verified: `quick_validate.py` valid; `grep -c '⚠️'` 7 → 7; `git
      diff` on `SKILL.md` confined to line 3; the landed text parsed
      back from the frontmatter byte-equal to the scored `d1-d4.txt`;
      json block of the note re-parsed, 20 items, 10 true; the four
      texts in the note byte-equal to the scratch baselines; `verifier`
      read-back M1–M7 7/7 (all eight table cells and the mixed-cell
      sentence recomputed from the raw json) and Q1–Q6 6/6; its
      no-other-mixed-cell claim re-checked against the main session's
      own per-query table. Plan 1.9.0 (status, table row,
      §2 In list); `CLAUDE.md` Open 1 now records the description run
      and points at `haos-cloud-backup`.
- [x] `web-stack-selector` Section F, Vue / Nuxt (2026-10-04). Asked
      whether Vue / React / Vite / TypeScript belong in the skill:
      React already has Section B; Vite and TypeScript are build and
      language choices, not per-scene libraries, already read as a
      Step 1 signal and as Step 2 constraint 2, so they stay out
      (maintainer call). The old "Vue / Nuxt: uncovered, no Vue pick
      meets the bar" row reflected the 2026-09-16 survey's scope, which
      never covered the Vue ecosystem. New snapshot
      `references/survey-2026-10-04-vue.md` (GitHub API, 2026-10-04,
      `sonnet` subagent): 21 named candidates, 17 within the bar (search
      hits such as `vbenjs/vue-vben-admin` counted apart); no uPlot,
      MapLibre, Leaflet or SortableJS Vue wrapper within it, so Section F
      mounts those directly; no Vue CRUD framework on the refine model.
      Old snapshot's Aceternity row said the Vue port `inspira-ui` had
      189 stars; `unovue/inspira-ui` reads 5,015 (API: created 2024-08-30,
      not a fork), so the row now points at the new snapshot. `SKILL.md`
      1.2.0 → 1.3.0: Step 1 row F, Step 2 constraints 2 and 3 name the
      Vue picks they remove, Section C routes Inertia + Vue to F,
      Section F (six scenes), Step 4 adds the PrimeVue and Nuxt UI
      MCPs and sends Vuetify's below-bar MCP to Context7. Verified: the
      four below-bar rows and the three non-existence claims (uPlot /
      MapLibre wrappers, vuejs-org MCP) re-read via the API in the main
      session, one within-bar row spot-checked; `verifier` read-back 7/7
      PASS (picks vs bar, numbers vs raw survey, cross-references, no
      leftover "uncovered" claim, table shape, read-back Q&A, versions),
      its no-leftover claim re-grepped; its Q&A ambiguity on low-power
      Vue charts fixed by naming uPlot in the Section F chart row; second
      `verifier` read-back 5/5 PASS on that row, this entry and the
      `CLAUDE.md` item. Open: the description still names only
      React among SPA stacks; adding Vue / Nuxt triggers needs a
      description run. `deep-reviewer` second opinion on the picks
      considered and skipped (maintainer call): every pick passes the
      bar mechanically, the edit is text-only, and the description run
      exercises Section F again. README row now names Vue/Nuxt.
- [x] `git-helper` Step 2 hit handling in plain text closed 2026-10-08
      (maintainer call). A scan hit was asked through a choice dialog,
      which covers the text above it, so the raw scan output and the
      hit lines could go unseen while the user ruled on them. Step 2
      now states the stop once, in its lead: the raw output and each
      hit's line go in the reply body, the question is the reply's
      last line, and the user answers by typing; the dialog is named
      (Claude Code's `AskUserQuestion`) only as the example to keep
      out. 2a's "stop and warn" and 2b's "stop and list" collapsed
      into that lead; 2b keeps only what resolves a PII hit and the
      eye-read. Description unchanged, so no README edit or
      description run. Edited via `writing-for-agents`.
      Verified by `verifier`: file intact (Core Rules 1–7, Steps 0–5,
      8 fences paired); read-back Q1–Q5 PASS (plain-text reply, raw
      output in the body, same handling for both scans, no dialog and
      why, PII resolution, no Step 3 while a hit is open); Core Rules
      5 and 6 agree, the stop rule stated once. Its finding that the
      question's content was unstated was fixed ("which hits are safe
      to commit"); re-check PASS. Left open, pre-existing: Step 2 never
      says what resolves a secrets hit, whether an eye-read find counts
      as a hit that stops the run, or whether "its line" means the
      diff text or a line number.
