#!/usr/bin/env bats

# Tests for daeshift --install, --update and --release
# (libexec/install). Each test gets its own home folder with a source
# repo holding daeshift's files (local/ ignored) and releases v0.1.0 and
# v0.2.0, with one more commit on main, and a fresh clone of it as
# DAESHIFT_HOME. The clone's prerequisites list git and python3, and its
# ci/install-tools only creates DIR/bin. Stand-ins on PATH: python3
# (version 3.13.5; "-m venv DIR" creates DIR/bin/pip) and npm. No
# network is used. set_up_services adds a project "demo" with the repo
# "site", the yq on PATH (mikefarah's) as the pinned yq, and stand-ins:
# node, loginctl (Linger from ~/linger), uname (Linux) and systemctl
# (calls kept in ~/systemctl-calls; is-enabled fails if ~/disabled).

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

# Installs once, then gives the services what they need (see the top of
# this file) and writes config.yaml with the lines given as arguments.
set_up_services() {
  local project="${DAESHIFT_HOME}/local/projects/demo"

  "${daeshift}" --install <<<"y" >/dev/null
  ln -s "$(command -v yq)" "${DAESHIFT_HOME}/local/tools/bin/yq"
  mkdir -p "${project}/.config" "${project}/repositories/site"
  printf '%s\n' 'repos:' '  - name: "site"' '    url: "git@example.com:site"' \
    > "${project}/.config/repos.yaml"
  echo "yes" > "${HOME}/linger"
  # The stand-ins' own lines must reach their files unexpanded.
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' \
    'echo "$*" >> "${HOME}/systemctl-calls"' \
    '[[ "$3" != "is-enabled" || ! -f "${HOME}/disabled" ]]' \
    > "${HOME}/bin/systemctl"
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' 'cat "${HOME}/linger"' \
    > "${HOME}/bin/loginctl"
  printf '%s\n' '#!/usr/bin/env bash' 'echo Linux' > "${HOME}/bin/uname"
  printf '%s\n' '#!/usr/bin/env bash' > "${HOME}/bin/node"
  chmod +x "${HOME}/bin/systemctl" "${HOME}/bin/loginctl" \
    "${HOME}/bin/uname" "${HOME}/bin/node"
  printf '%s\n' "runner: pi" "projects:" "$@" \
    > "${DAESHIFT_HOME}/local/config.yaml"
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
    "${code_dir}/requirements" "${code_dir}/services" "${source}/"
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

@test "install asks for a second run when config.yaml comes before yq" {
  mkdir -p "${DAESHIFT_HOME}/local"
  echo "runner: pi" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "Run daeshift --install again to set up"
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
  assert_equal "$(cat "${DAESHIFT_HOME}/local/config.yaml")" "runner: pi"
  assert_equal "$(ls -d "${DAESHIFT_HOME}/local/projects")" \
    "${DAESHIFT_HOME}/local/projects"
  assert_contains "$(ls "${DAESHIFT_HOME}/local/tools")" "installed-from"
  assert_equal "$(readlink "${DAESHIFT_HOME}/local/tools/bin/tiredize")" \
    "${DAESHIFT_HOME}/local/tools/tiredize/bin/tiredize"
}

@test "install keeps an existing config and projects" {
  mkdir -p "${DAESHIFT_HOME}/local/projects/demo"
  echo "runner: other" > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_equal "$(cat "${DAESHIFT_HOME}/local/config.yaml")" \
    "runner: other"
  assert_equal "$(ls "${DAESHIFT_HOME}/local/projects")" "demo"
}

@test "install leaves configured services alone on a second run" {
  set_up_services "  demo:" "    board: 4748"
  "${daeshift}" --install <<<"y"
  rm "${HOME}/systemctl-calls"
  run "${daeshift}" --install </dev/null
  assert_equal "${status}" 0
  assert_contains "${output}" "Nothing to change."
  assert_equal "$(cat "${HOME}/systemctl-calls")" \
    "--user --quiet is-enabled backlog-demo.service"
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

@test "install refuses a port out of range" {
  set_up_services "  demo:" "    board: 80"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "port '80' of the board of demo is not a number"
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "install refuses a port used twice" {
  set_up_services "  demo:" "    board: 4748" "    repos:" \
    "      site: 4748"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "port 4748 is used twice."
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "install refuses a project that does not exist" {
  set_up_services "  other:" "    board: 4748"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "there is no project 'other'"
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "install refuses a repo not listed in the project's repos.yaml" {
  set_up_services "  demo:" "    repos:" "      blog: 4747"
  mkdir -p "${DAESHIFT_HOME}/local/projects/demo/repositories/blog"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "repo 'blog' is not listed in"
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "install refuses a repo that is not cloned" {
  set_up_services "  demo:" "    repos:" "      site: 4747"
  rmdir "${DAESHIFT_HOME}/local/projects/demo/repositories/site"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "repositories/site does not exist."
}

@test "install refuses a unit it did not write" {
  set_up_services "  demo:" "    board: 4748"
  mkdir -p "${HOME}/.config/systemd/user"
  echo "[Unit]" > "${HOME}/.config/systemd/user/backlog-demo.service"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "was not written by daeshift."
  assert_equal \
    "$(cat "${HOME}/.config/systemd/user/backlog-demo.service")" "[Unit]"
}

@test "install reinstalls the tools when their pins change" {
  "${daeshift}" --install <<<"y"
  echo "an older stamp" > "${DAESHIFT_HOME}/local/tools/installed-from"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "install the pinned tools"
  assert_contains "${output}" "Pinned tools installed"
}

@test "install removes a service no longer configured" {
  set_up_services "  demo:" "    board: 4748" "    repos:" \
    "      site: 4747"
  "${daeshift}" --install <<<"y"
  echo "[Unit]" > "${HOME}/.config/systemd/user/other.service"
  printf '%s\n' "runner: pi" "projects:" "  demo:" "    board: 4748" \
    > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "remove service groma-demo-site.service"
  assert_contains "$(cat "${HOME}/systemctl-calls")" \
    "--user --quiet disable --now groma-demo-site.service"
  assert_equal "$(ls "${HOME}/.config/systemd/user")" \
    "$(printf 'backlog-demo.service\nother.service')"
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

@test "install sets up a configured board and map service" {
  local local_dir="${DAESHIFT_HOME}/local"
  local unit

  set_up_services "  demo:" "    board: 4748" "    repos:" \
    "      site: 4747"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "set up service backlog-demo.service on port"
  unit="$(cat "${HOME}/.config/systemd/user/groma-demo-site.service")"
  assert_contains "${unit}" \
    "WorkingDirectory=${local_dir}/projects/demo/repositories/site"
  assert_contains "${unit}" "Environment=\"PATH=${local_dir}/tools/node/"
  assert_contains "${unit}" ":${HOME}/bin:/usr/local/bin:/usr/bin:/bin\""
  assert_contains "${unit}" "/node_modules/.bin/groma\" web --port 4747"
  unit="$(cat "${HOME}/.config/systemd/user/backlog-demo.service")"
  assert_contains "${unit}" "WorkingDirectory=${local_dir}/projects/demo"$'\n'
  assert_contains "${unit}" "Environment=\"PATH=${local_dir}/tools/node/"
  assert_contains "${unit}" \
    "/node_modules/.bin/backlog\" browser --no-open --port 4748"
  assert_contains "$(cat "${HOME}/systemctl-calls")" \
    "--user restart backlog-demo.service"
}

@test "install sets up no service on a machine without systemd" {
  set_up_services "  demo:" "    board: 4748"
  printf '%s\n' '#!/usr/bin/env bash' 'echo Darwin' > "${HOME}/bin/uname"
  run "${daeshift}" --install </dev/null
  assert_equal "${status}" 0
  assert_contains "${output}" "they need systemd, which this machine lacks"
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "install starts a configured service that is not enabled" {
  set_up_services "  demo:" "    board: 4748"
  "${daeshift}" --install <<<"y"
  touch "${HOME}/disabled"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "start service backlog-demo.service"
}

@test "install updates a service whose port changed" {
  set_up_services "  demo:" "    board: 4748"
  "${daeshift}" --install <<<"y"
  printf '%s\n' "runner: pi" "projects:" "  demo:" "    board: 4750" \
    > "${DAESHIFT_HOME}/local/config.yaml"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "update service backlog-demo.service"
  assert_contains \
    "$(cat "${HOME}/.config/systemd/user/backlog-demo.service")" \
    "--port 4750"
}

@test "install warns when linger is off" {
  set_up_services "  demo:" "    board: 4748"
  echo "no" > "${HOME}/linger"
  run "${daeshift}" --install <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "sudo loginctl enable-linger"
}

@test "release checks out an older release to roll back" {
  "${daeshift}" --install <<<"y"
  run "${daeshift}" --release v0.1.0 <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "check out release v0.1.0"
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.1.0"
}

@test "release refuses a release from before the installer" {
  local source="${BATS_TEST_TMPDIR}/source"

  "${daeshift}" --install <<<"y"
  git -C "${source}" switch --quiet --create old v0.1.0
  git -C "${source}" rm -r --quiet libexec
  commit_all "${source}" "no installer yet"
  git -C "${source}" tag v0.0.5
  run "${daeshift}" --release v0.0.5 <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "Release v0.0.5 has no daeshift --install"
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.2.0"
}

@test "release refuses a release that does not exist" {
  "${daeshift}" --install <<<"y"
  run "${daeshift}" --release v9.9.9 <<<"y"
  assert_equal "${status}" 1
  assert_contains "${output}" "No release v9.9.9."
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.2.0"
}

@test "release without a tag prints the help and fails" {
  run "${daeshift}" --release
  assert_equal "${status}" 1
  assert_contains "${output}" "Usage: daeshift"
}

@test "update changes nothing when the answer is not yes" {
  "${daeshift}" --install <<<"y"
  git -C "${BATS_TEST_TMPDIR}/source" tag v0.3.0
  run "${daeshift}" --update <<<"n"
  assert_equal "${status}" 1
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.2.0"
}

@test "update checks out a newer release" {
  "${daeshift}" --install <<<"y"
  git -C "${BATS_TEST_TMPDIR}/source" tag v0.3.0
  run "${daeshift}" --update <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "check out release v0.3.0"
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.3.0"
}

@test "update leaves services for the run after a release" {
  set_up_services "  demo:" "    board: 4748"
  git -C "${BATS_TEST_TMPDIR}/source" tag v0.3.0
  run "${daeshift}" --update <<<"y"
  assert_equal "${status}" 0
  assert_contains "${output}" "Run daeshift --install again to set up"
  assert_equal "$(ls "${HOME}/.config/systemd/user" 2>/dev/null)" ""
}

@test "update moves a fresh clone to a release made after the clone" {
  local source="${BATS_TEST_TMPDIR}/source"

  echo "fourth" > "${source}/fourth"
  commit_all "${source}" "fourth"
  git -C "${source}" tag v0.3.0
  run "${daeshift}" --update <<<"y"
  assert_equal "${status}" 0
  assert_equal "$(git -C "${DAESHIFT_HOME}" describe --tags)" "v0.3.0"
}

@test "update on the newest release changes nothing" {
  "${daeshift}" --install <<<"y"
  run "${daeshift}" --update </dev/null
  assert_equal "${status}" 0
  assert_contains "${output}" "Nothing to change."
}
