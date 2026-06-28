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

# Add LiteLLM SSH tunnel configuration
if grep -q 'LITELLM_URL' ~/.bashrc; then
    echo "  -> LiteLLM SSH tunnel configuration already exists in ~/.bashrc."
else
    echo "  -> Adding LiteLLM SSH tunnel configuration to ~/.bashrc."
    cat << 'BASHRC_EOF' >> ~/.bashrc

# LiteLLM Gateway Configuration
export LITELLM_MASTER_KEY="<key>"
export LITELLM_URL="http://127.0.0.1:4000/v1/chat/completions"
export LITELLM_MODEL="gemini-flash"

# Check if SSH is already running before starting the tunnel
if ! pgrep -f "L 4000:127.0.0.1:4000" > /dev/null; then
    echo "Starting LiteLLM tunnel..."
    ssh -i ~/.ssh/<private_key> -f -N -L 4000:127.0.0.1:4000 ubuntu@<litellm_ip>
fi
BASHRC_EOF
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
