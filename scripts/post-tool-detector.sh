#!/bin/bash
# PostToolUse hook'una bağlı.
# tool_response.is_error == true ise "error" sesi çal.
# Başarılı tool'lar sessiz (PreToolUse zaten ses çaldı; her ack ses spam'i olur).

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLAY="$SCRIPT_DIR/play.sh"

PAYLOAD="$(cat)"

HAS_ERROR=0
if command -v jq >/dev/null 2>&1; then
    if echo "$PAYLOAD" | jq -e '.tool_response.is_error == true' >/dev/null 2>&1; then
        HAS_ERROR=1
    fi
else
    if echo "$PAYLOAD" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    r = d.get("tool_response", {})
    sys.exit(0 if (isinstance(r, dict) and r.get("is_error") is True) else 1)
except Exception:
    sys.exit(1)
' 2>/dev/null; then
        HAS_ERROR=1
    fi
fi

if [ "$HAS_ERROR" -eq 1 ]; then
    "$PLAY" error --force
fi

exit 0
