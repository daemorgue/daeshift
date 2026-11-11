#!/usr/bin/env bats

# Tests for ci/check-root. Each test gets its own home folder with an
# empty root folder to fill.

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

setup() {
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "${HOME}/root"
  check_root="${BATS_TEST_DIRNAME}/../ci/check-root"
}

@test "check-root fails a root holding an instruction file and names it" {
  touch "${HOME}/root/AGENTS.md"
  run "${check_root}" "${HOME}/root"
  assert_equal "${status}" 1
  assert_contains "${output}" "AGENTS.md must not be"
}

@test "check-root names every forbidden file it finds, not just the first" {
  mkdir -p "${HOME}/root/backlog"
  touch "${HOME}/root/CLAUDE.md"
  run "${check_root}" "${HOME}/root"
  assert_equal "${status}" 1
  assert_contains "${output}" "backlog must not be"
  assert_contains "${output}" "CLAUDE.md must not be"
}

@test "check-root passes a root with no forbidden files" {
  touch "${HOME}/root/README.md"
  run "${check_root}" "${HOME}/root"
  assert_equal "${status}" 0
}

@test "check-root passes daeshift's own root" {
  run "${check_root}"
  assert_equal "${status}" 0
}
