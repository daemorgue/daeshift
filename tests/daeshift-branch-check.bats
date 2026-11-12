#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-branch-check. Each test gets its
# own home folder and a git repo ~/repo with one commit on main, and
# runs the check from inside that repo.

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
  export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  mkdir -p "${HOME}"
  printf '%s\n' '[user]' '  name = Test' '  email = test@example.com' \
    > "${GIT_CONFIG_GLOBAL}"
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks/daeshift-branch-check"
  git init --quiet --initial-branch=main "${HOME}/repo"
  cd "${HOME}/repo" || return 1
  git commit --quiet --allow-empty --message "First"
}

@test "daeshift-branch-check allows a branch an --allow glob matches" {
  git switch --quiet --create tasks/task-12-pin-tools
  run "${check}" --allow 'tasks/*'
  assert_equal "${status}" 0
}

@test "daeshift-branch-check allows a detached HEAD during a bisect" {
  git checkout --quiet --detach
  touch "$(git rev-parse --git-path BISECT_LOG)"
  run "${check}"
  assert_equal "${status}" 0
}

@test "daeshift-branch-check allows a new repo's first commit" {
  git init --quiet --initial-branch=main "${HOME}/new"
  cd "${HOME}/new" || return 1
  run "${check}"
  assert_equal "${status}" 0
}

@test "daeshift-branch-check denies main and master by default" {
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "git switch -c tasks/<id>-<slug>"
  git branch --quiet --move main master
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Commits on master are not allowed"
}

@test "daeshift-branch-check lets --deny win over --allow" {
  git switch --quiet --create release/old
  run "${check}" --allow 'release/*' --deny 'release/old'
  assert_equal "${status}" 1
  assert_contains "${output}" "Denied branches: release/old"
}

@test "daeshift-branch-check matches folders like GitHub's rulesets" {
  git switch --quiet --create feature/a/b1
  run "${check}" --allow 'feature/*'
  assert_equal "${status}" 1
  run "${check}" --allow 'feature/**/b?'
  assert_equal "${status}" 0
  git switch --quiet --create feature/b1
  run "${check}" --allow 'feature/**/b?'
  assert_equal "${status}" 0
  run "${check}" --allow 'feature/**'
  assert_equal "${status}" 0
}

@test "daeshift-branch-check rejects a branch a lone --deny glob matches" {
  git switch --quiet --create release/old
  run "${check}" --deny 'release/*'
  assert_equal "${status}" 1
  assert_contains "${output}" "Denied branches: release/*"
}

@test "daeshift-branch-check rejects a commit on a detached HEAD" {
  git checkout --quiet --detach
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Commits on a detached HEAD are not allowed."
}

@test "daeshift-branch-check rejects main, naming the allowed branches" {
  run "${check}" --allow 'tasks/*'
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "Commits on main are not allowed. Allowed branches: tasks/*"
  assert_contains "${output}" "git switch -c tasks/<id>-<slug>"
}

@test "daeshift-branch-check says to set pass_filenames when given files" {
  run "${check}" README.md
  assert_equal "${status}" 1
  assert_contains "${output}" "pass_filenames: false"
}
