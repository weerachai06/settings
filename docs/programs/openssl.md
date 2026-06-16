# OpenSSL

> ชุดเครื่องมือ + ไลบรารี crypto/TLS — สร้าง key, cert, hash, และตรวจการเชื่อมต่อ TLS

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)
- อยู่ในรายการทั้งในฐานะ CLI และ **build/runtime dependency** ของเครื่องมืออื่นที่ลิงก์กับ libssl/libcrypto

## ใช้งาน

```bash
# สุ่มค่า / secret
openssl rand -hex 32             # token แบบ hex
openssl rand -base64 24

# hash / digest
openssl dgst -sha256 file

# key + self-signed cert (เช่น dev HTTPS)
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout key.pem -out cert.pem -days 365 -subj "/CN=localhost"

# ตรวจการเชื่อมต่อ TLS ของ server
openssl s_client -connect example.com:443 -servername example.com

# ดูรายละเอียด cert
openssl x509 -in cert.pem -noout -text
```

## ทำไมถึงใช้ตัวนี้

- มาตรฐานสำหรับงาน crypto/TLS บน CLI — สร้าง secret, dev cert, ดีบั๊ก TLS
- เป็น dependency ที่หลายเครื่องมือ/ภาษา (Python, Node native modules) ต้องลิงก์ด้วยตอน build

## ปัญหาที่เจอบ่อย

- **เวอร์ชัน OpenSSL ของระบบกับของ Nix ไม่ตรง** → ตรวจว่ากำลังเรียกตัวไหนด้วย `which openssl` / `openssl version`
- **`unable to load ... certificate`** → ตรวจ path และรูปแบบไฟล์ (PEM vs DER); แปลงด้วย `openssl x509 -inform DER -in cert.der -out cert.pem`
- **เบราว์เซอร์ไม่ยอมรับ self-signed cert** → ปกติสำหรับ dev; ต้อง trust cert เองในเครื่อง หรือใช้ tool อย่าง mkcert
