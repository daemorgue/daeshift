# Sources for bash

Each rule's source, with the text checked on its page on 2026-11-10.
Where Google's Shell Style Guide and bedford's bash guide disagree,
Google's rule is used (decision-12 on the daemorgue board); bedford's
rules are kept where Google is silent.

## Google's rules used over bedford's

From the [Google Shell Style
Guide](https://google.github.io/styleguide/shellguide.html):

- "Indent 2 spaces. No tabs." (bedford used 4.)
- "Maximum line length is 80 characters." (bedford used 70.)
- "quote your variables; prefer "${var}" over "$var"" (bedford used
  `"$name"`.)
- "Given the choice between invoking a shell builtin and invoking a
  separate process, choose the builtin." (bedford banned parameter
  expansion such as `${path##*/}` in favor of `basename`.)

## Google's rules bedford lacked

- "Declaration and assignment must be separate statements when the
  assignment value is provided by a command substitution"
- "Use an explicit path when doing wildcard expansion of filenames."
- "Pipelines should be split one per line if they don't all fit on one
  line."
- "Executables should have a .sh extension or no extension." No
  extension is used.
- Google suggests "process substitution or the readarray builtin
  (bash4+)" over piping into `while`; bash 3.2 has no `readarray`, so
  process substitution.

## bedford's rules kept

- No `set -e`. Greg's Wiki,
  [BashFAQ/105](https://mywiki.wooledge.org/BashFAQ/105): "These rules
  are extremely convoluted, and they still fail to catch even some
  remarkably simple cases." Google only warns about `(( ))` "with set
  -e enabled". The other side: Aaron Maxwell's [unofficial strict
  mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/):
  "Your bash scripts will be more robust, reliable and maintainable if
  you start them like this" (with `set -euo pipefail`).
- bash 3.2: zsh "is the default shell for all newly created user
  accounts, starting with macOS" 10.15
  ([Apple](https://support.apple.com/en-us/102360)), and "3.2.57 is the
  last Bash release that was published under the GPL v2"
  ([Julio Merino](https://jmmv.dev/2019/11/macos-bash-baggage.html)),
  so macOS's bash stays at 3.2.
- When to use bash: Greg's Wiki,
  [BashWeaknesses](https://mywiki.wooledge.org/BashWeaknesses), and
  Google: "Shell should only be used for small utilities or simple
  wrapper scripts."
- `-q` on every script: the [Command Line Interface
  Guidelines](https://clig.dev/).
- Alphabetical ordering, the usage layout, output helpers and the
  `dependencies` array are daemorgue's own conventions.
- [ShellCheck](https://www.shellcheck.net/) for linting.
