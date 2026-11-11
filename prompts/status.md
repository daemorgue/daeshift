---
description: Status - the current task, its step, and what waits on the developer
---
Report the current state in the agreed message format, without changing
anything:

1. The task being worked, its step (problem, plan, build, review,
   finish) and its acceptance criteria checked so far.
2. What waits on the developer: open pull requests (`gh pr list` in each
   code repository), approvals and questions.
3. Uncommitted or unpushed work in the project repository and the code
   repositories.
4. The next task, by the project's next-task command.
