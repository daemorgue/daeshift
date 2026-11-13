#!/usr/bin/env bats

# Tests for daeshift --add-project (libexec/pull). Each test gets its own home folder with a
# DAESHIFT_HOME holding local/projects/ and the yq on PATH as the pinned
# yq (it must be mikefarah's, as CI's pinned tools provide), and three
# source repos on main: demo.git, a project repo that ignores
# repositories/ and whose repos.yaml lists site and blog, and the code
# repos site and blog. No network is used.

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

# Commits a new file $2 in repo $1.
commit_file() {
  echo "$2" > "$1/$2"
  git -C "$1" add -A
  git -C "$1" -c user.name=test -c user.email=test@example.com commit \
    --quiet -m "$2"
}

# Writes the source project's repos.yaml listing each name given, each
# with the URL of the source repo of that name, and commits it.
list_repos() {
  local name
  local project="${BATS_TEST_TMPDIR}/demo.git"

  echo "repos:" > "${project}/.config/repos.yaml"
  for name in "$@"; do
    printf '%s\n' "  - name: \"${name}\"" \
      "    url: \"${BATS_TEST_TMPDIR}/${name}\"" \
      >> "${project}/.config/repos.yaml"
  done
  commit_file "${project}" "listed-$#"
}

setup() {
  local repo

  export HOME="${BATS_TEST_TMPDIR}/home"
  export DAESHIFT_HOME="${HOME}/.daeshift"
  mkdir -p "${DAESHIFT_HOME}/local/projects" \
    "${DAESHIFT_HOME}/local/tools/bin"
  ln -s "$(command -v yq)" "${DAESHIFT_HOME}/local/tools/bin/yq"
  for repo in demo.git site blog; do
    git init --quiet --initial-branch=main "${BATS_TEST_TMPDIR}/${repo}"
    commit_file "${BATS_TEST_TMPDIR}/${repo}" "first"
  done
  mkdir -p "${BATS_TEST_TMPDIR}/demo.git/.config"
  echo "repositories/" > "${BATS_TEST_TMPDIR}/demo.git/.gitignore"
  list_repos site blog
  daeshift="${BATS_TEST_DIRNAME}/../bin/daeshift"
  projects="${DAESHIFT_HOME}/local/projects"
}

@test "add-project clones the project and every repo it lists" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 0
  assert_contains "${output}" "Project demo is added."
  assert_equal "$(ls "${projects}/demo/repositories")" \
    "$(printf 'blog\nsite')"
}

@test "add-project names the project after --name" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git" \
    --name tired-labs
  assert_equal "${status}" 0
  assert_equal "$(ls "${projects}")" "tired-labs"
}

@test "add-project refuses a name that is not plain" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git" \
    --name ../outside
  assert_equal "${status}" 1
  assert_contains "${output}" "'../outside' is not a plain project name."
  assert_equal "$(ls "${HOME}/.daeshift/local")" "$(printf 'projects\ntools')"
}

@test "add-project refuses a project that already exists" {
  mkdir "${projects}/demo"
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 1
  assert_contains "${output}" "already exists. Choose another name"
  assert_equal "$(ls "${projects}/demo")" ""
}

@test "add-project refuses a URL it cannot reach" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/missing.git"
  assert_equal "${status}" 1
  assert_contains "${output}" "missing.git could not be reached."
  assert_equal "$(ls "${projects}")" ""
}

@test "add-project reports a repo it cannot clone and clones the rest" {
  list_repos site gone blog
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 1
  assert_contains "${output}" "Cloning ${BATS_TEST_TMPDIR}/gone into"
  assert_contains "${output}" "Some repos of demo were not cloned."
  assert_equal "$(ls "${projects}/demo/repositories")" \
    "$(printf 'blog\nsite')"
}

@test "add-project without a URL prints the help and fails" {
  run "${daeshift}" --name demo
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}
