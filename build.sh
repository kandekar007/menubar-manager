#!/bin/sh
set -e
cd "$(dirname "$0")"
A=MenuBarManager.app
rm -rf $A && mkdir -p $A/Contents/MacOS
swiftc -O -swift-version 5 main.swift -o $A/Contents/MacOS/MenuBarManager
cat > $A/Contents/Info.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>MenuBarManager</string>
<key>CFBundleIdentifier</key><string>local.menubar-manager</string>
<key>CFBundleName</key><string>MenuBarManager</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
EOF
codesign -s - --force $A
echo "built $A"
