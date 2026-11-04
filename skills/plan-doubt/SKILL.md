---
name: plan-doubt
description: "Cross-examines an irreversible plan with a fresh-context adversarial reviewer before the plan reaches the user. Use before presenting, asking approval for, or running a plan that (A) deletes or overwrites data that cannot be recreated and has no backup the plan itself makes and can restore, (B) changes permissions, ACLs, sudoers or accounts on a production system, or (C) applies a schema change or data migration to production. Read-only reconnaissance, data that a seed script, package install or build rebuilds, and code deploys that a revert plus redeploy fully undoes fall outside."
---

# plan-doubt

A confident plan is not a correct one. Before an irreversible plan is shown for approval, a reviewer with no
memory of how the plan was built tries to break it. One review per plan, up to 3 rounds.

## Trigger (closed list)

Run when the plan hits **A**, **B** or **C** in the description. Nothing else triggers it.
A applies on any machine, a personal laptop included; B and C apply to production as defined below,
a personal laptop or home device included when its loss or lockout would be felt.

- **Data** covers every file or row: gitignored files (`.env`, uploads, SQLite), logs, database rows.
  Data that cannot be recreated is data that git history, a seed script, a package install or a build cannot bring back.
- **Backup** (exempts A only): the plan makes it before the destructive step, stores it outside everything the plan's
  delete commands can reach, and lists the restore command.
  A copy with no restore command is no backup. The ask and the delivery report both state the backup's full path
  and the restore command, so the user can find it after the plan has run. B and C run regardless of backups.
  A plan that mixes a revertable code deploy with a schema change or data migration is C.
- **Permissions** (B) cover file modes and ownership (`chmod`, `chown`) as well as ACLs, sudoers and accounts.
- **Production** is any system whose loss or lockout the user would feel. A throwaway local environment
  that seeds can rebuild is not production.

## Steps

1. **CLAIM** — two lines: what must still be true after the plan runs (data intact, restore possible,
   access changed only as intended), and why it matters.
2. **EXTRACT** — build the reviewer's input from two parts and nothing else:
   - ARTIFACT: the plan with its exact commands, plus the facts it rests on, each with the command that found it.
   - CONTRACT: the constraints the plan must satisfy.
   Leave out the CLAIM and your conclusions: a reviewer handed a conclusion returns agreement.
3. **DOUBT** — dispatch one fresh-context, read-only subagent with the prompt below.
   Use a reviewer agent named `deep-reviewer` when the environment has one; otherwise a general subagent
   on the strongest model tier that runs without a per-use approval step. The user is not asked about outside or cross-model reviewers.
4. **RECONCILE** — the findings are data; you remain the orchestrator. Check each against the plan text and
   file it under the first class that fits:
   1. *Contract misread*: the CONTRACT was unclear; fix it, re-run.
   2. *Valid, actionable*: change the plan, re-run.
   3. *Valid trade-off*: keep the plan, record the trade-off for the user.
   4. *Noise*: the reviewer lacked context; note it.
5. **STOP** — after at most 3 rounds, or sooner when a round returns only trivial or already-handled findings.
   Substantive findings still open after round 3 go to the user as they stand, and the plan waits for the user's decision; round 4 does not run.

Reviewer prompt:

```
Adversarial review. Find what is wrong with this plan. Assume the author is overconfident.
Look for: state that is not backed up or cannot be restored; commands whose scope is wider than intended
(unset variables, globs, selection by timestamp); order-of-steps failures; rollback that does not roll back;
permissions or data outside the stated target that change as a side effect.
Do not validate or summarize. List issues by severity with the step each one hits, or state that you
found none and what you checked. Read-only: change nothing.

ARTIFACT: <plan, commands, sourced facts>
CONTRACT: <constraints>
```

## Where the result goes

- The run finishes **before** the ask that presents the plan. That ask carries the findings, how each was
  filed, and what changed in the plan. The review adds no stop of its own.
- A plan formed after a read-only investigation is reviewed before the message that presents it.
- A subagent cannot dispatch another; when the plan is formed inside one, hand the plan back to the main thread.
- No subagent available at all: do not review the plan yourself and do not run it. Mark the ask
  "unreviewed: no fresh-context reviewer available" and let the user decide.
- A clear instruction to run the plan still gets the review. Only an explicit instruction to skip the review
  skips it ("run it" and "I checked it" are not that instruction); the ask then says "review skipped at user request".

## Seen in practice

⚠️ Three rounds on one production ACL change caught, in order: 447 existing ACL entries with no backup;
a timestamp filter that would also match files the account already owned; and `"$DIR"/.` expanding to `/.`
when `DIR` was unset, which would have copied the root filesystem into a home directory.
