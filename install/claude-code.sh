#!/usr/bin/env bash
# install/claude-code.sh — install OpenAgents Skills into Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/claude-code.sh | bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/TalonForgeHQ/openagents-skills}"
BRANCH="${BRANCH:-main}"

DEST="$HOME/.claude/skills"

mkdir -p "$DEST"

TMP="$(mktemp -d)"
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP/openagents-skills" >/dev/null 2>&1

# Each skill goes into its own subdirectory under ~/.claude/skills/<name>/
# That matches Claude Code's skill discovery convention.
if [ -d "$TMP/openagents-skills/skills" ]; then
  cp -r "$TMP/openagents-skills/skills/." "$DEST/"
  echo "✓ Installed $(ls "$TMP/openagents-skills/skills" | wc -l) skills to $DEST"
else
  echo "✗ Repo layout changed — could not find skills/ directory" >&2
  exit 1
fi

rm -rf "$TMP"
echo "Done. Restart Claude Code to pick up new skills."
