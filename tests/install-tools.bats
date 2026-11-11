#!/usr/bin/env bats

# Tests for ci/install-tools. Each test gets its own home folder and
# stand-ins on PATH: git (clones nothing), curl (writes a file that
# matches no pin) and, where a test needs it, uname. No network is used.

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
  mkdir -p "${HOME}/bin"
  # The stand-ins' own lines must reach their files unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'if [[ "$1" == "clone" ]]; then mkdir -p "${@: -1}/bin"; fi' \
    > "${HOME}/bin/git"
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'while [[ $# -gt 0 ]]; do' \
    '  if [[ "$1" == "--output" ]]; then echo "not the release" > "$2"; fi' \
    '  shift' \
    'done' > "${HOME}/bin/curl"
  chmod +x "${HOME}/bin/git" "${HOME}/bin/curl"
  export PATH="${HOME}/bin:${PATH}"
  install_tools="${BATS_TEST_DIRNAME}/../ci/install-tools"
}

@test "install-tools stops on a download that does not match its pin" {
  run "${install_tools}" "${HOME}/tools"
  assert_equal "${status}" 1
  assert_contains "${output}" "ShellCheck: the download's SHA-256 is"
  assert_equal "$(ls "${HOME}/tools/shellcheck.tar.gz" 2>/dev/null)" ""
}

@test "install-tools stops on a platform with no pinned downloads" {
  printf '%s\n' '#!/usr/bin/env bash' 'echo "FreeBSD"' > "${HOME}/bin/uname"
  chmod +x "${HOME}/bin/uname"
  run "${install_tools}" "${HOME}/tools"
  assert_equal "${status}" 1
  assert_contains "${output}" "No pinned tools for FreeBSD"
}
