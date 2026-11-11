# Detailed rules: numbers, citation, punctuation and text marks

From bedford's User Documentation style guide
(governance/style-guides/user-documentation.md, version 0.1.0), with
the changes listed in sources.md. Read the section a sentence needs.

## Numbers and Units

The text MUST write each category of quantity as follows:

- **Numbers.** Zero to nine MUST be written in words. 10 and above
  MUST be written in numerals. A number paired with a unit or a symbol
  MUST be written in numerals, whatever its size.
- **Fractions and decimals.** MUST be written in numerals, as in "0.5"
  and "99.9".
- **Ordinals.** First to ninth MUST be written in words. 10th and
  above MUST be written in numerals with a suffix.
- **Ranges.** MUST be written as two values joined by "to", as in "1
  to 5".
- **Ratios and scores.** MUST be written in numerals joined by a
  colon, as in "16:9".
- **Abbreviated large numbers.** MUST be written as numerals followed
  by an uppercase letter with no space, as in "10K" and "2M".
- **Dates.** MUST be written as `YYYY-MM-DD`.
- **Times.** MUST be written in 24-hour form, `HH:MM`, followed by the
  time zone.
- **Durations.** MUST be written as numerals followed by the unit
  spelled out, as in "30 seconds".
- **Currency.** MUST be written as the currency symbol followed by
  numerals, as in "$5".
- **Percentages.** MUST be written as numerals followed by the percent
  sign with no space, as in "20%".
- **Units of measure.** MUST be written as numerals followed by the
  unit symbol with no space, as in "128MB" and "8GB".

An approximate quantity MAY carry a leading tilde, as in "~500MB".

A quantity in a category this list does not name MUST be written in
numerals.

## Citation and Attribution

The text MUST credit the source of every quotation, and SHOULD credit
a source whose work or ideas it relies on. The credit MUST appear
through a link on the text that names the source.

The text follows no citation format.

A direct quotation of one sentence or less MUST appear inline, between
quotation marks. A longer quotation MUST appear as a block quotation.

The text MAY shorten a quotation. An omission MUST be marked with an
ellipsis, and an added or changed word MUST be placed in brackets.

A paraphrase SHOULD be credited where it restates an idea that belongs
to one source.

A run of five or more words taken unchanged from a source MUST be
marked as a quotation.

A quotation SHOULD NOT exceed three sentences.

## Punctuation

Punctuation MUST NOT depart from standard usage, except in literal
text.

Each punctuation mark and whitespace MUST be used as follows, in a use
no other area section governs:

- **Period.** The plain period. It MUST end every complete sentence.
- **Comma.** The plain comma. A list of three or more items MUST carry
  a serial comma before the final "and" or "or".
- **Colon.** The plain colon. It MAY introduce an explanation that
  completes the sentence before it.
- **Semicolon.** MUST NOT be used.
- **Question mark.** The plain question mark. It MAY end a question,
  including a heading worded as a question.
- **Exclamation mark.** The plain exclamation mark. It MAY end a
  sentence that conveys enthusiasm. A paragraph MUST NOT carry more
  than one.
- **Em dash.** MUST NOT be used.
- **En dash.** MUST NOT be used.
- **Hyphen.** The plain hyphen-minus. It MUST join the words of a
  compound modifier placed before a noun, as in "command-line tool".
- **Parentheses.** Plain parentheses. They MAY hold an aside, an
  abbreviation after its full form, or an example introduced by "for
  example". (Changed from the source, which allowed "e.g.": Google's
  style guide rules it out.)
- **Brackets.** Plain square brackets. They MUST NOT be used outside a
  changed quotation and literal text.
- **Quotation marks.** Straight double quotation marks. Single
  quotation marks MUST NOT be used outside a quotation within a
  quotation and literal text.
- **Apostrophe.** The straight apostrophe.
- **Ellipsis.** Three periods with no spaces. It MAY mark an omission
  in a quotation, or a thought trailing off in an aside.
- **Slash.** The plain slash. It MAY join two alternatives or a pair
  of opposite actions, as in "start/stop".
- **Whitespace.** One space MUST separate sentences.

A punctuation mark this list does not name MUST NOT be used outside
literal text.

## Text Marks

The following kinds of content MUST take the text marks stated:

- **Literal text on a single line.** A code span, for every command,
  file name, path, option, value and name from code.
- **Literal text across more than one line.** A code block. A command
  the reader types MUST be shown after a `$ ` prompt, and the output
  it prints MUST be shown without one.
- **A term at the point where it is defined.** Bold.
- **Emphasis.** Bold. Emphasis SHOULD be rare. A word warning of a
  hazard MAY be written in capitals, as in "ALWAYS".
- **The title of a work.** A link to the work, where one exists.
  Otherwise, no mark.
- **A label beginning an item in a set.** Bold, followed by a period
  when the label is a phrase and by a colon when the label is a single
  word, as in "**Note:**".
- **A set of items whose order is required.** A numbered list.
- **A set of items whose order is not required.** A bulleted list.
- **A set of items sharing the same attributes.** A table.
- **The position of a section in the hierarchy of a document.** A
  heading.
- **A reference to a resource outside the document.** A link, whose
  text names the resource. A bare address MUST NOT appear outside
  literal text.
- **An aside or a note.** A callout: a paragraph opening with a bold
  label, such as "**Note:**" or "**WARNING:**". A short aside MAY sit
  in parentheses within a sentence instead.

A sentence introducing a list, a table or a code block MUST end with a
colon. A list item MUST end with a period when it is a complete
sentence and MUST NOT end with one when it is a fragment.

A kind of content this section does not name MUST take no text mark.

## Definitions

**Callout**: A paragraph that opens with a bold label naming its kind,
such as "Note" or "WARNING", and sets a note or a warning apart from
the text around it.

**Hazard**: A step or a setting that can lose the reader's data, break
their system, or leave something running that costs money or weakens
security.

**Literal text**: Text the reader types, copies or sees exactly as
written, such as a command, a path, a value, code, or the output of a
program.
