#!/usr/bin/env python3
"""
claude-villagers ses oynatıcı.

Tek dosyada tüm mantık:
  - mute check     (~/.claude-villagers-muted varsa atla)
  - 2sn lock       (--force ile baypas)
  - random select  (random.choice — ardışık çağrılarda farklı sonuç)
  - log            (/tmp/claude-villagers.log)
  - double-fork    (launchd adopt ettirir, hook bitince child ölmez)
  - afplay exec    (m4a/mp3/wav native decode)

Usage: _player.py <category> [--force]
"""

import os
import sys
import random
import glob
import datetime
import time


def main() -> int:
    if len(sys.argv) < 2:
        return 0

    category = sys.argv[1]
    force = '--force' in sys.argv[2:]

    # Plugin root: önce env var (Claude Code expand eder),
    # yoksa bu script'in iki üst klasörü (plugin-root/scripts/_player.py).
    plugin_root = os.environ.get('CLAUDE_PLUGIN_ROOT') or \
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    sounds_dir = os.path.join(plugin_root, 'sounds')
    category_dir = os.path.join(sounds_dir, category)

    mute_file = os.path.expanduser('~/.claude-villagers-muted')
    lock_file = '/tmp/.claude-villagers-playing.lock'
    log_file = '/tmp/claude-villagers.log'

    # Mute
    if os.path.exists(mute_file):
        return 0

    # Lock: son 2 sn içinde başka çağrı varsa --force değilse atla
    if not force and os.path.exists(lock_file):
        if time.time() - os.path.getmtime(lock_file) < 2:
            return 0

    # Adaylar: m4a / mp3 / wav (afplay native destek)
    candidates = []
    for ext in ('m4a', 'mp3', 'wav'):
        candidates.extend(glob.glob(os.path.join(category_dir, f'*.{ext}')))

    if not candidates:
        return 0

    file_path = random.choice(candidates)

    # Lock touch + log
    open(lock_file, 'w').close()
    try:
        with open(log_file, 'a') as f:
            now = datetime.datetime.now().strftime("%H:%M:%S")
            f.write(f'{now} {category} -> {os.path.basename(file_path)}\n')
    except Exception:
        pass

    # Double-fork daemonize → afplay launchd'in çocuğu olur
    if os.fork() != 0:
        return 0
    os.setsid()
    if os.fork() != 0:
        os._exit(0)

    devnull = os.open(os.devnull, os.O_RDWR)
    os.dup2(devnull, 0)
    os.dup2(devnull, 1)
    os.dup2(devnull, 2)

    os.execvp('afplay', ['afplay', file_path])


if __name__ == '__main__':
    sys.exit(main())
