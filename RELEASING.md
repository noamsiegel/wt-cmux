# Releasing wt-cmux

1. Start from a clean working tree on the release branch.
2. Run `bash -n wt-cmux`.
3. Run `bats tests/` and confirm all tests pass.
4. Confirm cmux-facing behavior still targets [`manaflow-ai/cmux`](https://github.com/manaflow-ai/cmux).
5. Confirm `WT_CMUX_BIN` still overrides cmux discovery for non-PATH installs.
6. Pick the next SemVer version, for example `0.1.2`.
7. Update `VERSION="X.Y.Z"` in `wt-cmux`.
8. Update `"version": "X.Y.Z"` in `wt-plugin.json`.
9. Add a `## vX.Y.Z - YYYY-MM-DD` section to `CHANGELOG.md`.
10. Keep changelog bullets user-facing: added, changed, fixed, release notes.
11. Re-run `bash -n wt-cmux`.
12. Re-run `bats tests/`; the version-match test must pass.
13. Smoke-test manifest version:
    `~/Documents/GitHub/wt-cmux/wt-cmux manifest | yq -p json '.version'`
14. With cmux installed, smoke-test health:
    `WT_CMUX_BIN=/path/to/cmux wt-cmux health`
15. Confirm health output includes `"ok": true`.
16. Commit release files: `wt-cmux`, `wt-plugin.json`, `CHANGELOG.md`, and tests/docs if changed.
17. Create an annotated tag on the release commit: `git tag -a vX.Y.Z -m "wt-cmux vX.Y.Z"`.
18. Push commit first: `git push origin HEAD`.
19. Push tag only after commit push succeeds: `git push origin vX.Y.Z`.
20. Create GitHub release:
    `gh release create vX.Y.Z --title "wt-cmux vX.Y.Z" --notes-file <(awk '/^## vX.Y.Z/{flag=1; next} /^## v/{flag=0} flag' CHANGELOG.md)`
21. If the commit push fails, do not create the release; fix the branch and retry push.
22. If the tag push fails, delete any bad local tag and recreate it on the release commit.
23. If `gh release create` ran against the wrong tag, delete the remote release/tag, recreate the tag on the release commit, push tag, then recreate the release.
24. If a stale shim breaks push hooks, remove the stale `.git/hooks/pre-push` shim and reinstall the current guardrails hook before retrying.
25. After release, verify `gh release view vX.Y.Z` points at the intended commit.
26. No Homebrew tap update is needed unless wt-cmux becomes brew-installed.
