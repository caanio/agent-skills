---
name: python-coding-standards
description: "Use before writing or editing any Python code — scripts, functions, bug fixes, cron jobs, data-processing one-offs, or additions to an existing .py file — even if the request sounds quick, casual, or \"just a simple script.\" Applies whether the user names a .py file, describes what the script should do, or asks you to add/fix a function in Python. Covers required standards: type hints, no global variables, logging instead of print, wrapping any I/O (HTTP, DB, subprocess, file) in try/except, commenting the why not the what, writing a real test, and where to place design docs. Does not apply to conceptual Python questions with no code to write (e.g. explaining language features, comparing list vs tuple, explaining what an existing traceback means when the user hasn't asked for a fix, package install help, or learning-resource recommendations), and does not apply to non-Python languages."
---

# python-coding-standards

Defaults for writing and editing Python, so every file in a project reads
consistently regardless of which session wrote it. None of this applies to
a snippet written purely to illustrate a concept, with no runnable entry
point, that nobody is going to execute — e.g. a one-off example in prose
showing what a decorator looks like. If you can't tell whether something
has a runnable entry point, assume it does. Everything else — including a
demo script, a one-off, or an example saved to a file — is real code the
rules below apply to.

## When to Invoke

- About to create or edit a `.py` file, or write Python code the user is
  going to run — except code covered by the illustrative-example exemption
  above.

## Core Rules

1. **[NEVER VIOLATE] Functions the user is going to run get complete type
   hints.** Every parameter and the return type — whether the code ends up
   in a file or stays in the chat as something to copy-paste and execute;
   a one-off script is still real code. When editing an existing file, this
   applies to the function you're adding or touching — don't backfill type
   hints across the rest of the file unless asked.

2. **[NEVER VIOLATE] No global variables.** Use instance attributes,
   closures, or dependency injection instead. The smell this rule targets
   is a module-level or class-level name that gets *mutated* after it's
   defined — whether one function touches it (the `global` keyword is the
   textbook case) or several. A constant — module-level or class-level,
   scalar or a dict/list/tuple that's never reassigned or mutated after
   definition (`MAX_RETRIES = 3`, `DEFAULT_HEADERS = {...}`) — is not a
   global *variable* and is fine, and so is a module-level
   `logger = logging.getLogger(__name__)`.

3. **Use `logging`, never `print()`, for anything diagnostic.** `print()`
   is acceptable only for a CLI tool's actual user-facing output — the
   thing the program exists to print, not a debug trace left behind. A
   standalone script calls
   `logging.basicConfig(level=logging.INFO, format=...)` once at its entry
   point (`if __name__ == "__main__":`) — without an explicit `level=`, the
   root logger defaults to WARNING and `logger.info` silently produces no
   output — a module meant to be imported never calls `basicConfig` itself,
   that's the importer's call.

4. **Wrap in try/except, and log the failure, any I/O that can fail for
   reasons your own code doesn't control:** HTTP calls, DB connections,
   subprocess calls, and file reads/writes. This doesn't cover writing to
   stdout/stderr (Rule 3's `print()` case) — that doesn't fail for external
   reasons. Log enough to diagnose without a repro — what was called, and
   the actual exception, not just "failed".

5. **Comment the WHY, not the WHAT.** Only add a comment when it explains
   something the code itself can't — a hidden constraint, a non-obvious
   trade-off, a workaround for a specific bug. A well-named function or
   variable already says what it does; restating that in a comment is
   noise that goes stale the moment the code changes.

## Testing

- Every piece of logic you write or change — a new script, a new feature,
  or a bug fix — needs a test that exercises its business logic — the
  behaviour a caller depends on, not the fact that the function ran.
  **[NEVER VIOLATE] Never hardcode a return value, or assert a tautology,
  just to make a test pass** — this applies to a probe just as much as a
  formal test.
- Test infra (e.g. `pytest`) already exists → write the test first, then
  the implementation.
- No test infra, but the code lives in an existing project (a repo, a
  package — somewhere with a future) → set up `pytest` rather than
  inventing a bespoke runner. It's the de facto standard, so any future
  session or agent already knows how to run it.
- No test infra, and the code really is a standalone one-off with no
  project to land in → at minimum, write a runnable probe: a short
  standalone snippet that feeds the new code a known input and checks the
  actual output against what you expect, not just that it ran without
  crashing. The probe satisfies this rule, it isn't an exemption from it.
- Project already has its own hand-rolled test/probe setup → don't
  silently replace it with `pytest`. Weigh whether the switch is worth the
  churn, and if it looks like a real improvement, suggest it to the user
  instead of doing it unprompted.

## Design Docs

- Design docs, if the project keeps them, go wherever that project's existing
  documentation convention already puts them. Don't invent a new location
  (e.g. an ad hoc `_doc/` folder) alongside a project that already has one.
