---
name: handover
description: Turn a session's work into something a human maintainer with zero session context can pick up — backfill ADRs, check README/CONTEXT.md, record production facts and the deploy path, confirm follow-ups reached the next-steps list.
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
  domain-modeling skill — this collection doesn't ship one (e.g.
  `mattpocock/skills`' `domain-modeling`). This skill decides *whether*
  one is owed and *when*; steps 2–3 hand the writing to that skill, or
  do it directly when none is installed.
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

## Process

Every new file this skill creates goes under `docs/`; the repo root keeps
only the files already there.

1. **Review the session for anything a maintainer needs that isn't in the
   diff**: decisions made, alternatives rejected and why, constraints
   discovered along the way. List each candidate before touching any file,
   tagged with where it lands: *architecture decision* (step 2),
   *top-level docs* (step 3), *production* (step 4) or *follow-up*
   (step 5).
   *Done when*: every decision, rejected alternative and discovered
   constraint from the session is on the list with a tag, or you've
   concluded there's nothing beyond the diff worth carrying forward.

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
   accurately after this session? Edit only what's now wrong or missing;
   `CONTEXT.md` edits go through your domain-modeling skill when one is
   installed.
   *Done when*: each of these files that exists was either edited or
   explicitly confirmed still accurate — or `CONTEXT.md` does not exist
   in this repo (your domain-modeling skill creates it lazily, not this
   step).

4. **Record production facts and the deploy path.** If this session touched
   anything that runs in production — config, infrastructure, a runtime
   dependency, a deploy step — write down what's now true about the
   production environment, and the exact steps to deploy this change
   (update the project's existing deployment doc if one exists; start one
   under `docs/` if it doesn't). Open that doc and compare it with this
   session's change before calling it current.
   *Done when*: the deployment doc reflects this session's change, or
   you've confirmed nothing production-facing happened.

5. **Check the follow-ups landed.** The repo's next-steps list is the one
   priority list a fresh session reads to learn what's next, usually kept
   by your completion gate's wrap-up: the list the repo's `CLAUDE.md` /
   `AGENTS.md` routes what's-next questions to, or holds itself; with
   neither, an existing `docs/TODO.md` or `TODO.md`; with none of these
   and at least one follow-up, create `docs/TODO.md` and add that route
   line to whichever of `CLAUDE.md` / `AGENTS.md` the repo loads; with
   neither, tell the user the list has no route line. Confirm each
   *follow-up* candidate from step 1 has an entry there — what it is,
   why it holds its rank, its next concrete action, the path to read
   first. Add any that are missing, in priority order, and decide
   whether each also belongs in this project's issue tracker.
   *Done when*: every follow-up candidate has an entry in the next-steps
   list.

## Also worth checking

Not gated steps — a maintainer-readiness sweep most sessions miss:

- **Secrets scan the docs you just wrote**, the same way you'd scan a diff
  before a commit — a deploy doc is exactly where a real credential leaks
  in "for reference."
- **This skill's own new files still need a commit.** Steps 2–5 above write
  to the repo but never stage or commit (see Scope boundary) — an ADR or
  a next-steps entry left uncommitted, or committed but unpushed, is invisible
  to the maintainer you're handing this to.
