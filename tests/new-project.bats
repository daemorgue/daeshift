#!/usr/bin/env bats

# Tests for daeshift --new-project NAME (libexec/new-project). Each test
# gets its own home folder with a DAESHIFT_HOME holding local/projects/,
# and a global git config with an identity and no hooks. mikefarah's yq
# and jq must be on PATH. No network is used. The commit with daeshift's
# hooks on is checked by hand (wiki: daeshift CLI, Verification).

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
  export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
  mkdir -p "${DAESHIFT_HOME}/local/projects"
  git config --global user.name "Test"
  git config --global user.email "test@example.com"
  daeshift="${BATS_TEST_DIRNAME}/../bin/daeshift"
  projects="${DAESHIFT_HOME}/local/projects"
}

@test "new-project commits the layout once, on main" {
  run "${daeshift}" --new-project demo
  assert_equal "${status}" 0
  assert_equal "$(git -C "${projects}/demo" branch --show-current)" main
  assert_equal "$(git -C "${projects}/demo" log --format=%s)" \
    "Board: Create the demo project"
  assert_equal "$(git -C "${projects}/demo" ls-files)" \
"$(printf '%s\n' .config/next-task.expected .config/next-task.jq \
  .config/next-task.test.json .config/pre-commit/_code.yaml \
  .config/pre-commit/_project.yaml .config/repos.yaml .gitignore \
  AGENTS.md backlog/config.yml repositories/.gitkeep wiki/README.md)"
  assert_equal "$(git -C "${projects}/demo" status --porcelain)" ""
}

@test "new-project fills in the name and the board settings" {
  "${daeshift}" --new-project demo
  run grep --recursive --fixed-strings "@NAME@" "${projects}/demo" \
    --exclude-dir=.git
  assert_equal "${status}" 1
  assert_contains "$(cat "${projects}/demo/AGENTS.md")" "# demo project"
  assert_contains "$(cat "${projects}/demo/AGENTS.md")" \
    "backlog task list --json | jq -r -f .config/next-task.jq"
  run grep --fixed-strings "decision-" "${projects}/demo/backlog/config.yml"
  assert_equal "${status}" 1
  run yq -o=json -I=0 '[.project_name, .default_status, .statuses,
    .projects, .auto_commit, .remote_operations, .bypass_git_hooks,
    .task_prefix, (.definition_of_done | length)]' \
    "${projects}/demo/backlog/config.yml"
  assert_equal "${output}" '["demo","To Do",["To Do","In Progress","Done"],["_project"],false,false,false,"task",11]'
}

@test "new-project ignores clones but keeps repositories/.gitkeep" {
  "${daeshift}" --new-project demo
  mkdir "${projects}/demo/repositories/site"
  touch "${projects}/demo/repositories/site/file"
  assert_equal "$(git -C "${projects}/demo" status --porcelain)" ""
}

@test "new-project prints how to push and start a session" {
  run "${daeshift}" --new-project demo
  assert_equal "${status}" 0
  assert_contains "${output}" "[+] Created project demo in ${projects}/demo"
  assert_contains "${output}" \
    "git -C ${projects}/demo remote add origin URL"
  assert_contains "${output}" \
    "git -C ${projects}/demo push -u origin main"
  assert_contains "${output}" "[+] Start a session with: daeshift --project demo"
}

@test "new-project refuses a machine where daeshift is not set up" {
  rm -r "${projects}"
  run "${daeshift}" --new-project demo
  assert_equal "${status}" 1
  assert_contains "${output}" "daeshift is not set up on this machine."
}

@test "new-project refuses a name that is not plain" {
  run "${daeshift}" --new-project "../demo"
  assert_equal "${status}" 1
  assert_contains "${output}" "'../demo' is not a plain project name."
  assert_equal "$(ls -A "${projects}")" ""
}

@test "new-project refuses an existing folder and leaves it alone" {
  mkdir "${projects}/demo"
  touch "${projects}/demo/mine"
  run "${daeshift}" --new-project demo
  assert_equal "${status}" 1
  assert_contains "${output}" "${projects}/demo already exists."
  assert_equal "$(ls -A "${projects}/demo")" "mine"
}

@test "new-project refuses git with no identity and creates nothing" {
  git config --global --unset user.email
  run "${daeshift}" --new-project demo
  assert_equal "${status}" 1
  assert_contains "${output}" "git has no identity yet"
  assert_equal "$(ls -A "${projects}")" ""
}

@test "new-project uses every template" {
  local file
  local templates=0

  "${daeshift}" --new-project demo
  for file in "${BATS_TEST_DIRNAME}"/../templates/project/*; do
    if [[ "${file##*/}" != "README.md" ]]; then
      templates=$((templates + 1))
    fi
  done
  # Every template, and repositories/.gitkeep.
  assert_equal "$(git -C "${projects}/demo" ls-files | wc -l | tr -d ' ')" \
    "$((templates + 1))"
}

@test "new-project with --add-project or --pull prints the help" {
  run "${daeshift}" --new-project demo --add-project /elsewhere
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
  run "${daeshift}" --new-project demo --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}

@test "new-project with --quiet prints only the remote warning" {
  run "${daeshift}" --quiet --new-project demo
  assert_equal "${status}" 0
  assert_equal "${#lines[@]}" 1
  assert_contains "${output}" "[-] demo has no remote yet."
}

@test "new-project without a name prints the help" {
  run "${daeshift}" --new-project
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
  run "${daeshift}" --new-project ""
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}

@test "new-project's next-task order passes its own check" {
  "${daeshift}" --new-project demo
  cd "${projects}/demo/.config"
  run bash -c 'jq -r -f next-task.jq next-task.test.json \
    | diff - next-task.expected'
  assert_equal "${status}" 0
}
