# Trigger audit notes — delegation-protocol & completion-gate

Started: 2026-08-21. Purpose: figure out why these two skills were invoked
essentially zero times across weeks of real usage, and decide what to do
about it. This is a running log — append new findings below, don't rewrite
past entries. Pick this up in a fresh session in this repo when acting on
the "Candidate fixes" section.

## Finding 1 (2026-08-21): near-zero invocation is mostly explained by duplication, not a bad trigger

Searched every locally available Claude Code session transcript for actual
`Skill` tool calls naming either skill. Result: **zero** real invocations
across every sampled project, over several weeks of usage. The only hit was
a request to run `skill-creator` to optimize these two skills' own
`description` fields (2026-08-06) — i.e. editing them, not using them.

Cross-checking against the maintainer's personal always-loaded AI rules file
(outside this repo, not itself public): it already contains a condensed,
independently-maintained copy of most of both skills' load-bearing content —
hard delegation thresholds, the model-tier concept, "definition of done"
rules, and a step-by-step end-of-session wrap-up procedure that matches
`completion-gate`'s wrap-up section almost 1:1 (same steps, same order). That
file is *always* in context; a skill is only reached if the model decides
mid-task to call it. Once the same rule already lives in permanent context,
there's no remaining reason for the model to also invoke the skill — so
near-zero invocation on this axis is a symptom of successful duplication
elsewhere, not of a broken trigger description.

