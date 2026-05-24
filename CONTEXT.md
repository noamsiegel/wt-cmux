# wt-cmux CONTEXT

Architecture context for agents working on `wt-cmux` itself. User-facing docs live in `README.md`; the plugin protocol lives in git-wt's `docs/plugin-contract.md`.

## Load-bearing invariants

1. **git-wt owns the contract**: this repo implements `git-wt.plugin.v0`; it does not define manifest schema, event vocabulary, or validation rules. See `wt-plugin.json` and `wt-cmux` (`cmd_manifest`, `cmd_event`).
2. **Manifest and executable stay in lockstep**: `wt-plugin.json` names `cmux`, executable `wt-cmux`, events `wt:worktree-created`, `wt:worktree-removed`, and `wt:focus`; the script must keep matching handlers.
3. **Workspaces are found by stable worktree identity**: cmux workspace lookup must prefer stored `git-wt.path` metadata and tolerate known cmux JSON shape changes. See `workspace_id_for_path`.
4. **Created workspaces get git-wt metadata**: `create_workspace` must call `annotate_workspace` so later focus/remove can find the workspace without relying only on title.
5. **Missing workspace is not fatal on remove**: removed worktree cleanup returns `noop` when cmux workspace is absent. Reaping a worktree must not fail because UI state was already gone.
6. **cmux binary discovery is overridable**: `WT_CMUX_BIN` must keep working for tests and users whose cmux CLI is not on `PATH`.

## Module map

```
wt-cmux                  bash executable: subcommands, JSON parsing, cmux calls, event handlers
wt-plugin.json           plugin manifest consumed by git-wt
tests/test_plugin.bats   bats coverage for manifest, health, created, focus, removed
README.md                user-facing behavior, requirements, env vars, limitations
CHANGELOG.md             release notes
```

## Real seams

- Event handlers are the real seams: created binds/creates workspace, focus selects workspace, removed closes workspace.
- cmux CLI access is a real seam because tests and users need `WT_CMUX_BIN` to point at a stub or app-bundle binary.
- Workspace lookup is isolated because cmux JSON shape has changed and metadata fallback matters.

## Hypothetical seams

- Do not extract a shared shell plugin framework. Three plugins duplicate a tiny subcommand shell; the contract is still settling and a shared runtime dependency would be heavier than the duplication.
- Do not add a separate cmux adapter layer until there is more than one cmux API surface in real use.
- Do not move protocol documentation into this repo. git-wt is the host and contract authority.

## Public API stability

No library API. The public surface is the executable CLI (`manifest`, `health`, `event <name>`, `--version`) plus `wt-plugin.json`. Breaking changes require a plugin release and matching git-wt compatibility note.

## ADRs

ADR-001 — use cmux metadata for identity: created workspaces store `git-wt.path` and `git-wt.id` so focus/remove can find the right workspace after title or cwd drift.

ADR-002 — keep socket/PATH configuration external: `WT_CMUX_BIN` and cmux socket settings remain environment/app concerns; the plugin reports health instead of installing or reconfiguring cmux.
