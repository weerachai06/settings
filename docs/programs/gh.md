# gh

> GitHub CLI — จัดการ PR, issue, repo, และเรียก GitHub API จาก terminal

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)
- ใช้ใน CLAUDE.md เป็นเครื่องมือมาตรฐานสำหรับงาน GitHub ทั้งหมด (PR/issue/API)
- `gh-pr-notifier/` ในรีโปก็เรียก `gh` เบื้องหลัง

## ตั้งค่าครั้งแรก

```bash
gh auth login            # ล็อกอิน (เลือก GitHub.com → HTTPS/SSH → browser)
gh auth status           # ตรวจสถานะ + scope ที่มี
```

> เป็น interactive login — ถ้าให้ agent ช่วย ให้พิมพ์ `! gh auth login` ในช่อง prompt เพื่อรันในเครื่องเอง

## ใช้งาน

```bash
# Pull requests
gh pr create             # เปิด PR จาก branch ปัจจุบัน
gh pr list               # ดู PR ในรีโป
gh pr view 123 --web     # เปิด PR #123 ในเบราว์เซอร์
gh pr checkout 123       # checkout branch ของ PR มาทดสอบ
gh pr status             # PR ที่เกี่ยวกับเรา

# Issues
gh issue create
gh issue list --label needs-triage

# Repo / API
gh repo view --web
gh api repos/{owner}/{repo}/pulls   # เรียก REST API ตรงๆ
```

## ทำไมถึงใช้ตัวนี้

- CLAUDE.md กำหนดให้ใช้ `gh` สำหรับงาน GitHub ทุกอย่าง — workflow สม่ำเสมอ ทั้งคนและ agent
- `gh api` เข้าถึง endpoint ที่ subcommand ยังไม่ครอบคลุมได้ ไม่ต้องเขียน curl + token เอง

## ปัญหาที่เจอบ่อย

- **`gh: command not found`** → ติดตั้งผ่าน Nix; รัน `home-manager switch` แล้วเปิด shell ใหม่
- **คำสั่งขึ้น `authentication required` / 401** → ยังไม่ได้ login หรือ token หมด scope; รัน `gh auth login` / `gh auth refresh -s <scope>`
- **interactive login รันใน agent ไม่ได้** → ใช้ `! gh auth login` ในช่อง prompt เพื่อรันในเครื่องเอง
