# Project templates

The files `daeshift --new-project NAME` copies into a new project repo.
A name ending in `.in` has `@NAME@` replaced by the project's name.
The names differ from their destinations so that no tool reads them as
a real board, real hook configuration or real agent instructions.

| Template | Destination in the project repo |
|---|---|
| `AGENTS.md.in` | `AGENTS.md` |
| `backlog-config.yml.in` | `backlog/config.yml` |
| `gitignore.in` | `.gitignore` |
| `next-task.expected` | `.config/next-task.expected` |
| `next-task.jq` | `.config/next-task.jq` |
| `next-task.test.json` | `.config/next-task.test.json` |
| `pre-commit-_code.yaml.in` | `.config/pre-commit/_code.yaml` |
| `pre-commit-_project.yaml.in` | `.config/pre-commit/_project.yaml` |
| `repos.yaml.in` | `.config/repos.yaml` |
| `wiki-README.md.in` | `wiki/README.md` |

Check the next-task order after changing it (no output means it
passes):

    jq -r -f next-task.jq next-task.test.json | diff - next-task.expected
