# daeshift

daeshift sets up daemorgue's day-to-day environment for agent-assisted
development. Clone it onto a new machine, install it, and the tools,
rules and workflow are ready to use.

It builds on three tools:

- [pi] runs the agent sessions, with whichever model suits the work.
- [Backlog.md] tracks the work as Markdown tasks.
- [groma.md] keeps a C4 map of each code repo's architecture.

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
`CLAUDE.md`, a Backlog.md board or its config, or
`.config/conventions.yaml`. CI runs `ci/check-root` to enforce this.

## How to install

There is no install script yet, so these steps are manual. You need
git, Node.js and [pi].

1. Install Backlog.md and groma.md:

```
$ npm install -g backlog.md groma.md
```

2. Clone daeshift to `~/.daeshift`. Everything that belongs to your
   machine goes in `~/.daeshift/local/`, which git ignores:

```
$ git clone git@github.com:daemorgue/daeshift.git ~/.daeshift
$ mkdir -p ~/.daeshift/local/projects
$ echo "runner=pi" > ~/.daeshift/local/config
```

3. Clone a project repo into `local/projects/`, and its code repos into
   its `repositories/` folder:

```
$ git clone git@github.com:daemorgue/daemorgue-context.git ~/.daeshift/local/projects/daemorgue
```

4. Add `~/.daeshift/bin` to your `PATH`.

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

## License

GPL-3.0. See [LICENSE](./LICENSE).

[Agent Skills]: https://agentskills.io/specification
[Backlog.md]: https://github.com/MrLesk/Backlog.md
[groma.md]: https://github.com/MrLesk/groma.md
[pi]: https://pi.dev
