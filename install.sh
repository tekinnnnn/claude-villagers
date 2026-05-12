#!/bin/bash
# Manuel kurulum — plugin marketplace yerine settings.json'a doğrudan
# hook'ları enjekte eder. /plugin install çalışmıyorsa fallback.
#
# Usage:  ./install.sh

set -euo pipefail

PLUGIN_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETTINGS="$HOME/.claude/settings.json"
HOOKS_TEMPLATE="$PLUGIN_ROOT/hooks/hooks.json"

if [ ! -f "$SETTINGS" ]; then
    echo "ERR: $SETTINGS bulunamadı. Claude Code yüklü mü?" >&2
    exit 1
fi
if [ ! -f "$HOOKS_TEMPLATE" ]; then
    echo "ERR: $HOOKS_TEMPLATE bulunamadı." >&2
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    echo "ERR: jq lazım. brew install jq" >&2
    exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
    echo "ERR: python3 lazım." >&2
    exit 1
fi
if ! command -v afplay >/dev/null 2>&1; then
    echo "ERR: afplay bulunamadı (macOS değil mi?). Bu paket macOS için." >&2
    exit 1
fi

# Yedek
BACKUP="$SETTINGS.bak-claude-villagers-$(date +%Y%m%d-%H%M%S)"
cp "$SETTINGS" "$BACKUP"
echo "→ settings.json yedeklendi: $BACKUP"

# CLAUDE_PLUGIN_ROOT placeholder'ını gerçek path ile değiştir + settings.json'a merge
RESOLVED_HOOKS=$(sed "s|\${CLAUDE_PLUGIN_ROOT}|$PLUGIN_ROOT|g" "$HOOKS_TEMPLATE")

# Mevcut settings.json + yeni hooks (mevcut hooks varsa üzerine yazılır)
echo "$RESOLVED_HOOKS" | jq --slurpfile cur <(cat "$SETTINGS") \
    '$cur[0] + {hooks: .hooks}' > "$SETTINGS.tmp"

mv "$SETTINGS.tmp" "$SETTINGS"

echo "✓ hook'lar yazıldı: $SETTINGS"
echo ""
echo "Test:"
echo "  $PLUGIN_ROOT/scripts/play.sh select"
echo ""
echo "Claude Code'u yeniden başlat — yeni session açılışında Turks jingle çalar."
echo "Kaldırmak için: ./uninstall.sh  (veya yedeği geri yükle: cp $BACKUP $SETTINGS)"
