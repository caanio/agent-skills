---
name: delegation-protocol
description: "Rules for handing work to subagents instead of doing it on the main thread. Use when deciding whether to delegate a search, a bulk edit, a documentation lookup or a verification; when writing a delegation prompt; when choosing a model tier; when escalating after a failure; when running agents in parallel; or when a delegated result comes back and you are about to believe it. Covers hard delegation thresholds, the three mandatory prompt elements, the reporting contract, anti-anchoring, parallel-write safety, and why not to ask the user to switch models mid-conversation."
---

# delegation-protocol

The main thread is a decision-maker with a scarce context window, not a worker.
Everything it reads itself, it pays for on every subsequent turn.

**Scope boundary** — these compose in sequence, they do not compete:
*how to farm work out* → here; *whether the result means the task is done* →
`completion-gate`; *the mechanics of committing* → your commit-workflow skill.

## When to Invoke

- About to read a lot of files, grep a repo, or look something up.
- About to make the same mechanical edit across many files.
- Something needs verifying or reviewing.
- Writing a prompt for a subagent, or choosing which tier to spawn.
- About to run agents in parallel.
- A subagent just reported back.
- Tempted to suggest the user switch the conversation's model.
- Your last search/grep/read on this exact target (same repo, same symbol,
  same file set) didn't fully resolve it and you're about to run another one
  — that's the "don't know which file it's in" threshold firing right now,
  not a reason to narrow once more yourself.

## Core Rules

1. **[NEVER VIOLATE] Never run two agents in parallel if both may write to the
   same file.** Whichever finishes second silently overwrites the first — no
   error, no conflict marker, no trace. Parallelise reading and analysis;
   serialise writing.

2. **[NEVER VIOLATE] When delegating a verification or review, hand over the
   artifact and the acceptance criteria only — never your reasoning, your draft
   rationale, or your defence of the work.**
   A reviewer who has read your argument reviews your argument. The entire value
   of a fresh context is that it does not already believe you. Anchor it and you
   have converted a gate into a rubber stamp — while still paying for it, and
   still feeling reassured.

3. **Hitting a threshold means delegate, not "consider delegating".** The
   numbers below are deliberately numbers. A vague threshold never fires.

4. **Do not accept a delegated result wholesale.** See the last section.

## Hard Thresholds

| Situation | Action |
|---|---|
| You expect to read **more than 3 files** or **more than 400 lines** to answer | Search agent |
| You do not know which file the thing is in | Search agent |
| Looking up web pages or official documentation | Delegate |
| The same mechanical change across **more than 5 files** | Cheap agent executes; you spot-check |
| **Any judgement-level verification or review** | Fresh-context agent (mechanical checks you may run yourself — see `completion-gate`) |

⚠️ **The "don't know which file it's in" row fires the moment a first search
attempt doesn't resolve it — not after several.** Each subsequent narrowing
grep on the same target feels like progress; measured against the rule, it's
the same "don't know which file" state repeating. Treat a second attempt on
the same target as the trigger, not a fourth.

**"It's faster if I just do it myself" is an illusion at the main-thread level.**
It is faster *this turn*. The context burned is repaid with interest on every
turn afterwards, and the debt stays invisible until the thread starts forgetting
things it was told.

Do not renegotiate a threshold because this case feels like an exception. If a
threshold is genuinely wrong, change it deliberately, with evidence, outside the
task that tripped it.

## If This Environment Has No Subagents

Not every harness can spawn agents, and some runs are non-interactive. Then:

- The thresholds become a **budget warning** rather than a dispatch instruction:
  the work still costs context, so do it in the smallest slice that answers the
  question, write intermediate findings to a file, and work from the file.
- Judgement-level verification cannot be faked by doing it yourself. Run every
  deterministic mechanical check available, then follow `completion-gate`'s
  "When No Subagent Is Available" procedure in full — starting with
  its first step, which is to check whether a *human* can be the fresh reader
  before anything gets downgraded. That procedure is not restated here on
  purpose: one copy, one place to change it.
- Never treat the absence of a reviewer as permission to self-certify.

## Every Delegation Prompt Needs Three Things

Missing any one, do not send it:

1. **Goal and motivation** — what this is for, and who consumes the result.
   An agent that knows why produces a usable answer; one that doesn't produces
   a technically-responsive one.
2. **Acceptance criteria** — objectively checkable. If you cannot write these,
   you have not thought the task through; that is the finding, not the agent's
   problem.
3. **Reporting format** — field by field. "Report your findings" returns an
   essay you then have to read, which defeats the point.

## The Reporting Contract (paste into every delegation prompt)

- Conclusions only, anchored as `file:line`.
- Long output goes to a file; report the path plus a three-line summary.
- Copy numbers exactly — never round, rephrase, or tidy a figure.
- **"Not found" is a valid answer.** Say so plainly; never fill the gap with
  something plausible.
- Never paste whole files back.

## Choosing a Tier

Think in tiers, not model names — names and IDs change, tiers don't:

| Tier | Use for |
|---|---|
| Cheap | Mechanical work, inventories, read-backs, bulk edits |
| Standard | Ordinary search, implementation, routine review — and the main thread |
| Expensive | Genuine judgement calls, adversarial review, second opinions |
| Premium | Rare. Confirm before spending it (nobody to confirm with → don't). |

**Do not keep a table of exact model IDs, prices, or feature-support matrices in
your rules or skills.** It is a copy of vendor documentation: it goes stale
silently, and a stale copy is worse than none because it is believed. Use the
harness's own alias or tier selector where one exists. Where the harness insists
on a concrete identifier and offers no lookup, state the tier you intended and
take the harness default — do not reconstruct an identifier from memory.

## Escalation

- Cheap tier fails acceptance **once** → go straight to standard. No second
  attempt: another round-trip plus re-verification costs more than escalating.
- Standard tier fails **twice on the same subtask** → escalate to the expensive
  tier **with the full failure trace**. Escalating without the trace just buys a
  more expensive repetition of the same mistake.
- Once the expensive tier finds the pattern, drop back to a cheap tier to apply
  it across the remaining cases.

⚠️ **When you need a stronger model, spawn a subagent at that tier — do not ask
the user to switch the conversation's model.** On providers that use prompt
caching, switching the main thread's model invalidates the cache, so the whole
conversation history is re-sent uncached on the next call. Measured on one real
session: of 7 observed cache breaks, 6 immediately followed a manual model
switch, averaging ~294k tokens burned per switch (single-session sample, one
provider — the magnitude will differ elsewhere, and on a provider without prompt
caching this particular cost does not apply). A subagent costs only its own call
and leaves the main thread's cache intact. Suggest a manual switch only when the
work genuinely cannot be delegated — it needs continuous back-and-forth with the
user rather than being a self-contained subtask — and weigh the rebuild cost
first.

## When the Result Comes Back

- **Spot-check one or two load-bearing claims.** Any number heading into a
  deliverable needs a second source.
- Warning signs: the report is suspiciously clean, or states a key fact you have
  never seen first-hand evidence for.
- ⚠️ **"X does not exist" is a far stronger claim than "X exists" and needs
  correspondingly more evidence** — recorded twice in practice, the second time
  while writing up the first. Before accepting a non-existence result,
  check the search actually covered backup directories, lock files, and
  alternate locations — not just the obvious live path. A search that only
  proves "not in the place I looked" is routinely written up as "never existed".
