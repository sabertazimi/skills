#!/usr/bin/env bash
# Sync version from package.json to .claude-plugin/ files
# Called by commit-and-tag-version's postbump hook

set -euo pipefail

VERSION=$(node -e "console.log(require('./package.json').version)")

MARKETPLACE_JSON=".claude-plugin/marketplace.json"
PLUGIN_JSON=".claude-plugin/plugin.json"

jq --arg v "$VERSION" '.plugins[0].version = $v' "$MARKETPLACE_JSON" > "${MARKETPLACE_JSON}.tmp" && mv "${MARKETPLACE_JSON}.tmp" "$MARKETPLACE_JSON"
jq --arg v "$VERSION" '.version = $v' "$PLUGIN_JSON" > "${PLUGIN_JSON}.tmp" && mv "${PLUGIN_JSON}.tmp" "$PLUGIN_JSON"

git add "$MARKETPLACE_JSON" "$PLUGIN_JSON"

echo "Synced version $VERSION to $MARKETPLACE_JSON and $PLUGIN_JSON"
