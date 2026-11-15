# The next-task order: every In Progress task, then every
# ready To Do task, each group by the task's own priority (a task with
# none after low), then board order (a task with none last). Only tasks
# without subtasks are ordered; parents never appear.
# Run from the project repo:
#   backlog task list --json | jq -r -f .config/next-task.jq
# Check after any change (no output means it passes):
#   jq -r -f .config/next-task.jq .config/next-task.test.json \
#     | diff - .config/next-task.expected

def rank: [(if .status == "In Progress" then 0 else 1 end),
  -({"high":3,"medium":2,"low":1}[(.priority // "") | ascii_downcase] // 0),
  (.ordinal // 1e9)];

.tasks as $all
| ([$all[] | .parentTaskId // empty] | unique) as $parents
| [$all[]
   | select(.id as $id | $parents | index($id) | not)
   | select(.status == "In Progress" or (.status == "To Do" and .isReady))]
| sort_by(rank)[]
| "\(.status)\t\(.priority // "-")\t\(.id)\t\(.title)"
