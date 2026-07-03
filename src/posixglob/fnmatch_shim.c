#include "fnmatch_shim.h"

#include <fnmatch.h>

#define PG_NOESCAPE   1
#define PG_PATHNAME   2
#define PG_PERIOD     4
#define PG_CASEFOLD   8
#define PG_LEADINGDIR 16

int pg_supported_flags(void) {
    int flags = 0;

#ifdef FNM_NOESCAPE
    flags |= PG_NOESCAPE;
#endif
#ifdef FNM_PATHNAME
    flags |= PG_PATHNAME;
#endif
#ifdef FNM_PERIOD
    flags |= PG_PERIOD;
#endif
#ifdef FNM_CASEFOLD
    flags |= PG_CASEFOLD;
#endif
#ifdef FNM_LEADING_DIR
    flags |= PG_LEADINGDIR;
#endif

    return flags;
}

int pg_fnmatch(const char *pattern, const char *text, int flags) {
    int native_flags = 0;

#ifdef FNM_NOESCAPE
    if (flags & PG_NOESCAPE) {
        native_flags |= FNM_NOESCAPE;
    }
#endif

#ifdef FNM_PATHNAME
    if (flags & PG_PATHNAME) {
        native_flags |= FNM_PATHNAME;
    }
#endif

#ifdef FNM_PERIOD
    if (flags & PG_PERIOD) {
        native_flags |= FNM_PERIOD;
    }
#endif

#ifdef FNM_CASEFOLD
    if (flags & PG_CASEFOLD) {
        native_flags |= FNM_CASEFOLD;
    }
#endif

#ifdef FNM_LEADING_DIR
    if (flags & PG_LEADINGDIR) {
        native_flags |= FNM_LEADING_DIR;
    }
#endif

    return fnmatch(pattern, text, native_flags);
}
