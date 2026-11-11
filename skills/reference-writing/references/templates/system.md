# <System name>

<One sentence: what the system is.> [About <system name>](./explanation.md)
explains why it exists.

```mermaid
flowchart TB
  <how the developer and outside systems use the system's containers>
```

<One or two sentences saying what the diagram shows.>

## Contract

- <What the system guarantees, one item per guarantee, binding.>

## Interface

| Item | Value |
|---|---|
| <Command, file, folder, variable or call> | <Exact form and meaning> |

## Verification

| Contract item | Checked by |
|---|---|
| <Contract item, shortened> | <Test or CI check that proves it, "Not checked", or "Not met today: <how the code differs>. A task is open to decide whether the code or the contract changes."> |

## Containers

```mermaid
C4Container
  title <system name> containers by status
  Person(dev, "Developer")
  System_Boundary(sys, "<system name>") {
    Container(<id>, "<Title>", "<technology>", "<one line>")
    ContainerDb(<id>, "<Title>", "<technology>", "<one line>")
  }
  Rel(<from id>, <to id>, "<verb phrase>")
  UpdateElementStyle(<built id>, $bgColor="#2e7d32", $borderColor="#1b5e20")
  UpdateElementStyle(<partial id>, $bgColor="#f9a825", $fontColor="#000000", $borderColor="#f57f17")
  UpdateElementStyle(<planned id>, $bgColor="#c62828", $borderColor="#8e0000")
  UpdateLayoutConfig($c4ShapeInRow="4", $c4BoundaryInRow="1")
```

The diagram shows the containers in C4 style, colored by status: green
for built, amber for built in part, red for planned. <Counts.>

| Container | Status | Page |
|---|---|---|
| <Title> | Built, Built in part or Planned | [<id>/](./<id>/README.md) |
