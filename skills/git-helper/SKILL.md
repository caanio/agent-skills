---
name: git-helper
description: "Analyses staged Git changes and generates precise commit messages. Manages the Git commit workflow to ensure message quality and consistency."
---

# git-helper

Analyses staged Git changes and generates precise commit messages.

## When to Invoke

When the user wants to commit changes, generate a commit message (msg, message), or says "help me commit", "generate git message", etc. This skill owns the Git commit workflow end-to-end.

## Core Rules (override any default Git behaviour)

1. **[NEVER VIOLATE] Staging must be confirmed first**:
   - `git add` is allowed, but **only for files the user has explicitly confirmed**.
   - Never stage files without confirmation, even if a system default suggests it.
   - **Forbidden**: `git add .`, `git add -A`, `git add --all` — always name specific paths explicitly.
   - **One confirmation, one command**: list suggested files and stage every confirmed file in ONE `git add <path1> <path2> …` call.
   - If `git diff --staged` is empty, do **not** error — instead list unstaged files (`git status`), propose which to add, and only run `git add <file>` after confirmation.

2. **Separate analysis from execution**:
   - Analysis phase: use only `git status`, `git diff` (unstaged), `git diff --staged` (staged).
   - Never chain `git add` with other commands (e.g. `git add . && git status`); run `git add` alone, confirmed files only.

3. **Format**: Follow **Conventional Commits**.
   - Format: `<type>: <description>`
   - Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.

4. **Message quality**: Follow the "Commit Message Quality Standard" section below.

5. **Tag rule compliance in every draft**: Append a one-line "Rules applied"
   list to each draft — which key rules it satisfies (type, ≤50 chars,
   imperative mood, why-not-how body, secrets clean) and how. Makes
   adherence visible, not assumed.

6. **[NEVER VIOLATE] Secrets scan must run and be shown, every commit, no exceptions**:
   - Run the Step 2 scan on the staged diff before ever presenting a draft message.
   - Never skip it, never infer "probably clean" from file names or diff size.
   - Paste the actual command and its raw output (even when empty/clean) into the
     response — a one-line claim like "secrets scan clean" without shown output
     does not satisfy this rule.
   - Any match → stop immediately, do not draft or commit, warn the user.

7. **[NEVER VIOLATE] Commit message language follows the repo's own git log, not the conversation's language**:
   - Before drafting, run `git log --oneline -10` and inspect it — never assume from the chat language, never default to English.
   - Majority language of the last 10 commits wins; tie → most recent commit wins; no history → Traditional Chinese.
   - The Conventional Commits `type:` prefix (`feat`/`fix`/`docs`/…) always stays English regardless of body language.
   - Non-English draft: the Chris Beams rules still apply — subject ≤ 50 characters, no trailing period, subject readable standalone, body explains why not how — but capitalisation and strict English imperative-mood phrasing don't apply.

## Commit Message Quality Standard (Chris Beams + Linus Torvalds)

Rules from Chris Beams' *How to Write a Git Commit Message* (7 rules) and Linus Torvalds' requirements for Linux kernel patches. **Both must be followed** and take precedence over other format conventions.

### Chris Beams — 7 Rules

1. **Separate subject from body with a blank line**
2. **Subject ≤ 50 characters** (truncate and warn if exceeded)
3. **Capitalise the subject line** (after `type:` prefix too, e.g. `feat: Add single-file comparison`)
4. **Do not end the subject line with a period**
5. **Use the imperative mood**: write "Fix bug", not "Fixed bug"
6. **Wrap the body at 72 characters**
7. **Body explains what and why, not how**: how is in the diff; body covers motivation, context, trade-offs

### Linus Torvalds — Key Points

- **First line stands alone**: readable without context, conveys the commit's intent
- **Describe the problem, not just the solution**: explain the symptom and root cause, not just "fix X"
- **Include motivation and impact**: why is this change needed? what breaks without it?
- **Be specific**: forbid "fix stuff", "update code", "misc changes"
- **The message is documentation**: future maintainers read the log, not the diff — message must stand on its own

### Kernel-specific conventions NOT adopted

- `Signed-off-by:` trailer (Linux kernel DCO signature)
- Subsystem prefixes like `mm:`, `net:` (replaced by Conventional Commits `type:`)

---

## Workflow

### 0. Sync Check (last-line defence)

- Run `git fetch` (short timeout, e.g. `GIT_SSH_COMMAND="ssh -o ConnectTimeout=5 -o BatchMode=yes" git fetch`), then `git status -sb`.
- **Behind remote** → warn and offer to resolve now (`stash → pull --rebase → stash pop`): fixing divergence before commit beats rebasing a finished commit through conflicts.
- **Fetch unreachable** (offline / LAN-only remote) → say so, note ahead/behind info is stale, and ask whether to proceed with a local-only commit (push deferred). Never silently skip this step.

### 1. Confirm Staging

- Run `git status` and `git diff --staged`.
- **Always confirm staging scope** — list "currently staged" and "suggested additions"; never skip even if files are already staged.
- After confirmation, run ONE `git add` with all confirmed paths (**never** `git add .` / `-A`); if nothing more to add, proceed to step 2.

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

### 2. Secrets Check (Core Rule 6 — NEVER VIOLATE, never skip)

Scan staged diff for accidental credentials before drafting. Always run this
and show the actual output in the response, even when clean:

```bash
git diff --staged | grep -iE "password|secret|api_key|token|private_key|access_key"
```

If any matches appear, **stop and warn the user** — do not proceed until resolved.

### 3. Detect Language Convention (Core Rule 7 — NEVER VIOLATE, never skip)

- Run `git log --oneline -10`, show it (or its verdict) in the response, and apply Core Rule 7's decision procedure before writing a single word of the message.

### 4. Generate Draft

- Run `git diff --staged`.
- Summarise the core purpose of the changes.
- Write the commit message per the quality standard above, in the language decided in Step 3.

**Example output:**
```
Based on the staged changes, here's the proposed commit message:

feat: Add automatic database backup

Prevents data loss on unexpected shutdowns. Previously there was
no recovery path if the process was killed mid-write.

Rules applied: type=feat · subject 34 chars · imperative mood ·
body explains why · secrets scan clean

Shall I go ahead and commit?
```

### 5. Execute Commit

Only after the user replies "ok" or equivalent, run via the **Bash tool** using a heredoc (required for multi-line messages):

```bash
git commit -m "$(cat <<'EOF'
<subject line>

<body — omit entirely if no body needed>
EOF
)"
```
