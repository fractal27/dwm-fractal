#!/bin/sh
#
# install-env.sh — Install dwm-fractal environment for a new user
#
# Usage:
#   sudo ./install-env.sh                    # interactive setup
#   sudo ./install-env.sh username           # setup for specific user
#   sudo ./install-env.sh --help             # this message
#
# Creates a new user (or uses existing) and installs all dependencies,
# custom scripts, and configuration for the dwm-fractal environment.

set -e

# ── Configuration ──────────────────────────────────────────────────────────

NEW_USER="${1:-}"

# Source code mirrors (change these if you have your own forks)
REPO_DWM="https://github.com/fractal27/dwm-fractal"
REPO_ST="https://git.suckless.org/st"
REPO_DMENU="https://git.suckless.org/dmenu"
REPO_DWMBLOCKS="https://github.com/lukesmithxyz/dwmblocks"
REPO_GOOM="https://git.fdeb.xyz/fdebian/goom"
REPO_SCRIPTS="https://git.fdeb.xyz/fdebian/scripts"

# ── Feature Flags ──────────────────────────────────────────────────
# Set to 1 to enable a feature, 0 or comment out to disable.
# Disabled-by-default features are marked with [OFF].
INSTALL_EMU=0          # [OFF] emulator packages & rom dir (fceux, etc.)
INSTALL_GOOM=0         # [OFF] build goom from $REPO_GOOM
INSTALL_SCRIPTS=0      # [OFF] clone extra scripts from $REPO_SCRIPTS

# Font
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/IosevkaTerm.zip"
FONT_NAME="IosevkaTerm Nerd Font"

# Binary path
BIN_DIR=".local/bin"
SCRIPT_DIR="scripts/exec"

# ── Helpers ────────────────────────────────────────────────────────────────

info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[ OK ]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*"; }
err()   { printf "\033[1;31m[ERR]\033[0m  %s\n" "$*" >&2; exit 1; }

usage() {
	sed -n '/^# Usage:/,/^$/p' "$0" | head -n -1 | sed 's/^# //; s/^#$//'
	exit 0
}

[ "$1" = "--help" ] && usage
[ "$(id -u)" -ne 0 ] && err "Must be run as root (sudo)."

# ── Package Manager Detection ──────────────────────────────────────────────

detect_pm() {
	for pm in emerge apt pacman dnf zypper xbps-install; do
		if command -v "$pm" >/dev/null 2>&1; then
			echo "$pm"
			return
		fi
	done
	echo "unknown"
}

PM=$(detect_pm)
info "Detected package manager: $PM"

install_packages() {
	case "$PM" in
		apt)
			apt update
			apt install -y "$@"
			;;
		pacman)
			pacman -Sy --noconfirm "$@"
			;;
		dnf)
			dnf install -y "$@"
			;;
		emerge)
			emerge --ask n "$@"
			;;
		zypper)
			zypper install -y "$@"
			;;
		xbps-install)
			xbps-install -Sy "$@"
			;;
		*)
			warn "Unknown package manager. Install these manually:"
			echo "  $*"
			;;
	esac
}

# ── System Dependencies ────────────────────────────────────────────────────

info "Installing build dependencies..."

