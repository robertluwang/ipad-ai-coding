# Gemini iOS 12 Chat Application

This repository contains the source code and deployment tools for a native custom Gemini Chat UI app, designed specifically to run on a headless iOS 12 device (e.g., a jailbroken iPad via Chimera/Zebra).

## Overview

Based on the Headless iOS 12 Server Master Guide, this application acts as a client connected to a LiteLLM Vertex gateway VM. It provides a visual chat bubble interface dynamically resizable for on-device keyboard interactions.

### Features
- Native iOS UIKit application logic (`main.swift`)
- Autonomously builds a split-cell conversation view
- Interacts with a LiteLLM gateway over HTTP
- Automates compilation, bundling (`Info.plist`), packing (`.ipa`), and remote deployment (`deploy.sh`)

## Setup & Deployment

1. **Prerequisites:**
   - MacOS/Linux environment with `swiftc` installed (for cross-compiling to ARM64 iOS).
   - Jailbroken iOS 12 iPad with OpenSSH, AppSync Unified, and `appinst` installed (via Zebra/Cydia).

2. **Configure:**
   - In `main.swift`: Update `apiURLString` to point to your LiteLLM Gateway VM address.
   - In `deploy.sh`: Update `IPAD_IP` with your device's network IP address.

3. **Deploy:**
   Execute the deployment shell script which compiles the codebase, builds the `.ipa` package, securely transfers it to the iPad, and forces local AppSync registration:
   ```bash
   ./deploy.sh
   ```

## Architecture

- **`main.swift`**: Complete uncompiled codebase utilizing pure Swift and `UIKit` layout anchors, sidestepping Storyboards/Xibs for seamless CLI cross-compilation.
- **`deploy.sh`**: The build toolchain orchestrating `swiftc` compilation, payload structuring, zip archiving, and remote SSH execution.