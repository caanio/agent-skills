---
name: git-helper
description: "Commit workflow: preview the commit, scan it for secrets and PII, draft a Conventional Commits message, then commit after one approval (on its own when every check is clean), then draft the push for approval. Use when the user wants to commit, write a commit message, or commit and push."
---

# git-helper

## Core Rules (override any default Git behaviour)

1. **[NEVER VIOLATE] Stage only what the user approved**:
   - The real index changes only when Step 5 runs the Step 4 block the user approved (on the Auto path, the block Auto path condition 2 covers).
     Before that, the only index you write is Step 2's preview index.
   - **Forbidden**: `git add .`, `git add -A`, `git add --all`, a directory or an empty line in a path file — every line names one file.
   - Paths never pass through the shell. The commit's paths sit in a **path file**, one per line, written by a quoted heredoc;
     ONE `git add` reads it. A path with `'`, `*`, a space or non-ASCII stays literal that way.
     The paths to unstage get a second path file the same way.
     Locations: `$(git rev-parse --path-format=absolute --git-path git-helper-paths)` and `…git-helper-unstage`.
   - Write each line as `git status --porcelain` prints the path: top-level-relative, and in git's own double-quoted C-escaping
     when it has special characters (`"sub/a b.txt"`), which `--pathspec-from-file` undoes.
     A rename line `R  old -> new` gives two lines, `old` and `new`.
   - Every git command that reads a path file starts `git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs`
     and ends `--pathspec-from-file=<path file>`: `-C` makes top-level-relative paths resolve from any directory,
     `--literal-pathspecs` makes `*` match a file named `*` and nothing else. Needs git 2.25+.
   - This rule and Core Rule 2 bind the real index; Step 2's `GIT_INDEX_FILE` commands write only the preview.

2. **Separate analysis from execution**:
   - Analysis (Steps 0–4): use only commands that leave the real index and working tree untouched —
     `git status`, `git diff`, `git log` (Step 3), `git fetch` (Step 0),
     and Step 2's preview commands, which write only the preview index and the path file.
   - Execution (Step 5): each command of the block is a Bash call of its own, never chained to another command or to a file edit.

3. **Format**: Follow **Conventional Commits** (`<type>: <description>`).

4. **Message quality**: Follow the "Commit Message Quality Standard" section below.

5. **Tag rule compliance in every draft**: Append a one-line "Rules applied" list to each draft (on the Auto path, to the reply right after the commit) — which key rules it satisfies (type, ≤50 chars, imperative mood, why-only body, secrets hits with output shown, PII hits with output shown plus the eye-read) and how — this makes adherence visible, not assumed.

6. **[NEVER VIOLATE] Secrets scan and personal-data (PII) scan must both run and be shown, every commit, no exceptions**:
   - Run both Step 2 scans on the preview diff before ever presenting a draft message — never skip either, never infer "probably clean" from file names or diff size.
   - Paste the actual commands and their raw output (even when empty/clean) into the response — a one-line claim like "secrets scan clean" or "PII clean" without shown output does not satisfy this rule.
   - Any hit puts the run on the manual path, and the user rules on it in the Step 4 reply, as Step 2 describes.

7. **[NEVER VIOLATE] Commit message language follows the repo's own git log**:
   - When history exists, the log decides.
   - Majority language of the last 10 commits wins; tie → most recent commit wins; no history → the conversation's language, and the draft says "no history — using the conversation's language" so the user can switch it before saying ok.
   - The Conventional Commits `type:` prefix (`feat`/`fix`/`docs`/…) always stays English regardless of body language.
   - Non-English draft: the Chris Beams rules still apply — subject ≤ 50 characters, no trailing period, subject readable standalone, body explains why not what/how — but capitalisation and strict English imperative-mood phrasing don't apply.

---

## Auto path

The user's standing authorization to commit without stopping when nothing needs their eyes.
It covers the commit alone: a commit stays on this machine, and the push always gets Step 7's draft and ok.
It holds while every condition below holds. The first condition that fails puts the run on the manual path
from that step on, until this git-helper run ends; the manual path's one stop is the Step 4 reply (besides Step 0's behind-remote offer).
Neither path writes the real index before Step 5.
It covers a run's first commit; a fix commit inside Step 6 takes the manual path.

1. Step 0: the branch has an upstream and is not behind it.
   A fetch that cannot reach the upstream leaves this condition standing; Step 0 reports it.
