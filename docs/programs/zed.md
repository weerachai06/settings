# Zed

> Code editor หลักของเครื่องนี้ — config เป็น JSON (รองรับ comment), เน้น TS/JS + Tailwind และ AI agent ในตัว

## ติดตั้งจากไหน

- จัดการโดย: ติดตั้งเอง (GUI app, อยู่นอก Nix — ดู [ADR-0002](../adr/))
- ไฟล์ config (ตั้ง symlink ใน [`home.nix`](../../home.nix)):

| ไฟล์ | symlink ไปที่ | ชนิด symlink |
| --- | --- | --- |
| [`zed/settings.json`](../../zed/settings.json) | `~/.config/zed/settings.json` | `mkOutOfStoreSymlink` (Zed เขียนกลับได้) |
| [`zed/keymap.json`](../../zed/keymap.json) | `~/.config/zed/keymap.json` | store symlink (read-only) |
| [`zed/tasks.json`](../../zed/tasks.json) | `~/.config/zed/tasks.json` | store symlink (read-only) |

`settings.json` เป็น out-of-store symlink ชี้กลับเข้ารีโป — แก้ใน Zed (UI) หรือแก้ไฟล์ในรีโปก็ได้ ทั้งสองทางคือไฟล์เดียวกัน ส่วน `keymap.json`/`tasks.json` เป็น store symlink ต้องแก้ในรีโปแล้ว `home-manager switch`

## การตั้งค่าที่สำคัญ

### Editor / UI
- `base_keymap: "VSCode"` — ใช้ keybinding แบบ VSCode เป็นฐาน
- `theme`: dark = Catppuccin Mocha, light = Ayu Light (สลับตาม mode)
- `preferred_line_length: 80`, `ui_font_size: 16`, `buffer_font_size: 12`
- panel ส่วนใหญ่ (`project_panel`, `outline_panel`, `git_panel`, ...) จอดไว้ฝั่งซ้าย; `agent` จอดขวา

### TypeScript / JavaScript (`vtsls`)
- `importModuleSpecifier: "non-relative"` — auto-import ใช้ path แบบ non-relative (เช่น `@/foo` แทน `../foo`)
- `updateImportsOnFileMove: "always"` — ย้ายไฟล์แล้วแก้ import ให้อัตโนมัติ
- `autoUseWorkspaceTsdk: true` — ใช้ TypeScript version ของ workspace

### Tailwind
- รู้จัก class helper: `cva`, `cx`, `clsx`, `cls`, `classnames`, `cn`
- CSS ใช้ `tailwindcss-intellisense-css` และปิด `vscode-css-language-server` (`!` นำหน้า)

### AI
- `agent.default_model`: GitHub Copilot Chat `gpt-5-mini`, `default_profile: "ask"`
- `agent_servers`: ต่อ `claude-acp`, `opencode` (effort medium), `github-copilot-cli`
- `edit_predictions`: provider = `zed`, mode = eager แต่ปิดในไฟล์ env (`.env`, `.env.local`, ...) กัน prediction รั่วข้อมูล secret

## Keymap

`keymap.json` ปรับเล็กน้อยจาก default:
- `alt-space` → `editor::ShowCompletions`
- ปลด `ctrl-space` ออกจาก `ShowCompletions` (กันชนกับ input method)

## Tasks

`tasks.json` มี git task ที่เรียกผ่าน command palette / runnable ได้ (tag `git-command`):
- **Create branch from: \<sha\>** — สร้าง branch จาก commit ที่เลือก (ถาม branch name)
- **Checkout: \<sha\>** — หา branch ที่ชี้ commit นั้นแล้ว checkout; ถ้า branch ถูก worktree ล็อกอยู่จะ fallback ไป checkout commit ตรงๆ

## ทำไมถึงใช้ตัวนี้

- เร็ว (เขียนด้วย Rust, GPU-accelerated), มี AI agent + ACP ในตัว ต่อ opencode/claude ได้
- config เป็นไฟล์ JSON track ในรีโปได้ ไม่ต้องพึ่ง settings sync ของ editor

## ปัญหาที่เจอบ่อย

- **แก้ `keymap.json`/`tasks.json` แล้วไม่มีผล** → เป็น store symlink (read-only) ต้องแก้ในรีโปแล้วรัน `home-manager switch`
- **แก้ `settings.json` ใน Zed แล้วหายหลัง switch** → ไม่หาย เพราะเป็น out-of-store symlink ชี้กลับรีโป; แต่ถ้าแก้แล้วอยากเก็บถาวรอย่าลืม commit ในรีโป
- **auto-import ออกมาเป็น relative path** → ตรวจว่าโปรเจกต์ตั้ง path alias (`tsconfig` `paths`) ตรงกับ `non-relative` ที่ตั้งไว้
