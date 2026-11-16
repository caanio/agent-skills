# git-helper in a linked worktree

Spell every git-helper command this way for the whole run when Step 0 finds a linked worktree,
or once a harness refuses a git-helper command for its form.
A refusal at Step 5 comes after the block was cleared to run, and its earlier commands may already have changed the real index:
stop there, say which commands ran, and start again at Step 1 on the manual path in this form,
as `SKILL.md` Step 5 does after a `write-tree` mismatch. Step 1 then shows the real index as those commands left it,
and the new block runs only on its own new ok.
Every rule in `SKILL.md` still binds: the preview index, both scans, the binary check,
the `write-tree` comparison and the one ok. Only the spelling changes, so the checks stay equivalent.

## What gets refused

⚠️ Claude Code's worktree-isolated sessions check each Bash call before it runs and refuse it when git's target
cannot be read from the command text alone. Refusals hit in recorded sessions, with the message's key phrase:

- git piped into another command (`git diff … | grep …`): "too complex to verify that it stays inside the worktree".
- `$(git …)` inside a git command: "names git more than once in a single command".
- `GIT_INDEX_FILE` under the shared `.git`, where `--git-path` points (`.git/worktrees/<name>/…`): "the shared checkout".
- `GIT_INDEX_FILE=$TMPDIR/…` and `-C "$(pwd)"`: "too complex to verify that it stays inside the worktree".
- `-C .`: "points git at a directory computed at runtime".
- `GIT_SSH_COMMAND=… git …`: "sets GIT_SSH_COMMAND, injecting git configuration".
- `git -c` with the keys `core.sshCommand` or `core.hooksPath`: "injecting configuration".
  The key decides: `-c core.quotepath=false` was accepted; treat any key not named here as untested.
- A command with a pipe whose text contains the letters `git` anywhere, even one that never runs git:
  a temp directory named `git-helper.*`, a grep pattern holding `github_pat_`.

Accepted: one git command per call with literal absolute paths, `GIT_INDEX_FILE` outside `.git` included;
`git commit -m "$(cat <<'EOF' … EOF)"`, its message mentioning git included; a quoted heredoc writing a file;
a pipe of non-git commands over files whose path and pattern hold no `git`.

## The forms

**Lookups, once per run.** Run each as its own call and copy the printed path into every later command, character for character:

```bash
git rev-parse --show-toplevel
mktemp -d -t commit-preview.XXXXXX
```

Below, `<top>` is the first output and `<tmp>` the second; keep `git` out of `<tmp>`'s name.
The `XXXXXX` lets GNU `mktemp` accept the template [unconfirmed: not run on Linux];
BSD `mktemp` keeps the X's and appends its own suffix, which works the same.
`<tmp>/paths` and `<tmp>/unstage` replace Core Rule 1's `--git-path` locations,
and `-C <top>` replaces `-C "$(git rev-parse --show-toplevel)"`.
Delete `<tmp>` (`rm -r <tmp>`) once the run ends.

**Step 0.** Plain `git fetch`, with the tool call's own timeout (about 20 s) in place of `ConnectTimeout`;
a timeout reads as "fetch unreachable".

**Step 2 preview.** One call per command, in order:

```bash
cat > <tmp>/paths <<'GIT_HELPER_END'
<path, one per line>
GIT_HELPER_END
GIT_INDEX_FILE=<tmp>/preview.index git read-tree HEAD   # no commits yet: git read-tree --empty
GIT_INDEX_FILE=<tmp>/preview.index git -C <top> --literal-pathspecs add --pathspec-from-file=<tmp>/paths
GIT_INDEX_FILE=<tmp>/preview.index git diff --cached --numstat --output=<tmp>/numstat
GIT_INDEX_FILE=<tmp>/preview.index git diff --cached --output=<tmp>/preview.diff
GIT_INDEX_FILE=<tmp>/preview.index git write-tree
```

Show `<tmp>/numstat` for the binary check, and keep the tree hash for Step 5.
A git call that exits non-zero is a failed preview, as a `fatal:` line is in `SKILL.md`.

**Step 2 scans.** Each scan reads `<tmp>/preview.diff`, so its pipeline holds no git.
Each keeps its status echo. Clean means the `git diff --cached --output=…` call exited 0,
the pipeline printed nothing, the last `grep` exited 1, and every earlier `grep` exited 0 or 1;
any other status, or a blank one, is a failed scan. 2a spells `github_pat_` as `[g]ithub_pat_`:

```bash
grep -E '^\+' <tmp>/preview.diff | grep -vE '^\+\+\+' | grep -iE "password|secret|api.?key|token|private.?key|access.?key|bearer|basic [A-Za-z0-9+/=]{8,}|://[^/ :@]+:[^/ @]+@|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|[g]ithub_pat_|sk-[A-Za-z0-9_-]{16,}|xox[abpr]-|AIza[0-9A-Za-z_-]{30,}|eyJ[A-Za-z0-9_-]{10,}\.|[0-9]{8,10}:AA[A-Za-z0-9_-]{30,}"; echo "status: $pipestatus"
grep -E '^\+' <tmp>/preview.diff | grep -vE '^\+\+\+|grep -iE' | grep -iE '\b[0-9]{1,3}\.[0-9]{4,}\b|real (home|work|address|coordinate|name)|fictional|真實|虛構|住家|家附近'; echo "status: $pipestatus"
```

(`$pipestatus` is zsh; bash uses `${PIPESTATUS[*]}`.)

**Step 4.** Read the draft's diff from `<tmp>/preview.diff`. The block keeps its order and content,
with `<tmp>/unstage` and `<tmp>/paths` as the path files and `-C <top>` in both pathspec commands:

```bash
cat > <tmp>/unstage <<'GIT_HELPER_END'
SPEC.md
GIT_HELPER_END

git -C <top> --literal-pathspecs restore --staged --pathspec-from-file=<tmp>/unstage

cat > <tmp>/paths <<'GIT_HELPER_END'
src/core/database.py
README.md
GIT_HELPER_END

git -C <top> --literal-pathspecs add --pathspec-from-file=<tmp>/paths

git write-tree

git commit -m "$(cat <<'EOF'
<message and trailers, as in SKILL.md>
EOF
)"
```

Nothing staged → leave out the unstage file and `restore --staged`.
No commits yet and something staged → replace those two with `git read-tree --empty`.
In the draft, `<top>` and `<tmp>` appear as the literal paths the lookups printed.
Step 5 compares `git write-tree` with Step 2's hash exactly as `SKILL.md` says.
