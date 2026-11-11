# Sources for software-design

Each rule's source, with the text checked on its page on 2026-11-10.
Most rules come from bedford's design guide, which cited these.

## Ordering

Alphabetical ordering is daemorgue's own rule, from bedford's bash
guide, applied to every language. Google's Shell Style Guide asks only
that functions sit together below constants, so it does not conflict.

The other side: Robert C. Martin's stepdown rule (*Clean Code*,
chapter 3) orders functions so each caller sits above the functions it
calls. Not quoted here: the book was not checked.

## Readability

Rich Hickey separates simple from easy in [Simple Made
Easy](https://www.infoq.com/presentations/Simple-Made-Easy/). Brian
Kernighan and P. J. Plauger, *The Elements of Programming Style*:
debugging is harder than writing, so code written as cleverly as
possible is too clever to debug (paraphrased; the book was not
checked).

## Build only what is needed

[Google's code review guide](https://google.github.io/eng-practices/review/reviewer/looking-for.html):
"Encourage developers to solve the problem they know needs to be solved
now". Martin Fowler names the idea
[YAGNI](https://martinfowler.com/bliki/Yagni.html), "You Aren't Gonna
Need It".

## Duplication

Sandi Metz, [The Wrong
Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction):
"duplication is far cheaper than the wrong abstraction".

## Functions

John Ousterhout's deep modules (*A Philosophy of Software Design*).
Bertrand Meyer's command-query separation, explained by [Martin
Fowler](https://martinfowler.com/bliki/CommandQuerySeparation.html).
Guard clauses: Martin Fowler, *Refactoring*. Books paraphrased, not
checked.

## Errors and output

Eric S. Raymond's Rule of Repair and Rule of Silence, [The Art of Unix
Programming](http://www.catb.org/esr/writings/taoup/html/ch01s06.html).
The [Command Line Interface Guidelines](https://clig.dev/) for output
meant for people.
