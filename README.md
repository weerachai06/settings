# gh-notifier-review

แจ้งเตือนผ่าน macOS Dialog ทุก 1 ชั่วโมง เมื่อมี GitHub Pull Request ที่รอการรีวิว กดปุ่ม "Open GitHub" เพื่อเปิด browser ไปยัง PR list ได้เลย

---

## ความต้องการ

- macOS
- [GitHub CLI (`gh`)](https://cli.github.com/) ติดตั้งผ่าน Homebrew
- Login GitHub CLI แล้ว (`gh auth login`)

---

## การติดตั้ง

### 1. Clone โปรเจกต์

```bash
git clone <repo-url> ~/Documents/projects/gh-notifier-review
cd ~/Documents/projects/gh-notifier-review
```

### 2. รัน install script

```bash
bash install.sh
```

script จะถามชื่อสำหรับ LaunchAgent แล้วจัดการทุกอย่างให้อัตโนมัติ หรือจะส่งชื่อเป็น argument เลยก็ได้:

```bash
bash install.sh yourname
```

**install.sh ทำอะไรบ้าง:**
1. สร้างไฟล์ `.plist` ใน `~/Library/LaunchAgents/` พร้อม path จริงอัตโนมัติ
2. ให้สิทธิ์ execute กับ `notify.sh`
3. โหลด LaunchAgent ให้ทันที

---

> **LaunchAgent คืออะไร?**
> ระบบ task scheduler ของ macOS ที่รัน script อัตโนมัติเป็น background process
> macOS จะอ่านไฟล์ `.plist` จาก `~/Library/LaunchAgents/` ของแต่ละ user
>
> | key | ความหมาย |
> |-----|----------|
> | `Label` | ชื่อ unique ของ job (reverse-domain convention) |
> | `ProgramArguments` | script ที่จะรัน |
> | `StartInterval` | รันทุกกี่วินาที |
> | `RunAtLoad` | รันทันทีเมื่อ login |

---

## วิธีใช้งาน

### ทดสอบรัน manual

```bash
bash notify.sh
```

ถ้ามี PR ค้างอยู่จะเห็น notification โผล่ขึ้นมาทันที ถ้าไม่มี PR จะไม่มีอะไรเกิดขึ้น

### ตรวจสอบสถานะ

```bash
launchctl list | grep gh-pr-notifier
```

ผลลัพธ์ที่ได้ `<PID>  0  com.weerachai.gh-pr-notifier` แปลว่าทำงานปกติ (exit code 0)

### ดู log

```bash
# stdout
cat /tmp/gh-pr-notifier.log

# error
cat /tmp/gh-pr-notifier-error.log
```

---

## จัดการ LaunchAgent

| คำสั่ง | ความหมาย |
|--------|----------|
| `launchctl load ~/Library/LaunchAgents/com.weerachai.gh-pr-notifier.plist` | เปิดใช้งาน |
| `launchctl unload ~/Library/LaunchAgents/com.weerachai.gh-pr-notifier.plist` | หยุดชั่วคราว |
| `launchctl list \| grep gh-pr-notifier` | ดูสถานะ |

LaunchAgent จะ start อัตโนมัติทุกครั้งที่ login เข้า macOS

---

## ปรับ interval

เปิดไฟล์ `com.weerachai.gh-pr-notifier.plist` แล้วแก้ค่า `StartInterval` (หน่วยเป็นวินาที)

```xml
<key>StartInterval</key>
<integer>3600</integer>  <!-- 3600 = 1 ชั่วโมง -->
```

ตัวอย่างค่าที่ใช้บ่อย:

| วินาที | เวลา |
|--------|------|
| 1800 | 30 นาที |
| 3600 | 1 ชั่วโมง |
| 7200 | 2 ชั่วโมง |
| 14400 | 4 ชั่วโมง |

หลังแก้ไขต้อง reload:

```bash
launchctl unload ~/Library/LaunchAgents/com.weerachai.gh-pr-notifier.plist
launchctl load ~/Library/LaunchAgents/com.weerachai.gh-pr-notifier.plist
```

---

## โครงสร้างไฟล์

```
gh-notifier-review/
├── notify.sh       # script หลัก
├── install.sh      # ติดตั้ง LaunchAgent อัตโนมัติ
└── README.md
```
# settings
