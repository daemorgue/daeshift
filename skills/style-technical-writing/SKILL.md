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
  operator runs the installer." The imperative mood ("Run the
  installer.") appears only as a step in a numbered procedure, and each
  step states one action.
- Formal and neutral: no opinion, no feelings, no evaluative words
  ("elegant", "clean"), no hedges ("usually", "often"), and never
  "feel", "think", "believe", "like" or "love" for the author's own
  state. State the condition under which a claim holds instead.
- A warning states its consequence: "Deleting the volume removes every
  snapshot."
- No generalizations about what people know ("everyone knows"). A
  reason states what happens if the rule is broken, never a quality
  such as "cleaner" or "more maintainable".

## Sentences and paragraphs

- Complete sentences, one claim each; fragments only in headings, table
  cells, list items and definitions. Present tense; past tense only for
  past events.
- Every sentence has a noun or noun phrase as its subject: no "It"
  openings and no "There is/are" openings.
- Each sentence stands alone: no pronoun referring to a noun in an
  earlier sentence; "this", "that", "these" or "those" only with a noun
  naming what it points to ("this flag").
- One referent per word in a sentence; if a word would mean two
  things, replace one with a specific term.
- Explicit before short: never drop a subject, swap a noun for a
  pronoun, or cut a needed qualifier to shorten a sentence. Split a
  sentence only when it holds more than one claim.
- Verbs, not nominalizations: "configure", not "perform configuration".
- A paragraph develops one idea. A paragraph introducing any set of
  items names every item; a count alone is not enough.
- No opening transitions ("However", "Additionally"); a sentence may
  open with "For example,". A supporting
  sentence comes right after the statement it supports.
- Never defer a paragraph's content with "described below"; a later
  section may be named only to point to extra detail.
- A paragraph stating a rule follows this order: the rule, its reason,
  any exception or alternative, then any example.

## Word choice

- American English, with standard spelling and capitalization;
  headings in title case. One term per concept; never a synonym for
  variety.
- No metaphors, similes, analogies or other figurative language; no
  idioms, clichés, slang, contractions or redundant expressions ("true
  fact", "exactly identical").
- Expand an abbreviation the first time, then use the abbreviation
  every time after: "Software Bill of Materials (SBOM)". Skip the
  expansion when it only records where a name came from; expand when
  unsure.
- Define a field-specific term at first use only when it is not in
  common use in the field. The name of a standard is a citation, not a
  term to define.
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
  Serial comma always. A colon only ends a sentence that introduces a
  block, or sits in a heading, after a bold label, or in literal text.
  (This skill's own colons after labels follow that last case; prose
  written in this style does not use them mid-sentence.)
- Bold marks a term where it is defined, or a list label; italic marks
  non-binding content; neither is ever emphasis. Code marks exact
  strings a system accepts, emits or stores, never a tool named in
  prose. Link text names its target; never "here".
