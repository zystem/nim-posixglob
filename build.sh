#!/usr/bin/env sh
set -eu

mkdir -p build

nim c \
  -d:release \
  --nimcache:build/nimcache/release \
  --path:src \
  --out:build/posixglob-basic \
  examples/basic.nim
