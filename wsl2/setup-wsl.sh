#!/bin/bash
# WSL Development Environment Setup Script
# Recreates the dev environment on a fresh Ubuntu 24.04 WSL instance
#
# Prerequisites:
#   - Windows NVIDIA GPU driver installed (do NOT install Linux GPU drivers in WSL)
#
# Usage:
#   git clone https://github.com/0xKev/dotfiles ~/dotfiles
#   chmod +x ~/dotfiles/wsl2/setup-wsl.sh
#   ~/dotfiles/wsl2/setup-wsl.sh

set -e
trap 'echo "ERROR: Script failed at line $LINENO" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== WSL Dev Environment Setup ==="
echo "Dotfiles: $DOTFILES_DIR"
echo ""

# ------------------------------------------
# 1. System packages
# ------------------------------------------
echo "[1/8] Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    rsync

# ------------------------------------------
# 2. CUDA Toolkit (WSL-specific install)
# ------------------------------------------
echo "[2/8] Installing CUDA Toolkit..."
if ! command -v nvcc &>/dev/null; then
    # Add NVIDIA package repo for WSL-Ubuntu
    wget -q https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb -O /tmp/cuda-keyring.deb
    sudo dpkg -i /tmp/cuda-keyring.deb
    rm /tmp/cuda-keyring.deb
    sudo apt-get update
    # IMPORTANT: Only install cuda-toolkit, NOT cuda or cuda-drivers (those overwrite WSL driver)
    sudo apt-get install -y cuda-toolkit
    echo "CUDA Toolkit installed."
else
    echo "CUDA Toolkit already installed: $(nvcc --version | grep release)"
fi

# ------------------------------------------
# 3. Go
# ------------------------------------------
echo "[3/8] Installing Go..."
if ! command -v go &>/dev/null; then
    GO_VERSION="1.25.6"
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    echo "Go installed."
else
    echo "Go already installed: $(go version)"
fi

# ------------------------------------------
# 4. Neovim
# ------------------------------------------
echo "[4/8] Installing Neovim..."
if ! command -v nvim &>/dev/null; then
    NVIM_VERSION="v0.11.6"
    wget -q "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" -O /tmp/nvim.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    rm /tmp/nvim.tar.gz
    echo "Neovim installed."
else
    echo "Neovim already installed: $(nvim --version | head -1)"
fi

# ------------------------------------------
# 5. uv + Python tooling
# ------------------------------------------
echo "[5/8] Installing uv and Python tools..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed."
else
    echo "uv already installed: $(uv --version)"
fi

export PATH="$HOME/.local/bin:$PATH"
uv tool install cmake

# ------------------------------------------
# 6. Directory structure
# ------------------------------------------
echo "[6/8] Creating directory structure..."
mkdir -p ~/projects/{pycharm,webstorm,idea,personal}
mkdir -p ~/tools
mkdir -p ~/models

# ------------------------------------------
# 7. llama.cpp (clone + build with CUDA)
# ------------------------------------------
echo "[7/8] Setting up llama.cpp..."
export PATH="/usr/local/cuda/bin:$HOME/.local/bin:$PATH"

if [ ! -d ~/tools/llama.cpp ]; then
    git clone https://github.com/ggerganov/llama.cpp ~/tools/llama.cpp
else
    echo "llama.cpp already cloned, pulling latest..."
    git -C ~/tools/llama.cpp pull
fi

echo "Building llama.cpp with CUDA support..."
cd ~/tools/llama.cpp
cmake -B build -DGGML_CUDA=ON
cmake --build build --target llama-cli llama-server llama-completion -j$(nproc)

# ------------------------------------------
# 8. Dotfiles + git config
# ------------------------------------------
echo "[8/8] Linking dotfiles and configuring git..."

git config --global user.name "0xKev"
git config --global user.email "56137695+0xKev@users.noreply.github.com"

# Symlink .bashrc
if [ -L ~/.bashrc ]; then
    echo ".bashrc symlink already exists."
elif [ -f ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc.bak
    ln -s "$DOTFILES_DIR/wsl2/.bashrc" ~/.bashrc
    echo "Backed up ~/.bashrc -> ~/.bashrc.bak"
    echo "Symlinked ~/.bashrc -> $DOTFILES_DIR/wsl2/.bashrc"
else
    ln -s "$DOTFILES_DIR/wsl2/.bashrc" ~/.bashrc
    echo "Symlinked ~/.bashrc -> $DOTFILES_DIR/wsl2/.bashrc"
fi

# Symlink Neovim config (LazyVim)
if [ -L ~/.config/nvim ]; then
    echo "Neovim config symlink already exists."
elif [ -d ~/.config/nvim ]; then
    echo "WARNING: ~/.config/nvim exists and is not a symlink."
    echo "  Back it up or remove it, then re-run to symlink from dotfiles."
else
    mkdir -p ~/.config
    ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
    echo "Symlinked ~/.config/nvim -> $DOTFILES_DIR/nvim"
fi

# Copy .wslconfig to Windows side (Windows can't follow Linux symlinks)
if command -v cmd.exe &>/dev/null; then
    WIN_USERPROFILE="$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')"
    WIN_HOME="$(wslpath "$WIN_USERPROFILE")"
    if [ -d "$WIN_HOME" ]; then
        cp "$DOTFILES_DIR/wsl2/.wslconfig" "$WIN_HOME/.wslconfig"
        echo "Copied .wslconfig -> $WIN_HOME/.wslconfig"
    else
        echo "WARNING: Could not detect Windows home directory, skipping .wslconfig copy."
    fi
else
    echo "WARNING: WSL interop not available, skipping .wslconfig copy."
fi

# ------------------------------------------
# Done
# ------------------------------------------
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Verify with:"
echo "  source ~/.bashrc"
echo "  nvcc --version"
echo "  nvidia-smi"
echo "  go version"
echo "  nvim --version"
echo "  ~/tools/llama.cpp/build/bin/llama-cli --version"
echo ""
echo "To migrate projects from Windows:"
echo "  rsync -av --progress /mnt/c/Users/kevin/PycharmProjects/ ~/projects/pycharm/"
echo "  rsync -av --progress /mnt/c/Users/kevin/WebstormProjects/ ~/projects/webstorm/"
echo "  rsync -av --progress /mnt/c/Users/kevin/IdeaProjects/ ~/projects/idea/"
echo ""
echo "After migrating, fix CRLF line endings in git repos:"
echo "  for repo in ~/projects/*/*/; do"
echo "    [ -d \"\$repo/.git\" ] && cd \"\$repo\" && git config core.autocrlf input && git checkout -- . && cd -"
echo "  done"
