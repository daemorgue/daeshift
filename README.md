# daeshift

daeshift sets up daemorgue's day-to-day environment for agent-assisted
development. Clone it onto a new machine, install it, and the tools,
rules and workflow are ready to use.

It builds on four tools:

- [pi] runs the agent sessions, with whichever model suits the work.
- [Backlog.md] tracks the work as Markdown tasks.
- [groma.md] keeps a C4 map of each code repo's architecture.
- [pre-commit] runs each repo's commit checks, from a per-repo config
  kept in its project repo.

**Note:** daeshift is in early development. Its folders are laid out,
but mostly empty so far.

## How work is laid out

Each project is a git repo of its own, the project repo. It holds the
project's board, wiki and architecture maps, and lists its code repos.
The code repos are cloned inside it:

```
~/.daeshift/local/projects/
  <project>/                  the project repo
    backlog/                  the Backlog.md board
    wiki/                     how the project works
    maps/<repo>/              each code repo's groma map
    .config/repos.yaml        the project's code repos
    repositories/<repo>/      each code repo, cloned here
```

Code repos hold only code. Agent instructions come from daeshift and
from the project repo, never from a file committed to a code repo.

## What is in this repo

```
instructions.md   instructions every session receives
skills/           knowledge an agent loads when a task needs it
prompts/          reusable prompts, run as /commands
runners/
  pi/             the parts only pi understands
    extensions/   code that adds commands and checks to pi
    agents/       roles, read by the subagent extension
ci/check-root     the check that keeps the root free of instruction files
tests/            tests for daeshift's scripts
LICENSE
```

The top-level parts work with any agent tool: skills follow the open
[Agent Skills] format, and instructions and prompts are plain
Markdown. Anything only one tool understands lives in
`runners/<tool>/`, so trying another tool means adding a folder there.

### Nothing at the root that tools search for

Projects are kept inside daeshift's folder, and agent tools read
instruction files such as `AGENTS.md` from every folder above the one
they start in. A file like that at daeshift's root would reach every
session in every project. So the root never holds `AGENTS.md`,
`CLAUDE.md`, or a Backlog.md board or its config. CI runs
`ci/check-root` to enforce this.

## How to install

1. Install the programs listed in
   [`requirements/prerequisites`](./requirements/prerequisites) with
   your system's package manager. daeshift checks them, but never
   installs them.

2. Clone daeshift to `~/.daeshift`, then run its installer:

