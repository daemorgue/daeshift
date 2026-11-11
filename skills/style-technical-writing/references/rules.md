# Detailed rules: numbers, punctuation and text marks

From tired-labs/governance's Technical Writing style guide (version 1.0.0,
style-guide/technical-writing.md), unchanged. Read the section a
sentence needs. The guide's own open-question comments are left out.
Where the text says "the Specification governing the class of the
document", daemorgue's writing skill for that kind (such as
reference-writing) plays that part.

## Numbers and Units

An author MUST NOT assert a quantity without stating that quantity. An author
asserts a quantity without stating that quantity by applying a word such as
"many", "few", "several", "some", "a lot", "much", "great", "big", or "huge" to
a set, and a reader has no means of verifying an assertion of that form. An
author asserting a quantity MUST state a number, a proportion, or a defined
set. A word naming a quantity without asserting one, as "how many" does where a
sentence names a category of content rather than a count, conforms.

A count from zero through nine MUST be written in words. A count of 10 or
greater MUST be written in numerals. A count below 10 MUST be written in
numerals where the count appears in the same sentence as a count of 10 or
greater referring to the same kind of thing. A quantity carrying a unit of
measure is a measurement rather than a count, and the rule for units of measure
in this section governs a measurement.

A number identifying a numbered element MUST be written in numerals, as in
"step 3".

A sentence MUST NOT begin with a numeral. An author rewrites the sentence or
writes the number in words.

Where two numbers referring to different things appear next to each other, an
author MUST write one of the two numbers in words, as in "fifteen 20-page
articles".

An ordinal MUST be written in words, as in "the second paragraph".

A decimal MUST be written in numerals. A decimal with a value below one MUST
carry a zero before the decimal point, as in "0.5". A fraction MUST be written
as a decimal where the decimal is exact. A fraction with no exact decimal form
MUST be written in words, as in "one-third".

A large number MUST be written in full numerals, as in "7,000,000". A number of
four or more digits MUST carry a comma between each group of three digits,
except a page number, which carries no comma. A decimal MUST NOT carry a
separator after the decimal point. An author MUST NOT abbreviate thousand,
million, or billion as K, M, or B in any letter case. An author MUST NOT write
a large number as a numeral followed by a word, as in "7 million".

A range of numbers carrying no unit MUST use a hyphen with no space on either
side, as in "2012-2016". A range whose unit is a symbol or an abbreviation MUST
repeat the unit and MUST use the word "to" between the two values, as in "10 GB
to 20 GB". A range whose unit is a spelled-out word, including a range of
durations, MUST use the hyphen form, as in "5-10 minutes".

A ratio or a score MUST be written as numerals separated by a colon with no
space on either side, as in "3:1".

A date MUST write the month as a word, as in "January 19, 2017". A date written
in numerals only MUST follow ISO 8601, as in "2017-04-15". A year MUST NOT
carry a comma.

A time of day MUST use the 12-hour clock with AM or PM, separated from the time
by one space, as in "3:45 PM". A time on a round hour MUST omit the minutes, as
in "3 PM". A time MAY use the 24-hour clock only where the thing the text
documents uses the 24-hour clock. Noon and midnight MUST be written as the
words "noon" and "midnight".

A time zone MUST appear only where the time refers to an event at a specific
moment. A time zone MUST be written as the full region name followed by the UTC
offset in parentheses, with no space on either side of the plus sign or the
minus sign, as in "Pacific Standard Time (UTC-8)".

A duration MUST be written as a numeral followed by a spelled-out unit, as in
"30 seconds". An abbreviated unit of time MAY appear only in literal text.

A monetary amount MUST carry a currency indicator before the amount, as in
"US$10,000.50". A monetary amount MUST use a comma between each group of three
digits and a period before the fractional part.

A percentage MUST be written as a numeral followed by the percent sign with no
space, as in "5%".

A measurement MUST be written in numerals, including a measurement below 10. A
measurement MUST carry a space between the number and the unit, as in "64 GB",
except a monetary amount, a percentage, and a measurement in degrees of an
angle, which carry no space. A rate MUST use the word "per" in place of a
slash, as in "100 requests per second".

## Punctuation

Every punctuation mark and every whitespace character MUST use the ASCII form
of the character. A quotation mark MUST be the straight form. An apostrophe
MUST be the straight form. An ellipsis MUST be written as three periods. A
space MUST be the ordinary space character. A typographic form of a mark
resembles the ASCII form on screen, and a reviewer cannot distinguish the two
forms by reading the text.

An author MUST NOT use an em dash. An author MUST NOT use an en dash. A range
uses a hyphen under the rules of the Numbers and Units section.

The text MUST use a serial comma in a list of three or more items. A comma
otherwise follows standard usage.

The rules for the colon and the parentheses in this section govern each use no
other area section governs. A time of day, a ratio, a score, and a time zone
follow the Numbers and Units section.

A colon MUST appear only in one of the following positions:

- At the end of a complete sentence that introduces a block element immediately
  following the colon. The block elements a colon introduces are a list, a
  table, a figure, an image, a graph, and a code block.
- Within a heading.
- Following a bolded label that begins a member of an enumerated set.
- Within literal text, where the colon is part of the content rather than
  punctuation.

