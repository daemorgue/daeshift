#!/usr/bin/env bats

# Tests for daeshift --add-project and --project NAME --pull
# (libexec/pull). Each test gets its own home folder with a
# DAESHIFT_HOME holding local/projects/ and the yq on PATH as the pinned
# yq (it must be mikefarah's, as CI's pinned tools provide), and three
# source repos on main: demo.git, a project repo that ignores
# repositories/, holds maps for site and blog, and whose repos.yaml lists
# them, and the code repos site and blog. No network is used.

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
  mkdir -p "${BATS_TEST_TMPDIR}/demo.git/maps/site" \
    "${BATS_TEST_TMPDIR}/demo.git/maps/blog"
  touch "${BATS_TEST_TMPDIR}/demo.git/maps/site/index.md" \
    "${BATS_TEST_TMPDIR}/demo.git/maps/blog/index.md"
  list_repos site blog
  daeshift="${BATS_TEST_DIRNAME}/../bin/daeshift"
  projects="${DAESHIFT_HOME}/local/projects"
}

@test "add-project clones the project and every repo it lists" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 0
  assert_contains "${output}" "Project demo is up to date."
  assert_equal "$(ls "${projects}/demo/repositories")" \
    "$(printf 'blog\nsite')"
}

@test "add-project creates the map folder of a repo with no map" {
  git init --quiet --initial-branch=main "${BATS_TEST_TMPDIR}/docs"
  commit_file "${BATS_TEST_TMPDIR}/docs" "first"
  list_repos docs
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 0
  assert_contains "${output}" "docs has no map yet."
  assert_equal "$(ls -d "${projects}/demo/maps/docs")" \
    "${projects}/demo/maps/docs"
  assert_equal "$(git -C "${projects}/demo" status --porcelain)" ""
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
  assert_contains "${output}" "already exists. Pull it with:"
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
  assert_contains "${output}" "Some repos of demo were not pulled."
  assert_equal "$(ls "${projects}/demo/repositories")" \
    "$(printf 'blog\nsite')"
}

@test "add-project sets up each clone" {
  local site="${projects}/demo/repositories/site"

  commit_file "${BATS_TEST_TMPDIR}/site" "AGENTS.md"
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  assert_equal "${status}" 0
  assert_contains "${output}" \
    "Set up ${site}: exclude lines, groma link, AGENTS.override.md"
  assert_equal "$(grep --invert-match '^#' "${site}/.git/info/exclude")" \
    "$(printf 'groma\nAGENTS.md\nAGENTS.override.md\nCLAUDE.md\n.pi/')"
  assert_equal "$(readlink "${site}/groma")" "../../maps/site"
  assert_contains "$(cat "${site}/AGENTS.override.md")" \
    "does not apply in daeshift"
  assert_equal "$(ls "${projects}/demo/repositories/blog/AGENTS.override.md" \
    2>/dev/null)" ""
}

@test "add-project without a URL prints the help and fails" {
  run "${daeshift}" --name demo
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}

@test "pull adds only the missing exclude lines" {
  local exclude="${projects}/demo/repositories/site/.git/info/exclude"

  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  printf '%s\n' "groma" ".pi/" > "${exclude}"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_equal "$(cat "${exclude}")" \
    "$(printf 'groma\n.pi/\nAGENTS.md\nAGENTS.override.md\nCLAUDE.md')"
}

@test "pull clones a repo the project lists since the last pull" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  git init --quiet --initial-branch=main "${BATS_TEST_TMPDIR}/docs"
  commit_file "${BATS_TEST_TMPDIR}/docs" "first"
  list_repos site blog docs
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_equal "$(ls "${projects}/demo/repositories")" \
    "$(printf 'blog\ndocs\nsite')"
}

@test "pull fails for a project that does not exist" {
  run "${daeshift}" --project nowhere --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "No project 'nowhere' in ${projects}."
}

@test "pull fast-forwards the project and its repos" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  commit_file "${BATS_TEST_TMPDIR}/demo.git" "board"
  commit_file "${BATS_TEST_TMPDIR}/site" "feature"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "Fast-forwarded ${projects}/demo"
  assert_equal "$(cat "${projects}/demo/board")" "board"
  assert_equal "$(cat "${projects}/demo/repositories/site/feature")" \
    "feature"
}

