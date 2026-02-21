#!/bin/bash

# ================================================
# Fedora GNOME - Ekran Scale Toggle
# Usage: son -> %125 | soff -> %100
# ================================================

ACTION="$1"

if [ "$ACTION" = "son" ]; then
    SCALE="1.25"
elif [ "$ACTION" = "soff" ]; then
    SCALE="1.0"
else
    echo "Usage: son -> %125 | soff -> %100"
    exit 1
fi

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

python3 << PYEOF
import subprocess, re, sys

state = subprocess.run([
    'gdbus', 'call', '--session',
    '--dest', 'org.gnome.Mutter.DisplayConfig',
    '--object-path', '/org/gnome/Mutter/DisplayConfig',
    '--method', 'org.gnome.Mutter.DisplayConfig.GetCurrentState'
], capture_output=True, text=True).stdout

serial = re.search(r'uint32 (\d+)', state)
if not serial:
    print("Serial error.")
    sys.exit(1)
serial = serial.group(1)

connector = re.search(r"'(eDP-\d+|HDMI-[\d-]+|DP-\d+|DisplayPort-\d+)'", state)
if not connector:
    print("Could not find Connector.")
    sys.exit(1)
connector = connector.group(1)

mode = re.search(r"'(\d+x\d+@[\d.]+)'[^}]+'is-current': <true>", state)
if not mode:
    mode = re.search(r"'(\d+x\d+@[\d.]+)'", state)
if not mode:
    print("Could not find Mode.")
    sys.exit(1)
mode = mode.group(1)

scale = float($SCALE)
print(f"ℹ️  Monitor: {connector} | Mod: {mode} | Scale: {scale}")

result = subprocess.run([
    'gdbus', 'call', '--session',
    '--dest', 'org.gnome.Mutter.DisplayConfig',
    '--object-path', '/org/gnome/Mutter/DisplayConfig',
    '--method', 'org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig',
    f'uint32 {serial}',
    'uint32 1',
    f"[(0, 0, {scale}, uint32 0, true, [('{connector}', '{mode}', {{}})])]",
    '{}'
], capture_output=True, text=True)

if result.returncode == 0:
    pct = int(scale * 100)
    print(f"✅ Scale has been changed to %{pct}")
else:
    print(f"❌ Error: {result.stderr.strip()}")
PYEOF
