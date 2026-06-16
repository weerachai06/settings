# fnm

> Fast Node Manager — สลับ Node version อัตโนมัติเมื่อ `cd` เข้าโปรเจกต์ที่มี `.node-version` / `.nvmrc`

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)
- shell integration ตั้งใน `programs.zsh.initContent` ([`home.nix`](../../home.nix)):

```bash
eval "$(fnm env --use-on-cd --shell zsh)"
```

`--use-on-cd` คือหัวใจ: ทุกครั้งที่ `cd` เข้า directory ที่มีไฟล์ระบุเวอร์ชัน fnm จะสลับ Node ให้อัตโนมัติ

## ใช้งาน

```bash
fnm install 22          # ติดตั้ง Node 22
fnm install --lts       # ติดตั้ง LTS ล่าสุด
fnm use 22              # สลับเวอร์ชันใน shell ปัจจุบัน
fnm default 22          # ตั้งเป็น default ของ shell ใหม่
fnm list                # ดูเวอร์ชันที่ติดตั้ง
fnm current             # เวอร์ชันที่ active อยู่ตอนนี้
```

### Auto-switch ต่อโปรเจกต์

วางไฟล์ระบุเวอร์ชันไว้ที่ root ของโปรเจกต์ แล้ว `cd` เข้าไป fnm จะสลับให้เอง:

```bash
echo "22.11.0" > .node-version    # หรือ .nvmrc
```

> CLAUDE.md / AGENTS.md กำหนดให้ **รัน `fnm use` ก่อนคำสั่ง Node/npm ทุกครั้ง** — กันใช้เวอร์ชันผิดโปรเจกต์

## ทำไมถึงใช้ตัวนี้

- เขียนด้วย Rust เร็วกว่า nvm มาก และ shell startup ไม่หน่วง
- `--use-on-cd` ทำให้ไม่ต้องจำสลับเวอร์ชันเอง
- ติดตั้งผ่าน Nix ได้ ไม่ต้องพึ่ง install script

## ปัญหาที่เจอบ่อย

- **`cd` แล้วไม่สลับเวอร์ชัน** → โปรเจกต์ไม่มี `.node-version`/`.nvmrc` หรือ shell ยังไม่ได้โหลด `fnm env`; เปิด shell ใหม่หรือ `source ~/.zshrc`
- **`cd` เข้าโปรเจกต์แล้วขึ้นว่าไม่มีเวอร์ชันนั้น** → ยังไม่ได้ติดตั้ง รัน `fnm install` (เวอร์ชันจะอ่านจากไฟล์ให้เอง)
- **`node: command not found` ใน shell ใหม่** → ยังไม่ได้ตั้ง default; รัน `fnm default <version>`
