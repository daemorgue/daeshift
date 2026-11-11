---
name: explanation-writing
description: How to write an explanation page (Diátaxis) that helps a reader understand a part of a system - why it is built this way, its background, the alternatives weighed - away from the task at hand. Use when writing or reviewing a wiki explanation.md, alongside style-user-documentation.
---

# Writing explanation

Explanation is for a reader stepping back from work to understand. It
answers "why" and "what else", and it is read, not consulted. Read
`references/sources.md` only when asked why. If style-user-documentation
is not installed yet, say so and follow this skill alone.

## Rules

- **About a topic.** The title should read naturally after "About":
  "About the git hook dispatcher", "About pinning by hash".
- **Give context.** Say why things are so: the history, the limits that
  shaped them, and the decisions behind them. Summarize each decision
  in your own words, then cite its record number in parentheses, as in
  "(decision-14)". Never cite a bare number without the summary, and
  never link to a file outside `wiki/`: the wiki may be published
  without the rest of its repository. Links to public web pages are
  fine.
- **Weigh alternatives.** Name what else was considered and why it lost.
  A clear judgement is welcome: "pre-commit was chosen over a home-made
  runner because…".
- **Make connections** to other parts, other tools, and ideas the
  reader already knows: "a git hook is to a commit what a CI check is
  to a pull request".
- **Introduce outside technology** the part relies on, briefly, before
  the part's own story: what it is, the one or two ideas needed, and a
  link to its own documentation, as in a page "About git hooks".
- **Show the idea:** one diagram where it helps, followed by a sentence
  saying what it shows.
- **Stay bounded.** No steps to follow and no list of every option.
  Link to the how-to guide or to the reference page instead.

## Page outline

Start from `references/templates/explanation.md`.

1. A short opening: what this page helps the reader understand.
2. Background, including any outside technology.
3. How it fits together, with a diagram.
4. Why it is this way: decisions and alternatives.
5. Limits and open questions.
6. Related: links to the reference page and how-to guides in the wiki.

## Gotchas

- Explanation tends to swallow everything about its topic. When a
  passage starts listing flags or giving steps, move it out and link.
- A judgement needs its reason in the same place. "X is better" alone
  is noise; "X is better here because Y" is explanation.
