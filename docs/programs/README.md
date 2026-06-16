# Programs

เอกสารอ้างอิงสำหรับโปรแกรม/เครื่องมือที่ใช้ในเครื่องนี้ — วิธีใช้, การตั้งค่า, และทำไมถึงเลือกใช้

แหล่งความจริงของ *การติดตั้ง* คือ [`home.nix`](../../home.nix); หน้านี้อธิบาย *การใช้งาน*

## CLI tools (ผ่าน Nix)

| โปรแกรม | หน้าที่ | เอกสาร |
| --- | --- | --- |
| `cmake` | build system | [cmake.md](cmake.md) |
| `fnm` | Node version manager (auto-switch on `cd`) | [fnm.md](fnm.md) |
| `gh` | GitHub CLI | [gh.md](gh.md) |
| `jq` | ประมวลผล JSON | [jq.md](jq.md) |
| `openssl` | crypto / cert tooling | [openssl.md](openssl.md) |
| `uv` | Python package/venv manager | [uv.md](uv.md) |

## นอก Nix (ดู ADR-0002)

| โปรแกรม | หน้าที่ | เอกสาร |
| --- | --- | --- |
| wezterm | terminal emulator | [wezterm.md](wezterm.md) |
| zed | editor | [zed.md](zed.md) |
| opencode | AI coding agent | [opencode.md](opencode.md) |
| orbstack | container/VM runtime | [orbstack.md](orbstack.md) |
| bun | JS runtime / package manager | [bun.md](bun.md) |

> เติมลิงก์ในคอลัมน์ "เอกสาร" เมื่อสร้างหน้าของโปรแกรมนั้น ใช้ [`_template.md`](_template.md) เป็นจุดเริ่ม
