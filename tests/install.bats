#!/usr/bin/env bats

# Tests for daeshift --install (libexec/install). Each test gets its own
# home folder with a source repo holding daeshift's files (local/
# ignored) and releases v0.1.0 and v0.2.0, with one more commit on main,
# and a fresh clone of it as DAESHIFT_HOME. The clone's prerequisites
# list git and python3, with a stand-in python3 (version 3.13.5) on
# PATH. No network is used.

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

# Commits everything in repo $1 with message $2.
commit_all() {
  git -C "$1" add -A
  git -C "$1" -c user.name=test -c user.email=test@example.com commit \
    --quiet -m "$2"
}

setup() {
  local code_dir
  local source="${BATS_TEST_TMPDIR}/source"

  export HOME="${BATS_TEST_TMPDIR}/home"
  export DAESHIFT_HOME="${HOME}/.daeshift"
  mkdir -p "${HOME}/bin" "${source}"
  printf '%s\n' '#!/usr/bin/env bash' 'echo "Python 3.13.5"' \
    > "${HOME}/bin/python3"
  chmod +x "${HOME}/bin/python3"
  export PATH="${HOME}/bin:${PATH}"

  code_dir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  cp -R "${code_dir}/.gitignore" "${code_dir}/bin" "${code_dir}/libexec" \
    "${code_dir}/requirements" "${source}/"
  printf '%s\n' 'git 2.31 git --version' 'python3 3.11 python3 --version' \
    > "${source}/requirements/prerequisites"
  git init --quiet --initial-branch=main "${source}"
  commit_all "${source}" "first"
  git -C "${source}" tag v0.1.0
  echo "second" > "${source}/second"
  commit_all "${source}" "second"
  git -C "${source}" tag v0.2.0
  echo "third" > "${source}/third"
  commit_all "${source}" "third"
  git clone --quiet "${source}" "${DAESHIFT_HOME}"
  daeshift="${DAESHIFT_HOME}/bin/daeshift"
}

@test "install changes nothing when the answer is not yes" {
  run "${daeshift}" --install <<<"n"
  assert_equal "${status}" 1
  assert_contains "${output}" "Nothing changed."
  assert_equal "$(ls "${DAESHIFT_HOME}/local" 2>/dev/null)" ""
  assert_equal "$(git -C "${DAESHIFT_HOME}" branch --show-current)" "main"
}

@test "install checks out the newest release on a fresh clone" {
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "check out release v0.2.0"
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.2.0"
  assert_equal "$(cat "${DAESHIFT_HOME}/local/config")" "runner=pi"
  assert_equal "$(ls -d "${DAESHIFT_HOME}/local/projects")" \
    "${DAESHIFT_HOME}/local/projects"
}

@test "install refuses a clone inside local/" {
  git clone --quiet "${BATS_TEST_TMPDIR}/source" "${HOME}/inside/local"
  run env DAESHIFT_HOME="${HOME}/inside" \
    "${HOME}/inside/local/bin/daeshift" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "daeshift is cloned inside ${HOME}/inside/local"
}

@test "install refuses a clone neither at a release nor fresh" {
  echo "local work" > "${DAESHIFT_HOME}/work"
  commit_all "${DAESHIFT_HOME}" "local work"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "is not at a release tag"
  assert_equal "$(ls "${DAESHIFT_HOME}/local" 2>/dev/null)" ""
}

@test "install refuses a clone with changes" {
  echo "draft" > "${DAESHIFT_HOME}/draft"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "has changes"
  assert_equal "$(ls "${DAESHIFT_HOME}/local" 2>/dev/null)" ""
}

@test "install reports every missing or old prerequisite before changing" {
  printf '%s\n' 'python3 3.99 python3 --version' \
    'no-such-tool - no-such-tool --version' \
    > "${BATS_TEST_TMPDIR}/source/requirements/prerequisites"
  commit_all "${BATS_TEST_TMPDIR}/source" "stricter prerequisites"
  git -C "${DAESHIFT_HOME}" pull --quiet
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "python3 3.13.5 was found; daeshift needs python3 3.99 or later."
  assert_contains "${output}" "no-such-tool was not found."
  assert_equal "$(ls "${DAESHIFT_HOME}/local" 2>/dev/null)" ""
}

@test "install run a second time changes nothing" {
  "${daeshift}" --install <<<"y"
  run "${daeshift}" --install </dev/null
  assert_equal "${status}" 0
  assert_contains "${output}" "Nothing to change."
  assert_equal "$(printf '%s\n' "${output}" | grep --count "Make these")" "0"
}