# Package groups per package manager — each variable holds the list for that PM.
case "$PM" in
	apt)
		APT_BASE="build-essential libx11-dev libxft-dev libxinerama-dev
			libxcb-res0-dev libfreetype-dev libfontconfig1-dev
			git xorg xinit picom"
		APT_MEDIA="mpv feh scrot"
		APT_AUDIO="pulseaudio-utils alsa-utils"
		APT_DEV="vim"
		APT_EXTRA="dmenu suckless-tools xclip xdotool mupdf"
		APT_EMU="fceux"

		install_packages $APT_BASE $APT_MEDIA $APT_AUDIO $APT_DEV $APT_EXTRA
		# st and dmenu from suckless-tools are fallbacks; we build our own

		[ "$INSTALL_EMU" = 1 ] && install_packages $APT_EMU
		;;
	pacman)
		PACMAN_BASE="base-devel libx11 libxft libxinerama libxcb xcb-util
			freetype2 fontconfig git xorg xorg-xinit picom"
		PACMAN_MEDIA="mpv feh scrot"
		PACMAN_AUDIO="libpulse alsa-utils"
		PACMAN_DEV="vim"
		PACMAN_EXTRA="xclip xdotool mupdf keepassxc"
		PACMAN_EMU="fceux"

		install_packages $PACMAN_BASE $PACMAN_MEDIA $PACMAN_AUDIO $PACMAN_DEV $PACMAN_EXTRA

		[ "$INSTALL_EMU" = 1 ] && install_packages $PACMAN_EMU
		;;
	dnf)
		DNF_BASE="@development-tools libX11-devel libXft-devel libXinerama-devel
			libxcb-devel xcb-util-devel freetype-devel fontconfig-devel
			git xorg-x11-server-Xorg xorg-x11-xinit picom"
		DNF_MEDIA="mpv feh scrot"
		DNF_AUDIO="pulseaudio-utils alsa-utils"
		DNF_DEV="vim"
		DNF_EXTRA="xclip xdotool mupdf"
		DNF_EMU="fceux"

		install_packages $DNF_BASE $DNF_MEDIA $DNF_AUDIO $DNF_DEV $DNF_EXTRA

		[ "$INSTALL_EMU" = 1 ] && install_packages $DNF_EMU
		;;
	emerge)
		EMERGE_BASE="x11-base/xorg-server x11-apps/xinit
			x11-libs/libX11 x11-libs/libXft x11-libs/libXinerama
			x11-libs/libxcb x11-libs/xcb-util
			media-libs/freetype media-libs/fontconfig
			dev-vcs/git x11-misc/picom
			media-video/pipewire"
		EMERGE_MEDIA="media-video/mpv media-gfx/feh media-gfx/scrot"
		EMERGE_AUDIO="media-sound/alsa-utils"
		EMERGE_DEV="app-editors/vim"
		EMERGE_EXTRA="x11-misc/xclip x11-misc/xdotool app-text/mupdf"
		EMERGE_EMU="games-emulation/fceux"

		install_packages $EMERGE_BASE $EMERGE_MEDIA $EMERGE_AUDIO $EMERGE_DEV $EMERGE_EXTRA
		# Enable pipewire-pulse for pactl support
		[ -f /etc/portage/package.use/pipewire ] || \
			echo "media-video/pipewire pipewire-pulse" > /etc/portage/package.use/pipewire 2>/dev/null || true

		[ "$INSTALL_EMU" = 1 ] && install_packages $EMERGE_EMU
		;;
	*)
		warn "Please install build tools, X11 dev libraries, picom, mpv, feh, scrot, vim, xclip, xdotool, alsa-utils, mupdf"
		warn "Enable INSTALL_EMU=1 for emulator packages."
		;;
esac

ok "System dependencies installed."

# ── User Setup ─────────────────────────────────────────────────────────────

if [ -z "$NEW_USER" ]; then
	printf "\nEnter username to create/setup: "
	read -r NEW_USER
	[ -z "$NEW_USER" ] && err "No username provided."
fi

if id "$NEW_USER" >/dev/null 2>&1; then
	info "User '$NEW_USER' already exists."
else
	info "Creating user '$NEW_USER'..."
	useradd -m -G audio,video,input,plugdev -s /bin/bash "$NEW_USER"
	passwd "$NEW_USER"
	ok "User '$NEW_USER' created."
fi

USER_HOME=$(getent passwd "$NEW_USER" | cut -d: -f6)
[ -z "$USER_HOME" ] && err "Could not determine home directory for '$NEW_USER'."

# We'll do the rest of the build as the new user where possible
as_user() { sudo -u "$NEW_USER" "$@"; }

