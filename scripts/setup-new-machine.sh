#!/bin/bash
# Quick setup script for new machines (Linux/WSL/macOS)
# Makes your environment 100% portable

set -e

echo "🚀 Setting up portable development environment..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "📱 Detected macOS"
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    OS="wsl"
    echo "🪟 Detected WSL"
else
    OS="linux"
    echo "🐧 Detected Linux"
fi

# Clone all repositories
echo "📦 Cloning repositories..."
cd ~

repos=(
    "https://github.com/EvanusModestus/dotfiles.git configs"
    "https://github.com/EvanusModestus/platform-tools.git tools-public"
    "https://github.com/EvanusModestus/infrastructure-lab.git lab"
    "https://github.com/EvanusModestus/tech-blog.git blog"
)

for repo in "${repos[@]}"; do
    url=$(echo $repo | cut -d' ' -f1)
    dir=$(echo $repo | cut -d' ' -f2)
    if [ ! -d "$dir" ]; then
        git clone $url $dir
        echo "✅ Cloned $dir"
    else
        echo "⏭️  $dir already exists, skipping"
    fi
done

# Private repos (will prompt for auth)
echo "🔐 Cloning private repos (will need GitHub auth)..."
if [ ! -d "tools-private" ]; then
    git clone https://github.com/EvanusModestus/internal-tools.git tools-private || echo "⚠️  Could not clone tools-private (private repo)"
fi

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf ~/configs/shell/.bashrc ~/.bashrc
ln -sf ~/configs/shell/.bash_aliases ~/.bash_aliases
ln -sf ~/configs/git/.gitconfig ~/.gitconfig
ln -sf ~/configs/tmux/tmux.conf ~/.tmux.conf

# Neovim config
mkdir -p ~/.config
ln -sf ~/configs/nvim ~/.config/nvim

echo "✅ Symlinks created"

# Install tools based on OS
echo "🛠️ Installing tools..."

if [ "$OS" = "macos" ]; then
    # macOS with Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install neovim tmux python3 node
    
elif [ "$OS" = "wsl" ] || [ "$OS" = "linux" ]; then
    # Linux/WSL with apt
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y neovim tmux python3 python3-pip nodejs npm
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim tmux python3 python3-pip nodejs npm
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm neovim tmux python python-pip nodejs npm
    fi
fi

# Install Python packages for tools
echo "🐍 Installing Python packages..."
pip3 install --user click pandas rich requests

# Install Neovim plugins
echo "📦 Installing Neovim plugins..."
nvim --headless +PackerSync +qa 2>/dev/null || echo "⚠️  Run :PackerSync in Neovim to install plugins"

# Source new bash config
source ~/.bashrc 2>/dev/null || true

echo "
✨ Setup Complete! ✨

Your portable environment is ready:
- ✅ Neovim with your config
- ✅ Tmux with your settings
- ✅ All your git repos
- ✅ Bash aliases and functions
- ✅ Python tools ready

Next steps:
1. Open tmux: tmux new -s main
2. Open Neovim: nvim
3. In Neovim, run :PackerSync to install plugins
4. Start coding!

Your repos:
- ~/lab           - Learning materials
- ~/configs       - Dotfiles
- ~/tools-public  - Public tools
- ~/tools-private - Private tools
- ~/blog          - Tech blog
"