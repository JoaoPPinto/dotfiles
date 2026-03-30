#!/usr/bin/env bash

# 30-theme-gruvbox-gtk
# Provide Instructions on installing and enabling
# the Gruvbox GTK Theme

set -euo pipefail

[[ "$BOOTSTRAP_PLATFORM" == "linux" ]] || return 0

THEME_FOUND=0

for dir in "$HOME/.themes" "/usr/share/themes"; do
    if [[ -d "$dir" ]]; then
        if find "$dir" -maxdepth 1 -type d -name 'Gruvbox*' | grep -q .; then
            THEME_FOUND=1
            break
        fi
    fi
done

if [[ "$THEME_FOUND" -eq 1 ]]; then
    print_msg INFO "Gruvbox GTK theme already appears to be installed. Skipping instructions"
    return 0
fi

print_msg INFO "Gruvbox GTK Theme Installation Instructions"

cat <<'EOF'

⚙️ Requirements Before Installing the Themes:

You must have the following packages installed:

Fedora:
    sudo dnf install gtk-murrine-engine

OpenSUSE:
    sudo zypper install gtk2-engine-murrine

Arch:
    sudo pacman -S gtk-engine-murrine

Debian/Ubuntu:
    sudo apt install gtk2-engines-murrine

-----------------------------------------

📁 Manual Installation Steps:

1. Download the theme packs from Pling:
   - https://www.pling.com/p/1681313

2. Extract the downloaded archives.

3. Move the GTK3 themes to:
       ~/.themes/
   (or system-wide: /usr/share/themes)

4. Move GTK4 assets (gtk.css, gtk-dark.css, etc.) to:
       ~/.config/gtk-4.0/

5. Apply the theme in your desktop environment:

GNOME:
    - Use Tweaks: Appearance > Applications
    - Or via command line:
        gsettings set org.gnome.desktop.interface gtk-theme "Gruvbox-BL-MB-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Gruvbox-Plus-Dark"

KDE Plasma:
    - System Settings > Appearance > Application Style > GNOME/GTK themes
    - System Settings > Appearance > Global Theme for window decorations

XFCE:
    - Settings > Appearance > Style
    - Settings > Window Manager > Style

Other window managers (i3, Openbox, etc.):
    - Configure GTK3 theme in:
        ~/.config/gtk-3.0/settings.ini
    - Example:
        [Settings]
        gtk-theme-name=Gruvbox-BL-MB-dark
        gtk-icon-theme-name=Gruvbox-Plus-Dark

Switch between Dark and Light variants by changing the theme names accordingly:
    - Dark: Gruvbox-BL-MB-dark / Gruvbox-Plus-Dark
    - Light: Gruvbox-BL-MB-light / Gruvbox-Plus-Light

EOF

print_msg INFO "Follow these instructions to install and activate Gruvbox GTK themes for your desktop environment."
