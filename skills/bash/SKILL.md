---
name: bash
description: Conventions for writing bash scripts that run on Linux and macOS, covering platform limits, layout, naming, options, output, control flow, errors and linting. Use when writing, changing or reviewing a bash script, alongside software-design. For tests, also load bash-testing.
---

# Bash

Bash is for glue: running other programs and passing their output on.
When the work needs real data structures, networking or speed, it
belongs in another language.

Starting a new script: copy `references/template` and fill it in.
Read `references/sources.md` only when asked why a rule exists.

## Platform

- Run on bash 3.2, the version macOS ships. Do not use associative
  arrays (`declare -A`), `mapfile`, `readarray`, `${var,,}`,
  `${var^^}` or `|&`.
- Run on Linux (GNU commands) and macOS (BSD commands): use only
  options both accept. Traps: `sed -i`, `grep -P`, `readlink -f`,
  `date -d`, `stat -c`.
- Read YAML and other structured data with mikefarah's `yq`, never by
  parsing it in bash.

## File

- First line: `#!/usr/bin/env bash`. No file extension.
- Then a comment saying what the script does and how to run it.
- Then exactly these two settings:

  ```bash
  set -o nounset
  set -o pipefail
  ```

- Never use `set -o errexit` (`set -e`). Handle each failure
  explicitly (see Errors).

## Layout

- Indent 2 spaces. No tabs.
- Lines at most 80 characters.
- Break a long command with a trailing `\`, indenting the rest 2 more
  spaces. A pipeline that does not fit on one line has one command per
  line.

## Names and variables

- Full words in `snake_case`: `config_path`, not `cfg`.
- Constants in `UPPER_SNAKE_CASE`, marked `readonly`.
- Quote every expansion and use braces: `"${name}"`. An unquoted
  expansion needs a comment saying why.
- Every variable in a function is `local`. When the value comes from
  `$(...)`, declare and assign on separate lines, or the failure of the
  command is lost:

  ```bash
  local name
  name="$(read_name)" || return 1
  ```

## Functions and main

- Name functions with a verb and full words: `create_config_file`.
- All work starts in a function named `main`, and the last line of the
  script is `main "$@"`.
- Shared helpers may sit first, between `### Helpers begin` and
  `### Helpers end`. Everything else follows in alphabetical order
  (software-design).
- A function that is not both obvious and short gets a comment above
  it: what it does, what `$1`, `$2`… are, and what it prints or
  returns.

## Options and help

- Every script has a `usage` function that prints the help text and
  exits with the code it is given. Layout:

  ```
  Usage: name [OPTIONS] ARGUMENT

  DESCRIPTION
      One or two lines.

  OPTIONS
      -h, --help       Display this help message
      -q, --quiet      Show only warnings and errors
  ```

- Read options in one `while [[ $# -gt 0 ]]` loop with a `case` on
  `"$1"`, inside `main`. Every script accepts `-h`/`--help` and
  `-q`/`--quiet`, and `--` ends the options.
- An unknown option prints the help text to stderr and exits 1.

## Output

Messages go through these helpers, each with its prefix. Define only
the ones used:

| Helper | Prefix | For | Goes to |
|--------|--------|-----|---------|
| `good` | `[+]` | something finished | stdout |
| `info` | `[*]` | what is happening now | stdout |
| `warn` | `[-]` | worth knowing, script goes on | stdout |
| `err` | `[!]` | something failed | stderr |

With `-q`, `good` and `info` print nothing. `warn` and `err` always
print.

## Control flow

- A decision is an `if` block. Never chain `a && b || c`: `c` runs when
  `b` fails. A single `|| return 1` or `|| exit 1` is not a decision.
- Tests use `[[ ... ]]`, never `[ ... ]` or `test`.
- Read lines with `while IFS= read -r line`. Feed a loop from a command
  with `done < <(command)`, not a pipe, so variables keep their values.
- Never use `eval`.
- Give wildcards an explicit path: `./*`, not `*`, so a file named
  `-rf` is not read as an option.

## Idioms

These short forms may be used anywhere:

| Idiom | Means |
|-------|-------|
| `err() { echo "[!] $*" >&2; }` | one-line helper whose name says it all |
| `command \|\| return 1` | stop here if `command` fails, keeping its message |
| `cat <<'EOF'` … `EOF` | print lines as written (unquoted `EOF` fills in variables) |
| `command <<<"${text}"` | feed one string to `command` |
| `for item in "${list[@]}"` | every item of an array; on bash 3.2 it must not be empty |
| `[[ "${text}" =~ ${pattern} ]]` | regular expression match; keep the pattern in a variable, unquoted |
| `"${path##*/}"` | the last part of a path, without running `basename` |
| `"${path%/}"` | the path without a trailing `/` |
| `"${#text}"` | length of `text` |
| `command >/dev/null 2>&1` | run `command` silently |

## Commands

- Use `$(...)`, never backticks.
- Use a command's long option where both GNU and BSD accept it
  (`grep --quiet`). Otherwise use the short option both accept, with a
  comment if its meaning is not obvious.
- Prefer a builtin to a separate program when it does the same job.

## Errors

- A failure stops the function or script: `|| return 1` when the
  command's own message is enough, or an `if` block that calls `err`
  when it is not (software-design, Errors).
- Messages say what failed and what to do:
  `[!] yq was not found. Install mikefarah's yq: https://...`
- List every outside program the script runs in a plain array named
  `dependencies` near the top, and check them all before any work,
  reporting every missing one before exiting 1.

## Linting

- Every script passes ShellCheck with no warnings.
- A warning may be turned off for one line only, with a comment above
  saying why.

## Gotchas

- `set -e` crept back in by habit: remove it.
- `local x="$(cmd)"` hides `cmd` failing. Declare first, then assign.
- `"${1:-$(cmd)}"` both hides a failure and packs a decision into an
  expansion. Use an `if` block that sets the variable.
- A script with no `usage`, `-h` or `-q` is not finished.
