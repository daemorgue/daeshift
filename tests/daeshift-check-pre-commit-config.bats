#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-check-pre-commit-config. Each test
# gets its own home folder and a config file to check at ~/config.yaml.

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
  mkdir -p "${HOME}"
  unset DAESHIFT_PRE_COMMIT
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks"
  check="${check}/daeshift-check-pre-commit-config"
  echo "repos: []" > "${HOME}/config.yaml"
}

@test "daeshift-check-pre-commit-config says to run it through the hooks" {
  run "${check}" "${HOME}/config.yaml"
  assert_equal "${status}" 1
  assert_contains "${output}" "Run this check through daeshift's git hooks"
}
