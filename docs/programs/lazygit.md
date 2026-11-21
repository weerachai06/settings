# lazygit

> Git TUI (หน้าจอใน terminal) — ดู status/diff/log, stage ทีละ hunk, commit, rebase และจัดการ branch ด้วยคีย์ลัด

## ติดตั้งจากไหน

- จัดการโดย: Nix — `programs.lazygit.enable` ใน [`home.nix`](../../home.nix)
- ยังไม่ได้ตั้งค่าอะไรเพิ่ม (ใช้ค่าเริ่มต้นของ lazygit); ถ้าจะปรับ ใช้ `programs.lazygit.settings`

หลังแก้ `home.nix` ต้องรัน `home-manager switch` ก่อนถึงจะมีคำสั่ง `lazygit`

## ใช้งาน

```bash
lazygit            # เปิดใน repo ปัจจุบัน
lazygit -p <path>  # เปิดใน repo อื่น
```

คีย์ที่ใช้บ่อย (กด `?` ในโปรแกรมเพื่อดูทั้งหมดของ panel ที่อยู่):

| คีย์ | ทำอะไร |
| --- | --- |
| `1`–`5` | ไปที่ panel Status / Files / Branches / Commits / Stash |
| `space` | stage / unstage ไฟล์ (หรือ checkout branch) |
| `enter` (ใน Files) | เข้าไปเลือก stage ทีละ hunk/บรรทัด |
| `c` | commit |
| `P` / `p` | push / pull |
| `?` | ดู keybinding ของ panel ปัจจุบัน |
| `q` | ออก |

## ทำไมถึงใช้ตัวนี้

- stage ทีละ hunk/บรรทัดและ interactive rebase ทำได้เร็วกว่าพิมพ์ `git add -p` / `git rebase -i`
- มี module ใน home-manager จึงติดตั้งและตั้งค่าแบบ declarative ได้

## ปัญหาที่เจอบ่อย

- **`lazygit: command not found`** → รัน `home-manager switch` แล้วเปิด shell ใหม่
- **สีหรือไอคอนเพี้ยน** → ตรวจว่า terminal รองรับ true color (wezterm รองรับ)
