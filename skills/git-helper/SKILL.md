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
   - **Forbidden**: `git add .`, `git add -A`, `git add --all` — always name specific paths one by one.
   - If `git diff --staged` is empty, do **not** error — instead list unstaged files (`git status`), propose which to add, and only run `git add <file>` after confirmation.

2. **Separate analysis from execution**:
   - Analysis phase: use only `git status`, `git diff` (unstaged), `git diff --staged` (staged).
   - Never chain `git add` with other commands (e.g. `git add . && git status`); run `git add` alone, confirmed files only.

3. **Format**: Follow **Conventional Commits**.
   - Format: `<type>: <description>`
   - Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.

4. **Message quality**: Follow the "Commit Message Quality Standard" section — body explains why, never lists changes.

5. **Step-by-step confirmation**:
   - Step 1 (Staging): **Always confirm staging scope** — list currently staged files and suggest any additions. Even if the user staged everything themselves, still list what's staged and ask them to confirm. Only run `git add <file>` after confirmation.
   - Step 2 (Secrets): Scan staged diff for credentials before drafting.
   - Step 3 (Draft): Generate a draft commit message for the user to review.
   - Step 4 (Commit): Only run `git commit` after the user replies with "ok" or equivalent.

6. **Tag rule compliance in every draft**: Append a one-line "Rules applied"
   list to each draft — which key rules it satisfies (type, ≤50 chars,
   imperative mood, why-not-how body, secrets clean) and how. Makes
   adherence visible, not assumed.

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

### 1. Confirm Staging

- Run `git status` and `git diff --staged`.
- **Always confirm staging scope** — list "currently staged" and "suggested additions"; never skip even if files are already staged.
- After confirmation, run `git add <file>` one at a time (**never** `git add .` / `-A`); if nothing more to add, proceed to step 2.

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

### 2. Secrets Check

Scan staged diff for accidental credentials before drafting:

```bash
git diff --staged | grep -iE "password|secret|api_key|token|private_key|access_key"
```

If any matches appear, **stop and warn the user** — do not proceed until resolved.

### 3. Generate Draft

- Run `git diff --staged`.
- Summarise the core purpose of the changes.
- Write the commit message per the quality standard above.

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

### 4. Execute Commit

Once the user confirms, run via the **Bash tool** using a heredoc (required for multi-line messages):

```bash
git commit -m "$(cat <<'EOF'
<subject line>

<body — omit entirely if no body needed>
EOF
)"
```