**Implication**: don't just delete the overlapping sections — this skill has
to stand on its own for anyone who *doesn't* already encode the same rules
in their own permanent context (see this repo's "Skills must stand on their
own"). The job for the fresh session is to separate "genuinely load-bearing
on its own" from "generic good-agent-behaviour a capable model already does
unprompted" (see Finding 2), and trim/restructure based on that, not based
on this one maintainer's personal duplication.

## Finding 2 (2026-08-21): real gaps found, not just duplication

Sampled several real sessions in depth (grep + judgement pass over the
transcripts) for moments that hit either skill's trigger conditions. Two
confirmed misses where the skill's guidance was *not* duplicated elsewhere
and the substance was actually violated:

1. `delegation-protocol`'s "When the Result Comes Back" section says a
   "does not exist" / "never happened" conclusion needs *more* evidence than
   an "it exists" conclusion, and should be spot-checked before being
   asserted. In one sampled session, the model ran its own string-match
   search across log files, concluded "confirmed: never invoked," and stated
   that as settled fact — no spot-check, no fresh-context check. This exact
   caution doesn't exist in the maintainer's always-loaded rules; it's
   unique to this skill, and because the skill never fires, the caution
   never gets applied. Clearest case of "should have triggered, didn't, and
   it mattered."

2. Even where the *same* rule already exists in the always-loaded rules (a
   >3-file / >400-line delegate-instead-of-reading-yourself threshold), the
   model still missed it in real time — it ran four successive rounds of
   manually narrowing a `grep` across a dozen-plus project directories on
   the main thread instead of recognizing the pattern and delegating. This
   means always-loaded context reduces but doesn't eliminate this failure
   mode: real-time self-recognition ("this exact action I'm about to take
   matches that abstract rule") is a separate, harder problem than "is the
   rule in context at all." Simply having a skill wouldn't obviously fix
   this either, since the same failure (not noticing the trigger applies)
   would also stop the skill from being invoked.

## Finding 3 (2026-08-21): second sample batch — same two patterns, plus a recurring sub-pattern

Sampled three more sessions across different projects to check the pattern held up.
Two came back completely clean (one was a short, correctly-interactive live-troubleshooting
session with no file-count/line-count thresholds crossed and no completion claim; the other
was a single-user-turn read-only diagnosis, same story). One had a real miss:

- A session doing a small, low-risk code fix (single-file, <400 lines, verified by actually
  running the script before claiming it worked — fine) also touched a *SessionStart hook* that
  would perform an unattended `git reset --hard` / `git clean -fd` inside another repo with no
  override. That is squarely a "trust-boundary design" judgement call. The model drafted the
  change, then asked the user "commit this now? (recommended)" — a completion-shaped question
  answered by *itself* recommending "yes" — without first proposing an independent
  (`deep-reviewer`-equivalent) review. Only after the user pushed back ("should this go through
  review?") did the model agree it needed one, and the review then genuinely caught real bugs
  worth fixing. Had the user not pushed back, an unreviewed unattended-destructive-operation
  hook would have shipped.

  This is the same shape as the EC2-terminate miss in Finding 2/the original session sample
  (there too, independent review happened only *after* the risky action, prompted from outside
  rather than offered by the model) — it's now shown up twice, independently, in unrelated
  projects. It's a real completion-gate violation each time (a "hard judgement call" per that
  skill's verification table), and it's exactly the kind of moment where the model's own
  incentive (finish the task, get a yes) works against raising the flag itself.

  **Correction (same day, caught during a downstream review):** this write-up originally
  classified this sub-pattern as skill-only content with no equivalent elsewhere. That's wrong —
  the maintainer's personal always-loaded rules *also* already say, in essentially these words,
  that a "trust-boundary design" judgement call needs an independent second opinion before
  proceeding. So this is not a Finding-2.1-style "only the skill says this" gap; it's a
  Finding-2.2-style "the rule already exists in permanent context on both sides (skill and
  personal rules) and still wasn't recognised as applying in the moment" gap. Sharpening the
  wording in this skill will not fix this for anyone who already has an equivalent always-loaded
  rule — the failure is recognition-in-the-moment, not missing text, same as Finding 2.2. It may
  still be worth doing for portability (someone installing this skill *without* an equivalent
  personal rule benefits from a sharper trigger), but don't expect it to change behaviour for a
  setup that already duplicates the rule.

- The other real miss in this batch was the same delegation-protocol pattern as before: a
  session doing security-checklist triage read through ~7 files and ran five separate greps
  across a repository on the main thread — no Task/Agent call at any point, despite crossing
  both the file/line-count threshold and the "don't know which file it's in" threshold. Medium
  confidence — the task had a clear starting point (a checklist from a prior session) rather than
  being open-ended search, which mitigates but doesn't erase the miss.

## Candidate fixes (not yet decided — pick up in a fresh session)

- Audit both `SKILL.md` files section-by-section against commonly-expected
  "definition of done" / delegation practice; keep what's genuinely unique
  (the no-evidence spot-check rule from Finding 2.1, the exact
  reporting-contract wording, escalation-after-N-failures specifics, the
  artifact-type verification table). Cut what a generally-capable model
  already does without being told, or reframe it as the deep-reference
  version that a shorter always-loaded summary (in whoever's personal setup)
  can point to — mirrors a pattern already working elsewhere for this
  maintainer (a short always-loaded rule pointing to a longer on-demand file
  for the wrap-up procedure), just applied to a portable skill instead of a
  personal rules file.
- The self-recognition failure (Finding 2.2, reinforced in Finding 3) is a
  different kind of problem — more words in a skill or rules file won't fix
  "didn't notice this matched a rule already in context." That likely needs
  a mechanical check outside the model's own judgement (e.g. a tool-use hook
  counting same-purpose reads/greps within a short window and flagging it)
  rather than a documentation fix — and so is arguably out of scope for a
  *skill* at all.
- The "propose the risky action as done-pending-approval instead of
  proactively flagging it needs a second opinion" sub-pattern (Finding 3)
  showed up twice, independently, in unrelated projects — but per the
  correction above, it's a recognition failure, not a missing-rule gap (the
  rule already existed in *two* always-loaded places and still wasn't
  applied). A sharper skill trigger phrase for this moment is still fine to
  add for portability's sake, but for a setup that already duplicates the
  rule, expect zero behavioural change from it — the real fix is the
  mechanical-check bullet above, applied to this moment too.

### Master finding (after the correction above)

Of the 5 confirmed violations across 6 sampled sessions, only **one**
(Finding 2.1, the "no-evidence needs more evidence" spot-check rule) is
content that exists *only* in a skill and nowhere in the maintainer's
personal always-loaded rules. The other four are all "the rule already
lives in permanent context and still wasn't recognised as applying to the
action being taken right now" — editing either skill's wording does not
address that class at all. Two separate, more useful follow-ups for
*personal* use (out of scope for this public repo, noted here only so the
link isn't lost): promote the Finding-2.1 rule directly into the
maintainer's own lessons/rules file (bypasses the "will the skill even get
read" problem entirely), and design a mechanical, non-text-based check for
the recognition-failure class. Editing these `SKILL.md` files is still
worth doing for anyone installing them *without* an equivalent personal
rule set, but won't change this maintainer's own future sessions.

## Executed (2026-08-21)

Acted on the Candidate fixes section, in light of the Master finding above:

- `delegation-protocol/SKILL.md`: left unchanged. Every section is either a
  specific number, a measured caution, or a specific process step — no
  generic-good-agent-behaviour fat to cut, and the misses found against it
  (Finding 2.2, the second miss in Finding 3) are recognition-failures out
  of a skill doc's reach per the Master finding.
- `completion-gate/SKILL.md`: added the sharper trigger for the
  done-pending-approval sub-pattern (Finding 3) in three places — frontmatter
  `description`, a new `When to Invoke` bullet, and a new numbered
  `[NEVER VIOLATE]` Core Rule (existing rules 2-4 renumbered to 3-5).
  Verified by `verifier` read-back (5/5 questions answered correctly from
  the file alone). Per the Master finding, treat this as a **portability
  fix only** — it will not change this maintainer's own behaviour, since an
  equivalent rule already lives in the always-loaded personal rules; it
  matters for anyone installing this skill without that equivalent.

**Correction to the delegation-protocol call above (same day):** "left
unchanged" was premature — it conflated "no generic fluff to cut" with "no
sharper trigger worth adding," which are separate questions. On a second
pass, the same class of fix applied to `completion-gate` (a moment-specific
trigger tied to one atomic, inspectable action, not a rewrite of the
already-correct threshold numbers) applies here too: the grep-loop misses
(Finding 2.2, the second miss in Finding 3) fail not because the threshold is
unclear but because each narrowing search *feels* like progress rather than
a repeat of "still don't know which file it's in." Added: a `When to Invoke`
bullet naming that exact moment (second attempt on the same target, not
resolved), and a ⚠️ note under the Hard Thresholds table stating the
threshold fires on the second attempt, not the fourth. Same caveat as
`completion-gate`'s fix: portability-only per the Master finding, expect no
behavioural change for a setup that already duplicates the rule. Verified by
`verifier` read-back (3/3 questions answered correctly from the file alone).

## Reversal: delegation-protocol retired (2026-08-24)

The 2026-08-21 "left unchanged" call rested on one premise: this skill "has
to stand on its own for anyone who doesn't already encode the same rules in
their own permanent context" — i.e. other people installing this public
repo without an equivalent personal rules file. Asked the maintainer
directly this session: **nobody else installs this repo.** That premise was
false in practice, which removes the entire reason not to cut the duplicated
content.

Re-ran the same trim the Master finding already recommended (separate
"genuinely load-bearing on its own" from "duplicated elsewhere"), independent
of the 2026-08-21 session, and landed on the same split as that session's own
analysis: only Finding 2.1 (no-evidence spot-check) is unique content, plus
two smaller unique bits not called out by name in the original findings — the
no-subagent-available fallback and the don't-switch-the-conversation's-model
cache-invalidation warning. Everything else (hard thresholds, the three
prompt elements, the reporting contract, anti-anchoring, parallel-write
safety, the generic tier table, escalation-after-N-failures) was already a
verbatim or near-verbatim duplicate of the maintainer's personal
always-loaded rules.

Action taken: folded the three unique bits into the maintainer's personal
rules file (outside this repo), deleted `skills/delegation-protocol/`
entirely, and fixed the two live cross-references in
`completion-gate/SKILL.md` plus the README skills table so nothing points at
a file that no longer exists. Verified by `verifier` read-back (8 checks:
5 on the personal-rules edit, 3 confirming no orphaned references — the
first pass found the `completion-gate` and README references this pass then
fixed).

**If this repo ever gains a second installer**: the deleted content is
recoverable from git history (`git log -- skills/delegation-protocol`) up to
this commit. Re-derive it from there rather than rewriting from memory.
