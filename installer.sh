#!/bin/bash

set -e

REPO_URL="https://github.com/Hacknummberk/EasySsh_python.git"
INSTALL_DIR="$HOME/easy_ssh_app"
BUILD_DIR="$INSTALL_DIR/build"
DIST_DIR="$INSTALL_DIR/dist"
LOG_FILE="$HOME/easy_ssh_install.log"

cleanup() {
    echo -e "\n[!] Error or interrupted. Rolling back..."
    rm -rf "$INSTALL_DIR"
    echo "[!] Removed installed files"
    exit 1
}

trap cleanup SIGINT

progress_bar() {
    local pid=$1
    local msg=$2
    spin='-\|/'
    i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r[%c] %s" "${spin:$i:1}" "$msg"
        sleep 0.1
    done

    wait $pid || cleanup
    printf "\r[✓] %s\n" "$msg"
}

run_bg() {
    "$@" > /dev/null 2>&1 &
    progress_bar $! "$1"
}

echo "=== easy_ssh installer ==="

# ---------- CHECK GIT ----------
if ! command -v git &> /dev/null; then
    read -p "Git not found. Install? (Y/N): " yn
    [[ "$yn" =~ ^[Yy]$ ]] || cleanup

    if command -v apt &> /dev/null; then
        run_bg sudo apt update
        run_bg sudo apt install -y git
    elif command -v pacman &> /dev/null; then
        run_bg sudo pacman -Sy --noconfirm git
    elif command -v dnf &> /dev/null; then
        run_bg sudo dnf install -y git
    else
        cleanup
    fi
fi
echo "[✓] Git ready"

# ---------- CLONE ----------
git clone --progress "$REPO_URL" "$INSTALL_DIR" || cleanup
cd "$INSTALL_DIR"

# ---------- VALIDATE ----------
[ -f "easy_ssh.py" ] || cleanup
echo "[✓] Repo validated"

# ---------- PYTHON ----------
command -v python3 >/dev/null || cleanup

if ! python3 -m pip --version &> /dev/null; then
    run_bg python3 -m ensurepip --upgrade
fi

# ---------- REQUIREMENTS ----------
if [ -f "requirements.txt" ]; then
    run_bg python3 -m pip install --break-system-packages -r requirements.txt
else
    run_bg python3 -m pip install --break-system-packages paramiko
fi

# ---------- COMPILER CHECK ----------
echo "[*] Checking build environment..."

OS=$(uname)

install_build_tools_linux() {
    if command -v apt &> /dev/null; then
        run_bg sudo apt install -y build-essential python3-dev
    elif command -v pacman &> /dev/null; then
        run_bg sudo pacman -Sy --noconfirm base-devel python
    elif command -v dnf &> /dev/null; then
        run_bg sudo dnf install -y gcc python3-devel
    else
        echo "Unsupported package manager"
        cleanup
    fi
}

# check gcc (needed sometimes)
if [[ "$OS" == "Linux" ]]; then
    if ! command -v gcc &> /dev/null; then
        read -p "GCC not found. Install build tools? (Y/N): " yn
        [[ "$yn" =~ ^[Yy]$ ]] || cleanup
        install_build_tools_linux
    fi
fi

# check pyinstaller
if ! python3 -c "import PyInstaller" &> /dev/null; then
    run_bg python3 -m pip install --break-system-packages pyinstaller
fi

# verify pyinstaller works
if ! command -v pyinstaller &> /dev/null; then
    echo "[!] PyInstaller not working"
    cleanup
fi

echo "[✓] Compiler ready"

# ---------- BUILD ----------
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

if [[ "$OS" == "Linux" ]]; then
    run_bg pyinstaller --onefile easy_ssh.py --distpath "$DIST_DIR" --workpath "$BUILD_DIR"
elif [[ "$OS" == *"MINGW"* || "$OS" == *"CYGWIN"* || "$OS" == *"MSYS"* ]]; then
    run_bg pyinstaller --onefile easy_ssh.py --distpath "$DIST_DIR" --workpath "$BUILD_DIR"
else
    echo "Unsupported OS"
    cleanup
fi

# ---------- CLEAN ----------
rm -rf "$BUILD_DIR"

echo
echo "[✓] Installation complete"
echo "Binary: $DIST_DIR"
echo "Log: $LOG_FILE"
