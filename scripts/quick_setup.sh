#!/usr/bin/env bash
#
# iPad AI Box - Quick Setup Wrapper
# Runs through the basic checks and bootstraps.
#

usage() {
    echo "Usage: $0 <iPad_IP_Address>"
    echo "Example: $0 192.168.1.15"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

IPAD_IP="$1"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting iPad Quick Setup..."
echo ""

# 1. Run Diagnostics
"${SCRIPTS_DIR}/check_connection.sh" "${IPAD_IP}"

if [ $? -ne 0 ]; then
    echo "❌ Connection check failed. Stopping setup."
    exit 1
fi

echo ""
read -p "Proceed to install essential system tools (curl, git, htop, etc.) as 'root'? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 2. Install Tools
    "${SCRIPTS_DIR}/install_tools.sh" "${IPAD_IP}"
else
    echo "Skipping tool installation."
fi

echo ""
read -p "Proceed to configure Python environment for 'mobile' user? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 3. Bootstrap Python
    "${SCRIPTS_DIR}/bootstrap_python.sh" "${IPAD_IP}"
else
    echo "Skipping Python setup."
fi

echo ""
echo "🎉 Quick Setup finished."
