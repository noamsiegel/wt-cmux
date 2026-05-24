# Changelog

## [0.1.0] - 2026-05-24

### Added

- Initial `git-wt.plugin.v0` manifest for cmux.
- `wt:worktree-created` handling that creates or selects a cmux workspace for the worktree.
- `wt:worktree-removed` handling that closes the matching cmux workspace.
- `wt:focus` handling that selects the matching cmux workspace.
- `health`, `manifest`, and `--version` commands.
- Bats coverage for manifest, health, event handling, and shell syntax.
