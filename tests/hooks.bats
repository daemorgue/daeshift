#!/usr/bin/env bats

# Tests for git/hooks/pre-commit and commit-msg. Each test gets its own
# home folder with a global git config that applies daeshift's
# git/gitconfig to ~/.daeshift/local/projects/, a project repo "proj"
# with a code repo "code" inside it, and a stand-in pre-commit that
# records its arguments and fails when ~/pre-commit-fails exists. Tests
# of daeshift's own checks replace the stand-in with the real pinned
# pre-commit named in DAESHIFT_TEST_PRE_COMMIT, which CI always sets;
# without it they are skipped.

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

# Commits a new file in repo $1, quietly.
commit_in() {
  touch "$1/file-${RANDOM}"
  git -C "$1" add --all
  git -C "$1" commit --quiet --message "Add a file"
}

setup() {
  # Physical path: on macOS the temporary folder sits behind a link, and
  # git reports physical paths.
  HOME="$(cd "${BATS_TEST_TMPDIR}" && pwd -P)/home"
  export HOME
  export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  unset DAESHIFT_HOME
  project="${HOME}/.daeshift/local/projects/proj"
  code="${project}/repositories/code"
  stub="${HOME}/.daeshift/local/tools/pre-commit/bin/pre-commit"
  mkdir -p "${project}/.config/pre-commit" "${code}" "${stub%/*}"
  # The real git/gitconfig points at ~/.daeshift/git/hooks.
  ln -s "${BATS_TEST_DIRNAME}/../git" "${HOME}/.daeshift/git"
  printf '%s\n' '[user]' '  name = Test' '  email = test@example.com' \
    '[includeIf "gitdir:~/.daeshift/local/projects/"]' \
    '  path = ~/.daeshift/git/gitconfig' > "${GIT_CONFIG_GLOBAL}"
  # The stand-in's own lines must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'call="$* kind=${DAESHIFT_REPO_KIND} name=${DAESHIFT_REPO_NAME}"' \
    'call="${call} root=${DAESHIFT_PROJECT_ROOT}"' \
    'echo "${call}" >> "${HOME}/pre-commit-calls"' \
    'if [[ -e "${HOME}/pre-commit-fails" ]]; then exit 1; fi' > "${stub}"
  chmod +x "${stub}"
  git init --quiet "${project}"
  echo "repositories/" > "${project}/.gitignore"
  git init --quiet "${code}"
}

@test "commit-msg hands pre-commit the message file" {
  touch "${project}/.config/pre-commit/code.yaml"
  commit_in "${code}"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "--hook-stage commit-msg --commit-msg-filename"
}

@test "hooks ignore _code.yaml in the project repo" {
  touch "${project}/.config/pre-commit/_code.yaml"
  commit_in "${project}"
  assert_equal "$(ls "${HOME}/pre-commit-calls" 2>/dev/null)" ""
}

@test "hooks leave a repo outside the projects folder alone" {
  mkdir -p "${HOME}/elsewhere/.config/pre-commit"
  touch "${HOME}/elsewhere/.config/pre-commit/_project.yaml"
  git init --quiet "${HOME}/elsewhere"
  commit_in "${HOME}/elsewhere"
  assert_equal "$(ls "${HOME}/pre-commit-calls" 2>/dev/null)" ""
}

@test "hooks pass a clean commit through daeshift's check" {
  if [[ -z "${DAESHIFT_TEST_PRE_COMMIT:-}" ]]; then
    skip "DAESHIFT_TEST_PRE_COMMIT does not name the pinned pre-commit"
  fi
  ln -sf "${DAESHIFT_TEST_PRE_COMMIT}" "${stub}"
  printf '%s\n' 'repos:' '- repo: local' '  hooks:' \
    '  - id: no-ai-attribution' '    name: no AI attribution' \
    '    entry: daeshift-no-ai-attribution' '    language: unsupported' \
    '    stages: [commit-msg]' > "${project}/.config/pre-commit/code.yaml"
  commit_in "${code}"
  assert_equal "$(git -C "${code}" rev-list --all | wc -l | tr -d ' ')" 1
}

