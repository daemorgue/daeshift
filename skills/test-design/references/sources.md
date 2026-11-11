# Sources for test-design

Each rule's source, with the text checked on its page on 2026-11-10.
Most rules come from bedford's testing guide, which cited these.

## How much to test

Kent Beck, [answering on Stack
Overflow](https://stackoverflow.com/questions/153234/how-deep-are-your-unit-tests):
"I get paid for code that works, not for tests, so my philosophy is to
test as little as possible to reach a given level of confidence".
Checked through the Stack Exchange API, since the page blocks scripts.

## Writing a test

[*Software Engineering at Google*, chapter
12](https://abseil.io/resources/swe-book/html/ch12.html):

- "rather than writing a test for each method, write a test for each
  behavior"
- "stick to straight-line code over clever logic"
- "Descriptive And Meaningful Phrases" (DAMP), preferred over removing
  every repeated line from tests

Kent Beck's [Test Desiderata](https://testdesiderata.com/) lists tests
as "Structure-insensitive". Guillermo Rauch, quoted by [Kent C.
Dodds](https://kentcdodds.com/blog/write-tests): "Write tests. Not too
many. Mostly integration."

## Regression test or one-time check

From dotclaude's testing knowledge, daemorgue's own rule: if a later
change could make a criterion false without anyone meaning to, it gets
a regression test.

## Coverage

Martin Fowler, [TestCoverage](https://martinfowler.com/bliki/TestCoverage.html):
"Test coverage is of little use as a numeric statement of how good your
tests are".
