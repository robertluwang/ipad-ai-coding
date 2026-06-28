#!/usr/bin/env bash
#
# iPad AI Box - Bootstrap Python Environment
# This script securely connects to the iPad as the 'mobile' user
# and sets up the local Python PATH and pip configurations.
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
SSH_USER="mobile" # We use mobile for development, not root!

echo "================================================="
echo " 🐍 Bootstrapping Python Env for user 'mobile'"
echo "================================================="
echo "Target iPad IP: ${IPAD_IP}"
echo ""

echo "Attempting to connect as '${SSH_USER}'..."
echo "  -> Note: default password is usually 'alpine'"

ssh -o ConnectTimeout=5 "${SSH_USER}@${IPAD_IP}" << 'EOF'
echo "✅ Connected as mobile."

# Check if Python is available system-wide
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 is not installed."
    echo "Please log in as root or use Zebra to install Python 3 first."
    exit 1
fi

echo "🔧 Configuring ~/.bashrc for local pip packages..."

# Create .bashrc if it doesn't exist
touch ~/.bashrc

# Check if the PATH export already exists
if grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo "  -> PATH export already exists in ~/.bashrc."
else
    echo "  -> Adding ~/.local/bin to PATH in ~/.bashrc."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Create local bin directory just in case
mkdir -p ~/.local/bin

echo "✅ Environment prepared."
echo ""
echo "To test your environment, SSH into the iPad as mobile and run:"
echo "  pip3 install --user requests"
echo "  python3 -c 'import requests; print(\"Requests installed successfully!\")'"
EOF

if [ $? -eq 0 ]; then
    echo "✨ Python environment setup complete."
else
    echo "❌ Setup failed."
fi
