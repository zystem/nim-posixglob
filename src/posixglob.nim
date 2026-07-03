## Small POSIX glob pattern matcher for Nim.
##
## This module wraps libc fnmatch() through a tiny C shim.
## It supports POSIX glob syntax, not Bash/Git extensions.

when not defined(posix):
  {.error: "posixglob requires a POSIX-like system with fnmatch().".}

{.compile: "posixglob/fnmatch_shim.c".}

const
  pgNoEscape* = 1.cint
  pgPathName* = 2.cint
  pgPeriod* = 4.cint
  pgCaseFold* = 8.cint
  pgLeadingDir* = 16.cint

type
  GlobFlag* = enum
    ## Disable backslash escaping.
    gfNoEscape
    ## Slash '/' must be matched explicitly.
    gfPathName
    ## Leading '.' must be matched explicitly.
    gfPeriod
    ## Case-insensitive matching, if supported by the platform.
    gfCaseFold
    ## Match leading directory, if supported by the platform.
    gfLeadingDir

proc pg_fnmatch(pattern, text: cstring; flags: cint): cint
  {.importc: "pg_fnmatch".}

proc pg_supported_flags(): cint
  {.importc: "pg_supported_flags".}

proc toNativeFlags(flags: set[GlobFlag]): cint =
  result = 0.cint
  if gfNoEscape in flags:
    result = result or pgNoEscape
  if gfPathName in flags:
    result = result or pgPathName
  if gfPeriod in flags:
    result = result or pgPeriod
  if gfCaseFold in flags:
    result = result or pgCaseFold
  if gfLeadingDir in flags:
    result = result or pgLeadingDir

proc supports*(flag: GlobFlag): bool =
  ## Returns true when the current platform exposes the corresponding FNM_* macro.
  let mask = case flag
    of gfNoEscape: pgNoEscape
    of gfPathName: pgPathName
    of gfPeriod: pgPeriod
    of gfCaseFold: pgCaseFold
    of gfLeadingDir: pgLeadingDir
  (pg_supported_flags() and mask) != 0

proc supportedFlags*(): set[GlobFlag] =
  ## Returns the set of fnmatch flags supported by the current platform.
  for flag in GlobFlag:
    if supports(flag):
      result.incl(flag)

proc globMatch*(pattern, text: string; flags: set[GlobFlag] = {}): bool =
  ## Returns true when `text` matches POSIX glob `pattern`.
  ##
  ## Invalid patterns and non-matches both return false.
  pg_fnmatch(pattern.cstring, text.cstring, toNativeFlags(flags)) == 0

proc match*(pattern, text: string; flags: set[GlobFlag] = {}): bool =
  ## Alias for globMatch().
  globMatch(pattern, text, flags)
