# Changelog

## [0.1.3] - 2026-05-24

### Added
- `.github/workflows/test.yml`: CI runs `bash -n` + `bats tests/` + `git-wt plugin validate .` against every push and PR. The validate step catches manifest schema drift against `git-wt.plugin.v0`.

### Fixed
- `health` no longer returns exit 30 when the cmux CLI/socket are unavailable. Health output now reports runtime availability via `cmux_available` and `socket_available` fields, returning exit 0 if the manifest and parser deps are valid. Event handlers still fail if cmux is required and missing — this only changes the read-only `health` introspection contract. Required so `git-wt plugin validate .` works on CI runners without cmux installed.
- Bumped manifest + script version to 0.1.3.

## [0.1.2] - 2026-05-24

### Added
- `RELEASING.md`: release checklist with version-site reminders (script + manifest), cmux smoke checks, `WT_CMUX_BIN` override note, and recovery steps.
- `tests/test_version.bats`: asserts script `VERSION` matches `wt-plugin.json` version.

### Changed
- Bumped manifest + script version to 0.1.2.

## [0.1.1] - 2026-05-24

### Added
- `CONTEXT.md` and `AGENTS.md` for plugin-specific invariants and agent orientation.

### Changed
- Slimmed `README.md` to plugin-specific behavior; links to `git-wt/docs/plugin-contract.md` for the protocol spec and to `git-wt/docs/plugins.md` for the family-wide comparison.
- Bumped manifest + script version to 0.1.1.

## [0.1.0] - 2026-05-24

### Added

- Initial `git-wt.plugin.v0` manifest for cmux.
- `wt:worktree-created` handling that creates or selects a cmux workspace for the worktree.
- `wt:worktree-removed` handling that closes the matching cmux workspace.
- `wt:focus` handling that selects the matching cmux workspace.
- `health`, `manifest`, and `--version` commands.
- Bats coverage for manifest, health, event handling, and shell syntax.
