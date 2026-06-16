# jq

> ตัวประมวลผล JSON บน command line — filter, แปลง, และดึงข้อมูลจาก JSON ด้วยภาษา query ของ jq เอง

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)

## ใช้งาน

```bash
# pretty-print + ระบายสี
cat data.json | jq

# ดึง field
jq '.name'                  # ค่าของ key "name"
jq '.user.email'            # nested
jq '.items[0]'              # element แรกของ array
jq '.items[]'               # ทุก element (กระจายออกมา)

# เลือกหลาย field เป็น object ใหม่
jq '{name: .name, id: .id}'

# กรอง array
jq '.items[] | select(.active == true)'
jq 'map(select(.price > 100))'

# แปลง / รวม
jq '.items | length'                       # นับ
jq '[.items[].name]'                        # ดึง name ทั้งหมดเป็น array
jq -r '.items[].name'                       # -r = raw (ไม่มี quote, ดีกับ pipe)
```

### คู่กับ gh

```bash
gh api repos/{owner}/{repo}/pulls | jq -r '.[].title'
gh pr list --json number,title | jq -r '.[] | "\(.number) \(.title)"'
```

## ทำไมถึงใช้ตัวนี้

- มาตรฐานโดยพฤตินัยสำหรับจัดการ JSON ใน shell — คู่กับ `gh api`, `curl`, REST API ทั่วไป
- ภาษา query ทรงพลัง (filter, map, select, string interpolation) ในบรรทัดเดียว

## ปัญหาที่เจอบ่อย

- **output มี quote ติดมา** → ใช้ `-r` (raw output) เวลาจะส่งต่อให้คำสั่งอื่นหรือเก็บลงตัวแปร
- **`jq: error: Cannot index ... with "x"`** → โครงสร้างไม่ตรงที่คิด; ลอง `jq .` ดูรูปร่างจริงก่อน หรือใช้ `?` กัน error (เช่น `.items[]?`)
- **อยากเทสต์ filter เร็วๆ** → วาง JSON เล็กๆ แล้ว `echo '{"a":1}' | jq '.a'`
