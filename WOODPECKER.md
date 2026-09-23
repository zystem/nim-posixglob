# Woodpecker publication credentials

GitHub releases use `woodpeckerci/plugin-release:0.3.1` with the existing
`github_token` secret. Its current global restriction to tag events and the
release plugin is compatible with this configuration.

Validate the workflow without publishing:

```sh
woodpecker-cli --disable-update-check lint --strict
```
