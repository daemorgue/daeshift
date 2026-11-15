# Sources for style-business-novel

Checked on their pages on 2026-11-14. The book is quoted only in short
lines, as evidence.

## Why a novel

- Gene Kim's afterword, reprinted in "The Phoenix Project: 10 Years of
  Transformation" (IT Revolution,
  https://itrevolution.com/articles/the-phoenix-project-10-years-of-transformation/):
  the authors "wanted to capture what the downward spiral looked and
  felt like, as well as what the surprising solutions felt like", and
  chose the novel form, "just like Dr. Eliyahu Goldratt did in The
  Goal". Readers wrote back "It's like you've been hiding in our
  building. I know these characters." This is the reason the problem
  chapter dramatizes real events.
- "Beyond The Phoenix Project: Modules 1, 2, 3"
  (https://itrevolution.com/articles/beyond-phoenix-project-making-book-goldratt-deming/):
  the book was built with Goldratt's current and future reality trees
  and core, chronic conflicts. A problem chapter is the current
  reality, the plan chapter the future one.
- Wikipedia, "The Goal (novel)"
  (https://en.wikipedia.org/wiki/The_Goal_(novel)): Jonah teaches Alex "through a series
  of telephone calls and brief meetings". Wikipedia, "Business fable"
  (https://en.wikipedia.org/wiki/Business_fable):
  a fictional narrative "is meant to affect the emotions of the
  audience, unlike a conventional tome". Wikipedia, "The Five
  Dysfunctions of a Team"
  (https://en.wikipedia.org/wiki/The_Five_Dysfunctions_of_a_Team): "the bulk of it is written as a business
  fable", and the book then sums up its model. This is the
  chapter-then-summary order.
- "Three Observations on Leading through Writing" (IT Revolution,
  https://itrevolution.com/articles/three-observations-on-leadership-writing/),
  quoting Jeff Bezos: "There is no way to write a six-page narratively
  structured memo and not have clear thinking."

## How the book writes

- First person, present tense, from the struggling manager, Bill. Quotes
  in reader notes (github.com/mischavandenburg/blog,
  content/zet/articles/phoenix-project.md, and
  github.com/jbdamask/Books, the-phoenix-project.md): "As Wes talks, I
  think about Erik challenging me...", "Startled, I realize he's
  talking about Erik's First Way."
- The mentor asks until the student sees it (jbdamask's notes, page
  207): "Get serious. I asked you what work centers are your
  constraints. Think." Wikipedia, "Socratic method"
  (https://en.wikipedia.org/wiki/Socratic_method): questions until
  "the partner is pressed to come to a conclusion on their own".
  Reader notes (github.com/rzuquim/edu-books,
  study_notes/The_Phoenix_Project/15.md) show the same rhythm:
  Bill works the idea out, then calls Erik to confirm it.
- Concrete, counted pain: "Twenty steps involving at least six
  different teams. ... We're losing days at each handoff." (jbdamask's
  notes, page 234). Blunt lines: "If you think IT Operations has
  nothing to learn from Plant Operations, you're wrong. Dead wrong."
  (jbdamask's notes, page 91).
- Dialogue-heavy, with characters "in their various states of distress
  and triumph", and jargon spoken by characters ("What I Learned
  Producing The Phoenix Project Audiobook", IT Revolution,
  https://itrevolution.com/articles/what-i-learned-the-phoenix-project-audiobook/).
  The same article gives the book's length as 111,000 words, too long
  to copy for a message.
- "Less is more": a five-page opening became three pages and a
  six-paragraph press release a few panels in the graphic novel ("From
  Prose to Panels", IT Revolution,
  https://itrevolution.com/articles/from-prose-to-panels-the-journey-of-turning-the-phoenix-project-into-a-graphic-novel/).
  This is the reason for the 300-word cap.
- Wikipedia, "Show, don't tell"
  (https://en.wikipedia.org/wiki/Show,_don%27t_tell): the reader experiences the story
  "through actions, words, subtext, thoughts, senses, and feelings
  rather than through the author's exposition".

## AI tells

- Wikipedia, "Wikipedia:Signs of AI writing"
  (https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing): AI vocabulary by period
  (crucial, pivotal, key, underscore, showcase, highlight, enhance,
  foster, leverage, quietly and others), negative parallelisms ("Not
  just X, but also Y", "Not X, but Y", "Y rather than X"), the rule of
  three, avoiding "is" for "serves as" or "marks", overuse of
  boldface, emoji, and title case in headings. The word list here
  merges it with dotclaude's ai-prose-hygiene list, used by the other
  style skills.

## Decisions made with the developer (TASK-26, 2026-11-14)

- The cast: Andrew narrates; Miles is the agent; Adam is the
  developer; Julia is the fresh review session.
- At most 300 words a chapter, with per-step ranges.
- Chapter titles are the step's name and a plain subtitle of at most
  ten words. Dates were dropped: the book's dates track months of
  pressure, while a task runs a day or two and its notes already carry
  timestamps.
- The whole story is kept in the task's final summary, appended
  chapter by chapter.
- Bold only for the sentence that settles a design decision.
- Every step message is a chapter followed by a summary with options.
- A pushback that puts doubt on a decision triggers a Deep check, shown
  in the chapter, and the decision returns to Adam.
