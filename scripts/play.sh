#!/bin/bash
# claude-villagers ses oynatıcı wrapper.
# Tüm mantık _player.py'da. Bu wrapper plugin path stability için duruyor.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec python3 "$SCRIPT_DIR/_player.py" "$@"
