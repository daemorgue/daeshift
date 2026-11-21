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
services/        templates for the board and map services
  systemd/        as systemd user units, for Linux
  launchd/        as user LaunchAgents, for macOS
templates/project/
                  the files a new project starts from
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
   your system's package manager, so they're on `PATH` in your own
   shell. A copy bundled with another tool doesn't count, such as pi's
   own `node`. daeshift's git hooks and the `backlog` and `groma`
   commands also run outside pi. daeshift checks these programs, but
   never installs them.

2. Clone daeshift to `~/.daeshift`, then run its installer:

   ```
   $ git clone https://github.com/daemorgue/daeshift.git ~/.daeshift
   $ ~/.daeshift/bin/daeshift --install
   ```

   The installer checks the clone and the prerequisites, lists every
   change it will make, and asks before making them. On a fresh clone
   it checks out the newest release. It creates `~/.daeshift/local/`,
   which git ignores, and installs the pinned tools there. It also
   turns on daeshift's git hooks for every repo under
   `~/.daeshift/local/projects/`, with one setting in your global git
   config. Running it again changes nothing.

3. Add the `PATH` line the installer prints to your shell profile. If
   git has no name and email yet, set them as the installer says.

4. Add a project. daeshift clones its project repo into
   `local/projects/`, then each code repo the project lists into its
   `repositories/` folder. It also sets each clone up. Git ignores the
   files agent tools write there, and a `groma` link points to the
   repo's map. `--name` sets the project's name; without it, the name
   comes from the URL:

   ```
   $ daeshift --add-project git@github.com:daemorgue/daemorgue-context.git --name daemorgue
   ```

   Later, `daeshift --project daemorgue --pull` brings the project and
   its code repos up to date. It only fast-forwards: a repo with
   changes or on another branch is skipped and left as it is.

## How to create a project

`--new-project` makes a new project repo in `local/projects/`, with an
empty board, the Definition of Done, a wiki start page, the next-task
command and the git hook settings. It commits once and doesn't touch
the network:

```
$ daeshift --new-project demo
```

To share it, create an empty repository on your Git host, then add it
as the remote and push, as the command prints:

```
$ git -C ~/.daeshift/local/projects/demo remote add origin git@github.com:you/demo.git
$ git -C ~/.daeshift/local/projects/demo push -u origin main
```

Then, beyond what the command prints, record the remote's default
branch. Without it, `--pull` fails on the project with "has no default
branch for origin":

```
$ git -C ~/.daeshift/local/projects/demo remote set-head origin --auto
```

To add code repos, list each in its `.config/repos.yaml` and in
`projects` in `backlog/config.yml`, commit and push, then run
`daeshift --project demo --pull` to clone them.

## How to start a session

```
$ daeshift --list-projects
daemorgue
$ daeshift --project daemorgue
```

`daeshift --project` starts the agent tool named by `runner:` in
`~/.daeshift/local/config.yaml` (only `pi` so far), in the project's folder,
with daeshift's instructions, skills and prompts. You can set
`DAESHIFT_HOME` to keep `local/` somewhere other than `~/.daeshift`, but
daeshift's git hooks then don't run, because they only look in
`~/.daeshift/local/projects/`.

## How to serve the board and maps

daeshift can run each project's board and each code repo's map as a
service, so you can open them in a browser: a systemd user service on
Linux, a user LaunchAgent on macOS. Give each one a port of its own in
`~/.daeshift/local/config.yaml`:

```yaml
runner: pi
projects:
  daemorgue:
    board: 4748
    repos:
      daeshift: 4747
```

Then run `daeshift --install`. It checks each project and repo, lists
the services to set up, update or remove, and asks first. On Linux, to
keep them running after you log out, run the `sudo loginctl
enable-linger` command it prints; daeshift never runs sudo itself. On
macOS, the services start when you log in and stop when you log out.

## How to update

```
$ daeshift --update
```

The update checks out the newest release, asking first, and installs
the pinned tools again when their pins changed. To go back to an
earlier release, name it, such as `daeshift --release v0.5.0`. daeshift
can't go back further than the first release with `daeshift
--install`.

## Learn more

The daemorgue project wiki, in `wiki/daeshift/` of the
daemorgue-context repo, describes the git hooks and their checks and
the pinned tools. It also has how-to guides for adding a check and
updating a pin.

## License

GPL-3.0. See [LICENSE](./LICENSE).

[Agent Skills]: https://agentskills.io/specification
[Backlog.md]: https://github.com/MrLesk/Backlog.md
[groma.md]: https://github.com/MrLesk/groma.md
[pi]: https://pi.dev
[pre-commit]: https://pre-commit.com/
