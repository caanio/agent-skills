---
name: completion-gate
description: "Decides whether work may be called done. Use before saying a task is complete, finished, ready, working or fixed; before writing a 'verified'/'PASS'/'tested' claim about your own deliverable; when wrapping up a session, calling it a day, picking work back up tomorrow, or about to commit; before drafting a yes/no confirmation question about a change that touches destructive operations, trust boundaries, or unattended automation; and after any failure. Covers what counts as verification per artifact type, which checks the producer may run and which need fresh context, the honest three-part delivery message, failure counting, and the end-of-session wrap-up order."
---

# completion-gate

The gate between "I think it works" and "it is done". Everything below is cheap
compared with shipping something broken and finding out later.

**Scope boundary** — these compose in sequence, they do not compete:
- *Whether something counts as done* → here.
- *How to farm a check out to a subagent* (thresholds, prompt structure,
  anti-anchoring, tier choice) → your own delegation rules, wherever they live.
- *The mechanics of committing* (staging, secrets scan, message wording) →
  your commit-workflow skill, entirely. This skill only governs what must
  happen **before** a commit; it never replaces the commit workflow itself.
- *The mechanics of a thorough code review* (a multi-axis check, severity
  labels, a real checklist) → your code-review skill, entirely — this
  collection doesn't ship one (e.g. `code-review-and-quality`). The Code
  row below is the one place that says what to do when none is installed.
- *Security review of code crossing a trust boundary* → your security skill,
  entirely — this collection doesn't ship one (e.g. `security-and-hardening`
  while writing it, `security-audit` at a milestone or before merge). The
  Code row below governs tests and code-review triage only; it makes no
  security judgement of its own.
- *A deeper maintainer-handover pass* (backfilling ADRs, checking
  README/CONTEXT.md against reality, recording production facts and the
  deploy path, a prioritized TODO) → the `handover` skill. Run it only
  after this gate passes, never in place of it — how often you reach for
  it (every wrap-up, or only at milestone/handoff moments) is your call,
  not this skill's.

## When to Invoke

- About to say **done / finished / complete / ready / it works / fixed**.
- About to write **verified / PASS / tested / confirmed** as a claim about your
  own deliverable.
- Wrapping up a session, or about to commit.
- About to draft a yes/no confirmation question ("commit this?", "proceed?",
  "apply this?") for a change that touches a destructive operation, a trust
  boundary, or unattended automation.
- **After any failure**, not just a repeated one.

## Core Rules

1. **[NEVER VIOLATE] You may run a check; you may not be the one who decides
   your own work passed.**
   Split the two:
   - **Deterministic mechanical checks** — a test suite's exit code, a diff, a
     linter, a build, a script's output. Run these yourself. The result does not
     depend on your opinion, and shipping them to a subagent usually just breaks
     them (wrong working directory, missing environment).
   - **Anything requiring judgement** — "is this documentation clear?", "does
     this design hold?", "is this test actually testing the right thing?",
     "is this finding real?" — goes to a **fresh context that was not told your
     reasoning**. Your own answer here is worth very little; you already believe
     you were right, which is why you wrote it that way.

   The trap this rule exists to close: running a green test suite and concluding
   the *task* is done. Green means the assertions you chose passed. Whether they
   were the right assertions is a judgement call, and therefore not yours.
   *How much* independent judgement a given change deserves is proportional to
   its risk — the Code row below draws that line. This rule fixes *who sets the
   standard*, not *how much review every change gets*: you may not quietly lower
   the bar for your own work, but a one-character **code** fix does not summon a
   panel. That proportionality is specific to code. The Docs row and the wrap-up
   read-back have no size exemption — a one-line edit to a rules file still gets
   read back, because the failure there is silent.

