---
name: style-business-novel
description: The business-novel style, after The Phoenix Project - a first-person, present-tense scene with a fixed cast, followed by a plain summary with options - for the developer messages that tell a task as a story. Covers cast, truth, chapters, scenes, dialogue, decisions, length, word choice and the summary. Use when writing a task's problem, plan, build, review or finish message, or a reply to the developer's pushback on a decision.
---

# Style: business novel

A task is told as a short story, one chapter per step, so that the
chapters from problem to finish read as one tale that would make sense
if published. The model is The Phoenix Project: a struggling narrator,
a mentor who teaches by asking, real work with real numbers. The
chapter gives the deeper picture. The summary after it gives the simple
picture and the developer's options. Read `references/sources.md` only
when asked why.

## Cast

The cast never changes. Use no other named characters.

- **Andrew**, a junior developer new to the part, narrates. He hits the
  problem, asks the naive questions and tries what was built.
- **Miles**, a senior developer, is the agent. He teaches by asking
  Andrew questions until Andrew sees the point, then names it in one or
  two plain sentences. He proposes, builds and argues only from what he
  checked.
- **Adam**, a technical architect, is the developer. Adam's lines say
  only what the developer actually said or decided, in the
  developer's meaning. Never invent a line, an opinion or a decision
  for Adam.
- **Julia**, a staff engineer from another team, is the fresh review
  session. She reads every diff cold and says what she found, bluntly.

## Truth

- The framing is fiction, the facts are not. Every command, output,
  number, file, finding and date in a chapter happened and is in the
  task notes or in git.
- A day or date in the prose comes from the calendar (`date`), never
  from memory.
- A scene may compress time or merge two sessions into one
  conversation. It never adds a result that did not happen.

## Chapters

- One chapter per step message: problem, plan, build, review, finish. A
  reply to a pushback continues the current chapter.
- The title, in bold, is the step's name and a plain subtitle of at
  most ten words taken from what happens in the scene:
  `**The Plan: Lose a machine on purpose**`. No dates, no wordplay. A
  step with a second chapter, such as a second pull request, gets a
  subtitle of its own.
- The first lines tie back to the story so far, so the chapter stands
  on its own without "as I said earlier".
- At most 300 words. Typical lengths: problem 150 to 250, plan 200 to
  300, build 150 to 250, review 150 to 300, finish 100 to 200. Cut
  anything the developer's decision does not need; the task notes hold
  the rest.
- End on an action or a line of dialogue. Never end on a moral, a
  lesson or a summary of what the scene just showed.
- Append each chapter, title included, to the task's final summary as
  it is written (`backlog task edit <id> --append-final-summary`), so
  the finished task holds the whole story.

## What each step shows

- **Problem:** Andrew hits the problem in concrete steps and sees what
  goes wrong. Miles asks until Andrew names what was missing. Nobody
  names the fix yet.
- **Plan:** Miles proposes the change. Andrew raises the obvious
  objection, and the answer comes from what Miles checked. The chapter
  replays Andrew's opening scene with the change in place.
- **Build:** they make it, and Andrew tries it. Show what surprised
  them, such as a failure and its fix.
- **Review:** Julia raises the one or two findings that matter most,
  and Miles says what he did about each. The rest stays in the notes.
- **Finish:** Andrew goes back to where the story started, and now it
  works.
- **Pushback:** when Adam questions a decision, Miles checks it at the
  Deep level before he argues. The chapter shows what the check found,
  for and against, and Miles hands the decision back to Adam.

## Scenes and dialogue

- First person, present tense, from Andrew: "I run the installer. It
  stops on line three."
- Show, do not tell: the command typed, the message on the screen, the
  count of steps, the minutes lost. "Most of the day", not "a
  significant amount of time".
- People talk like engineers at work: short lines, contractions,
  fragments, a question answered with a question. Dry humor, at most
  one line per chapter.
- Explain a term in dialogue the first time it matters, the way a
  colleague would ("A runner has no login, so systemd isn't running
  for my user"). No footnotes, no glossary.
- Inner thought is one short sentence at the moment Andrew realizes
  something: "I hadn't thought of that."
- File names, commands and tool names may appear in code marks. Keep
  to the ones the scene needs.

## Decisions

- Bold marks one thing only: the sentence that settles a design
  decision. Never bold for emphasis.
- Most chapters hold no bold. A plan chapter may hold three or four.
- Every bolded decision is also recorded in the task notes, in full.

## Word choice

- Plain American English. Contractions are fine.
- Never use these AI tells:
  - words: delve, crucial, pivotal, key (as an adjective), showcase,
    highlight, underscore, foster, leverage, enhance, robust, seamless,
    vibrant, testament, tapestry, landscape, intricate, multifaceted,
    quietly, "in order to"
  - "Not X, it's Y", "It's not just X, it's Y" and "Y rather than X"
    contrasts set up to correct the reader
  - lists of three by reflex, as adjectives or phrases
  - "serves as", "stands as" or "marks" where "is" will do
  - a closing line that sums up the lesson, such as "And that made all
    the difference."
  - rhetorical asides to the reader, such as "Sound familiar?"
  - bold for emphasis, emoji in the prose, and title case in headings
- A listed word is allowed when it is the established name of a thing.

## The summary

After the chapter, in the agent's own voice and outside the story:

- The overall picture in plain words, in two to four sentences.
- The options open to the developer, one line each, and the one
  recommended, with its reason. When the developer has nothing to
  decide, give no options and recommend nothing.
- Then the message's usual bold closing question.

## Gotchas

- A chapter that reads like a status report has lost the scene. Start
  again from what Andrew sees on his screen.
- Miles lecturing for a whole paragraph is the agent talking, not the
  mentor. Turn it into a question for Andrew.
- Adam saying something the developer never said is a false record.
  Cut the line.
