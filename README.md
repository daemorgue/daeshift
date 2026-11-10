# daeshift

daeshift sets up daemorgue's day-to-day environment for agent-assisted
development. Clone it onto a new machine, install it, and the tools,
rules and workflow are ready to use.

It builds on three tools:

- [pi] runs the agent sessions, with whichever model suits the work.
- [Backlog.md] tracks the work as Markdown tasks.
- [groma.md] keeps a C4 map of each code repo's architecture.

**Note:** daeshift is in early development. It holds only the empty
pi package so far.

## How work is laid out

Each project is a git repo of its own, the project repo. It holds the
project's board, wiki and architecture maps, and lists its code repos.
The code repos are cloned inside it:

```
~/.daeshift/projects/
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
package.json      declares the pi package
pi/
  extensions/     code that adds commands and checks to pi
  skills/         knowledge pi loads when a task needs it
  prompts/        reusable prompts, run as /commands
  agents/         roles, read by the subagent extension
LICENSE
```

## How to install

There is no install script yet, so these steps are manual. You need
git, Node.js and [pi].

1. Install Backlog.md and groma.md:

```
$ npm install -g backlog.md groma.md
```

2. Clone the project repo that lists daeshift, and daeshift inside it:

```
$ mkdir -p ~/.daeshift/projects
$ git clone git@github.com:daemorgue/daemorgue-context.git ~/.daeshift/projects/daemorgue
$ cd ~/.daeshift/projects/daemorgue
$ git clone git@github.com:daemorgue/daeshift.git repositories/daeshift
```

3. Register daeshift with pi. pi loads it from this folder, so a
   change here takes effect after `/reload`:

```
$ pi install ~/.daeshift/projects/daemorgue/repositories/daeshift
```

4. Start pi at the project root:

```
$ cd ~/.daeshift/projects/daemorgue
$ pi
```

## License

GPL-3.0. See [LICENSE](./LICENSE).

[Backlog.md]: https://github.com/MrLesk/Backlog.md
[groma.md]: https://github.com/MrLesk/groma.md
[pi]: https://pi.dev
