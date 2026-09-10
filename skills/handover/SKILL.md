---
name: handover
description: Turn a session's work into something a human maintainer with zero session context can pick up — backfill ADRs, check README/CONTEXT.md, record production facts and the deploy path, write a prioritized TODO.
argument-hint: "Anything this session touched that's easy to miss (optional)"
disable-model-invocation: true
---

# handover

Produces the durable, in-repo trail a future maintainer needs — someone who
was never in this conversation, reading only the repo. The target state
throughout is **maintainer-ready**: a human with zero session context can
open the repo cold and tell what changed, why, what's next, and how to run
it in production.

## Scope boundary — these compose, they do not compete

- *Whether this session's work is done enough to ship* → your completion
  gate (this collection ships one: `completion-gate`). Run this skill after
  that gate passes, not instead of it.
- *The mechanics of writing an ADR or maintaining `CONTEXT.md`* → your
  domain-modeling skill, entirely — this collection doesn't ship one (e.g.
  `mattpocock/skills`' `domain-modeling`). This skill only decides *whether*
  one is owed and *when*, never how.
- *Committing what this skill produces* → your commit-workflow skill (this
  collection ships `git-helper`). This skill writes docs; it does not stage
  or commit them.
- *A scratch note for a fresh **agent** to resume mid-task in the same
  session's tool state* → a conversation-handoff skill, entirely — this
  collection doesn't ship one (e.g. `mattpocock/skills`' `handoff`). That
  targets the next **agent turn**; this skill targets the next **human**,
  further out, and writes durable repo files, not a temp-directory note.

## When to invoke

- Closing out a feature, a milestone, or before a longer pause on the
  project.
- Before handing the repo to another engineer, or to your own future self
  on a different machine.
- After any change that touches production configuration, infrastructure,
  or how the project gets deployed.

Some run this after every wrap-up instead of reserving it for milestones —
each step below already resolves to "not warranted" when it doesn't apply,
so that cadence costs nothing extra on a small change. Either is valid; this
skill doesn't assume which.

## Process

1. **Review the session for anything a maintainer needs that isn't in the
   diff.** Decisions made, alternatives rejected and why, constraints
   discovered along the way — not just which lines changed. Build a short
   candidate list against steps 2–4 below before touching any file.
   *Done when*: you have that list, or you've concluded there's nothing
   beyond the diff worth carrying forward.

2. **Backfill architecture decisions.** For each candidate from step 1 that
   changes *how* the system is built or *why*, not just *what* changed, and
   isn't already recorded: write or update an ADR under `docs/adr/` (hand
   the mechanics to your domain-modeling skill, or write it directly if none
   is installed). Skip whatever didn't clear that bar.
   *Done when*: every candidate tagged "architecture decision" in step 1 has
   a matching ADR, or an explicit note that none was warranted.

3. **Check the top-level docs against reality.** Read `README.md` and
   `CONTEXT.md` (or `CONTEXT-MAP.md` if this repo has more than one
   context) and ask of each: does this still describe the system
   accurately after this session? Edit only what's now wrong or missing —
   don't re-transcribe what already holds.
   *Done when*: both files are checked, and each was either edited or
   explicitly confirmed still accurate.

4. **Record production facts and the deploy path.** If this session touched
   anything that runs in production — config, infrastructure, a runtime
   dependency, a deploy step — write down what's now true about the
   production environment, and the exact steps to deploy this change
   (update the project's existing deployment doc if one exists; start one
   under `docs/` if it doesn't — never at the repo root). No other step
   here covers this: don't skip it on the assumption someone already wrote
   it down without checking.
   *Done when*: the deployment doc reflects this session's change, or
   you've confirmed nothing production-facing happened.

5. **Write the handover TODO.** Produce or update `docs/TODO.md` (never at
   the repo root — keep the root to the files that already live there):
   what's done, what's next, and the priority order across what's left —
   written for a reader with none of this session's context. Point at the
   ADRs and docs above rather than restating them.
   *Done when*: `docs/TODO.md` is maintainer-ready on its own — a reader
   with no access to this conversation can tell what to do next and in
   what order.

## Also worth checking

Not gated steps — a maintainer-readiness sweep most sessions miss:

- **Secrets scan the docs you just wrote**, the same way you'd scan a diff
  before a commit — a deploy doc is exactly where a real credential leaks
  in "for reference."
- **This skill's own new files still need a commit.** Steps 2–5 above write
  to the repo but never stage or commit (see Scope boundary) — an ADR or
  `docs/TODO.md` left uncommitted, or committed but unpushed, is invisible
  to the maintainer you're handing this to.
- **Test/CI drift.** Does the test suite still exercise the behavior this
  session changed, or does it only prove the old behavior still works?
- **Open follow-up work.** Anything step 1 surfaced that isn't a doc
  update — does it belong in this project's issue tracker instead of only
  in `TODO.md`?