mkdir -p "$USER_HOME/$BIN_DIR"
mkdir -p "$USER_HOME/.local/share/fonts"
mkdir -p "$USER_HOME/.local/share/apps"
mkdir -p "$USER_HOME/$SCRIPT_DIR"
mkdir -p "$USER_HOME/.local/src"
mkdir -p "$USER_HOME/.config"

# Create emulator ROMs directory if that feature is enabled
if [ "$INSTALL_EMU" = 1 ]; then
	mkdir -p "$USER_HOME/Downloads/emu-roms"
	chown "$NEW_USER:" "$USER_HOME/Downloads/emu-roms"
	ok "EMU_ROMS directory created at ~/Downloads/emu-roms"
fi

# ── Font Installation ──────────────────────────────────────────────────────

info "Installing $FONT_NAME..."
if ! fc-list | grep -qi "IosevkaTerm" 2>/dev/null; then
	if command -v unzip >/dev/null 2>&1; then
		TMPDIR=$(mktemp -d)
		as_user sh -c "
			cd '$TMPDIR'
			curl -fL '$FONT_URL' -o font.zip 2>/dev/null || wget -q '$FONT_URL' -O font.zip
			unzip -q font.zip -d fontdir
			cp fontdir/*.ttf fontdir/*.otf '$USER_HOME/.local/share/fonts/' 2>/dev/null || true
			fc-cache -f '$USER_HOME/.local/share/fonts/'
		"
		rm -rf "$TMPDIR"
		ok "Font installed."
	else
		warn "unzip not found. Install $FONT_NAME manually."
	fi
else
	ok "Font already installed."
fi

# ── Build Suckless Tools ────────────────────────────────────────────────────

build_suckless() {
	NAME="$1"
	REPO="$2"
	CONFIG_SRC="${3:-}"
	WORKDIR_OVERRIDE="${4:-}"

	info "Building $NAME..."
	SRCDIR="$USER_HOME/.local/src/$NAME"

	if [ -d "$SRCDIR" ]; then
		info "$NAME already cloned, pulling updates..."
		as_user sh -c "cd '$SRCDIR' && git pull --ff-only 2>/dev/null || true"
	else
		as_user git clone --depth=1 "$REPO" "$SRCDIR"
	fi

	if [ -n "$CONFIG_SRC" ] && [ -f "$CONFIG_SRC" ]; then
		cp "$CONFIG_SRC" "$SRCDIR/config.h"
		chown "$NEW_USER:" "$SRCDIR/config.h"
	fi

	if [ -n "$WORKDIR_OVERRIDE" ]; then
		as_user sh -c "cd '$SRCDIR' && make WORKDIR='$WORKDIR_OVERRIDE'"
	else
		as_user sh -c "cd '$SRCDIR' && make"
	fi

	cp "$SRCDIR/$NAME" "$USER_HOME/$BIN_DIR/"
	chown "$NEW_USER:" "$USER_HOME/$BIN_DIR/$NAME"
	chmod +x "$USER_HOME/$BIN_DIR/$NAME"
	ok "$NAME built and installed to $USER_HOME/$BIN_DIR/"
}

# Build dwm
if [ -f "config.h" ]; then
	build_suckless "dwm" "$REPO_DWM" "$(pwd)/config.h"
else
	build_suckless "dwm" "$REPO_DWM"
fi

# Build st
build_suckless "st" "$REPO_ST"

# Build dmenu
build_suckless "dmenu" "$REPO_DMENU"

# Build dwmblocks — set WORKDIR so the status script path is correct
build_suckless "dwmblocks" "$REPO_DWMBLOCKS" "" "$USER_HOME/$BIN_DIR"

# Copy dwmblocks network status script (called by the status bar via WORKDIR/test)
if [ -f "dwmblocks/test" ]; then
	cp dwmblocks/test "$USER_HOME/$BIN_DIR/test"
	chown "$NEW_USER:" "$USER_HOME/$BIN_DIR/test"
	chmod +x "$USER_HOME/$BIN_DIR/test"
fi

# Copy man page
if [ -f "dwm-ui.1" ]; then
	cp dwm-ui.1 /usr/local/share/man/man1/
	mandb 2>/dev/null || true
	ok "Man page installed."
fi

# ── Add ~/.local/bin to PATH ───────────────────────────────────────────────

if ! grep -q "local/bin" "$USER_HOME/.bashrc" 2>/dev/null; then
	cat >> "$USER_HOME/.bashrc" << 'BASHEOF'
export PATH="$HOME/.local/bin:$PATH"
BASHEOF
	chown "$NEW_USER:" "$USER_HOME/.bashrc"
fi

# ── Custom Scripts ─────────────────────────────────────────────────────────

info "Creating custom scripts in $USER_HOME/$BIN_DIR/..."

# m-apps (app launcher)
cat > "$USER_HOME/$BIN_DIR/m-apps" << 'SCRIPT'
#!/bin/sh
# m-apps - universal app launcher (simplified version)
# Customize ~/.local/share/apps/apps.csv with: type,name,path
CMD="$1"
NAME="$2"
CSV="$HOME/.local/share/apps/apps.csv"

[ ! -f "$CSV" ] && echo "No apps.csv found" && exit 1

case "$CMD" in
	launch)
		ENTRY=$(grep -i ",$NAME," "$CSV" | head -1)
		[ -z "$ENTRY" ] && echo "App '$NAME' not found" && exit 1
		TYPE=$(echo "$ENTRY" | cut -d, -f1)
		FPATH=$(echo "$ENTRY" | cut -d, -f3)
		case "$TYPE" in
			graphics) "$FPATH/$NAME" & ;;
			term) st -e "$FPATH/$NAME" & ;;
			term-nonint) "$FPATH/$NAME" & ;;
		esac
		;;
	list)
		cat "$CSV" | cut -d, -f2
		;;
	*)
		echo "Usage: m-apps (launch|list) [name]"
		;;
esac
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/m-apps"

# ws (url opener)
cat > "$USER_HOME/$BIN_DIR/ws" << 'SCRIPT'
#!/bin/sh
[ "$1" != "" ] && { qutebrowser "$1" & }
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/ws"

# sv (invidious video browser)
cat > "$USER_HOME/$BIN_DIR/sv" << 'SCRIPT'
#!/bin/sh
PATH="$PATH:$HOME/.local/bin"
channel_sel=$(winv list-channels 2>/dev/null | dmenu | rev | cut -d ' ' -f1 | rev)
[ -z "$channel_sel" ] && exit 1
selected=$(winv --url "$channel_sel" show-feed 2>/dev/null | dmenu | cut -d ' ' -f1)
[ -z "$selected" ] && exit 1
m-apps launch qutebrowser "https://inv.nadeko.net/watch?v=$selected"
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/sv"

# timer_term
cat > "$USER_HOME/$BIN_DIR/timer_term" << 'SCRIPT'
#!/usr/bin/env bash
# timer_term - simple timer with optional comment
HELP_MSG="Usage: timer_term [-s] [-c COMMENT] DURATION"
SILENT="False"
COMMENT=""
[ $# -eq 0 ] && echo "$HELP_MSG" && exit 1
while [ $# -gt 0 ]; do
	case $1 in -s|--silent) SILENT="True" ;; -c|--comment) COMMENT="$2"; shift ;; -h|--help) echo "$HELP_MSG"; exit 0 ;; *) DURATION="$1" ;;
	esac
	shift
done
[ -z "$DURATION" ] && echo "$HELP_MSG" && exit 1
DURATION=$(echo "$DURATION" | cut -d# -f1)
case "$DURATION" in
	*m) SECS=$(echo "${DURATION%m}" | awk -Fh '{print ($1*3600)+($2*60)}') ;;
	*h) SECS=$(echo "${DURATION%h}" * 3600 | bc) ;;
	*s) SECS=${DURATION%s} ;;
	*) SECS="$DURATION" ;;
esac
[ "$SILENT" = "True" ] && { sleep "$SECS" && herbe "Timer done: $COMMENT" 2>/dev/null & exit; }
echo "Timer '$COMMENT' for ${SECS}s..."
for ((i=SECS; i>0; i--)); do
	printf "\r%3ds remaining..." "$i"
	sleep 1
done
echo; echo "Done!"
mpv --no-video ~/.alarms/beep.wav 2>/dev/null || true
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/timer_term"

# screenlock (simple i3lock wrapper)
cat > "$USER_HOME/$BIN_DIR/screenlock" << 'SCRIPT'
#!/bin/sh
# screenlock - simple screen locker wrapper
# Install i3lock-color or xsecurelock for actual locking
CMD="${1:-lock}"
case "$CMD" in
	lock) i3lock -c 1a1b26 2>/dev/null || slock ;;
	*) echo "Usage: screenlock [lock]" ;;
esac
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/screenlock"

# drawop placeholder
cat > "$USER_HOME/$BIN_DIR/drawop" << 'SCRIPT'
#!/bin/sh
notify-send "drawop" "Not yet implemented"
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/drawop"

# goom — built from source (disabled by default; set INSTALL_GOOM=1)
if [ "$INSTALL_GOOM" = 1 ]; then
	info "Building goom from $REPO_GOOM..."
	SRCDIR="$USER_HOME/.local/src/goom"
	if [ -d "$SRCDIR" ]; then
		as_user sh -c "cd '$SRCDIR' && git pull --ff-only 2>/dev/null || true"
	else
		as_user git clone --depth=1 "$REPO_GOOM" "$SRCDIR"
	fi
	# Try make first, fall back to go build
	if [ -f "$SRCDIR/Makefile" ] || [ -f "$SRCDIR/makefile" ]; then
		as_user sh -c "cd '$SRCDIR' && make"
	else
		as_user sh -c "cd '$SRCDIR' && go build -o goom ."
	fi
	if [ -f "$SRCDIR/goom" ]; then
		cp "$SRCDIR/goom" "$USER_HOME/$BIN_DIR/"
		chown "$NEW_USER:" "$USER_HOME/$BIN_DIR/goom"
		chmod +x "$USER_HOME/$BIN_DIR/goom"
		ok "goom built and installed."
	else
		warn "goom build produced no binary; check $SRCDIR"
	fi
else
	cat > "$USER_HOME/$BIN_DIR/goom" << 'SCRIPT'
#!/bin/sh
notify-send "goom" "Not yet implemented"
SCRIPT
	chmod +x "$USER_HOME/$BIN_DIR/goom"
fi

# img_select
cat > "$USER_HOME/$BIN_DIR/img_select" << 'SCRIPT'
#!/bin/sh
# img_select - pick a random image from given paths
find "$@" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' \) 2>/dev/null | shuf -n1
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/img_select"

# hnrss_reader placeholder
cat > "$USER_HOME/$BIN_DIR/hnrss_reader" << 'SCRIPT'
#!/bin/sh
curl -s "https://hnrss.org/frontpage" | sed 's/<[^>]*>//g' | grep -v '^[[:space:]]*$' | head -60
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/hnrss_reader"

# dmenurecord
cat > "$USER_HOME/$BIN_DIR/dmenurecord" << 'SCRIPT'
#!/bin/sh
# dmenurecord - simple screen recording frontend
CMD="${1:-menu}"
case "$CMD" in
	menu)
		CHOICE=$(printf "start\nstop\n" | dmenu -p "Recording:")
		[ "$CHOICE" = "start" ] && exec "$0" start
		[ "$CHOICE" = "stop" ] && exec "$0" stop
		;;
	start)
		FILE="$HOME/recording_$(date +%Y%m%d_%H%M%S).mp4"
		notify-send "Recording started" "$FILE"
		ffmpeg -f x11grab -s "$(xdpyinfo | awk '/dimensions/{print $2}')" -i :0.0 -c:v libx264 "$FILE" &
		echo "$!" > /tmp/dmenurecord.pid
		;;
	kill)
		kill "$(cat /tmp/dmenurecord.pid 2>/dev/null)" 2>/dev/null || pkill ffmpeg
		notify-send "Recording stopped"
		rm -f /tmp/dmenurecord.pid
		;;
	*) echo "Usage: dmenurecord (menu|start|kill)" ;;
esac
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/dmenurecord"

# pauseallmpv
cat > "$USER_HOME/$BIN_DIR/pauseallmpv" << 'SCRIPT'
#!/bin/sh
# Pause all running mpv instances
pkill -STOP mpv 2>/dev/null || true
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/pauseallmpv"

# sysact
cat > "$USER_HOME/$BIN_DIR/sysact" << 'SCRIPT'
#!/bin/sh
# sysact - system action menu
CHOICE=$(printf "lock\nlogout\nreboot\nshutdown\ncancel\n" | dmenu -p "System:")
case "$CHOICE" in
	lock) i3lock -c 1a1b26 2>/dev/null || slock ;;
	logout) pkill dwm ;;
	reboot) systemctl reboot 2>/dev/null || loginctl reboot 2>/dev/null || sudo reboot ;;
	shutdown) systemctl poweroff 2>/dev/null || loginctl poweroff 2>/dev/null || sudo poweroff ;;
esac
SCRIPT
chmod +x "$USER_HOME/$BIN_DIR/sysact"

chown -R "$NEW_USER:" "$USER_HOME/$BIN_DIR"
ok "Custom scripts created."

# ── Extra Scripts from Repo (disabled by default; set INSTALL_SCRIPTS=1) ────

if [ "$INSTALL_SCRIPTS" = 1 ]; then
	info "Cloning extra scripts from $REPO_SCRIPTS..."
	SCRIPTS_SRC="$USER_HOME/.local/src/scripts"
	if [ -d "$SCRIPTS_SRC" ]; then
		as_user sh -c "cd '$SCRIPTS_SRC' && git pull --ff-only 2>/dev/null || true"
	else
		as_user git clone --depth=1 "$REPO_SCRIPTS" "$SCRIPTS_SRC"
	fi
	# Copy any executables from the scripts repo into ~/.local/bin
	if [ -d "$SCRIPTS_SRC/exec" ]; then
		as_user sh -c "cp -r '$SCRIPTS_SRC/exec/'* '$USER_HOME/$BIN_DIR/' 2>/dev/null || true"
		chown -R "$NEW_USER:" "$USER_HOME/$BIN_DIR"
	fi
	ok "Extra scripts installed from $REPO_SCRIPTS."
fi

# ── Apps CSV ────────────────────────────────────────────────────────────────

if [ ! -f "$USER_HOME/.local/share/apps/apps.csv" ]; then
	cat > "$USER_HOME/.local/share/apps/apps.csv" <<- CSVEOF
	graphics,qutebrowser,/usr/bin
	graphics,keepassxc,/usr/bin
	term,st,$USER_HOME/.local/bin
	term-nonint,dwmblocks,$USER_HOME/.local/bin
	CSVEOF
	chown -R "$NEW_USER:" "$USER_HOME/.local/share/apps"
	ok "apps.csv created."
fi

# ── .xinitrc ────────────────────────────────────────────────────────────────

if [ ! -f "$USER_HOME/.xinitrc" ]; then
	cat > "$USER_HOME/.xinitrc" <<- 'XEOF'
	#!/bin/sh
	# Start dwm-fractal
	userresources=$HOME/.Xresources
	[ -f "$userresources" ] && xrdb -merge "$userresources"
	exec dwm
	XEOF
	chmod +x "$USER_HOME/.xinitrc"
	chown "$NEW_USER:" "$USER_HOME/.xinitrc"
	ok ".xinitrc created."
fi

# ── Xresources (Tokyo Night colors) ─────────────────────────────────────────

if [ ! -f "$USER_HOME/.Xresources" ]; then
	cat > "$USER_HOME/.Xresources" <<- 'XEOF'
	! Tokyo Night colors for dwm-fractal
	*.foreground:   #a9b1d6
	*.background:   #1a1b26
	*.color0:       #1a1b26
	*.color8:       #444b6a
	*.color1:       #f7768e
	*.color9:       #f7768e
	*.color2:       #9ece6a
	*.color10:      #9ece6a
	*.color3:       #e0af68
	*.color11:      #e0af68
	*.color4:       #7aa2f7
	*.color12:      #7aa2f7
	*.color5:       #bb9af7
	*.color13:      #bb9af7
	*.color6:       #7dcfff
	*.color14:      #7dcfff
	*.color7:       #a9b1d6
	*.color15:      #c0caf5

	! dwm overrides
	borderpx:       2
	snap:           32
	showbar:        1
	topbar:         0
	nmaster:        1
	mfact:          0.55
	gappih:         15
	gappiv:         5
	gappoh:         10
	gappov:         15
	smartgaps:      1
	XEOF
	chown "$NEW_USER:" "$USER_HOME/.Xresources"
	ok ".Xresources created."
fi

# ── dwm.desktop entry ──────────────────────────────────────────────────────

mkdir -p /usr/share/xsessions
cat > /usr/share/xsessions/dwm-fractal.desktop << 'DEOF'
[Desktop Entry]
Encoding=UTF-8
Name=dwm-fractal
Comment=Dynamic window manager (fractal27 build)
Exec=dwm
Icon=dwm
Type=XSession
DEOF
ok "Desktop entry created."

# ── Optional Extras ─────────────────────────────────────────────────────────

info "Installing optional extras..."

# Common optional apps
case "$PM" in
	apt)
		install_packages qutebrowser keepassxc i3lock ffmpeg 2>/dev/null || true
		;;
	pacman)
		install_packages qutebrowser keepassxc i3lock ffmpeg 2>/dev/null || true
		;;
	dnf)
		install_packages qutebrowser keepassxc i3lock ffmpeg 2>/dev/null || true
		;;
	*)
		warn "Install optional apps manually: qutebrowser, keepassxc, i3lock, ffmpeg"
		;;
esac

# Install some basic system utils for status bar
case "$PM" in
	apt) install_packages procps iproute2 2>/dev/null || true ;;
	pacman) install_packages procps-ng iproute2 2>/dev/null || true ;;
	dnf) install_packages procps-ng iproute 2>/dev/null || true ;;
	*) warn "Install procps and iproute2 for status bar" ;;
esac

# ── Done ───────────────────────────────────────────────────────────────────

cat << DONE

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Installation complete!

  User:       $NEW_USER
  Home:       $USER_HOME
  dwm:        $USER_HOME/$BIN_DIR/dwm
  Man page:   dwm-ui(1)

$(if [ "$INSTALL_GOOM" = 1 ]; then echo "  goom:       built from $REPO_GOOM"; fi)
$(if [ "$INSTALL_SCRIPTS" = 1 ]; then echo "  scripts:    cloned from $REPO_SCRIPTS"; fi)

  To start dwm:
    • From TTY:   startx
    • From DM:    select "dwm-fractal" session

  Key guide:
    • Mod+F1 or Mod+Shift+h  →  man dwm-ui (this guide)
    • Mod+Return             →  terminal
    • Mod+d                  →  app launcher

  Config files:
    ~/.xinitrc
    ~/.Xresources
    ~/.local/share/apps/apps.csv

  Feature flags (set in install-env.sh before running):
    INSTALL_EMU=0      Emulator packages (fceux, rom dir)
    INSTALL_GOOM=0     Build goom from source
    INSTALL_SCRIPTS=0  Clone extra scripts from repo

  NOTE: Some keybindings reference programs that were not
  installed (qutebrowser, tor-browser, fceux, termshark, etc.).
  Install them separately if needed.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DONE