@test "pull keeps an AGENTS.override.md that is already there" {
  local site="${projects}/demo/repositories/site"

  commit_file "${BATS_TEST_TMPDIR}/site" "AGENTS.md"
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  echo "mine" > "${site}/AGENTS.override.md"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_equal "$(cat "${site}/AGENTS.override.md")" "mine"
}

@test "pull keeps an ignored file that the upstream starts to track" {
  local site="${projects}/demo/repositories/site"

  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  echo "AGENTS.md" >> "${site}/.git/info/exclude"
  echo "mine" > "${site}/AGENTS.md"
  commit_file "${BATS_TEST_TMPDIR}/site" "AGENTS.md"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 1
  assert_equal "$(cat "${site}/AGENTS.md")" "mine"
}

@test "pull leaves a groma folder alone" {
  local site="${projects}/demo/repositories/site"

  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  rm "${site}/groma"
  mkdir "${site}/groma"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "groma is not a link to ../../maps/site."
  assert_equal "$(find "${site}/groma" -maxdepth 0 -type d)" \
    "${site}/groma"
}

@test "pull reports a clone it cannot fast-forward and pulls the rest" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  commit_file "${projects}/demo/repositories/site" "local"
  commit_file "${BATS_TEST_TMPDIR}/site" "upstream"
  commit_file "${BATS_TEST_TMPDIR}/blog" "upstream"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "repositories/site could not be fast-forwarded"
  assert_equal "$(ls "${projects}/demo/repositories/site/upstream" \
    2>/dev/null)" ""
  assert_equal "$(cat "${projects}/demo/repositories/blog/upstream")" \
    "upstream"
}

@test "pull reports a clone it cannot fetch and pulls the rest" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  mv "${BATS_TEST_TMPDIR}/site" "${BATS_TEST_TMPDIR}/moved"
  commit_file "${BATS_TEST_TMPDIR}/blog" "upstream"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "Fetching ${projects}/demo/repositories/site"
  assert_equal "$(cat "${projects}/demo/repositories/blog/upstream")" \
    "upstream"
}

@test "pull reports a repo folder that is not a clone" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  rm -rf "${projects}/demo/repositories/site"
  mkdir "${projects}/demo/repositories/site"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "repositories/site is not a git clone."
  assert_equal "$(printf '%s\n' "${output}" \
    | grep --count "Fast-forwarded")" "0"
}

@test "pull says nothing on success with --quiet" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  commit_file "${BATS_TEST_TMPDIR}/site" "upstream"
  run "${daeshift}" --quiet --project demo --pull
  assert_equal "${status}" 0
  assert_equal "${output}" ""
}

@test "pull sets up a clone it skips" {
  local site="${projects}/demo/repositories/site"

  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  rm "${site}/groma"
  echo "draft" > "${site}/draft"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "Set up ${site}: groma link"
}

@test "pull skips a clone on another branch" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  git -C "${projects}/demo/repositories/site" switch --quiet \
    --create tasks/task-1-work
  commit_file "${BATS_TEST_TMPDIR}/site" "upstream"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "skipped: it is on 'tasks/task-1-work'"
  assert_contains "${output}" "is pulled, except the skipped repos above."
  assert_equal "$(git -C "${projects}/demo/repositories/site" \
    branch --show-current)" "tasks/task-1-work"
}

@test "pull skips a clone with a detached HEAD" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  git -C "${projects}/demo/repositories/site" switch --quiet --detach
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "skipped: it is on 'a detached HEAD'"
}

@test "pull skips a clone with changes" {
  "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git"
  echo "draft" > "${projects}/demo/repositories/site/draft"
  commit_file "${BATS_TEST_TMPDIR}/site" "upstream"
  run "${daeshift}" --project demo --pull
  assert_equal "${status}" 0
  assert_contains "${output}" "repositories/site skipped: it has changes."
  assert_equal "$(cat "${projects}/demo/repositories/site/draft")" "draft"
  assert_equal "$(ls "${projects}/demo/repositories/site/upstream" \
    2>/dev/null)" ""
}

@test "pull with --add-project prints the help and fails" {
  run "${daeshift}" --add-project "${BATS_TEST_TMPDIR}/demo.git" --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}

@test "pull without --project prints the help and fails" {
  run "${daeshift}" --pull
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}
