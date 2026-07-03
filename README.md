# posixglob

Small POSIX glob pattern matcher for Nim.

`posixglob` is a thin Nim wrapper around the system `fnmatch()` function. It is intended for matching strings against POSIX shell-style glob patterns.

It supports the POSIX glob syntax provided by `fnmatch()`:

```text
*
?
[abc]
[a-z]
[!abc]
```

It does **not** implement Bash/Git extensions such as:

```text
**
@(foo|bar)
!(foo)
{foo,bar}
```

## Supported systems

This package targets POSIX-like systems with `fnmatch()`:

- Linux with glibc: Debian, Ubuntu, RHEL, Fedora, etc.
- Linux with musl: Alpine Linux
- FreeBSD
- OpenBSD
- NetBSD
- macOS

Windows is not supported by this package.

## Why a small C shim exists

`FNM_*` constants are C preprocessor macros, not exported symbols. Their numeric values are not guaranteed by POSIX.

For portability, this package vendors a tiny C shim that maps stable Nim-side flags to the native system `FNM_*` macros at compile time.

There is no external `libposixglob.so` or `libposixglob.a` dependency. Nim compiles the shim together with your program.

## Installation

From a local checkout:

```sh
nimble install
```

From Git:

```sh
nimble install https://github.com/zystem/nim-posixglob
```

## Usage

```nim
import posixglob

if globMatch("*.nim", "main.nim"):
  echo "match"
```

With flags:

```nim
import posixglob

# Slash must be matched explicitly.
doAssert globMatch("src/*.nim", "src/main.nim", {gfPathName})
doAssert not globMatch("src/*.nim", "src/app/main.nim", {gfPathName})

# Leading dot must be matched explicitly.
doAssert not globMatch("*", ".env", {gfPeriod})
doAssert globMatch(".*", ".env", {gfPeriod})
```

Check optional extension support:

```nim
import posixglob

if supports(gfCaseFold):
  doAssert globMatch("a", "A", {gfCaseFold})
```

Comma-separated pattern lists are application-level syntax, not POSIX glob
syntax. Use `parseGlobPatterns()` when you want to accept values such as an
environment variable:

```nim
import posixglob

let patterns = parseGlobPatterns("dev-*,ops-*,repo-?")

if globMatchAny(patterns, "ops-tool"):
  echo "match"
```

## API

```nim
type GlobFlag = enum
  gfNoEscape
  gfPathName
  gfPeriod
  gfCaseFold
  gfLeadingDir

proc globMatch(pattern, text: string; flags: set[GlobFlag] = {}): bool
proc match(pattern, text: string; flags: set[GlobFlag] = {}): bool
proc parseGlobPatterns(patterns: string; separator: char = ','): seq[string]
proc globMatchAny(
  patterns: openArray[string];
  text: string;
  flags: set[GlobFlag] = {}
): bool
proc supports(flag: GlobFlag): bool
proc supportedFlags(): set[GlobFlag]
```

`gfCaseFold` and `gfLeadingDir` are common libc extensions, not portable POSIX guarantees. Use `supports()` before relying on them.

## Tests

Run all tests:

```sh
nimble test
```

Run only the FreeBSD-derived compatibility table:

```sh
nimble testFreebsd
```

The large compatibility table in `tests/test_freebsd_cases.nim` is derived from the BSD-2-Clause FreeBSD libc regression test `tools/regression/lib/libc/gen/test-fnmatch.c` by Jilles Tjoelker.

The normal package license is MIT. The test cases derived from FreeBSD keep their BSD notice in the test file header.

## Local build workflow

Build the release smoke binary:

```sh
nimble buildRelease
```

or:

```sh
./build.sh
```

Both commands write generated files under `build/`, including `build/nimcache`, so normal development does not require compiler artifacts in `$HOME`.

The release smoke binary is `build/posixglob-basic`. It compiles the package and runs the example program; this package is a library and does not expose a service daemon.

## Configuration

`posixglob` has no runtime configuration, required environment variables, optional environment variables, long-running mode, or CLI options. Consumers configure matching behavior through the `flags` argument in the Nim API.

The service-oriented release items from the release template, such as `--once`, environment-based app config, HTTP e2e mocks, and downstream storage checks, are not applicable to this library.

## Helm

No Helm chart is shipped. This repository packages a Nim library, not a Kubernetes workload, so values files, secrets, runtime artifacts, and chart publishing would be artificial and are intentionally omitted.

## License

MIT for the package code.

The FreeBSD-derived test cases are BSD-2-Clause and are used only as test data.

## Release

Versioning is coordinated through:

- `posixglob.nimble` package `version`
- Git tags in the form `v0.1.6`

Release checklist:

```sh
nimble test -y
./build.sh
```

On a `v*` tag push, GitHub Actions:

- runs the Nim test suite
- builds the Linux release smoke binary
- creates a GitHub Release and attaches `posixglob-basic-linux-amd64`

Published artifacts:

- Nim package source
- Linux smoke binary attached to GitHub Releases
