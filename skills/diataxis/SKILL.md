---
name: diataxis
description: Decides which of the four kinds of documentation a page is (tutorial, how-to guide, reference or explanation), splits a page that mixes them, and names the writing and style skills to load next. Use before writing, restructuring or reviewing any documentation page.
---

# Diátaxis: choosing the kind of document

Every documentation page serves one need. Diátaxis (diataxis.fr, by
Daniele Procida) names four, and a page that tries to serve two serves
neither well. Read `references/sources.md` only when asked why.

## The compass

Ask two questions about the page, or about one passage of it:

| The content… | and serves the reader's… | so it is a… |
|--------------|--------------------------|-------------|
| guides action | learning (acquiring a skill) | tutorial |
| guides action | working (applying a skill) | how-to guide |
| informs understanding | working (applying a skill) | reference |
| informs understanding | learning (acquiring a skill) | explanation |

"Action" means steps the reader does. "Understanding" means knowledge
the reader holds.

## Then load

If a listed skill is not installed yet, say so, and use the compass
and this skill alone.

| Kind | Writing skill | Style skill |
|------|---------------|-------------|
| tutorial | tutorial-writing | style-user-documentation |
| how-to guide | how-to-writing | style-user-documentation |
| reference | reference-writing | style-technical-writing |
| explanation | explanation-writing | style-user-documentation |

## Where each kind lives

- Reference: each wiki level's `README.md` (in the project repo's
  `wiki/`, not a code repo's README), shaped like the C4 map in
  `maps/<repo>/`.
- Explanation: `explanation.md` beside the reference it explains.
- How-to guides: a code repo's `README.md`, and the project wiki's
  `how-to/` pages.
- Tutorials: the project wiki's `tutorials/` pages.

## Splitting a mixed page

Run the compass on each passage, not the whole page. Move each passage
that answers differently to the page of its kind, and link to it. If
that page does not exist, write it when a reader needs it; otherwise
cut the passage. A
reference page that starts explaining "why" gets a link to its
`explanation.md`; a how-to guide that starts describing every option
gets a link to the reference.

## Gotchas

- Diátaxis is a guide for each page, not a list of pages to produce.
  Write a kind only when a reader needs it.
- Words drift: "why it is so" is explanation; "what it is, how it
  behaves and how it is used" is reference; "how to reach a goal" is a
  how-to guide.
- Copy no text from diataxis.fr. It has no open licence: paraphrase
  and cite it.
