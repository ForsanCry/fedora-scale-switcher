# GNOME-scale-switcher
Fedora GNOME Scale switcher for Linux gaming on Laptop

GNOME Display Scale Fixer for Linux Gaming

This script provides a quick way to toggle display scaling on Fedora (GNOME/Wayland), specifically designed to solve resolution mismatch issues in Linux gaming.

## The Problem

When using fractional scaling (e.g., 125%) on high-resolution displays (like 1600p 16:10), many games fail to detect the native resolution correctly.

    Mathematical Error: At 125% scale, the system may report a virtual resolution (e.g., 2560p) as the maximum.

    Visual Artifacts: Switching back to the native 1600p often results in a "blurry" or "oily lens" effect due to improper sub-pixel rendering.

    Performance Hit: The GPU is forced to render at a higher internal resolution than necessary, leading to lower FPS and unnecessary thermal load.

## The Solution

This script automates the process of switching your display scale to 100% before launching a game and restoring your preferred scaling afterward. This ensures pixel-perfect native resolution, minimal GPU overhead, and maximum performance on high-end hardware.

## Installation & Usage

For convenience and to keep your home directory visually clean, we will hide the script and create easy-to-use terminal aliases.

1. Copy and hide the script in your home directory:
```bash
cp ~/Downloads/scale_toggle.sh ~/.scale_toggle.sh
chmod +x ~/.scale_toggle.sh
```
Note: Prefixing the file with a dot (.) hides it from standard directory views, keeping your environment tidy.

2. Clean up any old aliases (safe for first-time installation):
```bash
sed -i '/scale_toggle/d' ~/.bashrc
```

3. Set up the son (Scale ON) and soff (Scale OFF) aliases:
```bash
echo "alias son='bash ~/.scale_toggle.sh son'" >> ~/.bashrc
echo "alias soff='bash ~/.scale_toggle.sh soff'" >> ~/.bashrc
```

4. Apply the changes to your terminal:
```bash
source ~/.bashrc
```
Commands:

    son (Scale ON) → sets scale to 125%

    soff (Scale OFF) → sets scale to 100%

Note: If you want to use a different scale value (e.g., 150%), you can easily change it by editing the SCALE variable on line 12 of the script.

Now, you can simply type son to apply your custom scale, and soff to revert to 100% before launching a game!

## How It Works

The script automatically detects your monitor information by querying GNOME's Display Config. It dynamically finds three key parameters:

    Serial: A session ID that GNOME uses to verify the config change is fresh.

    Connector: Your monitor's connection name (e.g., eDP-1 for built-in laptop screens, HDMI-1 for HDMI, DP-1 for DisplayPort).

    Mode: Your current resolution and refresh rate (e.g., 2560x1600@240.001).

You don't need to set any of these manually; the script handles it at runtime. However, if the script fails to find your connector, you can check it yourself by running:
```bash
gdbus call --session \
--dest org.gnome.Mutter.DisplayConfig \
--object-path /org/gnome/Mutter/DisplayConfig \
--method org.gnome.Mutter.DisplayConfig.GetCurrentState 2>/dev/null | grep -oP "'(eDP-\d+|HDMI-[\d-]+|DP-\d+|DisplayPort-\d+)'" | head -1
```

## Compatibility & Under the Hood

⚠️ Limitations

    Single Monitor Only: This script is currently designed and optimized for single-monitor setups (e.g., using only your laptop's built-in display).

    Multi-Monitor Behavior: Because the script sends a configuration for only one connector to the Mutter API, running it while external monitors are connected may cause those secondary displays to turn off.

Theoretically, this script should work on any GNOME desktop environment because it relies on GNOME-specific, rather than distribution-specific, tools:

    gdbus: GNOME's native D-Bus API.

    gsettings: GNOME's configuration system.

    org.gnome.Mutter.DisplayConfig: The Mutter window manager API.

Potential Exceptions:

    Wayland is Mandatory: Mutter's DisplayConfig behaves differently on older X11 sessions.

    GNOME Version: Very old GNOME versions (below 3.30) used a different ApplyMonitorsConfig API.

    Fractional Scaling Feature: The script enables the scale-monitor-framebuffer experimental feature. While usually fine, some distributions might restrict this.

System Requirements:

    Tested on: Fedora 43 + GNOME (Wayland) on MSI Raider A18 HX

    Should work on: Any GNOME desktop running a Wayland session (Ubuntu, Arch, openSUSE, etc.)

    Requirements: GNOME 40+, Wayland, Python 3

## Uninstallation

  If you wish to remove the script and the aliases from your system, simply run:
  ```bash
  #1. Remove the hidden script
  rm ~/.scale_toggle.sh
  
  # 2. Remove aliases from .bashrc
  sed -i '/scale_toggle/d' ~/.bashrc
  
  # 3. Apply changes
  source ~/.bashrc
  ```
