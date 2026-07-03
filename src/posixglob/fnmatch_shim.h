#ifndef POSIXGLOB_FNMATCH_SHIM_H
#define POSIXGLOB_FNMATCH_SHIM_H

#ifdef __cplusplus
extern "C" {
#endif

int pg_fnmatch(const char *pattern, const char *text, int flags);
int pg_supported_flags(void);

#ifdef __cplusplus
}
#endif

#endif
