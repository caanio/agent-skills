# `completion-gate` trigger eval: HEAD, D1–D7 and two hybrids

Version: 1.0.0 | Date: 2026-10-02 | Status: decided 2026-10-02 (HEAD
stands, no `SKILL.md` edit; D5 refuted by the numbers, D6 double-edged,
D1–D4 and D7 untested on their own; the pass moves on to
`haos-https-tunnel`)

The description run that plan §2 of
`2026-10-01-skill-authoring-pass-plan.md` schedules after the 2026-10-02
body pass. Four descriptions were scored with `skill-creator`'s
`run_eval.py` (20 queries × 3 runs, `opus`, 10 workers, `--timeout 90`)
in two configurations, eight runs of 1.4–3 minutes each. The harness
fixes of `2026-10-02-web-stack-selector-trigger-eval.md` §2 were
reapplied on a scratch copy (§2 below). `run_loop.py` was not started:
HEAD fails one query, so it would have iterated this time, but the
hybrids answer the attribution question its proposals could only
re-ask, and its 40 % hold-out can park the one failing query on the test
side and exit `all_passed` on iteration 0.

## 1. Results

Mean trigger rate over the 10 should-trigger queries / the 10 should-not
queries; `pass` counts queries whose rate is on the right side of 0.5.
Each candidate fails on the same query in both configurations, so the
two decisive columns name the query and give isolated, competitors.

| Description | Isolated | With 43 competitor skills | Q4 own-work deploy failure (should) | Q19 delegated subagent failure (should-not) |
|---|---|---|---|---|
| HEAD | 19/20, 1.00 / 0.10 | 19/20, 1.00 / 0.10 | 3/3, 3/3 | 3/3, 3/3 |
| HEAD + D5 only | 18/20, 0.90 / 0.10 | 18/20, 0.90 / 0.10 | 0/3, 0/3 | 3/3, 3/3 |
| D1–D7 | 19/20, 0.90 / 0.00 | 19/20, 0.87 / 0.00 | 0/3, 0/3 | 0/3, 0/3 |
| D1–D7 with D6 restored | 18/20, 0.87 / 0.07 | 18/20, 0.90 / 0.07 | 0/3, 0/3 | 2/3, 2/3 |

The remaining mixed cells, all 2/3 and none decisive: D1–D7 on Q3 (the
delivery-message query) under competitors; D6-restored on Q9 (the
one-line rules edit) isolated.

**D5 is refuted.** Its clause, "after any failure in your own work",
is the one thing the three failing texts share and HEAD lacks. Q4 states
an own-work failure in Traditional Chinese (`我自己改的 config`), the
case D5 was written to keep; the texts carrying D5 miss it in 18 of 18
runs, HEAD hits it in 6 of 6. D5 also buys nothing on the query it was
written against: HEAD + D5 still fires 3/3 on Q19. For a gate skill a
missed should-trigger costs the gate; a spare trigger costs one context
load. D5 does not land, and the D1–D7 bundle does not land with it.

**D6 is double-edged.** Deleting the table-of-contents sentence takes
Q19 from 3/3 to 0/3 (its "failure counting" is the likely hook; D1–D4
and D7 account for the rest, since restoring the sentence alone brings
Q19 back only to 2/3). The same sentence holds Q3 at 3/3 under
competitors, where D1–D7 drops to 2/3 ("the honest three-part delivery
message" is the hook there). So the sentence is not pure context load as
the body-pass reviewer read it: it carries two branch triggers. A D6
that keeps those two phrases and drops the rest is untested.

**D1–D4 and D7 have no number of their own.** They were scored only
inside the bundle; the bundle's two failures are attributed above, so
they are neither confirmed nor refuted and stay candidates.

**The Q19 label was written with D5 in hand.** The body scopes failure
counting to "work you performed yourself", which grounds the should-not
label, but the same table's second row says "escalate to a stronger
model", which is what Q19 asks about. A reader who labels Q19
should-trigger makes HEAD 20/20 in both configurations and leaves the
other three texts where they are. The decision does not turn on the
label.

Limits of the measurement: 3 runs per query cannot see rate differences
below 1/3, and the mixed 2/3 cells were not re-run at a higher count
because no decision turned on them. The skill's triggers are situations
("about to commit", "after a failure"), but `claude -p` sees one prompt,
so every should-trigger query has the user *stating* the situation; a
live session reaches the same branch from the conversation's state,
which this harness cannot represent. The harness is a fresh `claude -p`
with project-only setting sources, a command-file stand-in and `opus`,
as before.

## 2. Harness (reapplied, not re-derived)

The scratch copy lives at `<scratchpad>/cg-eval/`: `scripts/` copied from
the previous session's patched copy, its `diff -u` against the installed
`~/.agents/skills/skill-creator/scripts/run_eval.py` identical hunk for
hunk to the diff recorded in
`2026-10-02-web-stack-selector-trigger-eval.md` §2; an empty `.claude/` at
the scratch root; a fresh `pool/` of 51 links, every `~/.agents/skills/*/`
with a `SKILL.md` except `completion-gate`. The previous session's pool
was built as "everything except `web-stack-selector`", so it held
`completion-gate` and would have reproduced defect 3 (the real copy
absorbing the trigger); this pool drops `completion-gate` and takes
`web-stack-selector` back in.
Probe before the runs: a `claude -p` from a call root with the pool linked
and a stand-in command file listed 43 skills, `completion-gate` absent,
`web-stack-selector` and `git-helper` present. The env name
`WSS_SKILL_POOL` is unchanged so the recorded diff stays current. The run
scripts are the recorded ones with the skill path and the baseline names
swapped; `python` is the pyenv 3.13 interpreter.

## 3. Eval set (reviewed in `eval_review_completion-gate.html`, used as drafted)

Ten should-trigger queries, each stating a situation from one of the
description's five branches (done claim, own-deliverable verified claim,
wrap-up or commit, a destructive or trust-boundary confirmation, own
failure), four of them Traditional Chinese one-liners. Ten should-not,
seven of them pool siblings' territory (`git-helper`,
`code-review-and-quality`, `debugging-and-error-recovery`, `handover`,
`tdd`, a CI workflow, a delegated failure), plus Core Rule 3's own
exemption (a PASS/FAIL template), a plain-English "complete" and a
conceptual "definition of done".

