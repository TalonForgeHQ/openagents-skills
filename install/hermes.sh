#!/usr/bin/env bash
# install/hermes.sh — install OpenAgents Skills into Hermes Agent
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/hermes.sh | bash
#   REPO_URL=https://github.com/somebody/fork bash install/hermes.sh
#   REPO_URL=file:///path/to/local/clone bash install/hermes.sh

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/TalonForgeHQ/openagents-skills}"
BRANCH="${BRANCH:-main}"
DEST="${DEST:-$HOME/.hermes/skills}"

mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Installing OpenAgents Skills..."
echo "  Source: $REPO_URL @ $BRANCH"
echo "  Target: $DEST"

if ! git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP/openagents-skills" 2>&1; then
  echo "✗ git clone failed. Check REPO_URL: $REPO_URL" >&2
  exit 1
fi

if [ -d "$TMP/openagents-skills/skills" ]; then
  count=$(ls "$TMP/openagents-skills/skills" | wc -l)
  cp -r "$TMP/openagents-skills/skills/." "$DEST/"
  echo "✓ Installed $count skills to $DEST"
else
  echo "✗ Repo layout changed — could not find skills/ directory" >&2
  exit 1
fi

echo ""
echo "Done. Restart any active agent sessions to pick up new skills."
echo "Try: 'load the office-hours skill' or 'office-hours this idea'"
