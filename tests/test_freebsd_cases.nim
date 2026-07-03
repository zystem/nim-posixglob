# Test cases derived from FreeBSD libc fnmatch regression tests.
#
# The upstream FreeBSD file is BSD-2-Clause licensed:
# tools/regression/lib/libc/gen/test-fnmatch.c
# Copyright (c) 2010 Jilles Tjoelker. All rights reserved.
#
# These cases intentionally exercise POSIX fnmatch behavior across glibc,
# musl, BSD libc, and Apple libSystem via the posixglob Nim wrapper.

import std/unittest
import posixglob

type
  Case = tuple[pattern: string, text: string, flags: set[GlobFlag], expected: bool]
  OptionalCase = tuple[
    pattern: string,
    text: string,
    flags: set[GlobFlag],
    expected: bool,
    required: GlobFlag
  ]

let coreCases: seq[Case] = @[
    (pattern: "", text: "", flags: {}, expected: true),
    (pattern: "a", text: "a", flags: {}, expected: true),
    (pattern: "a", text: "b", flags: {}, expected: false),
    (pattern: "a", text: "A", flags: {}, expected: false),
    (pattern: "*", text: "a", flags: {}, expected: true),
    (pattern: "*", text: "aa", flags: {}, expected: true),
    (pattern: "*a", text: "a", flags: {}, expected: true),
    (pattern: "*a", text: "b", flags: {}, expected: false),
    (pattern: "*a*", text: "b", flags: {}, expected: false),
    (pattern: "*a*b*", text: "ab", flags: {}, expected: true),
    (pattern: "*a*b*", text: "qaqbq", flags: {}, expected: true),
    (pattern: "*a*bb*", text: "qaqbqbbq", flags: {}, expected: true),
    (pattern: "*a*bc*", text: "qaqbqbcq", flags: {}, expected: true),
    (pattern: "*a*bb*", text: "qaqbqbb", flags: {}, expected: true),
    (pattern: "*a*bc*", text: "qaqbqbc", flags: {}, expected: true),
    (pattern: "*a*bb", text: "qaqbqbb", flags: {}, expected: true),
    (pattern: "*a*bc", text: "qaqbqbc", flags: {}, expected: true),
    (pattern: "*a*bb", text: "qaqbqbbq", flags: {}, expected: false),
    (pattern: "*a*bc", text: "qaqbqbcq", flags: {}, expected: false),
    (pattern: "*a*a*a*a*a*a*a*a*a*a*", text: "aaaaaaaaa", flags: {}, expected: false),
    (pattern: "*a*a*a*a*a*a*a*a*a*a*", text: "aaaaaaaaaa", flags: {}, expected: true),
    (pattern: "*a*a*a*a*a*a*a*a*a*a*", text: "aaaaaaaaaaa", flags: {}, expected: true),
    (pattern: ".*.*.*.*.*.*.*.*.*.*", text: ".........", flags: {}, expected: false),
    (pattern: ".*.*.*.*.*.*.*.*.*.*", text: "..........", flags: {}, expected: true),
    (pattern: ".*.*.*.*.*.*.*.*.*.*", text: "...........", flags: {}, expected: true),
    (pattern: "*?*?*?*?*?*?*?*?*?*?*", text: "123456789", flags: {}, expected: false),
    (pattern: "??????????*", text: "123456789", flags: {}, expected: false),
    (pattern: "*??????????", text: "123456789", flags: {}, expected: false),
    (pattern: "*?*?*?*?*?*?*?*?*?*?*", text: "1234567890", flags: {}, expected: true),
    (pattern: "??????????*", text: "1234567890", flags: {}, expected: true),
    (pattern: "*??????????", text: "1234567890", flags: {}, expected: true),
    (pattern: "*?*?*?*?*?*?*?*?*?*?*", text: "12345678901", flags: {}, expected: true),
    (pattern: "??????????*", text: "12345678901", flags: {}, expected: true),
    (pattern: "*??????????", text: "12345678901", flags: {}, expected: true),
    (pattern: "[x]", text: "x", flags: {}, expected: true),
    (pattern: "[*]", text: "*", flags: {}, expected: true),
    (pattern: "[?]", text: "?", flags: {}, expected: true),
    (pattern: "[", text: "[", flags: {}, expected: true),
    (pattern: "[[]", text: "[", flags: {}, expected: true),
    (pattern: "[[]", text: "x", flags: {}, expected: false),
    (pattern: "[*]", text: "", flags: {}, expected: false),
    (pattern: "[*]", text: "x", flags: {}, expected: false),
    (pattern: "[?]", text: "x", flags: {}, expected: false),
    (pattern: "*[*]*", text: "foo*foo", flags: {}, expected: true),
    (pattern: "*[*]*", text: "foo", flags: {}, expected: false),
    (pattern: "[0-9]", text: "0", flags: {}, expected: true),
    (pattern: "[0-9]", text: "5", flags: {}, expected: true),
    (pattern: "[0-9]", text: "9", flags: {}, expected: true),
    (pattern: "[0-9]", text: "/", flags: {}, expected: false),
    (pattern: "[0-9]", text: ":", flags: {}, expected: false),
    (pattern: "[0-9]", text: "*", flags: {}, expected: false),
    (pattern: "[!0-9]", text: "0", flags: {}, expected: false),
    (pattern: "[!0-9]", text: "5", flags: {}, expected: false),
    (pattern: "[!0-9]", text: "9", flags: {}, expected: false),
    (pattern: "[!0-9]", text: "/", flags: {}, expected: true),
    (pattern: "[!0-9]", text: ":", flags: {}, expected: true),
    (pattern: "[!0-9]", text: "*", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a0", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a5", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a9", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a/", flags: {}, expected: false),
    (pattern: "*[0-9]", text: "a:", flags: {}, expected: false),
    (pattern: "*[0-9]", text: "a*", flags: {}, expected: false),
    (pattern: "*[!0-9]", text: "a0", flags: {}, expected: false),
    (pattern: "*[!0-9]", text: "a5", flags: {}, expected: false),
    (pattern: "*[!0-9]", text: "a9", flags: {}, expected: false),
    (pattern: "*[!0-9]", text: "a/", flags: {}, expected: true),
    (pattern: "*[!0-9]", text: "a:", flags: {}, expected: true),
    (pattern: "*[!0-9]", text: "a*", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a00", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a55", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a99", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a0a0", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a5a5", flags: {}, expected: true),
    (pattern: "*[0-9]", text: "a9a9", flags: {}, expected: true),
    (pattern: "\\*", text: "*", flags: {}, expected: true),
    (pattern: "\\?", text: "?", flags: {}, expected: true),
    (pattern: "\\[x]", text: "[x]", flags: {}, expected: true),
    (pattern: "\\[", text: "[", flags: {}, expected: true),
    (pattern: "\\\\", text: "\\", flags: {}, expected: true),
    (pattern: "*\\**", text: "foo*foo", flags: {}, expected: true),
    (pattern: "*\\**", text: "foo", flags: {}, expected: false),
    (pattern: "*\\\\*", text: "foo\\foo", flags: {}, expected: true),
    (pattern: "*\\\\*", text: "foo", flags: {}, expected: false),
    (pattern: "\\(", text: "(", flags: {}, expected: true),
    (pattern: "\\a", text: "a", flags: {}, expected: true),
    (pattern: "\\*", text: "a", flags: {}, expected: false),
    (pattern: "\\?", text: "a", flags: {}, expected: false),
    (pattern: "\\*", text: "\\*", flags: {}, expected: false),
    (pattern: "\\?", text: "\\?", flags: {}, expected: false),
    (pattern: "\\[x]", text: "\\[x]", flags: {}, expected: false),
    (pattern: "\\[x]", text: "\\x", flags: {}, expected: false),
    (pattern: "\\[", text: "\\[", flags: {}, expected: false),
    (pattern: "\\(", text: "\\(", flags: {}, expected: false),
    (pattern: "\\a", text: "\\a", flags: {}, expected: false),
    (pattern: "\\", text: "\\", flags: {}, expected: false),
    (pattern: "\\*", text: "\\*", flags: {gfNoEscape}, expected: true),
    (pattern: "\\?", text: "\\?", flags: {gfNoEscape}, expected: true),
    (pattern: "\\", text: "\\", flags: {gfNoEscape}, expected: true),
    (pattern: "\\\\", text: "\\", flags: {gfNoEscape}, expected: false),
    (pattern: "\\\\", text: "\\\\", flags: {gfNoEscape}, expected: true),
    (pattern: "*\\*", text: "foo\\foo", flags: {gfNoEscape}, expected: true),
    (pattern: "*\\*", text: "foo", flags: {gfNoEscape}, expected: false),
    (pattern: "*", text: ".", flags: {gfPeriod}, expected: false),
    (pattern: "?", text: ".", flags: {gfPeriod}, expected: false),
    (pattern: ".*", text: ".", flags: {}, expected: true),
    (pattern: ".*", text: "..", flags: {}, expected: true),
    (pattern: ".*", text: ".a", flags: {}, expected: true),
    (pattern: "[0-9]", text: ".", flags: {gfPeriod}, expected: false),
    (pattern: "a*", text: "a.", flags: {}, expected: true),
    (pattern: "a/a", text: "a/a", flags: {gfPathName}, expected: true),
    (pattern: "a/*", text: "a/a", flags: {gfPathName}, expected: true),
    (pattern: "*/a", text: "a/a", flags: {gfPathName}, expected: true),
    (pattern: "*/*", text: "a/a", flags: {gfPathName}, expected: true),
    (pattern: "a*b/*", text: "abbb/x", flags: {gfPathName}, expected: true),
    (pattern: "a*b/*", text: "abbb/.x", flags: {gfPathName}, expected: true),
    (pattern: "*", text: "a/a", flags: {gfPathName}, expected: false),
    (pattern: "*/*", text: "a/a/a", flags: {gfPathName}, expected: false),
    (pattern: "b/*", text: "b/.x", flags: {gfPathName, gfPeriod}, expected: false),
    (pattern: "b*/*", text: "a/.x", flags: {gfPathName, gfPeriod}, expected: false),
    (pattern: "b/.*", text: "b/.x", flags: {gfPathName, gfPeriod}, expected: true),
    (pattern: "b*/.*", text: "b/.x", flags: {gfPathName, gfPeriod}, expected: true),
    (pattern: "a*b/*", text: "abbb/.x", flags: {gfPathName, gfPeriod}, expected: false)
]

let optionalCases: seq[OptionalCase] = @[
    (pattern: "a", text: "A", flags: {gfCaseFold}, expected: true, required: gfCaseFold),
    (pattern: "A", text: "a", flags: {gfCaseFold}, expected: true, required: gfCaseFold),
    (pattern: "[a]", text: "A", flags: {gfCaseFold}, expected: true, required: gfCaseFold),
    (pattern: "[A]", text: "a", flags: {gfCaseFold}, expected: true, required: gfCaseFold),
    (pattern: "a", text: "b", flags: {gfCaseFold}, expected: false, required: gfCaseFold),
    (pattern: "a", text: "a/b", flags: {gfPathName}, expected: false, required: gfPathName),
    (pattern: "*", text: "a/b", flags: {gfPathName}, expected: false, required: gfPathName),
    (pattern: "*b", text: "a/b", flags: {gfPathName}, expected: false, required: gfPathName),
    (pattern: "a", text: "a/b", flags: {gfPathName, gfLeadingDir}, expected: true, required: gfLeadingDir),
    (pattern: "*", text: "a/b", flags: {gfPathName, gfLeadingDir}, expected: true, required: gfLeadingDir),
    (pattern: "*", text: ".a/b", flags: {gfPathName, gfLeadingDir}, expected: true, required: gfLeadingDir),
    (pattern: "*a", text: ".a/b", flags: {gfPathName, gfLeadingDir}, expected: true, required: gfLeadingDir),
    (pattern: "*", text: ".a/b", flags: {gfPathName, gfPeriod, gfLeadingDir}, expected: false, required: gfLeadingDir),
    (pattern: "*a", text: ".a/b", flags: {gfPathName, gfPeriod, gfLeadingDir}, expected: false, required: gfLeadingDir)
]

proc flagNames(flags: set[GlobFlag]): string =
  result = "{"
  var first = true
  for flag in GlobFlag:
    if flag in flags:
      if not first:
        result.add(", ")
      result.add($flag)
      first = false
  result.add("}")

proc printFailure(i: int; pattern, text: string; flags: set[GlobFlag]; expected, actual: bool) =
  echo "failed case ", i
  echo "  pattern:  ", pattern.repr
  echo "  text:     ", text.repr
  echo "  flags:    ", flagNames(flags)
  echo "  expected: ", expected
  echo "  actual:   ", actual

suite "FreeBSD-derived fnmatch cases":
  test "core POSIX-compatible cases":
    for i, c in coreCases:
      let actual = globMatch(c.pattern, c.text, c.flags)
      if actual != c.expected:
        printFailure(i, c.pattern, c.text, c.flags, c.expected, actual)
      check actual == c.expected

  test "optional platform extension cases":
    for i, c in optionalCases:
      if supports(c.required):
        let actual = globMatch(c.pattern, c.text, c.flags)
        if actual != c.expected:
          printFailure(i, c.pattern, c.text, c.flags, c.expected, actual)
          echo "  required: ", $c.required
        check actual == c.expected
