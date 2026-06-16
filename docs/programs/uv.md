# uv

> Python package & project manager เขียนด้วย Rust — แทน pip / pip-tools / virtualenv / pyenv ในตัวเดียว

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)
- shell completion ตั้งใน `programs.zsh.initContent` ([`home.nix`](../../home.nix)):

```bash
eval "$(uv generate-shell-completion zsh)"
```

## ใช้งาน

### ทำงานกับโปรเจกต์ (`pyproject.toml`)

```bash
uv init                  # สร้างโปรเจกต์ใหม่ + pyproject.toml
uv add requests          # เพิ่ม dependency (อัปเดต lockfile + venv ให้)
uv remove requests       # ถอด dependency
uv sync                  # ติดตั้งให้ตรงกับ uv.lock
uv run script.py         # รันใน venv ของโปรเจกต์ (sync ให้อัตโนมัติ)
uv lock                  # อัปเดต uv.lock
```

### จัดการ Python version

```bash
uv python install 3.12   # ติดตั้ง Python 3.12
uv python list           # ดูเวอร์ชันที่มี/ติดตั้งแล้ว
uv venv                  # สร้าง .venv ใน directory ปัจจุบัน
```

### รันเครื่องมือแบบ one-off

```bash
uvx ruff check .         # รัน tool โดยไม่ติดตั้งถาวร (เทียบ pipx run)
uv tool install ruff     # ติดตั้ง tool แบบถาวร
```

## ทำไมถึงใช้ตัวนี้

- ตัวเดียวแทน pip + virtualenv + pyenv + pipx — เร็วกว่ามาก (Rust)
- จัดการ Python interpreter เองได้ ไม่ต้องพึ่ง system Python
- มี lockfile (`uv.lock`) ให้ install ซ้ำได้เป๊ะ

## ปัญหาที่เจอบ่อย

- **`uv run` ช้าครั้งแรก** → กำลัง resolve + sync venv; ครั้งต่อไปจะ cache แล้วเร็ว
- **completion ไม่ทำงานใน shell ใหม่** → ตรวจว่า `eval "$(uv generate-shell-completion zsh)"` ถูกโหลด; เปิด shell ใหม่หรือ `source ~/.zshrc`
- **อยากใช้ tool ครั้งเดียวไม่อยากติดตั้ง** → ใช้ `uvx <tool>` แทน `uv tool install`
