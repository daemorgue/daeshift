---
name: style-user-documentation
description: The user-documentation style - friendly, direct, second person, short sentences - for how-to guides, tutorials, explanation pages and a code repo's README (a how-to guide; wiki README.md pages are reference and use style-technical-writing). Covers voice, person, tone, sentences, paragraphs and word choice. Use when writing or reviewing any of those, after the diataxis skill picks the kind.
---

# Style: user documentation

The reader has a tool in front of them and wants to use it or
understand it. Write as one engineer talking to another: friendly,
direct, a little dry, honest about what the tool does not do yet.
Numbers, citation, punctuation and text marks are in
`references/rules.md`. Read it when a sentence holds one of those. In
every sentence: no semicolons, no em or en dashes, and a serial comma
before the last item of a list of three or more.
Read `references/sources.md` only when asked why.

## Voice and person

- Active voice. Passive only when the actor is unknown, or is the tool
  and naming it adds nothing ("Configuration is stored in `rc`."), or
  the thing acted on is the topic of the nearby sentences.
- Address the reader as "you". Describe the software in the third
  person: "daeshift starts pi in the project's folder."
- "I" only for the author's own recommendation, opinion or reason: "I
  recommend the encrypted option." "We" only for an organization
  already named: "TIRED Labs recommends the encrypted option. We test
  on macOS too."

## Tone

- Conversational, friendly, and respectful. No slang, and nothing
  overly casual.
- At most two humorous remarks in a document. Urgency only when warning
  of a hazard: data loss, a broken system, cost or a security risk.
- State an opinion in the first person singular ("I"), with its reason.
- Hedge ("most likely", "hopefully") only when genuinely unsure. Never
  hedge an instruction.

## Sentences

- Complete sentences in prose. Fragments only in headings, list items,
  table cells, link text, a tagline and a callout label.
- One claim or one instruction per sentence. At most 25 words.
- Present tense for what the software does. Future only for the result
  of a step the reader is about to take. Past only for history.
- Name actions with verbs: "configure the tool", not "perform
  configuration".

## Paragraphs

- One idea per paragraph, at most four sentences, the point first.
- An example follows the paragraph that introduces it. Any explanation
  of the example follows the example.
- Introduce a list, table or code block with "the following" rather
  than naming every item.
- A pronoun may point back one sentence when nothing else could be
  meant. A sentence may open with a transition such as
  "Alternatively", "Additionally" or "Otherwise".

## Word choice

- American English, standard spelling and capitalization, except a
  name its owner styles otherwise, and except literal text (commands,
  paths, code).
- One term per concept throughout a document.
- Contractions are fine ("don't", "you're").
- No idioms or colloquialisms. Readers include non-native speakers. A
  plain comparison that helps understanding is fine in explanation.
- Expand an abbreviation the field does not commonly use, the first
  time: "Nginx App Proxy (NAP)". Never "i.e." or "e.g.". Write "that
  is" or "for example". "etc." is fine in a list that is clearly
  partial, never after "for example" or "such as".
- Define a term the field does not commonly use, or link to a
  definition. Do not define common terms.
- Never use these AI tells: delve, foster, leverage, utilize, robust,
  seamless, holistic, synergy, paradigm, harness, elevate,
  cutting-edge, state-of-the-art, "in order to", "it's worth noting",
  "Moreover" or "Furthermore" to open a sentence. A listed word is
  allowed when it is the established name of a thing.

## Gotchas

- "Friendly" is not "chatty": the reader came for the one command they
  need. Lead with it.
- Short sentences beat clever ones. If a sentence needs a second
  reading, split it.
