---
name: reference-writing
description: How to write a reference page (Diátaxis) that describes a part of a system exactly, so a reader can look up what it is, what it guarantees and how to use it. Use when writing or reviewing a wiki README.md or any other reference page, alongside style-technical-writing.
---

# Writing reference

A reader consults reference while working; nobody reads it through.
It must be complete, exact and easy to scan. Read
`references/sources.md` only when asked why. If style-technical-writing
is not installed yet, say so and follow this skill alone.

## Rules

- **Stick to description.** State what the part is, how it behaves and
  how it is used. No teaching and no steps toward a goal. A short clause
  giving a reason is fine; longer reasoning, history or opinion goes in
  the part's `explanation.md`, and tasks go in a how-to guide.
- **Detailed enough to rebuild it.** An agent given only this page must
  be able to build a part that behaves identically at the user's end,
  in any language. Specify everything that crosses a boundary: inputs
  and outputs, options and their defaults, exit statuses, files and
  their formats, environment variables, APIs described language-neutrally
  (names, parameters, results, errors), and how processes call each
  other (arguments, call order, results). Leave out internal code. The
  call syntax for one language (a Python import, say) goes in a how-to
  guide. The contract binds (decision-17; see the first gotcha).
- **Self-contained.** The wiki may be published without the rest of
  its repository, so never link to a file outside `wiki/`. Name a test
  or a file as text when the reader needs it. Links to public web pages
  are fine.
- **Shape it like the thing.** A wiki page follows the C4 map in
  `maps/<repo>/` (the project repo's groma map, read with `groma view`): the
  system's page lists its containers, a container's page lists its
  components, each with a link down. Use each element's title from the
  map, and its ID as the folder name.
- **Start from the template** for the page's level:
  `references/templates/project.md`, `system.md` or `container.md`
  (`component.md` follows once its first page is approved).
  The developer approved these as the standard (2026-11-11).
- **Same sections, same order, every time,** so a reader knows where to
  look:

  1. One sentence: what it is.
  2. A diagram, followed by one or two sentences saying what it shows.
  3. **Contract**: what the part guarantees, as a short list of
     behaviours.
  4. **Interface**: commands, flags, inputs, outputs, files, settings,
     environment variables, exit codes: a table where there are more
     than three.
  5. **Verification**: a table pairing each contract item with the test
     or CI check that proves it, or "Not checked" when nothing does.
  6. **Systems** on a project page, **Containers** on a system page,
     **Components** on a container
     page: the C4 elements one level down. Open with a Mermaid C4
     diagram (`C4Context`, `C4Container` or `C4Component`), with
     the relationships between elements and each element colored by
     status with `UpdateElementStyle` (green built, amber in part, red
     planned). Then a sentence summarizing the counts, then a table with
     each element's status and a link to its page.

  No "Decisions" section: reasons belong in the explanation page.

  Leave out a section with nothing to say.
- **State facts plainly:** "`--project NAME` starts the runner in
  NAME's folder." Use "must" and "never" only for rules the reader has
  to follow.
- **Give a short example** of usage where it shows a fact faster than
  a sentence; no walkthroughs.
- **Planned parts** get one line: what they will do and the task that
  builds them.

## Gotchas

- The contract lists what the part is required to do, not what it
  happens to do today. If the code differs, never edit the contract to
  match the code: report the mismatch to the developer or as a task,
  which decides which one is wrong.
- A page that needs "first," "then" or "because" in most sentences has
  drifted into a how-to guide or explanation; move that part out.
- Keep it scannable. If a section outgrows a screen, move it to its own
  reference page and link to it. Never drop entries to make it fit.
