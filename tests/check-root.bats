#!/usr/bin/env bats

setup() {
  CHECK="${BATS_TEST_DIRNAME}/../ci/check-root"
  ROOT="$(mktemp -d)"
}

teardown() {
  rm -rf "${ROOT}"
}

@test "a clean root passes" {
  touch "${ROOT}/README.md"
  run "${CHECK}" "${ROOT}"
  [ "${status}" -eq 0 ]
}

@test "each forbidden name fails and is named in the message" {
  for name in AGENTS.md AGENTS.MD AGENTS.override.md CLAUDE.md CLAUDE.MD \
    backlog .backlog backlog.config.yml .config/conventions.yaml; do
    rm -rf "${ROOT:?}"/* "${ROOT:?}"/.[!.]*
    mkdir -p "$(dirname "${ROOT}/${name}")"
    touch "${ROOT}/${name}"
    run "${CHECK}" "${ROOT}"
    [ "${status}" -eq 1 ] || { echo "not caught: ${name}"; return 1; }
    [[ "${output}" == *"${name} must not be"* ]] || { echo "not named: ${name}"; return 1; }
  done
}

@test "daeshift's own root passes" {
  run "${CHECK}"
  [ "${status}" -eq 0 ]
}
