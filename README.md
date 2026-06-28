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
./bootstrap_python.sh <YOUR_IPAD_IP>  # Sets up ~/.local/bin PATH for the mobile user
```

## Examples & Use Cases

This repository includes real-world use cases to demonstrate the capabilities of your newly minted AI Box.

- **[Gemini Chat Native UI App](./examples/gemini-chat-app):** A complete example demonstrating how to cross-compile a pure programmatic Swift UI app from your laptop, deploying it via shell scripts (`deploy.sh`), and pointing it at a local LiteLLM Vertex gateway VM.

## Maintenance

To keep the iPad running efficiently:
1. Ensure Auto-Lock is set to "Never".
2. Keep it connected to a power source.
3. Use the Python `venv` methodology detailed in the guide to avoid dependency conflicts.
