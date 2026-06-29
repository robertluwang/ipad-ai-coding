# iPad AI Coding Workstation

An end-to-end solution for transforming an older 64-bit iOS 12 iPad into a headless, autonomous AI app factory and development workstation.

Older iPads often suffer from lack of modern app support, but their Darwin-based kernel and ARM64 architecture make them excellent lightweight Unix-like servers. By utilizing a semi-untethered jailbreak and setting up isolated development environments, you can repurpose this hardware into a dedicated coding platform for deploying edge applications or running scripts on-demand.

## Features

- **Jailbreak Architecture:** Detailed setup instructions using Chimera & Zebra to unlock the filesystem and install core packages.
- **Resource Management:** Outlines memory limitations, swap architectures, and thermal/power management for 24/7 headless operation.
- **Remote Access (SSH):** Robust Launchd socket configuration for seamless Terminal/PowerShell connections from other machines.
- **Python Sandboxing:** Dual-layer Python 3 environment layout to run custom scripts without polluting the system's root packages.
- **Cross-Compilation Workflows:** Deploy full iOS applications compiled directly from an external laptop via SSH.

## Getting Started

Check out the comprehensive **[Master Guide (design.md)](./design.md)** for step-by-step instructions on setting up your environment, managing the network gateway, and preparing package managers.

### Quick Setup Scripts

We have provided utility scripts in the `scripts/` directory to help you quickly verify connections and configure the environment on your iPad from your laptop.

```bash
cd scripts/

# Run the interactive quick setup wrapper
./quick_setup.sh <YOUR_IPAD_IP>

# Or run individual tools:
./check_connection.sh <YOUR_IPAD_IP>  # Diagnoses SSH and prints system info
./install_tools.sh <YOUR_IPAD_IP>     # Installs curl, git, htop, network-cmds, zip, vim via apt
./bootstrap_python.sh <YOUR_IPAD_IP>  # Sets up ~/.local/bin PATH for the mobile user
```

### Troubleshooting SSH

If you cannot connect to the iPad, open the local terminal app on the iPad (e.g., NewTerm 2) and manually restart the SSH daemon:
```bash
su root
launchctl kickstart -k system/com.openssh.sshd
```

## Examples & Use Cases

This repository includes real-world use cases to demonstrate the capabilities of your newly minted AI Box.

- **[Gemini Chat Native UI App](./examples/gemini-chat-app):** A complete example demonstrating how to cross-compile a pure programmatic Swift UI app from your laptop, deploying it via shell scripts (`deploy.sh`), and pointing it at a local LiteLLM Vertex gateway VM.

## Running AI Agents & CLI Tools on iPad

To fully utilize the iPad as an AI workstation, you can run standalone AI scripts like `chat_cli.py` or `edge_agent.py` directly on the device. Because the iPad lacks the compute to run modern LLMs locally, we use an SSH tunnel to offload inference to a remote LiteLLM Gateway.

### Setting up the LiteLLM Tunnel

Since the iPad typically operates on dynamic IP addresses or Wi-Fi without a public IP, we establish an outbound SSH tunnel to your remote gateway VM. This securely forwards local traffic on port `4000` to the remote LiteLLM API.

Create or edit `~/.env` on your iPad:

```bash
export LITELLM_MASTER_KEY=<key>
export LITELLM_URL="http://127.0.0.1:4000/v1/chat/completions"
export LITELLM_MODEL="gemini-flash"

# Check if SSH is already running before starting the tunnel
if ! pgrep -f "L 4000:127.0.0.1:4000" > /dev/null; then
    echo "Starting LiteLLM tunnel..."
    ssh -i ~/.ssh/<private_key> -f -N -L 4000:127.0.0.1:4000 <vm_user>@<vm_ip>
fi
```

Add the following to your `~/.bashrc` (or `~/.profile`) to automatically source it upon login:

```bash
echo "source ~/.env" >> ~/.bashrc
source ~/.bashrc
```

### Running Python Chat CLI (`chat_cli.py`)
Clone your `chat-py-cli` repository to the iPad, install its requirements, and run it:
```bash
python3 chat_cli.py
```
This gives you an interactive, ChatGPT-style terminal interface powered by your remote gateway, right on your iPad.

### Running Autonomous Edge Agent (`edge_agent.py`)
Similarly, clone your `edge-agent` repository:
```bash
python3 edge_agent.py "Check the system uptime and free memory, then save the report to system_report.txt"
```
The edge agent will autonomously execute commands, read/write files locally on the iPad, and use the LiteLLM gateway for its reasoning loop.

## Maintenance

To keep the iPad running efficiently:
1. Ensure Auto-Lock is set to "Never".
2. Keep it connected to a power source.
3. Use the Python `venv` methodology detailed in the guide to avoid dependency conflicts.
