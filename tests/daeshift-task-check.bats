#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-task-check. Each test gets its own
# home folder, a code repo ~/repo named "daeshift" with one commit on
# the branch tasks/task-7.2-fix-it, a project folder named in
# DAESHIFT_PROJECT_ROOT, and a stand-in backlog on PATH that prints the
# board in ~/board.json, or fails when ~/board-fails exists.

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
  export DAESHIFT_REPO_NAME="daeshift"
  mkdir -p "${HOME}/bin" "${DAESHIFT_PROJECT_ROOT}"
  printf '%s\n' '[user]' '  name = Test' '  email = test@example.com' \
    > "${GIT_CONFIG_GLOBAL}"
  # The stand-in's lines must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'echo "$* in ${PWD}" > "${HOME}/backlog-call"' \
    'if [[ -e "${HOME}/board-fails" ]]; then exit 1; fi' \
    'cat "${HOME}/board.json"' > "${HOME}/bin/backlog"
  chmod +x "${HOME}/bin/backlog"
  export PATH="${HOME}/bin:${PATH}"
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks/daeshift-task-check"
  git init --quiet --initial-branch=tasks/task-7.2-fix-it "${HOME}/repo"
  cd "${HOME}/repo" || return 1
  git commit --quiet --allow-empty --message "First"
}

@test "daeshift-task-check allows a detached HEAD during a rebase" {
  git checkout --quiet --detach
  mkdir "$(git rev-parse --git-path rebase-merge)"
  run "${check}"
  assert_equal "${status}" 0
}

@test "daeshift-task-check allows a new repo's first commit" {
  git init --quiet --initial-branch=main "${HOME}/new"
  cd "${HOME}/new" || return 1
  run "${check}"
  assert_equal "${status}" 0
}

@test "daeshift-task-check allows a task that is ready to be worked" {
  cat > "${HOME}/board.json" <<'JSON'
{"tasks": [{"id": "TASK-7.2", "status": "In Progress",
  "acceptanceCriteriaCount": 2, "project": "daeshift", "isReady": true}]}
JSON
  run "${check}"
  assert_equal "${status}" 0
  assert_equal "$(cat "${HOME}/backlog-call")" \
    "task list --json in ${DAESHIFT_PROJECT_ROOT}"
}

@test "daeshift-task-check fails closed when backlog or jq is missing" {
  mkdir "${HOME}/only-git"
  ln -s "$(command -v git)" "${HOME}/only-git/git"
  ln -s "$(command -v bash)" "${HOME}/only-git/bash"
  PATH="${HOME}/only-git" run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "backlog was not found"
  assert_contains "${output}" "jq was not found"
}

@test "daeshift-task-check fails closed when the board cannot be read" {
  touch "${HOME}/board-fails"
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "could not be read"
}

@test "daeshift-task-check matches the branch's task ID exactly" {
  echo '{"tasks": [{"id": "TASK-7.2.1", "status": "In Progress"}]}' \
    > "${HOME}/board.json"
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "TASK-7.2 is not on the board."
  git switch --quiet --create tasks/task-7.2x
  run "${check}"
  assert_contains "${output}" "names no task"
  git switch --quiet --create tasks/task-7.2.-x
  run "${check}"
  assert_contains "${output}" "names no task"
}

@test "daeshift-task-check names every reason a task is not ready" {
  cat > "${HOME}/board.json" <<'JSON'
{"tasks": [
  {"id": "TASK-7.2", "status": "To Do", "acceptanceCriteriaCount": 0,
   "project": "_project", "isReady": false},
  {"id": "TASK-7.2.1", "parentTaskId": "TASK-7.2", "status": "To Do"}]}
JSON
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "TASK-7.2 is To Do, not In Progress."
  assert_contains "${output}" "TASK-7.2 has no acceptance criteria."
  assert_contains "${output}" \
    'TASK-7.2 belongs to project "_project", not "daeshift".'
  assert_contains "${output}" "TASK-7.2 has subtasks"
  assert_contains "${output}" "TASK-7.2 waits on a dependency"
}

@test "daeshift-task-check rejects a branch that names no task" {
  git switch --quiet --create fix-it
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Branch fix-it names no task."
}

@test "daeshift-task-check rejects a commit on a detached HEAD" {
  git checkout --quiet --detach
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Commits on a detached HEAD name no task."
}

@test "daeshift-task-check rejects a task that is not on the board" {
  echo '{"tasks": []}' > "${HOME}/board.json"
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "TASK-7.2 is not on the board."
}

@test "daeshift-task-check rejects an orphan branch in a repo with history" {
  git checkout --quiet --orphan anything
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Branch anything names no task."
}
