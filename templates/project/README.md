# Project templates

The files `daeshift --new-project NAME` copies into a new project repo.
In a file whose name ends in `.in`, `@NAME@` is replaced by the
project's name. Files that a tool would pick up where they stand (agent
instructions, the board's settings, `.gitignore` and the hook
configuration) carry other names here, so no tool reads them inside
daeshift. The script also creates `repositories/.gitkeep`; Backlog.md
creates the board's folders and project pull creates `maps/<repo>/`
when they are first needed.

| Template | Destination in the project repo |
|---|---|
| `AGENTS.md.in` | `AGENTS.md` |
| `backlog-config.yml.in` | `backlog/config.yml` |
| `gitignore` | `.gitignore` |
| `next-task.expected` | `.config/next-task.expected` |
| `next-task.jq` | `.config/next-task.jq` |
| `next-task.test.json` | `.config/next-task.test.json` |
| `pre-commit-_code.yaml.in` | `.config/pre-commit/_code.yaml` |
| `pre-commit-_project.yaml.in` | `.config/pre-commit/_project.yaml` |
| `repos.yaml.in` | `.config/repos.yaml` |
| `wiki-README.md.in` | `wiki/README.md` |

Check the next-task order after changing it, from this folder (no
output means it passes):

    jq -r -f next-task.jq next-task.test.json | diff - next-task.expected
