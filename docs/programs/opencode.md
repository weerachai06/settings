# opencode

> AI coding agent ที่รันใน terminal — config เป็น JSONC, มีไฟล์ instruction กลาง (`AGENTS.md`) และต่อ MCP server ได้

## ติดตั้งจากไหน

- จัดการโดย: installer ของ opencode เอง (อยู่นอก Nix — ดู [ADR-0002](../adr/))
- อยู่บน PATH ผ่าน `~/.opencode/bin` (ตั้งใน [`home.nix`](../../home.nix) เฉพาะ macOS)
- ไฟล์ config (symlink เฉพาะ macOS, ตั้งใน [`home.nix`](../../home.nix)):

| ไฟล์ | symlink ไปที่ | ชนิด symlink |
| --- | --- | --- |
| [`opencode/opencode.jsonc`](../../opencode/opencode.jsonc) | `~/.config/opencode/opencode.jsonc` | `mkOutOfStoreSymlink` (เขียนกลับได้) |
| [`opencode/AGENTS.md`](../../opencode/AGENTS.md) | `~/.config/opencode/AGENTS.md` | store symlink (read-only) |

`opencode.jsonc` เป็น out-of-store symlink ชี้กลับรีโป — แก้ที่ไหนก็เป็นไฟล์เดียวกัน ส่วน `AGENTS.md` เป็น store symlink ต้องแก้ในรีโปแล้ว `home-manager switch`

## การตั้งค่าที่สำคัญ

จาก [`opencode.jsonc`](../../opencode/opencode.jsonc):

- `model: "opencode-go/deepseek-v4-pro"` — โมเดล default
- `compaction.auto: true` — ย่อ context อัตโนมัติเมื่อบทสนทนายาว
- `mcp.atlassian-mcp-server` — ต่อ Atlassian MCP (Jira/Confluence) แบบ remote, เปิดใช้อยู่

## AGENTS.md

[`opencode/AGENTS.md`](../../opencode/AGENTS.md) คือ instruction กลางที่ opencode โหลดทุก session (เทียบเท่า `CLAUDE.md` ของ Claude Code) — กำหนดสไตล์การทำงาน: เขียนโค้ดน้อยที่สุด, แตะเฉพาะที่งานต้องการ, วางแผนก่อนทำงานหลายขั้น, สรุป ✅/⬜ ท้ายงาน, และ git safety (ห้าม force push)

> เนื้อหาส่วนใหญ่ตรงกับ global `~/.claude/CLAUDE.md` โดยตั้งใจ เพื่อให้ agent ทุกตัวทำงานสไตล์เดียวกัน

## ใช้งาน

```bash
opencode            # เปิด TUI ใน working directory ปัจจุบัน
```

opencode ยังถูกต่อเป็น agent server ใน Zed ด้วย (effort medium) — ดู [zed.md](zed.md)

## ทำไมถึงใช้ตัวนี้

- agent ที่รันใน terminal, สลับ provider/model ได้อิสระ
- config + AGENTS.md track ในรีโปได้ → instruction และ MCP เหมือนกันทุกเครื่อง

## ปัญหาที่เจอบ่อย

- **`opencode: command not found`** → `~/.opencode/bin` เข้า PATH ผ่าน `~/.zshrc` (macOS only); เปิด shell ใหม่หรือ `source ~/.zshrc`
- **แก้ `AGENTS.md` แล้วไม่มีผล** → เป็น store symlink (read-only) ต้องแก้ในรีโปแล้วรัน `home-manager switch`
- **MCP/Atlassian ขอ auth** → server เป็น remote authv2 ต้องทำ auth flow ครั้งแรกตอนเรียกใช้