2. **[NEVER VIOLATE] A yes/no confirmation question about a destructive
   operation, a trust-boundary decision, or unattended automation may not
   recommend its own answer until the judgement-call check below has run.**
   Check the artifact-type table *before* drafting the question — not after
   the user pushes back. If the change is a hard judgement call, get the
   independent second opinion first, then ask "reviewed, ready to commit?" —
   never "commit this? (recommended)".
   ⚠️ Observed twice, independently: the model proposed the risky change as
   done-pending-approval, and the review only happened because the user
   pushed back — not because the model raised it.

3. **[NEVER VIOLATE] Completion language may not precede the result it
   describes.**
   *Ran / PASS / verified / confirmed / passed* — when used **as a claim about
   your own deliverable** — must never be written into a file or message before
   the corresponding check has actually returned. Draft with **"pending"** and
   fill it in once real output exists.
   No "it will run in a minute" exemption: writing it early plants a fact
   readers will believe, and it stays false even if the check later passes.
   (This governs *claims*. It does not touch ordinary content that contains
   those words — test fixtures, report templates, `assert status == "PASS"`,
   or reporting what someone else verified.)

4. **State the verification method before you start.** If you cannot write down
   "here is the command or observation that will prove this worked" *before*
   touching anything, you do not yet understand the task. Go gather information
   instead of starting.

5. **Report honestly, including the gaps.** Staying quiet about what you skipped
   destroys trust faster than the gap itself ever would.

## What Counts as Verification, by Artifact Type

| Artifact | Legitimate verification |
|---|---|
| Code | Run the tests or actually execute it — yourself. Compiling is not behaving. Then, **when the tests are new, or the change touches anything in the judgement-call row below**, hand it to your code-review skill if one is installed (see Scope boundary); with none installed, at minimum have a fresh context judge whether those tests cover what the task actually asked for. A typo fix does not need a reviewer; a new module's first test suite does. |
| Docs, rules, config | Give the file to a fresh context and have it **answer questions using only that file** — and the questions must target the passages your change touched, or the gate is theatre. Wrong answers are a finding about the file, not about the reader. |
| A hard judgement call (architecture trade-off, elusive bug, trust-boundary design, data migration, technology choice) | An independent adversarial second opinion. When it disagrees, analyse the disagreement — do not pick whichever answer you preferred. |
| A destructive or irreversible operation | **Out of scope for this skill.** Confirm the blast radius before, read back the effect after, and follow whatever high-risk procedure you operate under. Only add the adversarial review if the operation is *also* a hard judgement call, or if you cannot tell whether it is. |

Choose the **cheapest reviewer that is actually qualified** — a cheap model
doing mechanical read-back beats an expensive model doing nothing. You economise
on the unit price of verification, never on its existence.

When delegating any of the above, hand the reviewer the artifact and the
acceptance criteria only — never your reasoning or your defence of the work.
A reviewer who has read your argument reviews your argument.

## When No Subagent Is Available

Some environments cannot spawn agents at all; some runs are additionally
non-interactive (CI, headless, scheduled) with nobody to authorise an exception.
Neither unlocks self-certification.

**Always, whatever else is or isn't available**: run every deterministic
mechanical check you can, yourself. That part never depends on having a reviewer.

Then find the independent judgement:

1. **A human is a fresh context.** If someone is there, hand them the artifact
   and the acceptance criteria and ask what you would have asked a reviewer — or
   ask for a one-off exemption and record that you got it. "No subagents" is not
   the same as "no independent reader", and conflating the two is how an
   interactive session talks itself into self-certifying.
2. **Only when there is genuinely nobody to ask**: mark the output **"unverified
   draft"** and name exactly which judgement-level gate did not run, and why.
   Where a rule elsewhere says "ask the user" and there is no user, take this
   same path rather than proceeding as if the question had been answered.

A downgraded delivery is honest. It is still not a pass.

## The Delivery Message: Three Mandatory Parts

1. **What was done** — the change, in the reader's terms.
2. **How it was verified, and the raw result** — paste the actual output. A
   summary of a result is not a result.
3. **What was *not* done** — skipped steps, unverified areas, known gaps,
   anything deferred. State it even when nobody asked.

## Failure Counting (for work you performed yourself)

