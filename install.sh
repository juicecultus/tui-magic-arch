#!/bin/bash
# ══════════════════════════════════════════════════════════════
#  TUI Magic — Arch Linux Installer (MacBook 12" 2017)
# ══════════════════════════════════════════════════════════════

set -e
GREEN='\e[32m'
BOLD='\e[1m'
RESET='\e[0m'

echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║   TUI Magic — Arch Linux Installer   ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════╝${RESET}"
echo ""

# --- 1. System update ---
echo -e "${GREEN}[1/9] Updating system...${RESET}"
sudo pacman -Syu --noconfirm

# --- 2. Install packages from official repos ---
echo -e "${GREEN}[2/9] Installing TUI tools (pacman)...${RESET}"
sudo pacman -S --noconfirm --needed \
    tmux htop btop ranger nnn tig newsboat calcurse w3m \
    cmatrix figlet lolcat cava fzf bat fd ripgrep tree ncdu \
    git micro alsa-utils acpid brightnessctl inetutils \
    pulseaudio-alsa less wget curl fastfetch \
    tlp powertop evtest dkms linux-headers

# --- 3. Install AUR packages ---
echo -e "${GREEN}[3/9] Installing AUR packages...${RESET}"
if command -v yay &>/dev/null; then
    AUR=yay
elif command -v paru &>/dev/null; then
    AUR=paru
else
    echo "No AUR helper found, building manually..."
    for pkg in cbonsai tty-clock-git; do
        cd /tmp
        rm -rf "$pkg"
        git clone "https://aur.archlinux.org/${pkg}.git"
        cd "$pkg"
        makepkg -si --noconfirm
    done
    AUR=""
fi
if [ -n "$AUR" ]; then
    $AUR -S --noconfirm --needed cbonsai tty-clock-git || true
fi

# --- 4. Create directories ---
echo -e "${GREEN}[4/9] Creating config directories...${RESET}"
mkdir -p ~/bin ~/.tmux ~/.config/btop/themes ~/.config/cava \
    ~/.config/tig ~/.config/newsboat ~/.config/calcurse \
    ~/.config/micro

# --- 5. Deploy config files ---
echo -e "${GREEN}[5/9] Deploying config files...${RESET}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$SCRIPT_DIR/.bashrc"             ~/.bashrc
cp "$SCRIPT_DIR/.bash_profile"       ~/.bash_profile
cp "$SCRIPT_DIR/.tmux.conf"          ~/.tmux.conf
cp "$SCRIPT_DIR/bin/motd"            ~/bin/motd
cp "$SCRIPT_DIR/bin/screensaver"     ~/bin/screensaver
cp "$SCRIPT_DIR/bin/view"            ~/bin/view
cp "$SCRIPT_DIR/tmux/net.sh"         ~/.tmux/net.sh
cp "$SCRIPT_DIR/tmux/hw.sh"          ~/.tmux/hw.sh
cp "$SCRIPT_DIR/tmux/cpu.sh"                  ~/.tmux/cpu.sh
cp "$SCRIPT_DIR/tmux/mem.sh"                  ~/.tmux/mem.sh
cp "$SCRIPT_DIR/tmux/bat.sh"                  ~/.tmux/bat.sh
cp "$SCRIPT_DIR/tmux/dashboard.sh"            ~/.tmux/dashboard.sh
cp "$SCRIPT_DIR/tmux/cheatsheet.txt"          ~/.tmux/cheatsheet.txt
cp "$SCRIPT_DIR/btop/btop.conf"               ~/.config/btop/btop.conf
cp "$SCRIPT_DIR/btop/themes/matrix.theme"     ~/.config/btop/themes/matrix.theme
cp "$SCRIPT_DIR/cava/config"                  ~/.config/cava/config
cp "$SCRIPT_DIR/tig/.tigrc"                   ~/.tigrc
cp "$SCRIPT_DIR/newsboat/config"              ~/.config/newsboat/config
cp "$SCRIPT_DIR/newsboat/urls"                ~/.config/newsboat/urls
cp "$SCRIPT_DIR/calcurse/conf"                ~/.config/calcurse/conf
cp "$SCRIPT_DIR/micro/settings.json"          ~/.config/micro/settings.json

# Permissions
chmod +x ~/bin/motd ~/.tmux/*.sh

# --- 6. MacBook fn keys (evtest systemd service) ---
echo -e "${GREEN}[6/9] Setting up fn keys...${RESET}"
sudo cp "$SCRIPT_DIR/system/macbook-fnkeys.sh" /usr/local/bin/macbook-fnkeys.sh
sudo chmod +x /usr/local/bin/macbook-fnkeys.sh
sudo cp "$SCRIPT_DIR/system/macbook-fnkeys.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now macbook-fnkeys.service

# --- 7. TLP power management ---
echo -e "${GREEN}[7/9] Configuring TLP...${RESET}"
sudo systemctl mask power-profiles-daemon 2>/dev/null || true
sudo systemctl enable --now tlp
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket 2>/dev/null || true

# --- 8. WiFi resume hook ---
echo -e "${GREEN}[8/9] Installing WiFi resume hook...${RESET}"
if [ -f "$SCRIPT_DIR/system/wifi-resume.sh" ]; then
    sudo cp "$SCRIPT_DIR/system/wifi-resume.sh" /usr/lib/systemd/system-sleep/wifi-resume.sh
    sudo chmod +x /usr/lib/systemd/system-sleep/wifi-resume.sh
fi

# --- 9. Camera module autoload ---
echo -e "${GREEN}[9/9] Setting up FaceTime HD camera...${RESET}"
echo "facetimehd" | sudo tee /etc/modules-load.d/facetimehd.conf >/dev/null

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║        Installation Complete!         ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}Log out and back in to start using TUI Magic.${RESET}"
echo -e "${GREEN}Use Ctrl-a (then key) for tmux shortcuts.${RESET}"
echo -e "${GREEN}Press Ctrl-a then H for the full cheatsheet.${RESET}"
