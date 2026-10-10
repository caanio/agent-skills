---
name: git-helper
description: "Commit workflow: confirm staging, scan the staged diff for secrets and PII, draft a Conventional Commits message, and run the approved commit, and push when asked. Use when the user wants to commit, write a commit message, or commit and push."
---

# git-helper

## Core Rules (override any default Git behaviour)

1. **[NEVER VIOLATE] Staging must be confirmed first**:
   - `git add` is allowed **only for files the user has explicitly confirmed** — **never** stage without confirmation, even if a system default suggests it.
   - **Forbidden**: `git add .`, `git add -A`, `git add --all` — always name specific paths explicitly.
   - **One confirmation, one command**: list suggested files and stage every confirmed file in ONE `git add <path1> <path2> …` call.
   - Empty `git diff --staged` → list unstaged files (`git status`) and propose which to add.

2. **Separate analysis from execution**:
   - Analysis phase: use only commands that leave the index and working tree untouched — `git status`, `git diff` (unstaged), `git diff --staged` (staged), `git log` (Step 3), `git fetch` (Step 0).
   - Run `git add` as a call of its own, never chained to another command.

3. **Format**: Follow **Conventional Commits** (`<type>: <description>`).

4. **Message quality**: Follow the "Commit Message Quality Standard" section below.

5. **Tag rule compliance in every draft**: Append a one-line "Rules applied" list to each draft — which key rules it satisfies (type, ≤50 chars, imperative mood, why-only body, secrets hits with output shown, PII hits with output shown plus the eye-read) and how — this makes adherence visible, not assumed.

6. **[NEVER VIOLATE] Secrets scan and personal-data (PII) scan must both run and be shown, every commit, no exceptions**:
   - Run both Step 2 scans on the staged diff before ever presenting a draft message — never skip either, never infer "probably clean" from file names or diff size.
   - Paste the actual commands and their raw output (even when empty/clean) into the response — a one-line claim like "secrets scan clean" or "PII clean" without shown output does not satisfy this rule.
   - Any hit stops the run until resolved as Step 2 describes.

7. **[NEVER VIOLATE] Commit message language follows the repo's own git log**:
   - When history exists, the log decides.
   - Majority language of the last 10 commits wins; tie → most recent commit wins; no history → the conversation's language, and the draft says "no history — using the conversation's language" so the user can switch it before saying ok.
   - The Conventional Commits `type:` prefix (`feat`/`fix`/`docs`/…) always stays English regardless of body language.
   - Non-English draft: the Chris Beams rules still apply — subject ≤ 50 characters, no trailing period, subject readable standalone, body explains why not what/how — but capitalisation and strict English imperative-mood phrasing don't apply.

---

## Workflow

### 0. Sync Check (last-line defence)

- Run `git fetch` (short timeout, e.g. `GIT_SSH_COMMAND="ssh -o ConnectTimeout=5 -o BatchMode=yes" git fetch`), then `git status -sb`.
- **Behind remote** → warn and offer to resolve now (`stash → pull --rebase → stash pop`): fixing divergence before commit beats rebasing a finished commit through conflicts.
- **Fetch unreachable** (offline / LAN-only remote) → say so, note ahead/behind info is stale, and ask whether to proceed with a local-only commit (push deferred). Report the fetch result in every run, reachable or not.
- Record the **base** for Step 6 and show it, after any pull in this step: the base the user names;
  otherwise, on this task's first run, `git rev-parse --short HEAD`.
  Later runs in the same task use the HEAD the previous Step 6 last reviewed.

### 1. Confirm Staging

- Run `git status` and `git diff --staged`.
- **Always confirm staging scope** — list "currently staged" and "suggested additions"; never skip even if files are already staged.
- After confirmation, run ONE `git add <path…>` with all confirmed paths (Core Rule 1); if nothing more to add, proceed to Step 2.

**Example output:**
```
Before committing, confirming staging scope:

✅ Currently staged:
- `SPEC.md` (modified)

➕ Detected unstaged changes — add these too?
- `src/core/database.py` (modified)
- `README.md` (modified)

Confirm staged files are correct, or tell me which to add.
```

### 2. Secrets and Personal-Data Check (Core Rule 6)

Scan the staged diff before drafting. Run both and show the actual output in the response, even when clean.