```json
[
  {
    "query": "tests are all green now, I'm going to call this PR done and commit, anything else before I do?",
    "should_trigger": true
  },
  {
    "query": "測試都過了,這個功能算完成了吧?可以 commit 了嗎?",
    "should_trigger": true
  },
  {
    "query": "write the delivery message for this change: what I did, how I verified it, what's left",
    "should_trigger": true
  },
  {
    "query": "deploy 第二次失敗了,我自己改的 config,接下來怎麼辦?",
    "should_trigger": true
  },
  {
    "query": "draft the yes/no question asking the user to approve running this migration on prod, and mark 'yes' as recommended",
    "should_trigger": true
  },
  {
    "query": "I rewrote the README install section; can I put 'verified' in the changelog now? the reviewer hasn't come back yet",
    "should_trigger": true
  },
  {
    "query": "ok that's it for today, let's wrap up the session: update the notes and commit",
    "should_trigger": true
  },
  {
    "query": "the fix works on my machine, mark the ticket as fixed and close it",
    "should_trigger": true
  },
  {
    "query": "我只改了 rules 檔一行,這種小改要不要驗證?直接說 done 可以嗎?",
    "should_trigger": true
  },
  {
    "query": "no subagents in this CI run, so I'll self-review the config change and ship it, ok?",
    "should_trigger": true
  },
  {
    "query": "just commit with the message 'fix: handle empty payload' and push",
    "should_trigger": false
  },
  {
    "query": "review this diff for bugs and style issues before I merge it",
    "should_trigger": false
  },
  {
    "query": "tests fail with KeyError: 'id' in test_orders.py, find out why",
    "should_trigger": false
  },
  {
    "query": "寫一個 pytest 測試檔,報表模板裡要有 PASS/FAIL 欄位,狀態用 assert status == \"PASS\" 檢查",
    "should_trigger": false
  },
  {
    "query": "the progress bar says 100% complete but the output file is truncated, what's wrong with the download code",
    "should_trigger": false
  },
  {
    "query": "write the handover doc for the next maintainer: deploy path, prod facts, open TODOs",
    "should_trigger": false
  },
  {
    "query": "用 red-green-refactor 做這個功能,先寫一個會失敗的測試再實作",
    "should_trigger": false
  },
  {
    "query": "add a GitHub Actions workflow that runs the test suite on every push",
    "should_trigger": false
  },
  {
    "query": "the subagent I delegated the refactor to failed twice, should I switch it to a stronger model?",
    "should_trigger": false
  },
  {
    "query": "explain what 'definition of done' means in scrum",
    "should_trigger": false
  }
]
```

## 4. Candidate descriptions scored

HEAD is the frontmatter at 2026-10-02 (`eb26274`):

> Decides whether work may be called done. Use before saying a task is complete, finished, ready, working or fixed; before writing a 'verified'/'PASS'/'tested' claim about your own deliverable; when wrapping up a session, calling it a day, picking work back up tomorrow, or about to commit; before drafting a yes/no confirmation question about a change that touches destructive operations, trust boundaries, or unattended automation; and after any failure. Covers what counts as verification per artifact type, which checks the producer may run and which need fresh context, the honest three-part delivery message, failure counting, and the end-of-session wrap-up order.

D1–D7 hand-applied from the body-pass reviewer's seven description
findings (log entry 2026-10-02): D1 five done-synonyms to "done or
fixed", D2 two tokens for Core Rule 3, D3 drops "calling it a day", D4
drops "picking work back up tomorrow", D5 scopes the failure branch to
own work, D6 deletes the table-of-contents sentence, D7 front-loads the
gate:

> Gate on calling work done. Use before calling work done or fixed; before writing a 'verified' or 'PASS' claim about your own deliverable; when wrapping up a session or about to commit; before drafting a yes/no confirmation question about a change that touches destructive operations, trust boundaries, or unattended automation; and after any failure in your own work.

HEAD + D5 only: HEAD with "and after any failure." → "and after any
failure in your own work.", nothing else changed.

D1–D7 with D6 restored: the D1–D7 text with HEAD's last sentence
("Covers what counts as verification … wrap-up order.") appended.
