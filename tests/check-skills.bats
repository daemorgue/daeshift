#!/usr/bin/env bats

# Tests for ci/check-skills. Each test gets its own home folder with an
# empty skills folder to fill.

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
  mkdir -p "${HOME}/skills"
  check_skills="${BATS_TEST_DIRNAME}/../ci/check-skills"
}

# Writes skills/$1/SKILL.md with name $2 and description $3.
write_skill() {
  mkdir -p "${HOME}/skills/$1"
  printf -- '---\nname: %s\ndescription: %s\n---\n\n# Body\n' "$2" "$3" \
    > "${HOME}/skills/$1/SKILL.md"
}

@test "check-skills fails a SKILL.md of 500 lines or more" {
  write_skill "long" "long" "Use when testing."
  yes "line" | head -n 500 >> "${HOME}/skills/long/SKILL.md"
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 1
  assert_contains "${output}" "keep it under 500"
}

@test "check-skills fails a description over 1024 characters" {
  write_skill "wordy" "wordy" "$(head -c 1025 < /dev/zero | tr '\0' 'a')"
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 1
  assert_contains "${output}" "description is 1025 characters"
}

@test "check-skills fails a folder with no SKILL.md" {
  mkdir "${HOME}/skills/empty"
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 1
  assert_contains "${output}" "has no SKILL.md"
}

@test "check-skills fails a name that is not lowercase with single hyphens" {
  write_skill "Bash--Testing" "Bash--Testing" "Use when testing."
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 1
  assert_contains "${output}" "must be lowercase letters"
}

@test "check-skills fails a name that does not match its folder" {
  write_skill "bash" "shell" "Use when testing."
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 1
  assert_contains "${output}" "must match its folder"
}

@test "check-skills passes a skill that follows the specification" {
  write_skill "bash-testing" "bash-testing" "Use when testing."
  run "${check_skills}" "${HOME}/skills"
  assert_equal "${status}" 0
  assert_contains "${output}" "1 skills follow the specification"
}
