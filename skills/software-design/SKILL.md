---
name: software-design
description: Rules for shaping code in any language, covering ordering, readability, scope, duplication, functions, errors and output. Use when writing, changing or reviewing code in any language, alongside that language's own skill.
---

# Software design

Code here is read top to bottom by someone new to it. These rules apply
in every language. A language's skill adds its own rules, and a widely
used guide for that language wins where it conflicts with these.

Read `references/sources.md` only when asked why a rule exists.

## Ordering

Things that come in a set go in alphabetical order, so a reader finds
one without searching:

- functions and methods, `main` included
- constants and variables declared together
- imports and includes
- branches of a `case` or `switch` that parses options, by option name
- options in help text, and options on a long command
- tests in a test file

Exceptions:

- When a formatter or linter fixes an order, such as Go's or Python's
  import groups, its order wins.
- A value built from another comes after the one it uses.
- A catch-all branch (`*)`, `default`, `else`) comes last.
- An entry point that must be last in the file, such as `main "$@"` in
  bash, stays last.

## Readability

- Code is simple (few parts, each doing one thing) and easy (built from
  constructs a reader already knows). A design may be clever; the code
  carrying it may not.
- No tricks: nothing a reader has to look up to follow. A short form is
  allowed only when the language's skill lists it as an idiom.
- Names are full words: `config_path`, not `cfg` or `p`.

## Build only what is needed

- Solve the problem in front of you, not one that might come later.
- Add no option, setting or extension point before something uses it.
- A likely future need becomes a task on the board, not code.

## Duplication

- Leave two similar copies as they are. On the third, merge them, once
  the shared shape is clear.
- When a shared function grows flags and special cases to fit its
  callers, split it back into plain copies.

## Functions

- A function hides real work behind a short, plain interface. Do not
  write a function that only renames one command or exists only to
  keep another short.
- A function either does something or answers something, not both. An
  exit status saying whether it worked is fine.
- Return early for cases a function does not handle, so the main path
  is not nested inside conditions.

## Errors

- Add an error message of your own only to say more than the tool did,
  to recover, or to prevent damage (overwriting a file, acting on the
  wrong repo). Otherwise let the tool's message through, and still
  stop with a failure.
- Fail early and plainly.
- A message says what failed and what to do about it.

## Output

- Output read by another program says nothing when nothing surprising
  happened.
- Output read by a person is brief: one line per result they care
  about, not one per internal step.
- Code that changes something says what it changed.
- A slow step shows progress.

## Gotchas

- Check the language's skill before writing code. A habit from another
  language is not a rule here.
- A helper that captures a command's output can hide that command's
  failure. Check the language's skill for how to keep the failure.
