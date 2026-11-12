#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-parent-status. Each test gets its
# own home folder, a project folder ~/project named in
# DAESHIFT_PROJECT_ROOT, and a stand-in backlog on PATH that prints the
# board in ~/board.json.

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
  export DAESHIFT_PROJECT_ROOT="${HOME}/project"
  mkdir -p "${HOME}/bin" "${DAESHIFT_PROJECT_ROOT}"
  # The stand-in's line must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'echo "$* in ${PWD}" > "${HOME}/backlog-call"' \
    'cat "${HOME}/board.json"' > "${HOME}/bin/backlog"
  chmod +x "${HOME}/bin/backlog"
  export PATH="${HOME}/bin:${PATH}"
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks/daeshift-parent-status"
}

@test "daeshift-parent-status passes parents that follow their subtasks" {
  cat > "${HOME}/board.json" <<'JSON'
{"tasks": [
  {"id": "TASK-1", "status": "In Progress", "labels": ["parent"]},
  {"id": "TASK-1.1", "parentTaskId": "TASK-1", "status": "In Progress",
   "labels": ["parent"]},
  {"id": "TASK-1.1.1", "parentTaskId": "TASK-1.1", "status": "In Progress"},
  {"id": "TASK-1.2", "parentTaskId": "TASK-1", "status": "To Do"},
  {"id": "TASK-9.1", "parentTaskId": "TASK-9", "status": "To Do"},
  {"id": "TASK-2", "status": "Done", "labels": ["parent"]},
  {"id": "TASK-2.1", "parentTaskId": "TASK-2", "status": "Done"},
  {"id": "TASK-3", "status": "To Do", "labels": ["parent"]},
  {"id": "TASK-3.1", "parentTaskId": "TASK-3", "status": "Done"},
  {"id": "TASK-3.2", "parentTaskId": "TASK-3", "status": "To Do"}
]}
JSON
  run "${check}"
  assert_equal "${status}" 0
  assert_equal "${output}" ""
  assert_equal "$(cat "${HOME}/backlog-call")" \
    "task list --json in ${DAESHIFT_PROJECT_ROOT}"
}

@test "daeshift-parent-status rejects a parent without the parent label" {
  cat > "${HOME}/board.json" <<'JSON'
{"tasks": [
  {"id": "TASK-1", "status": "To Do", "labels": []},
  {"id": "TASK-1.1", "parentTaskId": "TASK-1", "status": "To Do"}
]}
JSON
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" 'TASK-1 has subtasks but no "parent" label'
}

@test "daeshift-parent-status rejects a stale parent, naming its status" {
  cat > "${HOME}/board.json" <<'JSON'
{"tasks": [
  {"id": "TASK-1", "status": "To Do", "labels": ["parent"]},
  {"id": "TASK-1.1", "parentTaskId": "TASK-1", "status": "In Progress"},
  {"id": "TASK-2", "status": "In Progress", "labels": ["parent"]},
  {"id": "TASK-2.1", "parentTaskId": "TASK-2", "status": "Done"}
]}
JSON
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "TASK-1 is To Do; its subtasks make it In Progress"
  assert_contains "${output}" "TASK-2 is In Progress; its subtasks make it Done"
}

@test "daeshift-parent-status says to run it through the hooks" {
  unset DAESHIFT_PROJECT_ROOT
  run "${check}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Run this check through daeshift's git hooks"
}
