#!/bin/bash
# Kaldırma: en son yedek'ten settings.json'u geri yükler.
# Yedek yoksa: settings.json'dan sadece claude-villagers path'i içeren
# hook'ları temizler (jq ile).

set -euo pipefail

PLUGIN_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETTINGS="$HOME/.claude/settings.json"

# En yeni yedeği bul
LATEST_BACKUP=$(ls -t "$SETTINGS".bak-claude-villagers-* 2>/dev/null | head -1)

if [ -n "$LATEST_BACKUP" ]; then
    cp "$LATEST_BACKUP" "$SETTINGS"
    echo "✓ Yedek geri yüklendi: $LATEST_BACKUP"
    echo "  Claude Code'u yeniden başlat."
    exit 0
fi

# Yedek yok — jq ile sadece claude-villagers path'i içeren hook'ları temizle
if ! command -v jq >/dev/null 2>&1; then
    echo "ERR: yedek bulunamadı ve jq yok — manuel temizlik gerekli." >&2
    echo "     $SETTINGS içinden $PLUGIN_ROOT path'i içeren satırları sil." >&2
    exit 1
fi

cp "$SETTINGS" "$SETTINGS.tmp"
jq --arg root "$PLUGIN_ROOT" '
    if .hooks then
        .hooks |= with_entries(
            .value |= map(
                .hooks |= map(select(.command | contains($root) | not))
            ) | .value |= map(select(.hooks | length > 0))
        ) | .hooks |= with_entries(select(.value | length > 0))
        | if (.hooks | length) == 0 then del(.hooks) else . end
    else . end
' "$SETTINGS.tmp" > "$SETTINGS"
rm -f "$SETTINGS.tmp"

echo "✓ claude-villagers hook'ları $SETTINGS'ten kaldırıldı."
echo "  Claude Code'u yeniden başlat."