```
$ git clone https://github.com/daemorgue/daeshift.git ~/.daeshift
$ ~/.daeshift/bin/daeshift --install
```

   The installer checks the clone and the prerequisites, lists every
   change it will make, and asks before making them. On a fresh clone
   it checks out the newest release. It creates `~/.daeshift/local/`,
   which git ignores, and installs the [pinned tools](#pinned-tools)
   there. Running it again changes nothing.

3. Add the `PATH` line the installer prints to your shell profile. If
   git has no name and email yet, set them as the installer says.

4. Clone a project repo into `local/projects/`, and its code repos into
   its `repositories/` folder:

```
$ git clone git@github.com:daemorgue/daemorgue-context.git ~/.daeshift/local/projects/daemorgue
```

## How to start a session

```
$ daeshift --list-projects
daemorgue
$ daeshift --project daemorgue
```

`daeshift --project` starts the agent tool named by `runner=` in
`~/.daeshift/local/config` (only `pi` so far), in the project's folder,
with daeshift's instructions, skills and prompts. Set `DAESHIFT_HOME`
to keep `local/` somewhere other than `~/.daeshift`.

## Git hooks

daeshift checks every commit in a repo under
`~/.daeshift/local/projects/`. One entry in `~/.gitconfig` turns this
on for that folder only:

```
[includeIf "gitdir:~/.daeshift/local/projects/"]
  path = ~/.daeshift/git/gitconfig
```

At each commit and push, daeshift's hook finds the repo's project and
hands the hook to [pre-commit] (at the `pre-commit`, `pre-merge-commit`,
`commit-msg` and `pre-push` stages), using the repo's configs from the
project repo:

```
<project>/.config/pre-commit/_code.yaml       every code repo, run first
<project>/.config/pre-commit/<repo>.yaml      one code repo, run next
<project>/.config/pre-commit/_project.yaml    the project repo itself
```

Put a rule every code repo shares in `_code.yaml`, once; a repo's own
file holds only what that repo adds.

A hook runs when it is listed in that file, with its settings; remove it
from the file to turn it off. The same file serves both the pre-commit
and commit-msg stages, so give each hook its `stages:` (or set
`default_stages: [pre-commit]` at the top), or a file check would also
run on the commit message. A repo with no file runs no daeshift hooks.
A linked worktree uses its main repo's file. A merge without conflicts
runs the pre-merge-commit stage instead of pre-commit. daeshift's hooks
need git 2.31 or later.

Hooks can read `DAESHIFT_PROJECT_ROOT` (the project folder),
`DAESHIFT_REPO_KIND` (`project` for the project repo, `code` for a code
repo) and `DAESHIFT_REPO_NAME` (the repo's name, or `_project`).

daeshift ships its own checks in `git/hooks/checks/`. The hook puts
that folder on `PATH`, so a config names a check by its command alone,
as a local hook:

```yaml
repos:
  - repo: local
    hooks:
      - id: no-ai-attribution
        name: no AI attribution
        entry: daeshift-no-ai-attribution
        language: unsupported
        stages: [commit-msg]
```

| Check | Stage | What it does |
|-------|-------|--------------|
| `daeshift-branch-check` | `pre-commit`, `pre-merge-commit`, `pre-push` | Rejects a commit on a branch matching a `--deny` glob, or matching no `--allow` glob when any is given; with neither, `main` and `master` are denied. Globs match like GitHub's rulesets: `*` and `?` never match `/`, `**/` matches any folders; character classes are not supported. A new repo's first commit, and a detached HEAD during a rebase or bisect, pass. When a `tasks/` branch would be allowed, the message suggests one. Give it `pass_filenames: false` and `always_run: true`. At `pre-push` it checks the local branch being pushed, or the checked-out branch for `git push origin HEAD`; in a push of several branches, pre-commit judges only the first with commits the remote lacks. |
| `daeshift-task-check` | `pre-commit`, `pre-merge-commit`, `pre-push` | In a code repo, rejects a commit unless the branch `tasks/task-<id>-<slug>` names a task on the project's board that is In Progress, has acceptance criteria, belongs to this repo, has no subtasks and waits on no unfinished dependency of its own (a parent's dependencies don't count). Fails closed when the board cannot be read. Needs `git`, `backlog` and `jq`. Give it `pass_filenames: false` and `always_run: true`. Like every local hook, `git commit --no-verify` skips it; the PR check on GitHub (planned) will be the gate. At `pre-push` it checks the local branch being pushed, or the checked-out branch for `git push origin HEAD`; in a push of several branches, pre-commit judges only the first with commits the remote lacks. |
| `daeshift-check-pre-commit-config` | `pre-commit` | Validates pre-commit config files with daeshift's pinned pre-commit. Add it to the project repo's `_project.yaml` like the example above, with `files: '^\.config/pre-commit/.*\.yaml$'` and `stages: [pre-commit]`. |
| `daeshift-parent-status` | `pre-commit` | In the project repo, rejects a commit while a parent task's status does not follow its subtasks (In Progress while any is, Done when all are, To Do otherwise) or a parent lacks the label `parent`. Needs `backlog` and `jq`. Give it `pass_filenames: false` and `always_run: true`. |
| `daeshift-commit-prefix` | `commit-msg` | Rejects a commit whose subject does not start with `TASK-<id>:`. In `_code.yaml` give it `--match-branch`, so the ID must be the branch's task; in `_project.yaml` give it `--allow-board --on-board`, so `Board:` is also accepted and the task must be on the board. The subject after `fixup!`, `squash!` or `amend!`, and inside `Revert "…"` or `Reapply "…"`, is checked the same way. Merge commits and a new repo's first commit are exempt. |
| `daeshift-no-ai-attribution` | `commit-msg` | Rejects a commit message that credits anyone besides its author: any `Co-Authored-By`, `Assisted-by`, `Generated-by`, `Made-with` or `Amp-Thread-ID` trailer, whatever it names, and Claude Code's "Generated with" footer. Credit people on GitHub instead, where squash merges add their own trailers; amending such a commit on this machine is rejected too. |

The checks only run through daeshift's hook; `pre-commit run` on its
own cannot find them. A config that names a check the installed
release lacks fails every commit, so turn a new check on only after
installing the release that has it.

A repo's own hooks in `.git/hooks/` still run, for the hooks git calls
on a working clone: applypatch-msg, commit-msg, post-applypatch,
post-checkout, post-commit, post-merge, post-rewrite, pre-applypatch,
pre-auto-gc, pre-commit, pre-merge-commit, pre-push, pre-rebase,
prepare-commit-msg and sendemail-validate. Not covered: hooks git calls
very often (`reference-transaction`, `post-index-change`), hooks for
repos that receive pushes (`pre-receive`, `update`, `post-receive`,
`post-update`, `proc-receive`, `push-to-checkout`) and Perforce's
`p4-*` hooks.

pre-commit must be daeshift's own pinned copy, at
`$DAESHIFT_HOME/local/tools/pre-commit/bin/pre-commit` (by default under
`~/.daeshift`); one on `PATH` is not used.

A repo that sets its own `core.hooksPath`, as husky does, overrides
daeshift's hooks entirely. If you set `DAESHIFT_HOME`, write the
`includeIf` path as `$DAESHIFT_HOME/local/projects/` in full, and set
the variable for every shell that runs git.

## Pinned tools

Every tool daeshift installs, in CI or on a machine, is pinned, by hash
where possible (decision-9 on the daemorgue board). Tools a machine
already shares with other software are prerequisites, listed in
[`requirements/prerequisites`](./requirements/prerequisites): they are
checked, not installed.

| Tools | Pinned in | How |
|-------|-----------|-----|
| bats, ShellCheck, yq | `ci/install-tools` | bats at a git commit; the others as downloads checked against their SHA-256 |
| pre-commit, tiredize | `requirements/*.txt` | every package, nested ones included, with hashes |
| backlog.md, groma.md | `requirements/npm/package-lock.json` | npm's integrity hash for every package |
| GitHub Actions | `.github/workflows/` | full commit SHA, version in a comment |

`daeshift --install` installs them into `~/.daeshift/local/tools/`,
and installs them again whenever a release changes a pin.

`--only-binary :all:` means nothing is built from source, so no unpinned
build tools are fetched, and `--ignore-scripts` means no package runs
code while installing.

Updating a pin:

- **bats, ShellCheck, yq:** change the version and its commit or
  SHA-256 at the top of `ci/install-tools`. yq lists SHA-256 values in
  its release's `checksums` file. ShellCheck publishes none: download
  the release and run `shasum -a 256` on it.
- **Python tools:** change the version in `requirements/<tool>.in`,
  then regenerate the `.txt` with pip-tools, in a throwaway
  virtualenv:

  ```
  $ python3 -m venv /tmp/pip-tools
  $ /tmp/pip-tools/bin/pip install pip-tools
  $ /tmp/pip-tools/bin/pip-compile --generate-hashes --strip-extras \
      --no-header --output-file requirements/<tool>.txt \
      requirements/<tool>.in
  ```

- **npm tools:** change the version in `requirements/npm/package.json`,
  then run `npm install --package-lock-only --ignore-scripts` in that
  folder.

- **GitHub Actions:** replace the commit SHA and the version in the
  comment after it, in every workflow that uses the action.

Commit the changed files together, so the PR shows every new version
and hash. Dependabot will make these updates itself once it is set up
(TASK-4.5 on the daemorgue board).

The Python files are resolved for Python 3.11 and later; CI checks that
they still install there. Pinned downloads in `ci/install-tools` exist
for Linux x86_64, Linux aarch64 and macOS arm64 only.

## License

GPL-3.0. See [LICENSE](./LICENSE).

[Agent Skills]: https://agentskills.io/specification
[Backlog.md]: https://github.com/MrLesk/Backlog.md
[groma.md]: https://github.com/MrLesk/groma.md
[pi]: https://pi.dev
[pre-commit]: https://pre-commit.com/