2. Step 1: list paths with `git status --porcelain --untracked-files=all`, one file per line.
   Every path is one this session wrote with its own tool calls for this task.
   Any of these fails the condition: a path staged before this run, a partly staged `MM` path, a `*.bak-*` file,
   a secret-looking name (`.env*`, `*.pem`, `*.p12`, `*.pfx`, `*.key`, `*.ppk`, `*.jks`, `*.kdbx`, `*.gpg`,
   `.netrc`, `.npmrc`, `.pypirc`, `.pgpass`, `id_*`, `*_ed25519`, `*credential*`).
   These paths are the commit's paths without asking; list them.
3. Step 2: each scan is clean. Run each pipeline and its status echo in one Bash call
   (`; echo "status: $pipestatus"` in zsh, `; echo "status: ${PIPESTATUS[*]}"` in bash).
   Clean means no output, the last `grep` exits 1, and every earlier stage exits 0 (a `grep` may also exit 1).
   Any other status, at any stage, or a blank status, is a failed scan. The eye-read also finds nothing,
   and the preview's `--numstat` (Step 2) shows no binary file (a `-<TAB>-` line): a scan cannot read one.
   Core Rule 6 still applies: paste the commands and their raw output.
4. Step 3: the repo has commit history.

On the auto path, Step 4 writes the block to every rule in it and skips only the draft display and its stop;
Step 5 runs that block, every trailer included, with no ok.
The "Rules applied" line and `git log -1 --format='%h %s%n%n%b'` go in the reply right after the commit.

## Workflow

### 0. Sync Check (last-line defence)

- Run `git fetch` (short timeout, e.g. `GIT_SSH_COMMAND="ssh -o ConnectTimeout=5 -o BatchMode=yes" git fetch`), then `git status -sb`.
- **Behind remote** → warn and offer to resolve now (`stash → pull --rebase → stash pop`): fixing divergence before commit beats rebasing a finished commit through conflicts.
- **Fetch unreachable** (offline / LAN-only remote) → say so in one line, note ahead/behind info is stale, and go on:
  the commit stays on this machine, and the push waits for Step 7's ok either way. Report the fetch result in every run, reachable or not.
- Record the **base** for Step 6 and show it, after any pull in this step: the base the user names;
  otherwise, on this task's first run, `git rev-parse --short HEAD`.
  Later runs in the same task use the HEAD the previous Step 6 last reviewed.

### 1. Choose the Commit's Paths

- Run `git status --porcelain --untracked-files=all`.
- Pick the paths this commit should hold, copied as porcelain prints them (Core Rule 1).
  Every other path already staged is marked for unstaging.
  A partly staged path (`MM`) is committed whole; mark it so the user can drop it.
- The list goes into the Step 4 reply, where the user's ok confirms it;
  on the Auto path, Auto path condition 2 stands in for that confirmation.
- No path to commit → say so and end the run.

### 2. Preview the Commit, Then Scan It (Core Rule 6)

Build the commit in a preview index: HEAD plus exactly the Step 1 paths.
The scans then read what the commit will hold, while the real index, partial staging included, stays as the user left it.
Run these in one Bash call and keep the printed tree hash for Step 5.
A `fatal:` line, or no tree hash, means the preview is wrong and its scans read nothing:
fix the cause and rebuild it before Step 4, on either path; a failed preview never drops the run to the manual path on its own.

```bash
F="$(git rev-parse --path-format=absolute --git-path git-helper-paths)"
cat > "$F" <<'GIT_HELPER_END'
<path, one per line>
GIT_HELPER_END
P="$(git rev-parse --path-format=absolute --git-path git-helper-preview.index)"
GIT_INDEX_FILE="$P" git read-tree HEAD   # no commits yet: git read-tree --empty
GIT_INDEX_FILE="$P" git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs add --pathspec-from-file="$F"
GIT_INDEX_FILE="$P" git diff --cached --numstat
GIT_INDEX_FILE="$P" git write-tree
```

Shell variables do not survive between Bash calls, so each later preview command sets `P` the same way.
The absolute path keeps a run from a subdirectory pointing at a missing index, which reads as an empty commit.
The next run's `read-tree` overwrites the preview file, so nothing needs cleaning.
Run both scans below and show the actual output in the response, even when clean.

