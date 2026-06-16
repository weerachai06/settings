# OrbStack

> Container & Linux VM runtime สำหรับ macOS — แทน Docker Desktop, เร็วและกินทรัพยากรน้อยกว่า

## ติดตั้งจากไหน

- จัดการโดย: ติดตั้งเอง (GUI app, macOS only, อยู่นอก Nix — ดู [ADR-0002](../adr/))
- shell integration ตั้งใน `programs.zsh.initContent` เฉพาะ macOS ([`home.nix`](../../home.nix)):

```bash
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
```

init script เพิ่ม `docker`/`orb` CLI เข้า PATH และตั้ง docker context ให้ชี้ OrbStack (`|| :` กัน error ตอนยังไม่ได้ติดตั้ง OrbStack)

## ใช้งาน

### Docker (drop-in)

OrbStack ให้ Docker engine ที่เข้ากันได้ — ใช้คำสั่ง `docker` / `docker compose` ได้ตามปกติ:

```bash
docker ps
docker compose up -d
docker context ls          # ควรเห็น context ของ orbstack เป็น active
```

### Linux VM / machine

```bash
orb create ubuntu my-vm    # สร้าง Linux machine
orb list                   # ดู VM/container ทั้งหมด
orb                        # เข้า shell ของ default machine
orb -m my-vm               # เข้า shell ของ machine ที่ระบุ
```

จัดการแบบ GUI ได้จาก OrbStack menu bar app

## ทำไมถึงใช้ตัวนี้

- เบากว่า/เร็วกว่า Docker Desktop, startup ไว, กิน RAM/แบตน้อยกว่า
- รวมทั้ง Docker container และ Linux VM ในแอปเดียว
- ฟรีสำหรับใช้งานส่วนตัว

## ปัญหาที่เจอบ่อย

- **`docker: command not found` หรือต่อ daemon ไม่ได้** → ยังไม่ได้เปิดแอป OrbStack หรือ `init.zsh` ไม่ถูกโหลด; เปิดแอปแล้ว `source ~/.zshrc`
- **`docker` ชี้ engine อื่น** → ตรวจ `docker context ls`; สลับด้วย `docker context use orbstack`
- **shell integration หาย** → ไฟล์ `~/.orbstack/shell/init.zsh` สร้างตอนติดตั้ง OrbStack; ถ้ายังไม่ติดตั้ง บรรทัด source จะถูกข้ามด้วย `|| :`
