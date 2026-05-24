# wt-cmux

`wt-cmux` is a [git-wt](https://github.com/noamsiegel/git-wt) plugin for [cmux](https://github.com/manaflow-ai/cmux), the native macOS terminal multiplexer for AI coding agents.

When `git-wt` creates a worktree, this plugin creates or selects a matching cmux workspace. When `git-wt` removes or focuses a worktree, this plugin closes or selects the matching cmux workspace.

## Install

From the git-wt registry:

```bash
wt plugin install cmux
```

Directly from GitHub:

```bash
wt plugin install noamsiegel/wt-cmux
```

For local development:

```bash
wt plugin link /path/to/wt-cmux
```

## Requirements

- `git-wt` with `git-wt.plugin.v0` support
- cmux CLI available as `cmux`
- `yq` for JSON parsing

cmux installs its CLI inside the macOS app bundle. If it is not on `PATH`, create the symlink documented by cmux:

```bash
sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
```

If `git-wt` runs outside a cmux terminal, cmux socket access may need to allow local non-cmux processes:

```bash
CMUX_SOCKET_MODE=allowAll
```

or equivalent cmux Settings access.

## Behavior

| git-wt event | cmux action |
| --- | --- |
| `wt:worktree-created` | Create a cmux workspace, attach `git-wt` metadata, and send `cd <worktree>` to the terminal. If a workspace for the worktree already exists, select it instead. |
| `wt:worktree-removed` | Find the cmux workspace by stored worktree path metadata and close it. Missing workspace is a no-op. |
| `wt:focus` | Find the cmux workspace by stored worktree path metadata and select it. Missing workspace returns `not-found`. |

cmux calls use the public CLI documented at `https://cmux.com/docs/api`: `new-workspace`, `list-workspaces --json`, `current-workspace --json`, `select-workspace`, `close-workspace`, `set-status`, `log`, `send`, and `send-key`.

## Commands

```bash
wt-cmux manifest
wt-cmux health
wt-cmux event wt:worktree-created < payload.json
wt-cmux --version
```

`WT_CMUX_BIN=/path/to/cmux` overrides cmux CLI discovery.

## Manifest

```json
{
  "name": "cmux",
  "executable": "wt-cmux",
  "api_versions": ["git-wt.plugin.v0"],
  "events": ["wt:worktree-created", "wt:worktree-removed", "wt:focus"],
  "capabilities": ["tab.focus", "tab.close"],
  "version": "0.1.0",
  "source": "https://github.com/noamsiegel/wt-cmux",
  "description": "cmux terminal multiplexer integration for git-wt"
}
```

## Development

```bash
bats tests/test_plugin.bats
bash -n wt-cmux
```

## License

MIT. See [LICENSE](./LICENSE).
