#!/usr/bin/env bash
# askpass.sh — askpass helper: ask the desktop user for a secret in a GUI dialog.
# Version: 1.0.0
# Usage: askpass.sh [prompt]   (sudo -A, ssh and git pass their prompt as argv[1])
# Backend: osascript on macOS, zenity on Linux (X11, or Wayland through XWayland).
# Output: the secret on stdout and nowhere else — it never enters the calling agent's transcript.
# Exit: 0 = secret entered; 1 = cancelled; 5 = timed out;
#       2 = no dialog could be shown, or ASKPASS_TIMEOUT is not 1-86400.
# Env (all optional): ASKPASS_TITLE (default "Claude Code"), ASKPASS_TIMEOUT (seconds, default 120),
#                     ASKPASS_DISPLAY (Linux only, default :1).
set -u

prompt="${1:-Password:}"
# The caller writes the prompt and may set the title, so the requesting program is appended here,
# where the user can check it against the command they were told about.
requester=$(ps -o comm= -p "$PPID" 2>/dev/null)
title="${ASKPASS_TITLE:-Claude Code} — requested by ${requester##*/}"
timeout="${ASKPASS_TIMEOUT:-120}"
# A malformed value would fail inside the dialog tool and read as a Cancel.
case "$timeout" in
  ''|*[!0-9]*) timeout=0 ;;
esac
# Past a day the value only risks overflowing the dialog tool's integer.
if [ "${#timeout}" -gt 5 ] || [ "$((10#$timeout))" -le 0 ] || [ "$((10#$timeout))" -gt 86400 ]; then
  echo "askpass: ASKPASS_TIMEOUT must be an integer from 1 to 86400 seconds" >&2; exit 2
fi

case "$(uname -s)" in
  Darwin)
    command -v osascript >/dev/null 2>&1 || { echo "askpass: osascript not found" >&2; exit 2; }
    # Dialog noise on stderr must never reach the consumer; stdout carries the secret alone.
    exec 2>/dev/null
    # The prompt travels as argv, never spliced into the script source: an ssh prompt carries a
    # host name the remote side controls. Every result is prefixed so no outcome can pass for a secret.
    out=$(osascript - "$prompt" "$title" "$timeout" <<'APPLESCRIPT'
on run argv
  set {thePrompt, theTitle, theTimeout} to {item 1 of argv, item 2 of argv, (item 3 of argv) as integer}
  activate
  try
    set r to display dialog thePrompt with title theTitle default answer "" with hidden answer giving up after theTimeout
  on error number -128
    return "C"
  end try
  if gave up of r then return "T"
  return "S" & text returned of r
end run
APPLESCRIPT
    ) || exit 2   # Cancel is caught above, so a failure here means no dialog could be shown
    case "$out" in
      S*) printf '%s\n' "${out#S}"; exit 0 ;;
      C)  exit 1 ;;
      T)  exit 5 ;;
      *)  exit 2 ;;
    esac
    ;;
  *)
    command -v zenity >/dev/null 2>&1 || { echo "askpass: zenity not found" >&2; exit 2; }
    # The agent's shell usually has no DISPLAY; fall back to the X11 session.
    export DISPLAY="${ASKPASS_DISPLAY:-${DISPLAY:-:1}}"
    export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
    # GTK writes warnings to stderr; stdout must stay clean for the secret alone.
    exec 2>/dev/null
    # zenity already exits 1 on Cancel and 5 on timeout.
    exec zenity --entry --hide-text --title="$title" --text="$prompt" --timeout="$timeout"
    ;;
esac