@test "hooks pass valid pre-commit configs with daeshift's check" {
  if [[ -z "${DAESHIFT_TEST_PRE_COMMIT:-}" ]]; then
    skip "DAESHIFT_TEST_PRE_COMMIT does not name the pinned pre-commit"
  fi
  ln -sf "${DAESHIFT_TEST_PRE_COMMIT}" "${stub}"
  printf '%s\n' 'repos:' '- repo: local' '  hooks:' \
    '  - id: check-pre-commit-config' '    name: pre-commit configs' \
    '    entry: daeshift-check-pre-commit-config' \
    '    language: unsupported' \
    "    files: '^\\.config/pre-commit/.*\\.yaml\$'" \
    > "${project}/.config/pre-commit/_project.yaml"
  git -C "${project}" add --all
  git -C "${project}" commit --quiet --message "Add configs"
  assert_equal "$(git -C "${project}" rev-list --all | wc -l | tr -d ' ')" 1
}

@test "hooks reject a commit on main with _code.yaml's branch check" {
  if [[ -z "${DAESHIFT_TEST_PRE_COMMIT:-}" ]]; then
    skip "DAESHIFT_TEST_PRE_COMMIT does not name the pinned pre-commit"
  fi
  ln -sf "${DAESHIFT_TEST_PRE_COMMIT}" "${stub}"
  printf '%s\n' 'repos:' '- repo: local' '  hooks:' \
    '  - id: branch-check' '    name: branch check' \
    '    entry: daeshift-branch-check' '    language: unsupported' \
    '    stages: [pre-commit, pre-merge-commit]' \
    '    pass_filenames: false' '    always_run: true' \
    "    args: [--allow, 'tasks/*']" \
    > "${project}/.config/pre-commit/_code.yaml"
  commit_in "${code}"
  run commit_in "${code}"
  assert_equal "${status}" 1
  assert_contains "${output}" "Commits on"
  assert_equal "$(git -C "${code}" rev-list --all | wc -l | tr -d ' ')" 1
}

@test "hooks reject AI credit with daeshift's check, named by command" {
  if [[ -z "${DAESHIFT_TEST_PRE_COMMIT:-}" ]]; then
    skip "DAESHIFT_TEST_PRE_COMMIT does not name the pinned pre-commit"
  fi
  ln -sf "${DAESHIFT_TEST_PRE_COMMIT}" "${stub}"
  printf '%s\n' 'repos:' '- repo: local' '  hooks:' \
    '  - id: no-ai-attribution' '    name: no AI attribution' \
    '    entry: daeshift-no-ai-attribution' '    language: unsupported' \
    '    stages: [commit-msg]' > "${project}/.config/pre-commit/code.yaml"
  touch "${code}/file"
  git -C "${code}" add --all
  run git -C "${code}" commit --quiet --message "Add a file" \
    --message "Co-Authored-By: Claude <noreply@anthropic.com>"
  assert_equal "${status}" 1
  assert_contains "${output}" "Commit messages credit no one but their author"
  assert_equal "$(git -C "${code}" rev-list --all | wc -l | tr -d ' ')" 0
}

@test "hooks reject an invalid pre-commit config with daeshift's check" {
  if [[ -z "${DAESHIFT_TEST_PRE_COMMIT:-}" ]]; then
    skip "DAESHIFT_TEST_PRE_COMMIT does not name the pinned pre-commit"
  fi
  ln -sf "${DAESHIFT_TEST_PRE_COMMIT}" "${stub}"
  printf '%s\n' 'repos:' '- repo: local' '  hooks:' \
    '  - id: check-pre-commit-config' '    name: pre-commit configs' \
    '    entry: daeshift-check-pre-commit-config' \
    '    language: unsupported' \
    "    files: '^\\.config/pre-commit/.*\\.yaml\$'" \
    > "${project}/.config/pre-commit/_project.yaml"
  echo "repos: not-a-list" > "${project}/.config/pre-commit/code.yaml"
  git -C "${project}" add --all
  run git -C "${project}" commit --quiet --message "Add configs"
  assert_equal "${status}" 1
  assert_contains "${output}" "code.yaml"
  assert_equal "$(git -C "${project}" rev-list --all | wc -l | tr -d ' ')" 0
}