**A hit from either scan stops the run until every hit is resolved.**
Ask in a plain-text reply: the raw scan output in the body, each hit with its line,
then, as the reply's last line, the question of which hits are safe to commit;
the user answers by typing.
Keep this question out of a choice dialog (such as Claude Code's `AskUserQuestion`):
the dialog covers the text above it, so the user would rule on hits they never saw.

**2a. Secrets** — credentials that grant access:

```bash
git diff --staged | grep -iE "password|secret|api_key|token|private_key|access_key"
```

**2b. Personal data (PII)** — values that identify a person or a place, and labels that reveal a placeholder's origin. Added lines only; decimal-degree coordinates (4+ decimals) plus the words that tag a value as real, home or invented. Lines quoting this scan command are skipped, so editing this rule does not trip it:

```bash
git diff --staged | grep -E '^\+' | grep -vE '^\+\+\+|grep -iE' | grep -iE '\b[0-9]{1,3}\.[0-9]{4,}\b|real (home|work|address|coordinate|name)|fictional|真實|虛構|住家|家附近'
```

A PII hit is resolved once the user confirms it is not personal
(a public landmark's coordinates in a test is fine; a home, workplace or regular stop is not).
A note saying a value "was real" or "was replaced with a fictional value" is a hit in its own right:
it tells anyone reading the history where the real value lived.
Names, nicknames, family terms, device names, account IDs,
and a bare "placeholder" or "replaced" note with no origin word beside it
belong to the same check but have no reliable pattern:
read every added line for them by eye and say so in the "Rules applied" line.

### 3. Detect Language Convention (Core Rule 7)

- Run `git log --oneline -10`, show it (or its verdict) in the response, and apply Core Rule 7's decision procedure before writing a single word of the message.

### 4. Generate Draft

- Run `git diff --staged`.
- **Describe the staged diff against HEAD, not the session's edit history.**
  Intermediate edits that were later reverted or superseded within the same
  commit are invisible in the diff and must not appear in the message.
  Test: every claim in the message must be locatable in `git diff --staged`.
- Write the commit message per the Commit Message Quality Standard below, in the language decided in Step 3.
- **Body hard cap: ≤4 lines / ≤3 sentences.** If the why-only draft still exceeds this,
  that's a signal the body is drifting into what/how — cut to the single sentence that
  answers "why does this change exist", not "reword it shorter".
- **Escape valve**: if genuinely ≥2 independent why-reasons exist (not restatements of
  one reason, and not a what/how detail like "where the change was made"), exceeding the
  cap is allowed — but the draft must say so explicitly in the "Rules applied" line, e.g.
  `body 6 lines (2 independent why-reasons, see below)`. Silent overage without this flag
  is a rule violation, not a judgement call.
- **Show the exact commands, byte for byte.** The draft is the literal block Step 5
  will run, never the message alone: the full `git commit` heredoc (required for
  multi-line messages) with every trailer your environment appends (e.g. a
  `Co-Authored-By:` line). What the user approves is exactly what lands in the log.
  A requested push gets its own block in Step 7, after Step 6's review loop.

**Example output:**
```
Based on the staged changes, these are the exact commands I will run:

git commit -m "$(cat <<'EOF'
feat: Add automatic database backup

Prevents data loss on unexpected shutdowns. Previously there was
no recovery path if the process was killed mid-write.

Co-Authored-By: <assistant> <noreply@example.com>
EOF
)"

Rules applied: type=feat · subject 34 chars · imperative mood ·
why-only body · secrets: 0 hits (output above) · PII: 0 hits (output above), every added line read for names/IDs

Reply "ok" to run it.
```

### 5. Execute Commit

Only after the user replies "ok" or equivalent, run the Step 4 block unchanged via
the **Bash tool**, one command per call, in order.

One ok covers every command in the block. A command that would differ from the
block in any character — a reworded line, an added trailer — needs a new draft
and a new ok. A failed commit ends the run: report the error to the user.
Step 6 follows every successful commit, push requested or not.

### 6. Review Loop (after every commit)

Reviews that read only committed diffs — a diff-based code review, a security
review over `git diff <from>..HEAD` — run here, after the commit and before any push.
⚠️ With commit and push approved as one block, this moment never existed:
reviews skipped earlier because nothing was committed yet never ran before the push.

- Each round runs every such review the project uses over `<from>..HEAD`.
  The first round's `<from>` is the Step 0 base, never the upstream (`origin/HEAD`):
  on a long-lived branch `origin/HEAD..HEAD` can hold dozens of earlier commits that belong to other tasks.
- A finding is a fix when the reviewer marks it a defect or a security issue and you agree;
  one that needs a preference or tradeoff from the user is a judgment call; style or wording is minor.
- Fixes decided on in a round → make them and commit them as new commits through Steps 1–5
  (staging confirmation, a new draft and a new ok). These commits stay inside this Step 6:
  run the next round with `<from>` = the previous round's HEAD, so it reviews the fix commits alone.
- At the end of each round, ask the user about its judgment calls: those picked join that round's fixes;
  the rest go to the project's issue tracker (an online one only after the user oks the exact command). Minor items are listed.
- The loop closes on a round with no fix decided on. After round 3's reviews it stops before making their fixes,
  lists what is still open and asks whether to stop here or keep fixing.
- A review the change's scope doesn't reach, or one not installed, is skipped with one line in the reply,
  `review-skip: <review> — <reason>`, rewritten every round.
- The project uses no committed-diff review → say so in one line and go to Step 7.

### 7. Push

No push requested → end the run with one line reminding the user the commits are unpushed.
Otherwise, once the loop closes, draft the exact `git push <remote> <branch>` line and stop
for the user's ok. Run it unchanged via the **Bash tool**; any other push needs a
new draft and a new ok, since Step 4's ok covered the commit alone.
A push requested later, in a run with nothing to commit, starts here,
after one Step 6 round over the commits not yet reviewed.

---

## Commit Message Quality Standard (Chris Beams + Linus Torvalds)

Rules from Chris Beams' *How to Write a Git Commit Message* (7 rules) and Linus Torvalds' requirements for Linux kernel patches. **Both must be followed** and take precedence over other format conventions.

### Chris Beams — 7 Rules

1. **Separate subject from body with a blank line**
2. **Subject ≤ 50 characters** (over the limit → rewrite to the core intent; if it still cannot fit, flag it in the "Rules applied" line)
3. **Capitalise the subject line** (after `type:` prefix too, e.g. `feat: Add single-file comparison`)
4. **Do not end the subject line with a period**
5. **Use the imperative mood**: write "Fix bug", not "Fixed bug"
6. **Wrap the body at 72 characters**
7. **Body is why-only**: motivation, context, trade-offs — why this change exists. The diff and project docs carry what and how.

### Linus Torvalds — Key Points

- **First line stands alone**: readable without context, conveys the commit's intent
- **Describe the problem being solved, not the mechanics of the fix**: explain the symptom and root cause behind the change — not what code changed or how it was fixed
- **Include motivation and impact**: why is this change needed? what breaks without it?
- **Be specific**: name the behaviour or symptom the change touches
- **The message is documentation**: future maintainers read the log without the diff
