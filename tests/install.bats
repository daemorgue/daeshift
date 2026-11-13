#!/usr/bin/env bats

# Tests for daeshift --install (libexec/install). Each test gets its own
# home folder with a source repo holding daeshift's files (local/
# ignored) and releases v0.1.0 and v0.2.0, with one more commit on main,
# and a fresh clone of it as DAESHIFT_HOME. The clone's prerequisites
# list git and python3, and its ci/install-tools only creates DIR/bin.
# Stand-ins on PATH: python3 (version 3.13.5; "-m venv DIR" creates
# DIR/bin/pip) and npm. No network is used.

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
  mkdir -p "${HOME}/bin" "${source}/ci"
  # The stand-ins' own lines must reach their files unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'if [[ "$1" == "--version" ]]; then echo "Python 3.13.5"; exit 0; fi' \
    'mkdir -p "$3/bin"' \
    'printf "%s\n" "#!/usr/bin/env bash" > "$3/bin/pip"' \
    'chmod +x "$3/bin/pip"' > "${HOME}/bin/python3"
  printf '%s\n' '#!/usr/bin/env bash' > "${HOME}/bin/npm"
  chmod +x "${HOME}/bin/python3" "${HOME}/bin/npm"
  export PATH="${HOME}/bin:${PATH}"

  code_dir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  cp -R "${code_dir}/.gitignore" "${code_dir}/bin" "${code_dir}/libexec" \
    "${code_dir}/requirements" "${source}/"
  printf '%s\n' 'git 2.31 git --version' 'python3 3.11 python3 --version' \
    > "${source}/requirements/prerequisites"
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' 'mkdir -p "$2/bin"' \
    > "${source}/ci/install-tools"
  chmod +x "${source}/ci/install-tools"
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

@test "install checks out the newest release on a fresh clone and installs" {
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "check out release v0.2.0"
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.2.0"
  assert_equal "$(cat "${DAESHIFT_HOME}/local/config")" "runner=pi"
  assert_equal "$(ls -d "${DAESHIFT_HOME}/local/projects")" \
    "${DAESHIFT_HOME}/local/projects"
  assert_contains "$(ls "${DAESHIFT_HOME}/local/tools")" "installed-from"
  assert_equal "$(readlink "${DAESHIFT_HOME}/local/tools/bin/tiredize")" \
    "${DAESHIFT_HOME}/local/tools/tiredize/bin/tiredize"
}

@test "install keeps an existing config and projects" {
  mkdir -p "${DAESHIFT_HOME}/local/projects/demo"
  echo "runner=other" > "${DAESHIFT_HOME}/local/config"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_equal "$(cat "${DAESHIFT_HOME}/local/config")" "runner=other"
  assert_equal "$(ls "${DAESHIFT_HOME}/local/projects")" "demo"
}

@test "install leaves no stamp when a tool fails to install" {
  "${daeshift}" --install <<<"y"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "${HOME}/bin/npm"
  echo "an older stamp" > "${DAESHIFT_HOME}/local/tools/installed-from"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "Installing backlog and groma failed."
  assert_equal "$(ls "${DAESHIFT_HOME}/local/tools/installed-from" \
    2>/dev/null)" ""
}

@test "install prints the PATH line and a missing git identity" {
  run "${daeshift}" --install <<<"y"
  assert_contains "${output}" "export PATH=\"${DAESHIFT_HOME}/bin:"
  assert_contains "${output}" "git has no identity yet"
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

@test "install reinstalls the tools when their pins change" {
  "${daeshift}" --install <<<"y"
  echo "an older stamp" > "${DAESHIFT_HOME}/local/tools/installed-from"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "install the pinned tools"
  assert_contains "${output}" "Pinned tools installed"
}

@test "install reports every missing or old prerequisite before changing" {
  # 3.13.5 passes 3.100 when compared as text, so this needs numbers.
  printf '%s\n' 'python3 3.100 python3 --version' \
    'no-such-tool 1.2 no-such-tool --version' \
    > "${BATS_TEST_TMPDIR}/source/requirements/prerequisites"
  commit_all "${BATS_TEST_TMPDIR}/source" "stricter prerequisites"
  git -C "${DAESHIFT_HOME}" pull --quiet
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "python3 3.13.5 was found; daeshift needs python3 3.100 or later."
  assert_contains "${output}" \
    "no-such-tool was not found. Install no-such-tool 1.2 or later"
  assert_equal "$(ls "${DAESHIFT_HOME}/local" 2>/dev/null)" ""
}

@test "install run a second time changes nothing" {
  "${daeshift}" --install <<<"y"
  run "${daeshift}" --install </dev/null
  assert_equal "${status}" 0
  assert_contains "${output}" "Nothing to change."
  assert_equal "$(printf '%s\n' "${output}" | grep --count "Make these")" "0"
}
