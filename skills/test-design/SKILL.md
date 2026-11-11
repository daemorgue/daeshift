---
name: test-design
description: Rules for choosing and writing tests in any language, covering what earns a test, edge cases, test structure, coverage and bugs. Use when planning, writing or reviewing tests, alongside the language's testing skill (such as bash-testing).
---

# Test design

Test as little as possible to reach real confidence. Every test is code
someone must read, run and keep working. The tools for each language
(bats, pytest, go test) are in that language's testing skill.

Read `references/sources.md` only when asked why a rule exists.

## What earns a test

A case gets a test when at least one is true:

- It is likely to happen in real use.
- Its failure would be costly or silent: the wrong repo, an overwritten
  file, success reported when something failed.
- It guards a decision the developer made, so a later change cannot
  quietly undo it.

A case gets no test when any is true:

- The tool it calls already reports the problem clearly.
- It cannot realistically happen.
- It takes the same path through the code as a case already tested.
  Inputs on one path are one case and get one test.

## Regression test or one-time check

Sort each acceptance criterion before writing anything:

- **Regression test:** behavior a later change could break without
  anyone meaning to. It gets a test that stays in the suite.
- **One-time check:** a change no later code undoes by accident, such
  as a file moved or a setting changed. It gets no test. Record the
  command run and its result in the task notes.

When unsure, it is a regression test.

## Edge cases

Answer each prompt with a test, or a one-line reason for none, and show
the answers when the plan is reviewed:

1. Missing or empty input?
2. Run twice, or already done?
3. One item failing in a loop?
4. Something already in the way?
5. The user's data at risk?
6. A developer's decision to guard?

## Writing a test

- One test checks one behavior, through the interface a user or caller
  uses. Write a test per behavior, not per function.
- The name says the behavior in plain words, so a failure explains
  itself: "backup leaves an existing backup untouched".
- No logic in a test: no loops, no conditionals. Use straight-line code.
  Several inputs on one path are one test; inputs on different paths
  are separate tests.
- A test reads on its own, even if that repeats a line from another
  test. Add a shared helper only once three or more tests repeat the
  same setup.
- A test does not break when code is restructured without changing
  what it does.
- Most tests run the program the way a user does, not its parts in
  isolation.
- A test touches nothing outside its own temporary folder.

## Coverage

Use coverage to find code no test runs. Never use it as a target.

## Bugs

A bug found after a merge is fixed starting with a test that reproduces
it: it fails, then passes with the fix.

## Gotchas

- A loop over inputs inside one test is logic. If the inputs take one
  path, test one of them; if they take different paths, write one test
  each.
- A check that fails in the middle of a test may not fail the test in
  some languages. Check the language's testing skill for how to assert.
