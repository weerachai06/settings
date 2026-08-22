# Troubleshooting

ปัญหาที่เจอมาแล้วในเครื่องจริง พร้อมวิธีเช็คและวิธีแก้

## `command not found: fnm` / `command not found: uv` หลังเปิด terminal ใหม่

### อาการ

เปิด terminal มาเจอ error แบบนี้ตอน shell เริ่มทำงาน:

```
/Users/<user>/.zshrc:40: command not found: fnm
/Users/<user>/.zshrc:42: command not found: uv
```

ทั้งที่ `fnm` และ `uv` มีอยู่ใน `home.packages` ของ [`home.nix`](../home.nix) แล้ว และ
`home-manager switch` ก็รันผ่านโดยไม่มี error

### สาเหตุ

`fnm`/`uv` (และทุกอย่างที่ nix ติดตั้ง) จะถูกมองเห็นได้ก็ต่อเมื่อ `PATH` มี
`~/.nix-profile/bin` — ซึ่งถูกเซ็ตผ่านการ source `nix-daemon.sh` ใน
**`/etc/zshrc`** (ไฟล์ระบบของ macOS เอง ไม่ใช่ไฟล์ในการดูแลของ dotfiles/home-manager)

ปกติ Nix installer จะเติมบล็อกนี้ให้อัตโนมัติตอนติดตั้ง:

```bash
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
```

แต่ macOS update บางครั้งจะ **reset `/etc/zshrc`/`/etc/bashrc` ทับ** ทำให้บล็อกนี้หายไป
— เป็นปัญหาที่รู้จักกันดีของ Nix บน macOS ไม่เกี่ยวกับ dotfiles repo นี้เลย

### วิธีเช็ค

ไล่เช็คทีละจุดตามลำดับนี้:

```bash
# 1. nix daemon ทำงานอยู่ไหม
sudo launchctl print system/org.nixos.nix-daemon
# ควรเห็น "state = running"

# 2. ไบนารีที่ nix ติดตั้งอยู่จริงไหม
ls -la ~/.nix-profile/bin/fnm ~/.nix-profile/bin/uv
# ควรเจอ symlink ชี้เข้า /nix/store/...

# 3. /etc/zshrc มีบล็อก source nix-daemon.sh อยู่ไหม (จุดที่มักหาย)
grep -n "Nix" /etc/zshrc
# ถ้าไม่มี output เลย = นี่คือสาเหตุ
```

ถ้าข้อ 1–2 ผ่าน แต่ข้อ 3 ไม่เจออะไร แปลว่า nix เองติดตั้งสมบูรณ์ดี ปัญหาอยู่ที่
`/etc/zshrc` ล้วน ๆ

### วิธีแก้

ต้องแก้ไฟล์ `/etc/zshrc` ด้วย `sudo` — **ต้องรันใน terminal จริง** (Terminal.app/iTerm)
เท่านั้น เพราะต้องพิมพ์รหัสผ่านสด ๆ ตอน sudo ถาม (รันผ่าน agent/AI ไม่ได้เพราะไม่มี TTY
ให้กรอกรหัสผ่าน)

```bash
sudo sh -c 'printf "\n# Nix\nif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then\n  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh\nfi\n# End Nix\n" >> /etc/zshrc'
```

จากนั้น**เปิด terminal window ใหม่** (แค่แท็บใหม่บางทีไม่พอ ต้องเป็น window ใหม่จริง ๆ
เพื่อให้ shell เริ่มอ่าน `/etc/zshrc` ใหม่) แล้วเช็คว่าใช้ได้แล้ว:

```bash
which nix
which fnm
which uv
```

> ถ้าคำสั่ง `sudo` ไม่มีอะไรขึ้นหลังใส่รหัสผ่านถูก ถือว่าปกติ (`sudo`/`tee` ไม่ print
> อะไรตอนสำเร็จ) — สิ่งที่ยืนยันผลจริงคือ `grep -n "Nix" /etc/zshrc` ในข้อ 3 ด้านบน
> ต้องเจอบล็อกที่เพิ่งเติมเข้าไป

### จะเกิดซ้ำอีกไหม

- **ลง Nix ใหม่ทั้งหมด (uninstall แล้ว install ใหม่)** → installer เติมบล็อกนี้ให้เอง
  อัตโนมัติ ไม่ต้องแก้มือ
- **แค่ macOS update ในเครื่องเดิม** → เกิดซ้ำได้ เพราะสาเหตุคือ macOS
  เขียนทับ `/etc/zshrc` ไม่ใช่ nix หรือ dotfiles ทำอะไรผิด หลัง major macOS update
  ถ้า `fnm`/`uv`/`nix` หายจาก PATH อีก ให้กลับมาไล่เช็คตามลำดับด้านบนได้เลย
- dotfiles repo นี้จงใจไม่แตะ system-level config (ไม่ใช้ nix-darwin, ไม่ใช้ sudo —
  ดู [ADR-0002](adr/0002-home-manager-standalone.md)) ดังนั้น `/etc/zshrc`
  จะอยู่นอกเหนือการดูแลของ home-manager เสมอ ไม่มีทางป้องกันจุดนี้แบบถาวรจาก repo ได้
