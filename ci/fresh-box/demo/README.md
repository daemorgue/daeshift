# demo

A daeshift project used only by the fresh-box CI job
(`.github/workflows/ci.yaml`). The job copies this folder, makes it a
git repository and adds it with `daeshift --add-project`.

Its code repos are real public repos, cloned at their newest commit,
so the job also needs GitHub to be reachable and those repos to stay
public.
