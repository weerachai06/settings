#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.${1:-}.gh-pr-notifier"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

# รับ your-name ถ้าไม่ได้ส่งมาเป็น argument
if [[ -z "$1" ]]; then
  read -rp "กรอกชื่อสำหรับ LaunchAgent (เช่น weerachai): " INPUT_NAME
  if [[ -z "$INPUT_NAME" ]]; then
    echo "❌ กรุณากรอกชื่อ"
    exit 1
  fi
  PLIST_NAME="com.${INPUT_NAME}.gh-pr-notifier"
  PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
fi

echo "→ สร้างไฟล์ $PLIST_PATH"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${PLIST_NAME}</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${SCRIPT_DIR}/notify.sh</string>
  </array>

  <key>StartInterval</key>
  <integer>3600</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/gh-pr-notifier.log</string>

  <key>StandardErrorPath</key>
  <string>/tmp/gh-pr-notifier-error.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    <key>HOME</key>
    <string>${HOME}</string>
  </dict>
</dict>
</plist>
EOF

echo "→ ให้สิทธิ์ execute กับ notify.sh"
chmod +x "$SCRIPT_DIR/notify.sh"

# unload ก่อนถ้ามีอยู่แล้ว
launchctl unload "$PLIST_PATH" 2>/dev/null

echo "→ โหลด LaunchAgent"
launchctl load "$PLIST_PATH"

if launchctl list | grep -q "${PLIST_NAME}"; then
  echo "✅ ติดตั้งสำเร็จ — จะแจ้งเตือนทุก 1 ชั่วโมง"
else
  echo "❌ โหลด LaunchAgent ไม่สำเร็จ ลองรัน: launchctl load $PLIST_PATH"
  exit 1
fi
