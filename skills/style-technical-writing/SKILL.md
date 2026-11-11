---
name: style-technical-writing
description: The technical-writing style - neutral, third person, one meaning per sentence - for reference pages and specifications. Covers voice, person, tone, sentences, paragraphs, word choice, numbers, punctuation and text marks. Use when writing or reviewing reference documentation or a specification, after the diataxis skill picks the kind.
---

# Style: technical writing

A reader consults this text for an exact answer, and every sentence
must allow only one reading. Detailed rules for numbers, punctuation and
text marks are in `references/rules.md`; read it when a sentence holds
one of those. Read `references/sources.md` only when asked why.

## Voice, person, tone

- Active voice. Passive only when the actor is unknown or irrelevant,
  and then never name the actor.
- Third person: no "I", "we" or "you". Name the party instead: "The
  operator runs the installer." A numbered step may be imperative:
  "Run the installer."
- Formal and neutral: no opinion, no feelings, no evaluative words
  ("elegant", "clean"), no hedges ("usually", "often"). State the
  condition under which a claim holds instead.
- A warning states its consequence: "Deleting the volume removes every
  snapshot."
- No generalizations about what people know ("everyone knows"). A
  reason states what happens if the rule is broken, never a quality
  such as "cleaner" or "more maintainable".

## Sentences and paragraphs

- Complete sentences, one claim each; fragments only in headings, table
  cells, list items and definitions. Present tense; past tense only for
  past events.
- Each sentence stands alone: no pronoun referring to a noun in an
  earlier sentence; "this" or "that" only with a noun naming what it
  points to ("this flag"); no sentence opening with "It".
- Verbs, not nominalizations: "configure", not "perform configuration".
- A paragraph develops one idea. A paragraph introducing a list names
  every item. No opening transitions ("However", "Additionally").

## Word choice

- American English. One term per concept; never a synonym for variety.
- No metaphors, similes, analogies or other figurative language, and
  no idioms, clichés, slang or contractions.
- Expand an abbreviation the first time: "Software Bill of Materials
  (SBOM)". Define each field-specific term at first use.
- Never use these AI tells: delve, foster, leverage, utilize, robust,
  seamless, holistic, synergy, paradigm, harness, elevate,
  cutting-edge, state-of-the-art, "in order to", "it's worth noting".
  A listed word is allowed when it is the established name of a thing
  (pi is "a coding agent harness").

## Numbers, punctuation, text marks (summary)

- No vague quantities ("many", "several", "some", "a lot"): state a
  number, a proportion or a defined set.
- Zero to nine in words, 10 and up in numerals; measurements always in
  numerals with a space: "64 GB".
- ASCII punctuation only. No em or en dashes, exclamation marks,
  question marks, semicolons joining clauses, or parenthetical asides.
  Serial comma always.
- Bold marks a term where it is defined, or a list label; italic marks
  non-binding content; neither is ever emphasis. Code marks exact
  strings a system accepts, emits or stores, never a tool named in
  prose. Link text names its target; never "here".
