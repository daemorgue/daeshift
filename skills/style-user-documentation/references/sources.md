# Sources for style-user-documentation

Checked on their pages on 2026-11-11.

- The rules come from bedford's User Documentation style guide
  (daemorgue/bedford, governance/style-guides/user-documentation.md,
  version 0.1.0, GPL-3.0, the same licence as daeshift), which follows
  tired-labs/governance's Style Guide specification. references/rules.md
  carries its numbers, citation, punctuation, text-marks and definitions
  sections.
- Where Google's developer documentation style guide conflicts, Google's
  rule is used (decision-12 on the daemorgue board):
  - [Abbreviations](https://developers.google.com/style/abbreviations):
    "Don't use i.e. or e.g.; instead, use that is or for example".
    bedford allowed "e.g."; it is now ruled out here and in rules.md.
    The same page: "It's okay to use etc. in some circumstances"; the
    skill keeps "etc." only for a clearly partial list.
  - [Tone](https://developers.google.com/style/tone): "a
    conversational, friendly, and respectful tone ... avoiding slang
    and overly casual language". bedford allowed slang; it is now
    ruled out.
  - [Pronouns](https://developers.google.com/style/pronouns): first
    person is reserved for specific contexts, such as an organization's
    statements. bedford banned "we" outright; "we" is now allowed for
    an organization already named.
  - [Writing for a global audience](https://developers.google.com/style/translation):
    omit "colloquialisms, idioms, humor, and seasonal references".
    bedford allowed idioms; they are now ruled out. bedford's limit of
    two humorous remarks per document is kept as a ceiling.
  - Pronouns: Google also allows first person where the author comments
    in the first person, which matches bedford's "I" for the author's
    own recommendation or opinion; that rule stays.
- The AI-tell word list comes from dotclaude's ai-prose-hygiene
  knowledge file.
- This style serves how-to guides, tutorials, explanation and a code
  repo's README; reference (including wiki README.md pages) and
  specifications use style-technical-writing (decision-16).
- Not yet checked against Google: rules.md's rules for units, dates,
  times, exclamation marks and "~" for approximate values follow
  bedford as written. A review on 2026-11-11 flagged them as possible
  conflicts; check each against Google's pages before relying on them.
