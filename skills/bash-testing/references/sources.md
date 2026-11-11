# Sources for bash-testing

Each rule's source, with the text checked on its page on 2026-11-10.
Google's Shell Style Guide says nothing about testing, so bedford's
rules are kept (decision-12 on the daemorgue board).

- bats-core's [gotchas](https://bats-core.readthedocs.io/en/stable/gotchas.html):
  "Older versions, like 3.2 on MacOS, don't abort the test when they
  fail, unless they are the last command before the (test) function
  returns". This is why every check goes through an `assert_` function.
- bats-core's [writing tests](https://bats-core.readthedocs.io/en/stable/writing-tests.html):
  `$status` holds the exit code and `$output` "the combined contents of
  the command's standard output and standard error streams";
  "`$BATS_TEST_TMPDIR` is a temporary directory unique for each test".
- [bats-assert](https://github.com/bats-core/bats-assert) is "a helper
  library providing common assertions for Bats". It is not used, to
  avoid a dependency; the two hand-written asserts cover what the tests
  need.
- One test file per script, `HOME` in a temporary folder, and test names
  starting with the script's name are bedford's own conventions.