A failure is: verification did not pass, an acceptance criterion was violated,
the same tool error recurred, or the user corrected you.

| Attempt | What you are allowed to do |
|---|---|
| 1st | Record the exact error text verbatim. Identify the single difference from what you expected. Change **one variable**. Retry. |
| 2nd | Stop trying variants. Write down what you tried and the evidence. Change approach, or escalate to a stronger model. |
| 3rd | The same route is now forbidden. Pick one: roll back, re-plan from scratch, or take the failure record to the user (no user → downgrade as above). |

⚠️ **Two consecutive "I changed it but nothing changed" means you are not
editing the thing that runs.** Prove the code path is actually being executed
before editing it a third time. Recorded repeatedly in practice, not a
theoretical worry: it is the most expensive loop to stay stuck in, and from the
inside it always looks like bad luck.

## End-of-Session Wrap-Up (order matters, do not reorder)

1. **First, confirm every code change this round has actually passed its
   Code-row verification** — tests run yourself, code-review triage if the
   tests are new or the change is a judgement call, a security skill if it
   crosses a trust boundary (see Scope boundary). Docs describe verified
   behaviour, not aspirational behaviour: writing them before this holds
   means step 2 documents something that may still be broken.
2. **Update the substantive docs first.** Walk the diff and ask of each doc:
   "does this describe behaviour or a decision my change just invalidated?"
   If yes, update it. If unsure, list the candidates and ask — never skip
   silently. Do not re-transcribe what the code already states.
3. **Prove step 2 actually happened.** If you edited any doc, hand the changed
   file plus a summary of the intended change to a fresh reader and ask whether
   the file now reflects it. It must answer yes *and* **quote the passage back**.
   If it cannot, return to step 2 and really make the edit — you may not
   proceed. Twice unable to answer → stop and ask (no user → downgrade).
   This is deliberately narrower than the open-ended read-back above: that one
   asks "does this file teach correctly?", this one only asks "did the edit
   land?". Telling the reader what you intended would anchor the first question,
   but it *is* the second one — which is why the answer has to be a quotation
   rather than a yes.
   ⚠️ Without this check, step 2 degrades into claiming an update that was never
   made — observed in practice, not hypothetical.
4. **Decide out loud whether this also needs the adversarial second opinion**
   from the judgement-call row above (architecture trade-off, elusive bug,
   trust-boundary design, migration, tech choice — or a rules/config file
   whose failure mode is silent). State a recommendation — run it or skip it —
   with your reasoning, every time step 3 finishes, whether it passed or had
   to escalate. Running it is optional and proportional to risk, same as Core
   Rule 1; skipping it is a choice you record, not a default you fall into
   silently. Steps 5–6 proceed either way — this step only blocks one thing:
   you may not write **verified / PASS** as a claim about the change until the
   second opinion you decided to run has actually come back.
5. **Then** update the continuation notes / TODO index. You must have actually
   run `git diff HEAD --stat` for the whole session and checked every file it
   lists — not recalled from memory — before this step counts as done. This
   step writes pointers only, never substance — which is exactly why it comes
   after the real docs. Update the index first and it points at content that
   no longer exists.
   ⚠️ This checks a different scope than step 2: step 2 asks "did *this round's*
   diff invalidate a doc", step 5 asks "has the *whole session's* accumulated
   work drifted from the continuation notes". A round with nothing to update in
   step 2 does not excuse skipping step 5 — reusing that verdict across both
   has produced stale continuation notes in practice.
6. **Then ask — out loud, every time — whether to run `handover`.** This is a
   real question to the user, not a decision you make alone: attach your own
   recommendation — run it now or skip it — and your reasoning, never a bare
   yes/no. How often `handover` actually runs is the user's call (see Scope
   boundary); whether you asked this time is not. Completing step 5 is not
   permission to skip straight to committing.
   ⚠️ Observed in practice: finishing step 5 reflexively rolls straight into
   commit, skipping this question entirely — that is exactly the gap this
   step closes.
