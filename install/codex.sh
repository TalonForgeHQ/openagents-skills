#!/usr/bin/env bash
# install/codex.sh — install OpenAgents Skills into OpenAI Codex CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/codex.sh | bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/TalonForgeHQ/openagents-skills}"
BRANCH="${BRANCH:-main}"

DEST="${CODEX_HOME:-$HOME/.codex}/skills"

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
echo "Done. Codex will discover skills from $DEST on next launch."
