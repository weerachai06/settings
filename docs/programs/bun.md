# Bun

> JavaScript runtime + package manager + bundler + test runner ในตัวเดียว เขียนด้วย Zig เน้นความเร็ว

## ติดตั้งจากไหน

- จัดการโดย: installer ของ bun เอง (macOS only, อยู่นอก Nix — ดู [ADR-0002](../adr/))

```bash
curl -fsSL https://bun.sh/install | bash
bun upgrade              # อัปเดตเป็นเวอร์ชันล่าสุด
```

- PATH + completion ตั้งใน `programs.zsh.initContent` เฉพาะ macOS ([`home.nix`](../../home.nix)):

```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"   # shell completion
```

## ใช้งาน

```bash
# Package manager (เร็วกว่า npm มาก)
bun install              # ติดตั้ง dependency จาก package.json
bun add <pkg>            # เพิ่ม dependency
bun remove <pkg>

# รัน
bun run <script>         # รัน script ใน package.json
bun <file.ts>            # รัน TS/JS ตรงๆ ไม่ต้อง transpile ก่อน
bun --hot server.ts      # hot reload

# Test / bundle
bun test
bun build ./index.ts --outdir ./dist
```

## bun vs fnm/Node

- [fnm](fnm.md) จัดการ **Node** runtime (สลับเวอร์ชันต่อโปรเจกต์)
- bun เป็น runtime **คนละตัว** — ใช้เมื่ออยากได้ความเร็วของ bun (รัน TS ตรงๆ, install เร็ว) ไม่ได้แทน fnm; เลือกใช้ตามโปรเจกต์

## ทำไมถึงใช้ตัวนี้

- install/รัน/test/bundle ครบในเครื่องมือเดียว ไม่ต้องประกอบ tool หลายตัว
- รัน TypeScript ได้ตรงๆ ไม่ต้องตั้ง ts-node/transpile
- เร็วกว่า npm/yarn/pnpm ในงาน install ส่วนใหญ่

## ปัญหาที่เจอบ่อย

- **`bun: command not found`** → `~/.bun/bin` เข้า PATH ผ่าน `~/.zshrc` (macOS only); เปิด shell ใหม่หรือ `source ~/.zshrc`
- **completion ไม่ขึ้น** → ตรวจว่ามีไฟล์ `~/.bun/_bun` (สร้างตอนติดตั้ง); ถ้าไม่มีให้ `bun completions`
- **บางแพ็กเกจที่พึ่ง Node API เฉพาะรันบน bun ไม่ได้** → fallback ไปใช้ Node ผ่าน [fnm](fnm.md) สำหรับโปรเจกต์นั้น
