#!/bin/bash

set -e

REPO_URL="https://github.com/Hacknummberk/EasySsh_python.git"
INSTALL_DIR="$HOME/easy_ssh_app"
BUILD_DIR="$INSTALL_DIR/build"
DIST_DIR="$INSTALL_DIR/dist"

PROGRESS=0

draw_progress() {
    BAR_LEN=40
    FILLED=$((PROGRESS * BAR_LEN / 100))
    EMPTY=$((BAR_LEN - FILLED))

    BAR=$(printf "%0.s#" $(seq 1 $FILLED))
    SPACE=$(printf "%0.s-" $(seq 1 $EMPTY))

    echo -ne "\r[$BAR$SPACE] $PROGRESS%"
}

update_progress() {
    PROGRESS=$1
    draw_progress
}

rollback() {
    echo -e "\n[!] Error or interrupted. Rolling back..."
    rm -rf "$INSTALL_DIR"
    echo "[!] Cleanup complete."
    exit 1
}

trap rollback SIGINT

echo "[*] Starting installer..."

update_progress 5

# Check git
if ! command -v git &> /dev/null; then
    read -p "Git not found. Install git? (Y/N): " yn
    if [[ "$yn" == "Y" || "$yn" == "y" ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        else
            echo "Unsupported package manager"
            rollback
        fi
    else
        rollback
    fi
fi

update_progress 15

# Clone repo
git clone "$REPO_URL" "$INSTALL_DIR"

update_progress 30

cd "$INSTALL_DIR"

# Check python
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found"
    rollback
fi

update_progress 40

# Install pip if needed
if ! python3 -m pip --version &> /dev/null; then
    python3 -m ensurepip --upgrade || rollback
fi

update_progress 50

# Install requirements
if [ -f "requirements.txt" ]; then
    python3 -m pip install --break-system-packages -r requirements.txt || rollback
else
    python3 -m pip install --break-system-packages paramiko || rollback
fi

update_progress 65

# Install pyinstaller
python3 -m pip install --break-system-packages pyinstaller || rollback

update_progress 75

OS_TYPE=$(uname)

mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

# Build executable
if [[ "$OS_TYPE" == "Linux" ]]; then
    echo -e "\n[*] Building Linux executable..."
    pyinstaller --onefile easy_ssh.py --distpath "$DIST_DIR" --workpath "$BUILD_DIR" || rollback

elif [[ "$OS_TYPE" == "MINGW"* || "$OS_TYPE" == "CYGWIN"* || "$OS_TYPE" == "MSYS"* ]]; then
    echo -e "\n[*] Building Windows executable..."
    pyinstaller --onefile easy_ssh.py --distpath "$DIST_DIR" --workpath "$BUILD_DIR" || rollback
else
    echo "Unsupported OS"
    rollback
fi

update_progress 95

echo -e "\n[*] Cleaning build cache..."
rm -rf "$BUILD_DIR"

update_progress 100

echo -e "\n[✓] Installation complete"
echo "Binary located in: $DIST_DIR"

exit 0
