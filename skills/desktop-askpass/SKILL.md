---
name: desktop-askpass
description: Run a command that needs a password without the password passing through the agent — a GUI dialog on the user's desktop (osascript on macOS, zenity on Linux) collects it instead. Use whenever sudo, ssh, scp, rsync, git, or a LUKS/gpg helper is about to prompt for a password the agent cannot type, when the user says 密碼不要給你 / 密碼框彈在我桌面 / askpass, or when a command just failed with "no tty present", "sudo: a password is required", "a terminal is required", or "Permission denied (password)".
---

# Desktop askpass

Version: 1.0.0 | Date: 2026-10-29

Tested 2026-10-29 on macOS 15.8.2 (osascript backend): a typed secret matched its expected value
(compared in the shell, never printed), Cancel (exit 1), timeout (exit 5),
a malformed `ASKPASS_TIMEOUT` (exit 2, no dialog), an AppleScript-injection prompt left no side effect,
`sudo -A -v` authenticated through the dialog, and every sudo message in the failure table below was observed.
Not tested here: the ssh and git invocations, the stdin consumers,
and the Linux zenity path (carried over from a colleague's Ubuntu use).

The agent's shell has no controlling tty, so anything that prompts for a password
hangs or fails. The fix is the askpass protocol: the program execs a helper,
the helper prints the secret on stdout, the program reads one line.
`scripts/askpass.sh` in this skill's folder is that helper — it pops a hidden-text
entry dialog on the user's desktop and the typed secret goes straight to the
consuming program, never into the transcript.
The dialog title ends in `requested by <program>`, the helper's parent process,
so the user can check it against the command you announced.

Below, `<skill-dir>` is this skill's base directory; write it out as an absolute path in every command.

## Preconditions

- **macOS**: `osascript` (built in). The agent runs inside the user's logged-in desktop session.
- **Linux**: `zenity` installed and a desktop session the user is sitting at.
  The helper uses `ASKPASS_DISPLAY`, else an inherited `DISPLAY`, else `:1`.
  Find the live display with `who` or `ls /tmp/.X11-unix/`, pass it as `ASKPASS_DISPLAY`,
  and check reachability with `DISPLAY=<live> xset q >/dev/null` before launching anything.
  On Wayland zenity works through XWayland, but `XAUTHORITY` usually has to point at the real cookie file.

## Invocations

sudo — `-A` is what makes it consult `SUDO_ASKPASS`:

```bash
SUDO_ASKPASS=<skill-dir>/scripts/askpass.sh sudo -A systemctl restart some.service
```

ssh / scp / rsync / sftp — `SSH_ASKPASS_REQUIRE=force` is mandatory: without it
OpenSSH ≥ 8.4 consults the helper only when there is no tty *and* `DISPLAY` is set,
a combination the agent's shell does not reliably have:

```bash
SSH_ASKPASS=<skill-dir>/scripts/askpass.sh SSH_ASKPASS_REQUIRE=force ssh user@host 'command'
```

git over HTTPS — git passes the prompt as argv[1], and asks for the username through the same hidden box
unless the URL or credential config already names it. git then hands the password to its `credential.helper`,
which may store it (`osxkeychain` on a stock macOS git; `store` writes plain text to `~/.git-credentials`);
`-c credential.helper=` keeps this push from storing it:

```bash
GIT_ASKPASS=<skill-dir>/scripts/askpass.sh git -c credential.helper= push
```

Programs that **check an existing** passphrase read on stdin take the helper's output through a pipe:
`cryptsetup open` without `--key-file`, `openssl -passin fd:0`,
`gpg --batch --pinentry-mode loopback --passphrase-fd 0` (GnuPG ≥ 2.1 ignores `--passphrase-fd` without both).
On Cancel or timeout the pipe carries nothing, so a command that **sets** a new secret
(`luksFormat`, `luksAddKey`, `gpg --symmetric`, `openssl enc -e`) gets its passphrase another way.
The secret ends in one newline, so a whole-stdin key reader (`--key-file=-`) would take that newline as part of the key.
When the consumer also needs sudo, authenticate sudo first, in the same Bash call
(without a tty, sudo's cached credential is tied to the parent process), so only one dialog is open at a time:

```bash
SUDO_ASKPASS=<skill-dir>/scripts/askpass.sh sudo -A -v &&
  <skill-dir>/scripts/askpass.sh "LUKS passphrase:" | sudo -n cryptsetup open /dev/sdX vault
```

Optional knobs: `ASKPASS_TITLE` (default `Claude Code`), `ASKPASS_TIMEOUT` (seconds, 1–86400, default 120),
`ASKPASS_DISPLAY` (Linux only).

## Rules

- **The helper's stdout goes only to the program that asked.** Hand the helper to it through
  `SUDO_ASKPASS` / `SSH_ASKPASS` / `GIT_ASKPASS`, or pipe it straight into the consumer.
  Anything else — the helper run on its own, `$(askpass.sh)`, a redirect to a file, the secret as an argument
  (`-p"$(…)"`, where `ps` shows it) — prints or stores the password where the agent and others can read it.
  To test the dialog, discard the secret: `<skill-dir>/scripts/askpass.sh test >/dev/null; echo $?`.
- **Every password reaches its command through the dialog.** The user types it there, never into the chat,
  and the agent never reads one out of a file to feed a command.
- **Say what the dialog is for before running the command**: which command, on which host,
  and ask the user to wait for the box before typing. The dialog takes focus when it opens,
  so keystrokes meant for another window land in the hidden field.
  Without that context the right answer is Cancel.
- **One dialog per command.** Loop over hosts outside the helper, one invocation each, so every dialog names its host — or use keys.
- **Tell a cancel from a wrong password.** The helper exits 1 on Cancel, 5 on timeout,
  2 when no dialog could be shown or `ASKPASS_TIMEOUT` is out of range; in a pipe, `set -o pipefail` surfaces it.
  Run by sudo, ssh or git, the helper's code is hidden: read the consumer's message (table below),
  and when it cannot say which happened, ask the user.
- **Each prompt is answered fresh.** The secret lives only in the pipe between helper and program —
  no temp file, no `export` for later calls, no `sudo -S <<< "$pw"`.
- **Three dialogs for one task means it wanted an ssh key or a sudoers rule.** Raise that with the user.

## Failure modes

| Symptom | Cause |
| --- | --- |
| ⚠️ `sudo: a terminal is required to read the password` | `-A` missing; `SUDO_ASKPASS` alone does nothing |
| ⚠️ `sudo: no password was provided` | the dialog was cancelled, timed out, or never shown — ask the user which |
| `Sorry, try again.`, then a second dialog | wrong password typed; sudo retries through a fresh dialog |

## Scope

This is for interactive secrets that belong to the human sitting at the machine.
A scheduled or background job has no one to answer the dialog: the helper fails or waits out the timeout.
That job needs a key, a token file with tight permissions, or a sudoers rule.
