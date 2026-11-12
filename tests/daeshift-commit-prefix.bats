#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-commit-prefix. Each test gets its
# own home folder, a repo ~/repo with one commit on the branch
# tasks/task-7.2-fix-it, a project folder named in DAESHIFT_PROJECT_ROOT,
# a stand-in backlog on PATH that prints the board in ~/board.json (with
# TASK-7.2 on it) or fails when ~/board-fails exists, and writes the
# commit message it checks to ~/message.

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
  export DAESHIFT_PROJECT_ROOT="${HOME}/project"
  mkdir -p "${HOME}/bin" "${DAESHIFT_PROJECT_ROOT}"
  printf '%s\n' '[user]' '  name = Test' '  email = test@example.com' \
    > "${GIT_CONFIG_GLOBAL}"
  # The stand-in's line must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'if [[ -e "${HOME}/board-fails" ]]; then exit 1; fi' \
    'cat "${HOME}/board.json"' > "${HOME}/bin/backlog"
  chmod +x "${HOME}/bin/backlog"
  echo '{"tasks": [{"id": "TASK-7.2"}]}' > "${HOME}/board.json"
  export PATH="${HOME}/bin:${PATH}"
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks/daeshift-commit-prefix"
  message="${HOME}/message"
  git init --quiet --initial-branch=tasks/task-7.2-fix-it "${HOME}/repo"
  cd "${HOME}/repo" || return 1
  git commit --quiet --allow-empty --message "TASK-7.2: First"
}

@test "daeshift-commit-prefix allows a merge commit" {
  touch "$(git rev-parse --git-path MERGE_HEAD)"
  echo "Merge branch 'main'" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 0
}

@test "daeshift-commit-prefix allows a new repo's first commit" {
  git init --quiet --initial-branch=main "${HOME}/new"
  cd "${HOME}/new" || return 1
  echo "Initial commit" > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 0
}

@test "daeshift-commit-prefix allows Board: with --allow-board" {
  echo "Board: draft a task" > "${message}"
  run "${check}" --allow-board --on-board "${message}"
  assert_equal "${status}" 0
}

@test "daeshift-commit-prefix allows the branch's task, past comments" {
  printf '%s\n' '# Please enter the commit message' 'TASK-7.2: Fix it' \
    > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 0
}

@test "daeshift-commit-prefix checks the subject after fixup! and in a revert" {
  echo "fixup! TASK-7.2: Fix it" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 0
  echo 'Reapply "TASK-7.2: Fix it"' > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 0
  echo "fixup! anything" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 1
}

@test "daeshift-commit-prefix fails closed when the board cannot be read" {
  touch "${HOME}/board-fails"
  echo "TASK-7.2: Fix it" > "${message}"
  run "${check}" --on-board "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "could not be read"
}

@test "daeshift-commit-prefix rejects a subject without TASK-<id>:" {
  echo "TASK-7.2 done; fix it" > "${message}"
  run "${check}" --allow-board "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "The subject must start with TASK-<id>: or Board:, not: TASK-7.2 done"
}

@test "daeshift-commit-prefix rejects a task ID with no text after it" {
  echo "TASK-7.2:x" > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 1
  echo "TASK-7.2: " > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 1
}

@test "daeshift-commit-prefix rejects a task not on the board" {
  echo "TASK-7.3: Fix it" > "${message}"
  run "${check}" --on-board "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "TASK-7.3, which is not on the board."
}

@test "daeshift-commit-prefix rejects another task than the branch's" {
  echo "TASK-7.3: Fix it" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "names TASK-7.3, but branch tasks/task-7.2-fix-it is for TASK-7.2."
}

@test "daeshift-commit-prefix rejects Board: without --allow-board" {
  echo "Board: draft a task" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "must start with TASK-<id>:, not: Board:"
}

@test "daeshift-commit-prefix uses the rebased branch during a rebase" {
  git checkout --quiet --detach
  mkdir "$(git rev-parse --git-path rebase-merge)"
  echo "refs/heads/tasks/task-7.2-fix-it" \
    > "$(git rev-parse --git-path rebase-merge/head-name)"
  echo "TASK-7.3: Fix it" > "${message}"
  run "${check}" --match-branch "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "branch tasks/task-7.2-fix-it is for TASK-7.2"
}
