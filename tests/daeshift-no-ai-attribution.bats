#!/usr/bin/env bats

# Tests for git/hooks/checks/daeshift-no-ai-attribution. Each test gets
# its own home folder with a global git config naming a person as the
# user, and writes the commit message it checks to ~/message.

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
  mkdir -p "${HOME}"
  export GIT_CONFIG_GLOBAL="${HOME}/.gitconfig"
  export GIT_CONFIG_NOSYSTEM=1
  unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME \
    GIT_COMMITTER_EMAIL
  printf '%s\n' '[user]' '  name = Jane Doe' \
    '  email = jane@example.com' > "${GIT_CONFIG_GLOBAL}"
  check="${BATS_TEST_DIRNAME}/../git/hooks/checks/daeshift-no-ai-attribution"
  message="${HOME}/message"
}

@test "daeshift-no-ai-attribution allows a person as co-author" {
  printf '%s\n' 'Fix the parser' '' \
    'Co-Authored-By: John Roe <john@example.com>' > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 0
  assert_equal "${output}" ""
}

@test "daeshift-no-ai-attribution ignores git's comment lines" {
  printf '%s\n' 'Fix the parser' '' \
    '# Co-Authored-By: Claude <noreply@anthropic.com>' > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 0
}

@test "daeshift-no-ai-attribution rejects a Generated with footer" {
  printf '%s\n' 'Fix the parser' '' \
    '🤖 Generated with [Claude Code](https://claude.com/claude-code)' \
    > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "message line 3: 🤖 Generated with"
}

@test "daeshift-no-ai-attribution rejects a pattern a project adds" {
  printf '%s\n' 'Fix the parser' '' 'Written by Robo 3000' > "${message}"
  run "${check}" --pattern 'robo [0-9]+' "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "message line 3: Written by Robo 3000"
}

@test "daeshift-no-ai-attribution rejects aider's author name" {
  printf '%s\n' 'Fix the parser' > "${message}"
  GIT_AUTHOR_NAME="Jane Doe (aider)" run "${check}" "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "author: Jane Doe (aider) <jane@example.com>"
}

@test "daeshift-no-ai-attribution rejects aider's subject prefix" {
  printf '%s\n' 'aider: Fix the parser' > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" "message line 1: aider: Fix the parser"
}

@test "daeshift-no-ai-attribution rejects an AI tool as co-author" {
  printf '%s\n' 'Fix the parser' '' \
    'co-authored-by: Claude Opus 4 <noreply@anthropic.com>' > "${message}"
  run "${check}" "${message}"
  assert_equal "${status}" 1
  assert_contains "${output}" \
    "message line 3: co-authored-by: Claude Opus 4 <noreply@anthropic.com>"
}
