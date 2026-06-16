# CMake

> Build system generator ข้ามแพลตฟอร์ม — สร้าง build files (Makefile, Ninja, ฯลฯ) จาก `CMakeLists.txt`

## ติดตั้งจากไหน

- จัดการโดย: Nix — อยู่ใน `home.packages` ใน [`home.nix`](../../home.nix)
- ส่วนใหญ่อยู่ในรายการเพราะเป็น **build dependency** ของแพ็กเกจ/ไลบรารีเนทีฟ (native module, tool ที่ build จาก source) ไม่ค่อยได้เรียกใช้ตรงๆ

## ใช้งาน

```bash
# โฟลว์มาตรฐาน (out-of-source build)
cmake -B build -S .              # generate build files ลงโฟลเดอร์ build/
cmake --build build              # คอมไพล์
cmake --build build --target install

# เลือก generator / build type
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
```

## ทำไมถึงใช้ตัวนี้

- เป็น dependency ที่หลายเครื่องมือต้องใช้ตอน build (เช่น node-gyp, Python wheel ที่มี C extension); ใส่ไว้ใน Nix ให้พร้อมใช้
- ข้ามแพลตฟอร์ม — `CMakeLists.txt` เดียวใช้ได้ทั้ง macOS/Linux

## ปัญหาที่เจอบ่อย

- **`cmake: command not found` ตอน build แพ็กเกจ** → ติดตั้งผ่าน Nix แล้ว; รัน `home-manager switch` แล้วเปิด shell ใหม่
- **build cache เพี้ยนหลังเปลี่ยน config** → ลบโฟลเดอร์ `build/` แล้ว generate ใหม่ (`cmake -B build -S .`)
