# Package
version       = "0.1.6"
author        = "Andrii Zahriadskyi"
description   = "Small POSIX glob pattern matcher for Nim, backed by libc fnmatch()."
license       = "MIT"
srcDir        = "src"

# Dependencies
requires "nim >= 1.6.0"

# Tasks
task buildRelease, "Build release smoke binary":
  exec "mkdir -p build"
  exec "nim c -d:release --nimcache:build/nimcache/release --path:src --out:build/posixglob-basic examples/basic.nim"

task test, "Run all tests":
  exec "mkdir -p build/nimcache"
  exec "nim c -r --nimcache:build/nimcache/test --path:src tests/all.nim"

task testBasic, "Run API smoke tests":
  exec "mkdir -p build/nimcache"
  exec "nim c -r --nimcache:build/nimcache/test-basic --path:src tests/test_posixglob.nim"

task testFreebsd, "Run FreeBSD-derived fnmatch compatibility cases":
  exec "mkdir -p build/nimcache"
  exec "nim c -r --nimcache:build/nimcache/test-freebsd --path:src tests/test_freebsd_cases.nim"
