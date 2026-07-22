#!/usr/bin/env bash
# install/cursor.sh — install OpenAgents Skills into Cursor (project-scoped)
# Usage: cd your-project && curl -fsSL ... | bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/TalonForgeHQ/openagents-skills}"
BRANCH="${BRANCH:-main}"

# Cursor reads skills from .cursor/skills/ in the project root.
DEST="${CURSOR_PROJECT:-$(pwd)}/.cursor/skills"

if [ ! -d "$(dirname "$DEST")" ]; then
  echo "✗ No .cursor/ directory in $(dirname "$DEST"). Are you in a project root?" >&2
  exit 1
fi

mkdir -p "$DEST"

TMP="$(mktemp -d)"
git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP/openagents-skills" >/dev/null 2>&1

if [ -d "$TMP/openagents-skills/skills" ]; then
  cp -r "$TMP/openagents-skills/skills/." "$DEST/"
  echo "✓ Installed $(ls "$TMP/openagents-skills/skills" | wc -l) skills to $DEST"
else
  echo "✗ Repo layout changed — could not find skills/ directory" >&2
  exit 1
fi

rm -rf "$TMP"
echo "Done. Cursor will pick up skills on next chat."
