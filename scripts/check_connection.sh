#!/usr/bin/env bash
#
# iPad AI Box - Initial Connection & Diagnostic Tool
# This script helps diagnose SSH connectivity and kickstart
# services on the iPad when first setting up or debugging.
#

set -e

print_header() {
    echo "================================================="
    echo " 📱 iPad AI Coding Box - Setup & Diagnostics"
    echo "================================================="
}

usage() {
    echo "Usage: $0 <iPad_IP_Address>"
    echo "Example: $0 192.168.1.15"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

IPAD_IP="$1"
SSH_USER="root"

print_header
echo "Target iPad IP: ${IPAD_IP}"
echo ""

# 1. Ping test
echo "📡 [1/4] Checking network reachability..."
if ping -c 1 -W 2 "${IPAD_IP}" > /dev/null 2>&1; then
    echo "  ✅ Host is reachable."
else
    echo "  ❌ Host unreachable. Check if iPad is on the same network and not asleep."
    exit 1
fi

# 2. Port 22 check
echo "🚪 [2/4] Checking if SSH port (22) is responding..."
if nc -z -w 3 "${IPAD_IP}" 22 > /dev/null 2>&1; then
    echo "  ✅ SSH port is open."
else
    echo "  ⚠️  SSH port appears closed."
    echo "  -> Note: OpenSSH on Chimera/Zebra uses Launchd Sockets (on-demand)."
    echo "  -> Attempting connection anyway, as the socket might spin up on connection."
fi

# 3. Connection and Basic Info Gathering
echo "🔐 [3/4] Attempting SSH connection & gathering system info..."
echo "  -> You may be prompted for the root password (default is usually 'alpine')."
echo "  -> NOTE: You should change default passwords immediately after setup using the 'passwd' command!"
echo ""

# We use a heredoc to run multiple commands on the remote device
ssh -o ConnectTimeout=5 "${SSH_USER}@${IPAD_IP}" << 'EOF'
echo "  ✅ Connected successfully!"
echo "  --------------------------"
echo "  OS Version:   $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
echo "  Kernel:       $(uname -v | awk '{print $1, $2, $3, $4}')"
if command -v htop >/dev/null 2>&1; then
    echo "  htop:         Installed"
else
    echo "  htop:         Not installed (Recommend installing via Zebra)"
fi

if command -v python3 >/dev/null 2>&1; then
    echo "  Python 3:     Installed ($(python3 --version))"
else
    echo "  Python 3:     Not installed"
fi

echo "  Disk Usage:   $(df -h / | awk 'NR==2 {print $4 " available"}')"
echo "  --------------------------"
EOF

# 4. Success
if [ $? -eq 0 ]; then
    echo "✨ [4/4] Diagnostics complete. Your iPad is ready for connections!"
else
    echo "❌ SSH connection failed."
    echo "Troubleshooting:"
    echo "1. Ensure the iPad is actively jailbroken (open Chimera app)."
    echo "2. Ensure OpenSSH is installed via Zebra/Sileo."
    echo "3. If it timed out, try kickstarting the SSH daemon on the iPad terminal:"
    echo "   launchctl kickstart -k system/com.openssh.sshd"
fi

echo ""
