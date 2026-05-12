#!/bin/bash
# UserPromptSubmit hook'una bağlı detector.
# stdin'den Claude Code JSON payload alır, prompt'ta yüksek-budget thinking
# keyword'lerinden biri varsa "ultrathink" kategorisinden çalar, yoksa "select".

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLAY="$SCRIPT_DIR/play.sh"

PAYLOAD="$(cat)"

# jq tercih, yoksa python3 fallback
if command -v jq >/dev/null 2>&1; then
    PROMPT=$(echo "$PAYLOAD" | jq -r '.prompt // empty')
else
    PROMPT=$(echo "$PAYLOAD" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)
fi

PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Plain "think" özellikle dışarıda — "I think...", "let me think..." normal
# cümlelerde geçer ve alwaysThinkingEnabled açık olabilir.
PATTERN='\b(ultrathink|megathink|think harder|think really hard|think hard|think a lot|think more|think deeply|think longer|think step by step)\b'

if echo "$PROMPT_LOWER" | grep -qE "$PATTERN"; then
    "$PLAY" ultrathink --force
else
    "$PLAY" select
fi

exit 0
