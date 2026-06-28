#!/usr/bin/env bash
set -e

# Configuration
IPAD_IP="192.168.1.15"  # Replace with your iPad IP address
APP_NAME="GeminiChat"

echo "🔨 Step 1: Cross-compiling Swift code targeting iOS 12.0 ARM64..."
swiftc -target arm64-apple-ios12.0 main.swift -o ${APP_NAME}

echo "📦 Step 2: Generating local Application Folder Hierarchy..."
rm -rf Payload
mkdir -p Payload/${APP_NAME}.app

# Move binary into place
mv ${APP_NAME} Payload/${APP_NAME}.app/

echo "📝 Step 3: Writing minimal programmatic Info.plist metadata config..."
cat <<EOF > Payload/${APP_NAME}.app/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.ai.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>Gemini Chat</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>12.0</string>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
</dict>
</plist>
EOF

echo "🗜️ Step 4: Compressing structural package into launchable IPA archive..."
zip -r ${APP_NAME}.ipa Payload/
rm -rf Payload

echo "🚀 Step 5: Transferring IPA payload directly to the iPad system filesystem..."
scp ${APP_NAME}.ipa root@${IPAD_IP}:/var/mobile/
rm ${APP_NAME}.ipa

echo "📱 Step 6: Forcing local AppSync registration and rebuilding UI Cache over SSH..."
ssh root@${IPAD_IP} "appinst /var/mobile/${APP_NAME}.ipa && rm /var/mobile/${APP_NAME}.ipa && uicache"

echo "✨ Complete! Check your iPad home screen for your native Gemini Client App!"