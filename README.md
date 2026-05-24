# wt-cmux

[git-wt](https://github.com/noamsiegel/git-wt) plugin for [cmux](https://github.com/manaflow-ai/cmux), the native macOS terminal multiplexer for AI coding agents.

`wt-cmux` does one thing: bridge git-wt worktree lifecycle events to cmux workspaces. It implements `git-wt.plugin.v0`; the protocol source of truth is git-wt's [`docs/plugin-contract.md`](https://github.com/noamsiegel/git-wt/blob/main/docs/plugin-contract.md). Plugin-family comparison lives in git-wt's [`docs/plugins.md`](https://github.com/noamsiegel/git-wt/blob/main/docs/plugins.md).

## Install

From the git-wt registry:

```bash
wt plugin install cmux
```

Explicit install from GitHub:

```bash
wt plugin install noamsiegel/wt-cmux
```

Local development:

```bash
wt plugin link /path/to/wt-cmux
```

## Behavior

| git-wt event | cmux action |
|---|---|
| `wt:worktree-created` | Create a cmux workspace, attach `git-wt` metadata, and send `cd <worktree>` to the terminal. If a workspace for the worktree already exists, select it instead. |
| `wt:worktree-removed` | Find the cmux workspace by stored worktree path metadata and close it. Missing workspace is a no-op. |
| `wt:focus` | Find the cmux workspace by stored worktree path metadata and select it. Missing workspace returns `not-found`. |

cmux calls use the public CLI documented at <https://cmux.com/docs/api>: `new-workspace`, `list-workspaces --json`, `current-workspace --json`, `select-workspace`, `close-workspace`, `set-status`, `log`, `send`, and `send-key`.

## Requirements

- `git-wt` with `git-wt.plugin.v0` support.
- cmux CLI available as `cmux`, or `WT_CMUX_BIN` pointing to the cmux binary.
- `yq` for JSON parsing.

cmux installs its CLI inside the macOS app bundle. If it is not on `PATH`, create the symlink documented by cmux:

```bash
sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
```

If `git-wt` runs outside a cmux terminal, cmux socket access may need to allow local non-cmux processes:

```bash
CMUX_SOCKET_MODE=allowAll
```

or equivalent cmux Settings access.

## Commands

```bash
wt-cmux manifest
wt-cmux health
wt-cmux event wt:worktree-created < payload.json
wt-cmux --version
```

## Environment

- `WT_CMUX_BIN=/path/to/cmux` overrides cmux CLI discovery.
- `CMUX_SOCKET_PATH=/path/to/cmux.sock` overrides the socket path checked by `health`; default is `/tmp/cmux.sock`.
- `CMUX_SOCKET_MODE=allowAll` is a cmux-side setting often needed when git-wt runs outside cmux.

## What it doesn't do

- Does not define the git-wt plugin API; git-wt owns `git-wt.plugin.v0`.
- Does not install, update, or configure cmux.
- Does not manage git worktree naming, branch policy, or cleanup policy.
- Does not create terminal panes beyond the cmux workspace's initial terminal.
- Does not make removal fatal when the matching cmux workspace is already gone.

## Development

```bash
bats tests/test_plugin.bats
bash -n wt-cmux
```

## License

MIT. See [LICENSE](./LICENSE).
