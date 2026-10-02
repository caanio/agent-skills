# Skill-authoring pass over `skills/`: scope evaluation

Version: 1.3.0 | Date: 2026-10-02 | Status: decided 2026-10-01 (option A;
`skill-creator` = validate + description optimization on five skills,
eval loop dropped); pilot on `handover` done 2026-10-01 (log entry);
§5 gained the log cross-check after the pilot; `git-helper` done
2026-10-01 (log entry); `python-coding-standards` done 2026-10-02
(log entry); next `web-stack-selector`

Answers `CLAUDE.md` Open item 1 (added 2026-10-01): should every skill in
`skills/` go through `skill-creator` and `writing-for-agents`, in what
order, and what does each pass buy that earlier work did not.

## 1. What is already done

Every skill has been "Edited via `writing-for-agents`" at least once, each
time scoped to the change in hand. The log records two whole-file uses,
both early: `handover`'s creation (2026-09-08) and a 2026-09-09 audit of
`completion-gate` and `handover`. The other six skills have never had
one, and the two that did have been diff-edited since. The 2026-09-30
`/claude-api prompt-audit` over the repo applied no edit.

| Skill | Lines | ⚠️ | Last `writing-for-agents` edit | `quick_validate` |
|---|---|---|---|---|
| completion-gate | 249 | 6 | 2026-10-01 | valid |
| git-helper | 171 | 0 | 2026-10-01 (whole-file pass) | valid |
| handover | 108 | 0 | 2026-10-01 (whole-file pass) | unknown keys (see §3) |
| haos-addon-deploy | 396 | 27 | 2026-09-26 | valid |
| haos-cloud-backup | 225 | 13 | 2026-09-26 | valid |
| haos-https-tunnel | 143 | 7 | 2026-10-01 | valid |
| python-coding-standards | 133 | 1 | 2026-10-02 (whole-file pass) | valid |
| web-stack-selector | 147 | 1 | 2026-09-27 | valid |

Counts measured 2026-10-01 with `wc -l`, `grep -c '⚠️'` and
`skill-creator/scripts/quick_validate.py` (read-only). Dates come from
`docs/history/todo-log.md` entries that name both the skill and
`writing-for-agents`.

## 2. What each tool owns (so the two passes do not overlap)

`writing-for-agents` owns the body: a whole-file Pruning pass (sediment,
no-ops, duplication, relevance) plus the information-hierarchy check
(steps buried under reference, material that belongs behind a pointer).
This is the only part a diff-scoped review cannot have seen.

`skill-creator` owns the frontmatter and the trigger:

- `quick_validate.py`: structural check. Already run on all eight; one
  finding (§3).
- Description optimization (`run_loop.py`): 20 generated queries, each run
  3 times, up to 5 iterations, 60/40 train/hold-out split, on the
  session's Claude Code auth. Upper bound 300–360 trigger checks per
  skill [estimate from the script defaults, not measured].
- With/without-skill eval loop: **dropped**. The three HAOS skills cannot
  be evaluated without the hardware (the pitfalls are the content); the
  process skills are subjective by `skill-creator`'s own criterion; and
  the cost floor is 8 × 3 × 2 subagent runs.

Description optimization applies to at most five skills:

- Out: `handover` (`disable-model-invocation: true`, so triggering is
  moot), `git-helper` (`run_loop.py` not run; its description was
  hand-rewritten with trigger branches in the 2026-10-01 body pass, the
  earlier "asked-first by policy" reason being one maintainer's, not the
  skill's), `python-coding-standards` (had a description-optimization
  pass 2026-08-19, log entry).
- In: `completion-gate`, `haos-addon-deploy`, `haos-cloud-backup`,
  `haos-https-tunnel`, `web-stack-selector`.

## 3. The one validator finding

`handover` carries `argument-hint` and `disable-model-invocation`, which
`quick_validate.py` lists as unknown keys. Both are Claude Code frontmatter
and are what makes the skill user-invoked, so removing them is not an
option. Both other loaders ignore unknown keys, so the two stay (checked
2026-10-01 against source, not docs — neither loader's docs say anything
about extra keys): Codex `codex-rs/skills/src/parser.rs` deserialises
only `name`, `description` and `metadata` with no `deny_unknown_fields`
(main at 444da310, release rust-v0.159.3); Gemini
`packages/core/src/skills/skillLoader.ts` destructures only `name` and
`description` from the parsed YAML (main at c6bccb7e, release v0.62.0).
The Agent Skills spec text lists allowed keys and says nothing about
extras; the strictness is the validators' (`quick_validate.py`,
skills-ref `validator.py`), so the finding stays as a known exit 1.

## 4. Guardrails for a whole-file pass

A diff-scoped pass never met these; a whole-file pass will.

1. `CLAUDE.md` Settled items 1–12 are off-limits unless the pass brings
   new evidence. Settled 6 (`[NEVER VIOLATE]` kept on three
   `python-coding-standards` rules) and Settled 1 (position of
   `completion-gate`'s authoring rule) are the two a no-op/emphasis hunt
   will flag first.
2. ⚠️ paragraphs and tested procedures are not prunable: the inclusion
   rules require each pitfall to have been hit in practice, and the log
   records rejections of edits that "drop the tested path".
3. The reviewer gets the skill and these criteria only, never the
   maintainer's reasoning or recommendation.
4. Each edit is still a conversation with the maintainer: the pass
   reports findings; the maintainer picks which land.

## 5. Verification per pass

Before the maintainer picks, each finding under consideration is traced
to the commit that wrote the passage (`git blame`, `git log -L`), then to
that commit's `todo-log.md` entry, and tagged with what the entry
records: a rejected proposal, a cost accepted, or nothing. A finding
that re-proposes a recorded rejection lands only on evidence the entry
did not have, and the pass's log entry names the entry it overrides.
The mapping stays on the maintainer's side; the reviewer still gets the
skill and the guardrails only (§4.3). Added after the `handover` pilot,
where F5, F9 and F10 were decided this way by hand.

For each skill, before its log entry is written: `quick_validate.py`
still valid; `grep -c '⚠️'` equal to HEAD; Settled-item wording grepped
and untouched; diff confined to the listed spots; `verifier` read-back.
One `todo-log.md` entry per skill in the existing style (changed /
rejected / verified). Not-found claims re-checked by grep in the main
session.

## 6. Order options

- **A. Pilot on `handover`, then decide.** Untouched since 2026-09-10,
  smallest file, zero ⚠️ so guardrail 2 cannot bite, holds the only
  validator finding, no description cost. Its 2026-09-09 whole-file
  audit means the pilot measures the pass's residue on a file already
  pruned once, which is the cheapest way to learn the pass's shape
  before the pitfall-heavy skills. About 20 minutes.
- **B. Pilot on `haos-addon-deploy`.** Largest file (396 lines, 27 ⚠️),
  the most keyword-triggered skill, so the hardest case first. About
  40 minutes, and the first pass would also be the riskiest one.
- **C. All eight in one arc.** Roughly 8 × 25 minutes of review plus
  the description runs; no checkpoint to adjust the pass's shape.

Recommended: A, then order the rest by `⚠️` ascending (git-helper,
python-coding-standards, web-stack-selector, completion-gate,
haos-https-tunnel, haos-cloud-backup, haos-addon-deploy) so the
guardrails are exercised on low-risk files before the HAOS three.