**A hit from either scan is ruled on in the Step 4 reply**: the raw scan output in the body, each hit with its line.
There, `ok` means every hit is safe to commit and runs the block;
naming a hit as real, or `no`, ends the run with the real index untouched.
Keep this question out of a choice dialog (such as Claude Code's `AskUserQuestion`):
the dialog covers the text above it, so the user would rule on hits they never saw.

**2a. Secrets** — credentials that grant access, in added lines only:

```bash
P="$(git rev-parse --path-format=absolute --git-path git-helper-preview.index)"; GIT_INDEX_FILE="$P" git diff --cached | grep -E '^\+' | grep -vE '^\+\+\+' | grep -iE "password|secret|api.?key|token|private.?key|access.?key|bearer|basic [A-Za-z0-9+/=]{8,}|://[^/ :@]+:[^/ @]+@|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_|sk-[A-Za-z0-9_-]{16,}|xox[abpr]-|AIza[0-9A-Za-z_-]{30,}|eyJ[A-Za-z0-9_-]{10,}\.|[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}"
```

**2b. Personal data (PII)** — values that identify a person or a place, and labels that reveal a placeholder's origin. Added lines only; decimal-degree coordinates (4+ decimals) plus the words that tag a value as real, home or invented. Lines quoting this scan command are skipped, so editing this rule does not trip it:

```bash
P="$(git rev-parse --path-format=absolute --git-path git-helper-preview.index)"; GIT_INDEX_FILE="$P" git diff --cached | grep -E '^\+' | grep -vE '^\+\+\+|grep -iE' | grep -iE '\b[0-9]{1,3}\.[0-9]{4,}\b|real (home|work|address|coordinate|name)|fictional|真實|虛構|住家|家附近'
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

- Read the preview diff (`GIT_INDEX_FILE="$P" git diff --cached`, `P` set as in Step 2).
- **Describe the preview diff against HEAD, not the session's edit history.**
  Intermediate edits that were later reverted or superseded within the same
  commit are invisible in the diff and must not appear in the message.
  Test: every claim in the message must be locatable in the preview diff.
- Write the commit message per the Commit Message Quality Standard below, in the language decided in Step 3.
- Every rule in this step binds the Auto path too, except showing the draft and stopping for the ok.
- **Body length follows the why.** A body that keeps growing has usually drifted
  into what/how — cut back to the sentences that answer "why does this change
  exist", not "reword it shorter". Each genuinely independent why-reason (not a
  restatement of another, and not a what/how detail like "where the change was
  made") gets its own sentences.
- **Show the exact commands, byte for byte.** The draft is the literal block Step 5
  will run, in order, never the message alone:
  1. the unstage path file, a quoted heredoc as in Step 2, holding every path already staged: the ones Step 1 marked for
     unstaging and this commit's own that are staged, so the real index starts from HEAD like the preview.
     A staged rename takes two lines, old and new, as in the commit's path file;
  2. `git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs restore --staged --pathspec-from-file="$(git rev-parse --path-format=absolute --git-path git-helper-unstage)"`;
  Nothing staged → leave out steps 1 and 2. No commits yet and something staged → replace steps 1 and 2 with the single command
  `git read-tree --empty`: it needs no file, unstages every staged path (all of them are unstaged anyway),
  and succeeds where `git rm --cached` refuses an `AM` path;
  3. the commit's path file, the same quoted heredoc as Step 2;
  4. `git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs add --pathspec-from-file="$(git rev-parse --path-format=absolute --git-path git-helper-paths)"`;
  5. `git write-tree`, which Step 5 compares to Step 2's tree hash;
  6. the full `git commit` heredoc (required for multi-line messages) with every
     trailer your environment appends (e.g. a `Co-Authored-By:` line).
  The unstage file lists only paths that are staged now: `restore --staged` errors on a path that is neither in HEAD nor staged,
  and fails the whole call. The commit's path file also takes the old path of a rename and a path deleted in the working tree
  (`D`, written like any other line); `git add` stages both removals.
  What the user approves is exactly what lands in the log.
  The push gets its own block in Step 7, after Step 6's review loop.
- **The reply is the run's one stop**, besides Step 0's offer when the branch is behind: Step 0's fetch result, Step 1's list, both scans'
  commands and raw output with any hits numbered, Step 3's verdict, then the block,
  and a last line naming the replies.

**Example output:**
```
Fetch: up to date with origin/main.

Paths in this commit:
- `src/core/database.py` (modified)
- `README.md` (modified)
Unstaged first: `SPEC.md` (staged before this run, not part of this change)

Secrets scan: <command> → no output · status: 0 0 0 1
PII scan: <command> → no output · status: 0 0 0 1
Language: last 10 commits English → English

These are the exact commands I will run, one call each:

cat > "$(git rev-parse --path-format=absolute --git-path git-helper-unstage)" <<'GIT_HELPER_END'
SPEC.md
GIT_HELPER_END

git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs restore --staged --pathspec-from-file="$(git rev-parse --path-format=absolute --git-path git-helper-unstage)"

cat > "$(git rev-parse --path-format=absolute --git-path git-helper-paths)" <<'GIT_HELPER_END'
src/core/database.py
README.md
GIT_HELPER_END

git -C "$(git rev-parse --show-toplevel)" --literal-pathspecs add --pathspec-from-file="$(git rev-parse --path-format=absolute --git-path git-helper-paths)"

git write-tree

git commit -m "$(cat <<'EOF'
feat: Add automatic database backup

Prevents data loss on unexpected shutdowns. Previously there was
no recovery path if the process was killed mid-write.

Co-Authored-By: <assistant> <noreply@example.com>
EOF
)"

