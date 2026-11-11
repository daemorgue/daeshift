---
name: bash-testing
description: How to write tests for bash scripts with bats-core, covering file layout, isolation, assertions and running them on Linux and macOS. Use when writing, changing or reviewing tests for a bash script, alongside test-design and bash.
---

# Bash testing

Which cases earn a test is in test-design. This skill says how to write
them for bash. Read `references/sources.md` only when asked why a rule
exists.

## Layout

- Tests use [bats-core](https://github.com/bats-core/bats-core).
- One test file per script: `tests/<script>.bats`.
- The file starts with `#!/usr/bin/env bats` and a comment saying what
  each test's setup gives it.
- Follow the bash skill for everything else: 2-space indent, 80
  columns, `"${var}"`, helpers first, then alphabetical order. Tests
  are in alphabetical order too.

## Isolation

- `setup` points `HOME` at the test's own temporary folder, so no test
  touches the real home folder:

  ```bash
  setup() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    mkdir -p "${HOME}"
    script="${BATS_TEST_DIRNAME}/../path/to/script"
  }
  ```

- A test creates every file it needs inside `${HOME}`.

## Running the script

- Run the script the way a user does, with `run`, then check
  `${status}` and `${output}` (stdout and stderr together).
- Name each test for its behavior, starting with the script's name:
  `@test "backup leaves an existing backup untouched"`.

## Assertions

Every check goes through an `assert_` function built on an `if` block.
On bash 3.2 (macOS), a failing `[[ ]]` or `[ ]` in the middle of a test
does not fail it. Copy the ones a file uses:

```bash
# Fails the test when the text does not contain the expected part.
assert_contains() {
  if ! printf '%s\n' "$1" | grep --fixed-strings --quiet -- "$2"; then
    echo "expected to find: $2"
    echo "in: $1"
    return 1
  fi
}

# Fails the test when the first value is not the second.
assert_equal() {
  if [[ "$1" != "$2" ]]; then
    echo "expected: $2"
    echo "actual:   $1"
    return 1
  fi
}
```

A helper that builds test files, such as `write_skill`, is allowed once
three or more tests repeat the same setup.

## Checks

- ShellCheck passes every `.bats` file.
- CI runs the tests on Linux and macOS, so a GNU-only or newer-bash
  habit fails before it merges. Install bats with `apt-get install
  bats` on Linux and `brew install bats-core` on macOS.

## Gotchas

- `[ "${status}" -eq 1 ]` mid-test passes on macOS even when false. Use
  `assert_equal "${status}" 1`.
- A loop over inputs inside a test is logic (test-design). Write one
  test per path instead.
- Testing the script's helper functions one by one couples tests to its
  structure. Test what the script does.
