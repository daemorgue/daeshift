# <Container Title>

<One sentence: what the container does.> [About <topic>](./explanation.md)
gives the background.

```mermaid
sequenceDiagram
  <the calls that cross the container's boundary, in order>
```

<One or two sentences saying what the diagram shows.>

## Contract

1. **<Topic>.** <Binding behavior, detailed enough to rebuild the
   container identically at the user's end in any language: inputs,
   outputs, options, exit statuses, files and formats, environment
   variables, interprocess calls.>

## Interface

| Item | Value |
|---|---|
| <Path, command, variable or exit status> | <Exact form and meaning> |

## Verification

| Contract item | Checked by |
|---|---|
| 1. <Topic> | <Test or check, "Partly: …" naming the gaps, "Not checked", or "Not met today: …"> |

## Components

```mermaid
C4Component
  title <Container Title> components by status
  Container_Boundary(<container id>, "<Container Title>") {
    Component(<id>, "<Title>", "<technology>", "<one line>")
  }
  Rel(<from id>, <to id>, "<verb phrase>")
  UpdateElementStyle(<built id>, $bgColor="#2e7d32", $borderColor="#1b5e20")
  UpdateElementStyle(<planned id>, $bgColor="#c62828", $borderColor="#8e0000")
  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

The diagram shows the components in C4 style, colored by status:
green for built, amber for built in part, red for planned. <Counts.>

| Component | Status |
|---|---|
| <Title> | Built, Built in part or Planned |
