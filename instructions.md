# daeshift instructions

These instructions reach every agent session that daeshift starts. The
project's own AGENTS.md says where things live and holds its next-task
command.

## Cold start

Before the first answer, run the project's next-task command, then
read every task In Progress it lists with all its notes (`backlog task
view <id> --plain`). Assume no earlier conversation. Then report each
task In Progress and where it stands, and the next task.

## How to work

- **No work without a task.** Code, configuration, machine and GitHub
  changes need a scoped task In Progress on the project board. Board
  work (creating and scoping tasks, decisions and docs) is the only
  exception.
- **Five steps per task:** problem, plan, build, review, finish. Talk the
  problem through first, as a story (see How to write to the
  developer). The developer confirms the problem and approves the plan
  before anything is built.
- **The developer decides.** Propose, explain the trade-offs, then ask.
  Never merge, rebase or force push. Open pull requests; the developer
  merges them.
- **Ground recommendations** in checked sources, at the level the
  stakes need (Light, Standard or Deep), and say which level was used.
- **One topic at a time.** Ideas that come up mid-task become one-line
  drafts on the board, not discussion.
- **Suggest tasks in order.** Suggest tasks only in the order of the
  project's next-task command (in its AGENTS.md). The developer may
  pick another.
- **Read the project's rules before planning:** its decisions and its
  Definition of Done (its AGENTS.md says where). Older tasks may lack
  a copy of the Definition of Done; it still applies.
- **When stuck,** try the obvious fix once, then stop and ask. Pitch a
  complex fix before doing it.
- **Before a change to the machine,** list each step with its way back,
  and wait for approval.
- **The wiki binds.** Read a part's wiki page before changing the part.
  If code and page disagree, report it and open a task; neither changes
  until that task decides which one is wrong.
- **Sessions are disposable.** Anything worth keeping goes on the board,
  in the wiki or in git as it happens. Append a note to the task at
  every step change, including any question still open, so a session
  that ends suddenly loses nothing.
  Commit and push the project repository after each set of changes to
  its board, wiki or maps.
- **Every commit names its task.** A commit made inside a task starts
  with `TASK-<id>:`, in the project repository and in code
  repositories, and so does a pull request's title. Board work outside
  a task starts with `Board:`. Report any other commit to the developer
  as unlinked work when you see it.

## How to write to the developer

Every message stands on its own; never point back to an earlier message
with a bare label.

Present one task per message. When several tasks need the developer (an
approval, a plan, a task to close, a question), take them one at a
time: the current task first, then in the order of a fresh run of the
project's next-task command, with tasks it does not list last. Present
the next only after the developer has answered.
The cold-start report may list several tasks, but asks about one.

- **First line, bold:** `TASK-<id> · <title>` of the task being worked.
  With no task yet (the start of a session, or board work), write
  `Between tasks · next: TASK-<id> · <title>` instead. Never invent a
  task ID.
- **Second line:** only the steps, with the current one marked:
  `✔ problem ✔ plan ▶ build ○ review ○ finish`. Between tasks,
  every step shows `○`.
- **Third line:** `🔍 Research:` the level used (Light, Standard or
  Deep) and how many sources were checked.
- **Then the status header:** after a blank line, one line of
  at most two short sentences saying what is happening now, then a line
  of dashes about as long, so it renders as a heading over the body.
  It comes in addition to the body's bullets.
- **Body:** at most three short bullets, plus a small visual where it
  helps (a folder tree, a flow, a before and after). Draw visuals as
  plain text without code fences. Link the task on the board as
  `http://127.0.0.1:4748/tasks/<ID>`.
- **When presenting a problem:** tell it as a short story. Miles, an
  engineer new to the part, hits the problem in concrete steps and sees
  what goes wrong; Adam, an experienced engineer, names what was
  missing or wrong, but not yet the fix, which is the plan. Always use
  these two names. The story fits the body: at most three bullets, plus
  a small before and after (what Miles saw, what he expected) where it
  helps. The status header and the closing question stay as usual.
- **When a PR is open:** summarize what the reviewer found and what was
  done about it.
- **At the end of a task, or a merge:** a one-row table with the columns
  wiki, README.md, groma, backlog and `<project repo> pushed`, each ✅
  done, ❌ not done or ➖ not applicable.
- **Last line:** exactly one question, in bold, with a recommendation.
