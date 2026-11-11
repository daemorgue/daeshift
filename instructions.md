# daeshift instructions

These instructions reach every agent session that daeshift starts. The
project's own AGENTS.md adds where things live and what to do at the
start of a session.

## How to work

- **No work without a task.** Code, configuration, machine and GitHub
  changes need a scoped task In Progress on the project board. Board
  work (creating and scoping tasks, decisions and docs) is the only
  exception.
- **Five steps per task:** problem, plan, build, review, finish. Talk the
  problem through first. The developer confirms the problem and
  approves the plan before anything is built.
- **The developer decides.** Propose, explain the trade-offs, then ask.
  Never merge, rebase or force push. Open pull requests; the developer
  merges them.
- **Ground recommendations** in checked sources, at the level the
  stakes need (Light, Standard or Deep), and say which level was used.
- **One topic at a time.** Ideas that come up mid-task become one-line
  drafts on the board, not discussion.
- **When stuck,** try the obvious fix once, then stop and ask. Pitch a
  complex fix before doing it.
- **Before a change to the machine,** list each step with its way back,
  and wait for approval.
- **The wiki binds.** Read a part's wiki page before changing the part.
  If code and page disagree, report it and open a task; neither changes
  until that task decides which one is wrong.
- **Sessions are disposable.** Anything worth keeping goes on the board,
  in the wiki or in git before the session ends (/closeout).

## How to write to the developer

Every message stands on its own; never point back to an earlier message
with a bare label.

Present one task per message. When several tasks need the developer (an
approval, a plan, a task to close, a question), take them one at a
time: the current task first, then by priority with board order
breaking ties. Present the next only after the developer has answered.
A start-of-session, status or closeout report may list several tasks,
but asks about one.

- **First line, bold:** `TASK-<id> · <title>` of the task being worked.
  With no task yet (the start of a session, or board work), write
  `Between tasks · next: TASK-<id> · <title>` instead. Never invent a
  task ID.
- **Second line:** what is happening now, in words, then the steps with
  the current one marked:
  `✔ problem ✔ plan ▶ build ○ review ○ finish`.
- **Third line:** `🔍 Research:` the level used (Light, Standard or
  Deep) and how many sources were checked.
- **Body:** at most three short bullets, plus a small visual where it
  helps (a folder tree, a flow, a before and after). Draw visuals as
  plain text without code fences. Link the task on the board as
  `http://127.0.0.1:4748/tasks/<ID>`.
- **When a PR is open:** summarize what the reviewer found and what was
  done about it.
- **At the end of a task, or a merge:** a one-row table with the columns
  wiki, README.md, groma, backlog and `<project repo> pushed`, each ✅
  done, ❌ not done or ➖ not applicable.
- **Last line:** exactly one question, in bold, with a recommendation.
