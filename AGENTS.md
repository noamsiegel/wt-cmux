# AGENTS.md

This file orients agents working on **wt-cmux** itself. Read `CONTEXT.md` for plugin-specific invariants. Read git-wt's `docs/plugin-contract.md` for the host protocol; do not redefine it here.

## How to work here

- Keep code edits in `wt-cmux`; it is intentionally one Bash executable.
- Keep plugin metadata in `wt-plugin.json` in sync with implemented events and capabilities.
- Add or update bats tests in `tests/test_plugin.bats` for behavior changes.
- Run `bats tests/test_plugin.bats` and `bash -n wt-cmux` before yielding.
- Preserve `WT_CMUX_BIN`; tests and app-bundle installs depend on it.
- Never make worktree removal fail because cmux workspace is already gone.
- Never move plugin-contract details from git-wt into this repo.

## Docs index

- `README.md` — user-facing install, behavior, requirements, env vars, limitations.
- `CONTEXT.md` — maintainer invariants, module map, seams, ADRs.
- `CHANGELOG.md` — release history.
- `tests/test_plugin.bats` — plugin behavior tests.
- `wt-plugin.json` — manifest consumed by git-wt.
- git-wt `docs/plugin-contract.md` — source of truth for `git-wt.plugin.v0`.
- git-wt `docs/plugins.md` — plugin family comparison.

<!-- INDEX:START -->
<!-- Optional future agents-toc-managed index. -->
<!-- INDEX:END -->
