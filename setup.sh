#!/usr/bin/env bash
set -e

R='\033[0m'
B='\033[1m'
DIM='\033[2m'
RED='\033[38;5;196m'
GRN='\033[38;5;84m'
CYN='\033[38;5;87m'
PRP='\033[38;5;141m'
YLW='\033[38;5;228m'
GRY='\033[38;5;245m'
WHT='\033[38;5;255m'
LINE='\033[38;5;240m'

clear 2>/dev/null || true
sleep 0.1

echo ""
echo -e "${PRP}${B}"
cat << 'BANNER'
    ___       __        __
   / __\__ _ / /_      / /
  / _\/ _` | __|_____/ /
 / / | (_| | ||_____/ /
 \/   \__,_|\__|   /_/
BANNER
echo -e "${R}"
echo -e "  ${DIM}${GRY}Lua(u) Decompiler${R}  ${PRP}│${R}  ${DIM}${GRY}Made by bisam${R}"
echo -e "  ${LINE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""

REPO="DexCodeSX/fat"

spin() {
    local pid=$1
    local msg=$2
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYN}${frames[$i]}${R} ${WHT}%s${R}" "$msg"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep 0.08
    done
    wait "$pid" 2>/dev/null
    local rc=$?
    if [ $rc -eq 0 ]; then
        printf "\r  ${GRN}✓${R} ${WHT}%s${R}\n" "$msg"
    else
        printf "\r  ${RED}✗${R} ${RED}%s${R}\n" "$msg"
        return $rc
    fi
}

info() { echo -e "  ${PRP}▸${R} ${WHT}$1${R}"; }
warn() { echo -e "  ${YLW}▸${R} ${YLW}$1${R}"; }
fail() { echo -e "\n  ${RED}✗ $1${R}\n"; exit 1; }
ok() { echo -e "  ${GRN}✓${R} ${WHT}$1${R}"; }

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH_OK="x86_64" ;;
    aarch64|arm64) ARCH_OK="aarch64" ;;
    *)
        fail "Only 64-bit systems are supported (x86_64 or aarch64). Your arch: $ARCH"
        ;;
esac

IS_TERMUX=0
IS_MACOS=0
IS_LINUX=0
PLATFORM="unknown"
BINARY_NAME=""

if [ -d "/data/data/com.termux" ] || [ "$PREFIX" = "/data/data/com.termux/files/usr" ]; then
    IS_TERMUX=1
    PLATFORM="termux"
    if [ "$ARCH_OK" != "aarch64" ]; then
        fail "Termux only supports aarch64 (64-bit ARM). Your arch: $ARCH"
    fi
    BINARY_NAME="medal-aarch64-android"

elif [ "$(uname -s)" = "Darwin" ]; then
    IS_MACOS=1
    PLATFORM="macos"
    if [ "$ARCH_OK" = "aarch64" ]; then
        BINARY_NAME="medal-aarch64-macos"
    else
        BINARY_NAME="medal-x86_64-macos"
    fi

elif [ "$(uname -s)" = "Linux" ]; then
    IS_LINUX=1
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        PLATFORM="$ID"
    else
        PLATFORM="linux"
    fi
    if [ "$ARCH_OK" = "x86_64" ]; then
        BINARY_NAME="medal-x86_64-linux-musl"
    else
        fail "Linux builds are only available for x86_64 right now. Your arch: $ARCH"
    fi

else
    fail "Couldn't figure out your OS. Only Termux, Linux and macOS are supported."
fi

echo -e "  ${GRY}Platform${R}    ${PRP}│${R}  ${WHT}${B}${PLATFORM}${R}"
echo -e "  ${GRY}Arch${R}        ${PRP}│${R}  ${WHT}${ARCH_OK}${R}"
echo -e "  ${GRY}Binary${R}      ${PRP}│${R}  ${WHT}${BINARY_NAME}${R}"
echo ""
echo -e "  ${LINE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""

if [ $IS_TERMUX -eq 1 ]; then
    if [ ! -d "$HOME/storage" ]; then
        info "Requesting storage access..."
        termux-setup-storage 2>/dev/null || true
        sleep 2
    fi

    if ! command -v curl &>/dev/null; then
        (pkg install -y curl) > /dev/null 2>&1 &
        spin $! "Installing curl"
    fi
fi

if [ $IS_MACOS -eq 1 ]; then
    if ! command -v curl &>/dev/null; then
        fail "curl not found. Install it with: brew install curl"
    fi
fi

if [ $IS_LINUX -eq 1 ]; then
    if ! command -v curl &>/dev/null; then
        if command -v sudo &>/dev/null; then
            S="sudo"
        else
            S=""
        fi
        ($S apt-get update -qq && $S apt-get install -y -qq curl) > /dev/null 2>&1 &
        spin $! "Installing curl"
    fi
fi

info "Fetching latest release..."

TAG=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | head -1 | cut -d'"' -f4)

if [ -z "$TAG" ]; then
    TAG=$(curl -sL "https://api.github.com/repos/${REPO}/releases" | grep '"tag_name"' | head -1 | cut -d'"' -f4)
fi

if [ -z "$TAG" ]; then
    fail "Couldn't find any releases on GitHub. Make sure ${REPO} has at least one release."
fi

ok "Found release: ${TAG}"

DL_URL="https://github.com/${REPO}/releases/download/${TAG}/${BINARY_NAME}"

info "Downloading ${BINARY_NAME}..."

DEST="$HOME/medal"

(curl -sL -o "$DEST" "$DL_URL") &
spin $! "Downloading binary"

if [ ! -f "$DEST" ] || [ ! -s "$DEST" ]; then
    fail "Download failed. Check your internet or try again."
fi

chmod +x "$DEST"
ok "Saved to ${DEST}"

"$DEST" --version 2>/dev/null && true

echo ""
echo -e "  ${LINE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""
echo -e "  ${GRN}${B}Done!${R}"
echo ""
echo -e "  ${WHT}To start the server:${R}"
echo -e "    ${PRP}\$${R} ${WHT}cd ~ && ./medal serve${R}"
echo ""
echo -e "  ${WHT}To decompile a file:${R}"
echo -e "    ${PRP}\$${R} ${WHT}cd ~ && ./medal decompile -i input.bin -o output.lua${R}"
echo ""
echo -e "  ${WHT}For all commands:${R}"
echo -e "    ${PRP}\$${R} ${WHT}./medal help${R}"
echo ""

if [ $IS_TERMUX -eq 1 ]; then
    echo -e "  ${GRY}Tip: use ngrok to expose the server to your executor${R}"
    echo -e "    ${PRP}\$${R} ${WHT}pkg install ngrok${R}"
    echo -e "    ${PRP}\$${R} ${WHT}ngrok http 3000${R}"
    echo ""
fi

if [ $IS_MACOS -eq 1 ]; then
    echo -e "  ${GRY}Tip: if macOS blocks it, run this first:${R}"
    echo -e "    ${PRP}\$${R} ${WHT}xattr -d com.apple.quarantine ~/medal${R}"
    echo ""
fi

if [ $IS_LINUX -eq 1 ]; then
    echo -e "  ${GRY}Tip: move it to your PATH so you can run it from anywhere${R}"
    echo -e "    ${PRP}\$${R} ${WHT}sudo mv ~/medal /usr/local/bin/medal${R}"
    echo ""
fi

echo -e "  ${DIM}${GRY}Made by bisam${R}"
echo ""
