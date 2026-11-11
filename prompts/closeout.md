---
description: Close out - leave everything on the board and in git so the next session starts cold
---
Close out this session so a new session can start with no history.
Saying /closeout approves the commits and pushes below, never a merge,
a rebase or a force push.

1. For each In Progress task, append a note starting "HANDOFF <date>:"
   with what is done, what is next, what waits on the developer, and
   any open question (`backlog task edit <id> --append-notes ...`).
2. Commit the project repository's changes (board, wiki, maps) and push
   `main`.
3. In each code repository, push the current task branch if it has
   unpushed commits. Never commit to `main`.
4. Report in the agreed message format, ending with the status table:
   wiki, README.md, groma, backlog, project repository pushed.
