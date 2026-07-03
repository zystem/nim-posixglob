import std/unittest
import posixglob

suite "posixglob API":
  test "basic wildcards":
    check globMatch("*.nim", "main.nim")
    check globMatch("file?.log", "file1.log")
    check not globMatch("file?.log", "file10.log")

  test "character classes":
    check globMatch("[a-z]*.nim", "main.nim")
    check globMatch("[!0-9]*.nim", "main.nim")
    check not globMatch("[!0-9]*.nim", "1main.nim")

  test "pathname flag":
    check globMatch("src/*.nim", "src/main.nim", {gfPathName})
    check not globMatch("src/*.nim", "src/app/main.nim", {gfPathName})
    check globMatch("src/*.nim", "src/app/main.nim")

  test "period flag":
    check not globMatch("*", ".env", {gfPeriod})
    check globMatch(".*", ".env", {gfPeriod})

  test "no escape flag":
    check globMatch(r"a\*", r"a*", {})
    check not globMatch(r"a\*", r"a*", {gfNoEscape})

  test "supported flags introspection":
    check gfNoEscape in supportedFlags()
    check gfPathName in supportedFlags()
    check gfPeriod in supportedFlags()

  test "alias":
    check match("*.nim", "main.nim")

  test "comma-separated pattern lists":
    check parseGlobPatterns("") == newSeq[string]()
    check parseGlobPatterns("src/*, tests/*, ,*.nim") == @["src/*", "tests/*", "*.nim"]
    check parseGlobPatterns("src/*;tests/*", ';') == @["src/*", "tests/*"]

  test "match any parsed pattern":
    let patterns = parseGlobPatterns("dev-*, ops-*, repo-?")
    check globMatchAny(patterns, "dev-api")
    check globMatchAny(patterns, "ops-tool")
    check globMatchAny(patterns, "repo-a")
    check not globMatchAny(patterns, "repo-aa")
    check not globMatchAny(patterns, "prod-api")
    check not globMatch("dev-*,ops-*", "ops-tool")
