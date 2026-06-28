#!/usr/bin/env bash
#
# iPad AI Box - Tool Installation
# This script securely connects to the iPad as 'root'
# and installs essential command-line tools via APT.
#

set -e

usage() {
    echo "Usage: $0 <iPad_IP_Address>"
    echo "Example: $0 192.168.1.15"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

IPAD_IP="$1"
SSH_USER="root" # APT requires root privileges

echo "================================================="
echo " 🛠️ Installing Essential Tools via APT"
echo "================================================="
echo "Target iPad IP: ${IPAD_IP}"
echo ""

echo "Attempting to connect as '${SSH_USER}'..."
echo "  -> Note: default password is usually 'alpine'"

ssh -o ConnectTimeout=5 "${SSH_USER}@${IPAD_IP}" << 'EOF'
echo "✅ Connected as root."

# We need to make sure apt-get is available (Procursus bootstrap)
if ! command -v apt-get >/dev/null 2>&1; then
    echo "❌ apt-get not found. Ensure Chimera jailbreak and Procursus bootstrap are fully initialized."
    exit 1
fi

echo "🔄 Updating APT package lists..."
apt-get update

echo "📦 Installing core utilities (network-cmds, curl, wget, git, htop, zip, unzip, vim)..."
# Using -y to automatically answer yes to prompts
apt-get install -y network-cmds curl wget git htop zip unzip vim

echo "📝 Configuring Vim for better defaults (pasting, backspace)..."
cat << 'VIMRC' > ~/.vimrc
set nocompatible
set backspace=indent,eol,start
set pastetoggle=<F2>
syntax on
VIMRC

if [ $? -eq 0 ]; then
    echo "✅ Essential tools installed successfully."
else
    echo "❌ Failed to install one or more tools."
    exit 1
fi

echo "🧹 Cleaning up APT cache to save space..."
apt-get clean

echo "✅ Tool installation complete."
EOF

if [ $? -eq 0 ]; then
    echo "✨ Base system tools configured."
else
    echo "❌ Tool installation failed."
fi
