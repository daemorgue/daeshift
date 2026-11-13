#!/usr/bin/env bats

# Tests for bin/daeshift. Each test gets its own home folder holding a
# DAESHIFT_HOME with two projects, a config naming pi and the yq found on
# PATH as its pinned yq, and a stand-in pi on PATH that records the folder
# it started in and its arguments.

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
  export DAESHIFT_HOME="${HOME}/.daeshift"
  mkdir -p "${HOME}/bin" \
    "${DAESHIFT_HOME}/local/projects/daemorgue" \
    "${DAESHIFT_HOME}/local/projects/tired-labs" \
    "${DAESHIFT_HOME}/local/tools/bin"
  echo "runner: pi" > "${DAESHIFT_HOME}/local/config.yaml"
  ln -s "$(command -v yq)" "${DAESHIFT_HOME}/local/tools/bin/yq"
  # The stand-in's own lines must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    '{ pwd; printf "%s\n" "$@"; } > "${HOME}/pi-call"' > "${HOME}/bin/pi"
  chmod +x "${HOME}/bin/pi"
  export PATH="${HOME}/bin:${PATH}"
  daeshift="${BATS_TEST_DIRNAME}/../bin/daeshift"
  code_dir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
}

@test "daeshift --list-projects prints each project" {
  run "${daeshift}" --list-projects
  assert_equal "${status}" 0
  assert_equal "${output}" "$(printf 'daemorgue\ntired-labs')"
}

@test "daeshift --project fails for a config that yq cannot read" {
  echo "runner: [pi" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_contains "${output}" "config.yaml could not be read"
}

@test "daeshift --project fails for a config with no runner" {
  echo "model: other" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_contains "${output}" "has no runner. Add one, such as: runner: pi"
}

@test "daeshift --project fails for an unknown project and lists the rest" {
  run "${daeshift}" --project bedford
  assert_equal "${status}" 1
  assert_contains "${output}" "No project 'bedford'"
  assert_contains "${output}" "tired-labs"
}

@test "daeshift --project fails for an unknown runner and names it" {
  echo "runner: codex" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_contains "${output}" "No runner 'codex'"
}

@test "daeshift --project fails without a config and says what to create" {
  rm "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_contains "${output}" "Create it with the line: runner: pi"
}

@test "daeshift --project fails without the pinned yq and says to install" {
  rm "${DAESHIFT_HOME}/local/tools/bin/yq"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_contains "${output}" "yq was not found. Run daeshift --install."
}

@test "daeshift --project starts pi in the project with daeshift's parts" {
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 0
  assert_equal "$(sed -n 1p "${HOME}/pi-call")" \
    "${DAESHIFT_HOME}/local/projects/daemorgue"
  assert_contains "$(cat "${HOME}/pi-call")" "${code_dir}/instructions.md"
  assert_contains "$(cat "${HOME}/pi-call")" "${code_dir}/skills"
  assert_contains "$(cat "${HOME}/pi-call")" "${code_dir}/prompts"
}

@test "daeshift does not run a command written in the config" {
  echo "runner: \$(touch ${HOME}/ran)" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --project daemorgue
  assert_equal "${status}" 1
  assert_equal "$(ls "${HOME}/ran" 2>/dev/null)" ""
}