Rules applied: type=feat · subject 34 chars · imperative mood ·
why-only body · secrets: 0 hits (output above) · PII: 0 hits (output above), every added line read for names/IDs

Reply "commit" or "ok" to run it; "no" ends here with nothing staged or committed.
```

### 5. Execute Commit

On the Auto path, run the Step 4 block now. Otherwise, only after the user answers the Step 4 reply
with "commit", "ok" or equivalent, run the block unchanged via the **Bash tool**, one command per call, in order.

`git write-tree` printing anything other than Step 2's tree hash means the files changed after the preview:
stop before the commit, show both hashes, say the block's staging commands already ran,
and start again at Step 1 on the manual path, which now lists those paths as staged.

One ok covers every command in the block. A command that would differ from the
block in any character — a reworded line, an added trailer — needs a new draft
and a new ok. A failed commit ends the run: report the error to the user.
Step 6 follows every successful commit, push requested or not.

### 6. Review Loop (after every commit)

Reviews that read only committed diffs — a diff-based code review, a security
review over `git diff <from>..HEAD` — run here, after the commit and before any push.
This is why the push always gets its own draft (Step 7): approved together with
the commit, it would leave no point at which these reviews can run.

- Each round runs every such review the project uses over `<from>..HEAD`.
  The first round's `<from>` is the Step 0 base, never the upstream (`origin/HEAD`):
  on a long-lived branch `origin/HEAD..HEAD` can hold dozens of earlier commits that belong to other tasks.
- A finding is a fix when the reviewer marks it a defect or a security issue and you agree;
  one that needs a preference or tradeoff from the user is a judgment call; style or wording is minor.
- Fixes decided on in a round → make them and commit them as new commits through Steps 1–5
  (one draft and one ok, Step 4's single stop). These commits stay inside this Step 6:
  run the next round with `<from>` = the previous round's HEAD, so it reviews the fix commits alone.
- At the end of each round, ask the user about its judgment calls: those picked join that round's fixes;
  the rest go to the project's issue tracker (an online one only after the user oks the exact command). Minor items are listed.
- Each ticket a round opens and each item a fix commit closes reach the project's next-steps list (its TODO or priority list)
  that same round, inside that round's fix commit; a round with no fix commit puts them in a docs-only commit of its own,
  reviewed as one more round before the push.
- The loop closes on a round with no fix decided on. After round 3's reviews it stops before making their fixes,
  lists what is still open and asks whether to stop here or keep fixing.
- A review the change's scope doesn't reach, or one not installed, is skipped with its own Bash call before the push,
  `echo 'review-skip: <review> — <reason>'`, sent again every round:
  a tool call is kept verbatim in the session record, so a later check of that record finds the skip;
  reply text between tool calls may be stored rewritten.
- The project uses no committed-diff review → say so in one line and go to Step 7.
  A review you are required to run counts as one the project uses; skip it only with the echo above.

### 7. Push

Once the loop closes, draft the exact `git push <remote> <branch>` line and stop
for the user's ok, push requested or not. Set the draft apart so it cannot be skimmed past:
a heading carrying the unpushed commit count, every commit the push sends (`git log --format='%h %s' @{u}..HEAD`),
the push line in its own code block,
and a bold last line naming the replies ("push" or "ok" pushes; "no" leaves the commits unpushed).
Run it unchanged via the **Bash tool**; any other push needs a new draft and a new ok,
since a commit's ok, where one was given, never covers the push.
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