A colon MUST NOT appear in any other position. A colon placed within a sentence
joins two statements that the sentence then carries together, and the rule
requiring a sentence to state one claim prohibits that construction.

An author MUST NOT use a semicolon to join two independent clauses. Two
independent clauses state two claims, and the rule requiring a sentence to
state one claim prohibits joining the two clauses. An author MAY use a
semicolon to separate items in a list where an item contains a comma.

An author MUST NOT use parentheses to enclose an aside. An author MAY use
parentheses to enclose an abbreviated form on the first occurrence of the
expanded term, and to enclose a reference to a numbered element.

An author MUST NOT use an exclamation mark.

An author MUST NOT use a question mark. A question in technical material states
no fact and requires a reader to supply an answer the document is responsible
for stating.

An author MUST NOT use quotation marks to signal irony, skepticism, or an
unusual application of a term. An author MAY use quotation marks to enclose a
quoted passage and to enclose a literal value where an inline code mark does
not apply.

An author MUST NOT use an ellipsis to omit content from a statement the author
is making. An author MAY use an ellipsis to mark an omission within a quoted
passage.

## Text Marks

A text mark carries a defined meaning. An author MUST apply a mark only where
the content carries the meaning that mark defines, and MUST NOT apply a mark
for emphasis, decoration, or visual variation.

**Bold** marks a term at the point where that term is defined. Bold also marks
a label that begins a member of an enumerated set, where a member is a list
item or a paragraph. Bold MUST NOT mark a word for emphasis. Whether the
members of an enumerated set carry labels is determined by the Specification
governing the class of the document, and this Style Guide states only how a
label is marked. A label that is itself a term being defined carries both
meanings at once, and both meanings hold for that span.

*Italic* marks content the author identifies as informative rather than
binding. Italic MUST NOT mark a word for emphasis. Italic MUST NOT mark binding
content. Whether informative content carries a textual introduction in addition
to the italic mark is determined by the Specification governing the class of
the document, and an author MAY apply both the italic mark and such an
introduction to one span of content.

`Inline code` marks a string that the document reproduces exactly as a system
emits, accepts, or stores that string, where changing a character of the string
changes what the string refers to. A word naming a concept, a product, a
protocol, or a technology MUST NOT be marked as inline code, even where a
system elsewhere accepts that word as a literal value.

The following are marked as inline code:

- File names, file paths, and directory names
- Command names, full command lines, and text a user types into an interface
- Function names, method names, class names, type names, and variable names
- Field names, key names, and the literal values those fields and keys hold
- Environment variable names, registry keys, process names, hostnames, and
  network addresses
- Text an interface displays back to a user
- A string showing the form of a value, including a URL written to illustrate
  URL structure

The following are not marked as inline code:

- A term at the point where that term is defined, which bold marks instead
- A product name, a tool name, a protocol name, or a technology name used in
  prose to name the thing itself
- A URL that a reader follows, which a link marks instead

The same characters MAY be marked in one sentence and unmarked in another. A
tool name used in prose to name the tool is unmarked, and the same name used as
the command that invokes the tool is marked. A protocol name used in prose to
name the protocol is unmarked, and the same name used as a literal
configuration value is marked.

A code block marks a span of literal text that a reader reproduces exactly and
that extends beyond a single line. A code block MUST NOT contain prose. A code
block MUST declare the language of its content where the content is written in
a language, and MUST declare no language where the content is literal output,
literal input, or plain text.

A list marks a set of items of the same kind. An ordered list marks a set whose
order is required. An unordered list marks a set whose order is not required.
An item in an unordered list MUST state content whose meaning a reader
determines without reading another item in that list. A reader takes the items
of an unordered list in any order, and an item whose meaning requires another
item is then read before the item supplying that meaning. An ordered list MAY
carry an item whose meaning requires an item preceding that item, because the
numbering states that the order is required. Prose whose parts require each
other, and whose order is not numbered, MUST appear as paragraphs.

A table marks a set of items sharing the same attributes, where each row holds
one item and each column holds one attribute. A table MUST NOT hold content
that varies in structure from row to row.

A heading level marks the position of a section within the hierarchy of the
document. Heading level 1 MUST appear exactly once and MUST carry the title of
the document. A heading level MUST NOT be selected for the size at which a
format renders that level. A heading MUST carry a level either one greater than
the level of the heading preceding that heading, or less than or equal to the
level of the heading preceding that heading. A document that skips a heading
level produces an outline in which a section has no parent, and an automated
consumer building an outline from heading levels cannot place that section.

A link marks a reference to a resource located outside the current position in
the document. The text of a link MUST name the resource the link points to. The
words "here", "this", "click here", and "see this" MUST NOT serve as link text.

A footnote MUST NOT appear. Content that supports a statement MUST appear in
the statement. Content that does not support a statement MUST be removed rather
than relocated to a footnote. A reader consulting technical material reads one
section to answer one question, and a footnote places content outside the
section that reader is holding.

Capitalization of a full word marks that word as carrying a defined meaning
distinct from the meaning the same word carries in lowercase.

This Style Guide records the following gap in the Text Marks area:

- **Formats lacking a native text mark.** This section states what each mark
  means. A format that provides no native equivalent for a mark requires an
  author to select an approximation, and this Style Guide states no rule for
  selecting that approximation.

