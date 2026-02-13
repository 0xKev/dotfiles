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

set -euo pipefail
trap 'echo "ERROR: Script failed at step \"$CURRENT_STEP\" (line $LINENO)" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CURRENT_STEP="init"

# ------------------------------------------
# Helper: symlink with backup
# ------------------------------------------
# Why: the original had this logic copy-pasted 4 times with slight
# variations (starship didn't back up existing files, nvim refused
# to act on existing dirs). One function, consistent behavior.
link_dotfile() {
    local src="$1"
    local dest="$2"
    local label="${3:-$(basename "$dest")}"

    if [ -L "$dest" ]; then
        echo "$label symlink already exists."
    elif [ -e "$dest" ]; then
        mv "$dest" "${dest}.bak"
        ln -s "$src" "$dest"
        echo "Backed up $dest -> ${dest}.bak"
        echo "Symlinked $dest -> $src"
    else
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        echo "Symlinked $dest -> $src"
    fi
}

echo "=== WSL Dev Environment Setup ==="
echo "Dotfiles: $DOTFILES_DIR"
echo ""

# ------------------------------------------
# 1. System packages
# ------------------------------------------
CURRENT_STEP="System packages"
echo "[1/9] Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    rsync \
    zsh

# ------------------------------------------
# 2. CUDA Toolkit (WSL-specific install)
# ------------------------------------------
CURRENT_STEP="CUDA Toolkit"
echo "[2/9] Installing CUDA Toolkit..."
if ! command -v nvcc &>/dev/null; then
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
CURRENT_STEP="Go"
echo "[3/9] Installing Go..."

# Why export here: Go and Neovim are installed to non-standard paths
# (/usr/local/go/bin, /opt/nvim-linux-x86_64/bin). The original script
# never added these to PATH, so `command -v go` would fail on re-runs
# even after a successful install, and the llama.cpp build step couldn't
# find these tools. We front-load all PATH additions so every subsequent
# step (and idempotency check) sees the full environment.
export PATH="/usr/local/go/bin:/opt/nvim-linux-x86_64/bin:/usr/local/cuda/bin:$HOME/.local/bin:$PATH"

if ! command -v go &>/dev/null; then
    GO_VERSION="1.25.7"
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    echo "Go $GO_VERSION installed."
else
    echo "Go already installed: $(go version)"
fi

# ------------------------------------------
# 4. Neovim
# ------------------------------------------
CURRENT_STEP="Neovim"
echo "[4/9] Installing Neovim..."
if ! command -v nvim &>/dev/null; then
    NVIM_VERSION="v0.11.6"
    wget -q "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" -O /tmp/nvim.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    rm /tmp/nvim.tar.gz
    echo "Neovim $NVIM_VERSION installed."
else
    echo "Neovim already installed: $(nvim --version | head -1)"
fi

# ------------------------------------------
# 5. uv + Python tooling
# ------------------------------------------
CURRENT_STEP="uv + Python tooling"
echo "[5/9] Installing uv and Python tools..."

# Why not `curl | sh` directly: with set -e, if the install script
# returns non-zero for a benign reason (already installed, etc.) the
# entire setup script dies. Downloading first also lets you inspect
# the script and avoids partial-pipe failures.
#
# Trade-off: extra disk write and two commands instead of one. Worth it
# for a setup script you want to be robust.
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
    sh /tmp/uv-install.sh
    rm /tmp/uv-install.sh
    echo "uv installed."
else
    echo "uv already installed: $(uv --version)"
fi

uv tool install cmake

# ------------------------------------------
# 6. Starship & Zsh Plugins
# ------------------------------------------
CURRENT_STEP="Starship & Zsh plugins"
echo "[6/9] Installing Starship and Zsh plugins..."

if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh -o /tmp/starship-install.sh
    sh /tmp/starship-install.sh -y
    rm /tmp/starship-install.sh
    echo "Starship installed."
else
    echo "Starship already installed."
fi

mkdir -p ~/.zsh
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi

# Why sudo usermod instead of sudo chsh: chsh prompts for a password
# interactively, which breaks unattended runs. usermod -s does the same
# thing but doesn't prompt. Trade-off: none really — usermod is the
# better tool for scripted shell changes.
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    sudo usermod -s "$(which zsh)" "$USER"
fi

# ------------------------------------------
# 7. Directory structure
# ------------------------------------------
CURRENT_STEP="Directory structure"
echo "[7/9] Creating directory structure..."
mkdir -p ~/projects/{pycharm,webstorm,idea,personal}
mkdir -p ~/tools
mkdir -p ~/models

# ------------------------------------------
# 8. llama.cpp (clone + build with CUDA)
# ------------------------------------------
CURRENT_STEP="llama.cpp"
echo "[8/9] Setting up llama.cpp..."

if [ ! -d ~/tools/llama.cpp ]; then
    git clone https://github.com/ggerganov/llama.cpp ~/tools/llama.cpp
else
    echo "llama.cpp already cloned, pulling latest..."
    git -C ~/tools/llama.cpp pull
fi

echo "Building llama.cpp with CUDA support..."

# Why -j with a cap: the original used -j$(nproc) which uses all cores.
# CUDA compilation is memory-hungry (~1-2GB per parallel nvcc job). In
# WSL with a memory cap (often 8-16GB via .wslconfig), using all cores
# can OOM and kill the build with a cryptic signal 9.
#
# Half of nproc is a reasonable default. If you have 32GB+ in .wslconfig,
# you could bump this back to $(nproc).
#
# Why subshell (cd ...): the original did a bare `cd ~/tools/llama.cpp`
# which changes the working directory for the rest of the script. If the
# cmake build fails and you add steps after it later, they'd run from
# the wrong directory. A subshell scopes the cd.
(
    cd ~/tools/llama.cpp
    cmake -B build -DGGML_CUDA=ON
    cmake --build build --target llama-cli llama-server llama-completion -j$(($(nproc) / 2 + 1))
)

# ------------------------------------------
# 9. Dotfiles + git config
# ------------------------------------------
CURRENT_STEP="Dotfiles + git config"
echo "[9/9] Linking dotfiles and configuring git..."

git config --global user.name "0xKev"
git config --global user.email "56137695+0xKev@users.noreply.github.com"
git config --global core.autocrlf false
git config --global core.eol lf

link_dotfile "$DOTFILES_DIR/wsl2/.bashrc" ~/.bashrc ".bashrc"
link_dotfile "$DOTFILES_DIR/wsl2/.zshrc" ~/.zshrc ".zshrc"
link_dotfile "$DOTFILES_DIR/nvim" ~/.config/nvim "Neovim config"

# Starship config: only link if source exists in the repo
if [ -f "$DOTFILES_DIR/wsl2/starship.toml" ]; then
    link_dotfile "$DOTFILES_DIR/wsl2/starship.toml" ~/.config/starship.toml "Starship config"
else
    echo "WARNING: starship.toml not found in dotfiles. Using default Starship preset."
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
echo "  exec zsh"
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
echo "    [ -d \"\$repo/.git\" ] && cd \"\$repo\" && git add --renormalize . && git checkout -- . && cd -"
echo "  done"
