# <Project name>

<One sentence: what the project is and which code repositories it
holds.>

```mermaid
flowchart LR
  <the developer, the project repository's board, maps and wiki, and the code repositories it lists>
```

<One or two sentences saying what the diagram shows.>

## Contract

- <What the project guarantees, one item per guarantee, binding.>

## Interface

| Path in the project repository | Holds |
|---|---|
| `backlog/` | The Backlog.md board: tasks, drafts, decisions and documents |
| `maps/<repo>/` | The groma map of one code repository |
| `wiki/` | This wiki, one folder per code repository |
| `.config/repos.yaml` | The code repositories of the project |
| `repositories/<repo>/` | A clone of each code repository, which is not committed |

## Verification

| Contract item | Checked by |
|---|---|
| <Contract item, shortened> | <Check, "Not checked", or "Not met today: …"> |

## Systems

```mermaid
C4Context
  title <Project name> systems by status
  Person(dev, "Developer")
  System(<id>, "<System name>", "<one line>")
  Rel(dev, <id>, "<verb phrase>")
  Rel(<from id>, <to id>, "<verb phrase>")
  UpdateElementStyle(<built id>, $bgColor="#2e7d32", $borderColor="#1b5e20")
  UpdateElementStyle(<partial id>, $bgColor="#f9a825", $fontColor="#000000", $borderColor="#f57f17")
  UpdateElementStyle(<planned id>, $bgColor="#c62828", $borderColor="#8e0000")
```

The diagram shows each code repository's system in C4 style, colored
by status: green for built, amber for built in part, red for planned.
<Counts.>

| System | Repository | Status | Purpose |
|---|---|---|---|
| [<System name>](./<repo>/README.md) | <repo> | Built, Built in part or Planned | <one line> |
