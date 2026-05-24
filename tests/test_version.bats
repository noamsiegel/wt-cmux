#!/usr/bin/env bats

@test "script VERSION matches manifest version" {
  local script_version manifest_version
  script_version=$(grep -oE 'VERSION="[^"]+"' "$BATS_TEST_DIRNAME/../wt-cmux" | head -1 | sed -E 's/VERSION="([^"]+)"/\1/')
  manifest_version=$(yq -p json -oy '.version' "$BATS_TEST_DIRNAME/../wt-plugin.json")
  [ -n "$script_version" ]
  [ -n "$manifest_version" ]
  [ "$script_version" = "$manifest_version" ]
}
