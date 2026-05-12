# 🏰 claude-villagers

> Claude Code'a Age of Empires II Türk medeniyeti sesleri ekler. Her tool çağrısında köylülerin _"Buyrun?"_, _"Hemen!"_, _"Olur!"_ dediği bir geliştirme deneyimi.

`Read` → köylü ot/maden toplama sesi
`Edit / Write` → "İnşa ediyoruz!"
`Bash` → asker yürüyüş sesi
`Task / Agent` → Sultan emir verir
`ultrathink` yazarsan → görkemli **Turks jingle** çalar
Tool hata verir → asker savaş narası
Claude bitirir → kral hareket sesi

14 kategori, **67 farklı ses**, hepsi gerçek AoE2 DE Turks medeniyeti dub'ından — yani _gerçekten Türkçe_ konuşan köylüler.

---

## Kurulum

### 1) Claude Code plugin marketplace olarak (önerilen)

```
/plugin marketplace add tekinnnnn/claude-villagers
/plugin install claude-villagers@tekinnnnn
```

Claude Code'u yeniden başlat — yeni session açılışında jingle ile karşılanırsın.

### 2) Manuel kurulum

```bash
git clone https://github.com/tekinnnnn/claude-villagers ~/claude-villagers
cd ~/claude-villagers
./install.sh
```

`install.sh`:
- `~/.claude/settings.json` yedeği alır
- `hooks/hooks.json`'daki `${CLAUDE_PLUGIN_ROOT}` placeholder'ını gerçek path ile değiştirir
- jq ile mevcut settings.json'a merge eder

Kaldırmak için `./uninstall.sh` — yedeği geri yükler.

---

## Gereksinimler

- **macOS** — `afplay` kullanır (Linux/Windows'ta çalışmaz; Linux için kolay port: `aplay`/`paplay` ile değiştirilir)
- **Python 3** — script'ler için (her macOS'ta var)
- 1.2 MB disk

`ffmpeg` ve `jq` opsiyonel — yoksa Python fallback'i devreye girer.

---

## Hook → Kategori Haritası

| Event | Kategori | Ses karakteri |
|---|---|---|
| `SessionStart` | session-start | Turks jingle (DE) |
| `UserPromptSubmit` | select | Villager _"Buyrun?"_ |
| `UserPromptSubmit` + thinking keyword | ultrathink | Sultan jingle (random 2 versiyon) |
| `PreToolUse` / Bash | bash | Asker hareket sesi |
| `PreToolUse` / Edit\|Write\|NotebookEdit | edit | Köylü inşaat/onarım |
| `PreToolUse` / Read\|Grep\|Glob | read | Köylü kaynak toplama |
| `PreToolUse` / Task\|Agent | agent | King select (sultan emir) |
| `PreToolUse` / WebFetch\|WebSearch | web | Köylü forage |
| `PostToolUse` + `is_error` | error | Asker savaş narası |
| `Notification` | notify | Monk sesleri (sakin) |
| `Stop` | done | King move (görev tamam) |
| `SubagentStop` | subagent | Asker select |
| `SessionEnd` | session-end | Turks jingle (orijinal) |

Thinking keyword'leri (ultrathink tetikleyiciler): `ultrathink`, `megathink`, `think hard`, `think harder`, `think really hard`, `think a lot`, `think more`, `think deeply`, `think longer`, `think step by step`. Plain `think` özellikle dışarıda — _"I think..."_ false-positive verir.

---

## Komutlar

```bash
# Manuel test
~/claude-villagers/scripts/play.sh select         # köylü "Buyrun?"
~/claude-villagers/scripts/play.sh ultrathink --force  # sultan jingle
~/claude-villagers/scripts/play.sh error --force  # savaş narası

# Geçici sustur
touch ~/.claude-villagers-muted

# Tekrar aç
rm ~/.claude-villagers-muted

# Log izle
tail -f /tmp/claude-villagers.log
```

---

## Özelleştirme

### Bir kategoriye yeni ses ekle

`afplay` `.ogg` desteklemez — m4a/mp3/wav lazım:

```bash
ffmpeg -i yeni-ses.ogg -c:a aac -b:a 96k yeni-ses.m4a
cp yeni-ses.m4a sounds/select/
```

Tek dosya olsa bile script rotasyona alır.

### Bir sesi devre dışı bırak

```bash
mkdir -p sounds/edit/_disabled
mv sounds/edit/sevmedigim-ses.m4a sounds/edit/_disabled/
```

`_player.py` sadece root-level dosyaları okur.

### Uzun ultrathink theme'ini geri al

Orijinal 36 sn'lik Turks theme `sounds/ultrathink/_disabled/` altında duruyor. Geri almak için:

```bash
mv sounds/ultrathink/_disabled/Turks_theme_AoE2_DE.m4a sounds/ultrathink/
```

Veya kısaltıp eklemek:

```bash
ffmpeg -i sounds/ultrathink/_disabled/Turks_theme_AoE2_DE.m4a \
       -t 10 -af "afade=t=out:st=8:d=2" -c:a aac -b:a 96k \
       sounds/ultrathink/theme-10s.m4a
```

---

## Mimari Notu

- **Tek script — `_player.py`** mute/lock/random/log/detach/exec mantığının hepsini yönetir
- **Double-fork daemonize** — `afplay` launchd'in çocuğu olur (PPID=1), Claude Code hook bitse de uzun sesler kesilmez
- **2 saniye lock** — `PreToolUse` + `PostToolUse` ardışık tetiklendiğinde üst üste ses binmesin diye. `--force` ekli komutlar (Stop, ultrathink, agent, notify, session-start/end) lock'u baypas eder

---

## Telif

- **Kod**: MIT lisansı — bkz. [LICENSE](LICENSE)
- **Ses dosyaları**: © Microsoft / Forgotten Empires (Age of Empires II: Definitive Edition). Bu repodaki ses asset'leri **non-commercial, eğitim/eğlence amaçlı fan kullanımı** kapsamında dağıtılır. Microsoft veya Forgotten Empires'ın yasal şikayeti halinde asset'ler kaldırılır

---

## Katkı

PR'lar açık. Özellikle:

- Diğer medeniyetler için sound pack çıkarma (`/Vikings`, `/Mongols`, `/Persians` vb. — fandom wiki kaynaklarından)
- Linux port (`aplay`/`paplay` ile `afplay` swap)
- Kategori-bazlı volume kontrolü

---

_Yapan: [@tekinnnnn](https://github.com/tekinnnnn) — Wololo._
