---
description: Start of session - rebuild context from the project board, with no earlier history
---
Start this session from the project's records alone. Assume no earlier
conversation.

1. Read the project's AGENTS.md if it is not already in your context.
2. Run `backlog task list --status "In Progress" --plain`, then
   `backlog task view <id> --plain` for each task. Read every note,
   including any HANDOFF note.
3. Find the next ready task with the project's next-task command
   (in AGENTS.md).
4. Check `git status` in the project repository and in each repository
   under `repositories/`: report uncommitted or unpushed work.
5. Report to the developer in the agreed message format: each task in
   progress and where it stands, anything waiting on the developer
   (open pull requests, approvals), and the next task. Ask which to
   work on.
