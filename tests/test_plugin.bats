#!/usr/bin/env bats

setup() {
  export REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export WT_CMUX_LOG="$BATS_TEST_TMPDIR/cmux.log"
  export WT_CMUX_STATE="$BATS_TEST_TMPDIR/state.json"
  export WT_CMUX_BIN="$BATS_TEST_TMPDIR/cmux"
  export CMUX_SOCKET_PATH="$BATS_TEST_TMPDIR/cmux.sock"
  : > "$WT_CMUX_LOG"
  printf '{"workspaces":[]}\n' > "$WT_CMUX_STATE"

  cat > "$WT_CMUX_BIN" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
log() { printf '%s\n' "$*" >> "$WT_CMUX_LOG"; }
state_json() { cat "$WT_CMUX_STATE"; }
write_state() { printf '%s\n' "$1" > "$WT_CMUX_STATE"; }
case "$1" in
  ping)
    log "ping"
    ;;
  list-workspaces)
    log "list-workspaces $*"
    state_json
    ;;
  current-workspace)
    log "current-workspace $*"
    printf '{"workspace_id":"workspace:1"}\n'
    ;;
  new-workspace)
    log "new-workspace $*"
    write_state '{"workspaces":[{"workspace_id":"workspace:1"}]}'
    printf '{"workspace_id":"workspace:1"}\n'
    ;;
  select-workspace)
    log "select-workspace $*"
    ;;
  close-workspace)
    log "close-workspace $*"
    ;;
  set-status)
    key="$2"; value="$3"; workspace="$5"
    log "set-status $key $value $workspace"
    current=$(state_json)
    updated=$(printf '%s' "$current" | KEY_ARG="$key" VALUE_ARG="$value" yq -p json -o json '.workspaces[0].status[strenv(KEY_ARG)] = strenv(VALUE_ARG)')
    write_state "$updated"
    ;;
  log)
    log "sidebar-log $*"
    ;;
  send)
    log "send ${2:-}"
    ;;
  send-key)
    log "send-key ${2:-}"
    ;;
  *)
    log "unknown $*"
    exit 64
    ;;
esac
EOF
  chmod +x "$WT_CMUX_BIN"
}

@test "manifest prints plugin manifest" {
  run "$REPO_ROOT/wt-cmux" manifest
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | yq -p json -r '.name')" = "cmux" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.executable')" = "wt-cmux" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.api_versions[0]')" = "git-wt.plugin.v0" ]
}

@test "health reports tool availability without requiring live cmux" {
  run "$REPO_ROOT/wt-cmux" health
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | yq -p json -r '.ok')" = "true" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.cmux_available')" = "true" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.socket_available')" = "false" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.cmux')" = "$WT_CMUX_BIN" ]
}

@test "worktree-created creates cmux workspace and anchors it to worktree path" {
  payload='{"repo":{"name":"demo"},"worktree":{"id":"ABC-1-test","path":"/tmp/demo/ABC-1-test","branch":"noam/ABC-1-test"}}'

  run bash -c 'printf "%s" "$1" | "$2/wt-cmux" event wt:worktree-created' _ "$payload" "$REPO_ROOT"

  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | yq -p json -r '.status')" = "ok" ]
  [ "$(printf '%s' "$output" | yq -p json -r '.action')" = "created-workspace" ]
  run bash -c 'log=$(<"$1"); [[ "$log" == *"new-workspace"* && "$log" == *"set-status git-wt.path /tmp/demo/ABC-1-test workspace:1"* && "$log" == *"send cd"* ]]' _ "$WT_CMUX_LOG"
  [ "$status" -eq 0 ]
}

@test "focus selects existing workspace found by stored worktree path" {
  printf '{"workspaces":[{"workspace_id":"workspace:7","status":{"git-wt.path":"/tmp/demo/ABC-1-test"}}]}\n' > "$WT_CMUX_STATE"
  payload='{"repo":{"name":"demo"},"worktree":{"id":"ABC-1-test","path":"/tmp/demo/ABC-1-test"}}'

  run bash -c 'printf "%s" "$1" | "$2/wt-cmux" event wt:focus' _ "$payload" "$REPO_ROOT"

  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | yq -p json -r '.status')" = "ok" ]
  run bash -c 'log=$(<"$1"); [[ "$log" == *"select-workspace select-workspace --workspace workspace:7"* ]]' _ "$WT_CMUX_LOG"
  [ "$status" -eq 0 ]
}

@test "worktree-removed closes existing workspace" {
  printf '{"workspaces":[{"workspace_id":"workspace:7","status":{"git-wt.path":"/tmp/demo/ABC-1-test"}}]}\n' > "$WT_CMUX_STATE"
  payload='{"repo":{"name":"demo"},"worktree":{"id":"ABC-1-test","path":"/tmp/demo/ABC-1-test"}}'

  run bash -c 'printf "%s" "$1" | "$2/wt-cmux" event wt:worktree-removed' _ "$payload" "$REPO_ROOT"

  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | yq -p json -r '.status')" = "ok" ]
  run bash -c 'log=$(<"$1"); [[ "$log" == *"close-workspace close-workspace --workspace workspace:7"* ]]' _ "$WT_CMUX_LOG"
  [ "$status" -eq 0 ]
}

@test "bash syntax is clean" {
  run bash -n "$REPO_ROOT/wt-cmux"
  [ "$status" -eq 0 ]
}
