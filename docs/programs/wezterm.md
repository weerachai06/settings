# WezTerm

> Terminal emulator ที่ตั้งค่าด้วย Lua — เป็น terminal หลักของเครื่องนี้

## ติดตั้งจากไหน

- จัดการโดย: ติดตั้งเอง (GUI app, อยู่นอก Nix — ดู [ADR-0002](../adr/))
- ไฟล์ config: [`wezterm/wezterm.lua`](../../wezterm/wezterm.lua)
- home-manager symlink ไปที่ `~/.config/wezterm/wezterm.lua` (read-only store symlink, ตั้งใน [`home.nix`](../../home.nix))

หลังแก้ `wezterm.lua` ต้องรัน `home-manager switch` เพื่ออัปเดต symlink (config เป็น store symlink จึงไม่แก้ตรงๆ ใน `~/.config`)

## ใช้งาน

WezTerm โหลด config อัตโนมัติตอนเปิด และ reload ทันทีเมื่อไฟล์เปลี่ยน

```bash
# เปิด config ที่ wezterm กำลังใช้
wezterm show-keys          # ดู keybinding ที่ active อยู่
wezterm ls-fonts           # ตรวจว่า font ไหนถูกโหลด
```

## การตั้งค่าที่สำคัญ

ตอนนี้ config ตั้งต้นแบบ minimal — option ส่วนใหญ่ comment ไว้เป็นจุดเริ่ม เปิดใช้โดยลบ `--` ออก:

```lua
-- Font
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 14.0

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.hide_tab_bar_if_only_one_tab = true
```

โครงสร้าง: ใช้ `wezterm.config_builder()` แล้ว `return config` — เพิ่ม option ด้วยการ set field บน `config` ก่อน return

## ทำไมถึงใช้ตัวนี้

- config เป็น Lua → เขียน logic ได้ (เลือก theme ตาม OS, keybinding แบบมีเงื่อนไข) ต่างจาก terminal ที่ config เป็นไฟล์ static
- GPU-accelerated, cross-platform, ดูแลต่อเนื่อง

## ปัญหาที่เจอบ่อย

- **แก้ `wezterm.lua` แล้วไม่มีผล** → config เป็น store symlink ต้องรัน `home-manager switch` ก่อน แล้ว wezterm จะ reload ให้เอง
- **ตั้ง font แล้วขึ้น fallback** → font ยังไม่ได้ติดตั้งในเครื่อง; เช็คด้วย `wezterm ls-fonts --list-system`