@test "hooks run _code.yaml alone for a code repo with no config of its own" {
  touch "${project}/.config/pre-commit/_code.yaml"
  commit_in "${code}"
  assert_contains "$(head -n 1 "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/_code.yaml"
  assert_equal "$(grep -c "code.yaml --hook-stage" "${HOME}/pre-commit-calls")" 2
}

@test "hooks run _code.yaml before the code repo's own config" {
  touch "${project}/.config/pre-commit/_code.yaml" \
    "${project}/.config/pre-commit/code.yaml"
  commit_in "${code}"
  assert_contains "$(sed -n 1p "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/_code.yaml"
  assert_contains "$(sed -n 2p "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/code.yaml"
}

@test "hooks run nothing for a repo with no config" {
  commit_in "${code}"
  assert_equal "$(ls "${HOME}/pre-commit-calls" 2>/dev/null)" ""
}

@test "hooks run pre-commit with the code repo's config" {
  touch "${project}/.config/pre-commit/code.yaml"
  commit_in "${code}"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/code.yaml"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "--hook-stage pre-commit kind=code name=code"
}

@test "hooks skip the code repo's own config when _code.yaml fails" {
  touch "${project}/.config/pre-commit/_code.yaml" \
    "${project}/.config/pre-commit/code.yaml" "${HOME}/pre-commit-fails"
  run commit_in "${code}"
  assert_equal "${status}" 1
  assert_equal "$(wc -l < "${HOME}/pre-commit-calls" | tr -d ' ')" 1
}

@test "hooks still run the repo's own commit-msg hook with the message" {
  # The own hook's line must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' 'cat "$1" > "${HOME}/own-hook-got"' \
    > "${code}/.git/hooks/commit-msg"
  chmod +x "${code}/.git/hooks/commit-msg"
  commit_in "${code}"
  assert_equal "$(cat "${HOME}/own-hook-got")" "Add a file"
}

@test "hooks still run the repo's own post-commit hook" {
  # The own hook's line must reach its file unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' 'touch "${HOME}/own-post-commit"' \
    > "${code}/.git/hooks/post-commit"
  chmod +x "${code}/.git/hooks/post-commit"
  commit_in "${code}"
  assert_equal "$(ls "${HOME}/own-post-commit")" "${HOME}/own-post-commit"
}

@test "hooks stop the commit when pre-commit fails" {
  touch "${project}/.config/pre-commit/code.yaml" "${HOME}/pre-commit-fails"
  run commit_in "${code}"
  assert_equal "${status}" 1
  assert_equal "$(git -C "${code}" rev-list --all | wc -l | tr -d ' ')" 0
}

@test "hooks stop the commit when the repo's own hook fails" {
  printf '%s\n' '#!/usr/bin/env bash' 'exit 1' > "${code}/.git/hooks/pre-commit"
  chmod +x "${code}/.git/hooks/pre-commit"
  run commit_in "${code}"
  assert_equal "${status}" 1
  assert_equal "$(git -C "${code}" rev-list --all | wc -l | tr -d ' ')" 0
}

@test "hooks use _project.yaml in the project repo" {
  touch "${project}/.config/pre-commit/_project.yaml"
  commit_in "${project}"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/_project.yaml"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "kind=project name=_project"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" "root=${project}"
}

@test "hooks use the main repo's config in a linked worktree" {
  touch "${project}/.config/pre-commit/code.yaml"
  commit_in "${code}"
  git -C "${code}" worktree add --quiet -b tasks/task-1-x "${project}/wt"
  rm "${HOME}/pre-commit-calls"
  commit_in "${project}/wt"
  assert_contains "$(cat "${HOME}/pre-commit-calls")" \
    "--config ${project}/.config/pre-commit/code.yaml"
}
