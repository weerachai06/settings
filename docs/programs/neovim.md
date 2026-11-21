# Neovim

> Editor ใน terminal ที่ตั้งค่าด้วย Lua — ตอนนี้มี LSP ของ TypeScript/JavaScript, sidebar file tree (`nvim-tree`) และ syntax highlighting (`nvim-treesitter`) ไม่มี plugin manager (plugin มาจาก Nix)

## ติดตั้งจากไหน

- จัดการโดย: Nix — `programs.neovim` ใน [`home.nix`](../../home.nix) (ได้ Neovim 0.12.x)
- ไฟล์ config: [`nvim/init.lua`](../../nvim/init.lua)
- home-manager symlink ไปที่ `~/.config/nvim/init.lua` (read-only store symlink, ตั้งใน `xdg.configFile` ของ [`home.nix`](../../home.nix))
- LSP server ติดตั้งผ่าน `programs.neovim.extraPackages` (`typescript-language-server`, `typescript`) — อยู่ใน PATH ของ `nvim` เท่านั้น ไม่ได้อยู่ใน PATH ของ shell
- Plugin ติดตั้งผ่าน `programs.neovim.plugins`: `nvim-tree-lua`, `nvim-web-devicons`, `nvim-treesitter` (grammar: typescript, tsx, javascript, json, lua) — home-manager วางไว้ที่ `~/.local/share/nvim/site/pack/hm`

หลังแก้ `init.lua` หรือ `extraPackages` ต้องรัน `home-manager switch` เพื่ออัปเดต (config เป็น store symlink จึงไม่แก้ตรงๆ ใน `~/.config`)

## ใช้งาน

```bash
nvim file.ts                 # เปิดไฟล์ — LSP เริ่มเองเมื่อเจอ tsconfig.json / jsconfig.json / package.json / .git
```

คำสั่งใน nvim:

```vim
:checkhealth vim.lsp         " ดูว่า LSP client ทำงานปกติไหม
:lua =vim.lsp.get_clients()  " ดู client ที่ attach อยู่
```

Keymap ที่ใช้ได้ตอน LSP attach:

| คีย์ | ทำอะไร | มาจาก |
| --- | --- | --- |
| `gd` | ไปที่ definition | `init.lua` (ตั้งเอง) |
| `K` | hover (ดู type/doc) | default ของ Neovim 0.11+ |
| `grn` | rename symbol | default ของ Neovim 0.11+ |
| `gra` | code action | default ของ Neovim 0.11+ |
| `grr` | หา references | default ของ Neovim 0.11+ |
| `[d` / `]d` | ไป diagnostic ก่อนหน้า/ถัดไป | default ของ Neovim 0.11+ |

Keymap ของ sidebar (leader = `Space`):

| คีย์ | ทำอะไร |
| --- | --- |
| `<leader>e` | เปิด/ปิด file tree ด้านซ้าย |
| `<leader>E` | เปิด tree และชี้ไปที่ไฟล์ปัจจุบัน |
| `g?` (ใน tree) | ดู keymap ทั้งหมดของ nvim-tree |

Completion เปิดเองอัตโนมัติ (`autotrigger`) ผ่าน `vim.lsp.completion`

## การตั้งค่าที่สำคัญ

`nvim/init.lua` ใช้ `vim.lsp.config` / `vim.lsp.enable` ที่มากับ Neovim 0.11+ โดยตรง:

- **`ts_ls`** — รัน `typescript-language-server --stdio` กับ `javascript`, `javascriptreact`, `typescript`, `typescriptreact`
- **`root_markers`** — `tsconfig.json`, `jsconfig.json`, `package.json`, `.git` (หา root ของโปรเจกต์จากไฟล์เหล่านี้)
- **`vim.diagnostic.config({ virtual_text = true })`** — แสดงข้อความ error ต่อท้ายบรรทัด (Neovim ไม่เปิดให้เป็นค่าเริ่มต้น)
- **`LspAttach`** — เปิด completion และ map `gd` เฉพาะ buffer ที่มี LSP
- **`FileType` autocmd** — เรียก `vim.treesitter.start` เพื่อเปิด highlighting ของ ts/tsx/js/json/lua
- **`nvim-tree`** — กว้าง 32 คอลัมน์ แสดง diagnostics และสี git status ที่ชื่อไฟล์

### เพิ่ม language server ตัวอื่น

1. เพิ่ม package ใน `programs.neovim.extraPackages` ใน [`home.nix`](../../home.nix)
2. เพิ่ม `vim.lsp.config("<ชื่อ>", { cmd, filetypes, root_markers })` และ `vim.lsp.enable("<ชื่อ>")` ใน `nvim/init.lua`
3. `home-manager switch`

## ทำไมถึงใช้แบบนี้

- **ไม่มี plugin manager** — Neovim 0.11+ มี LSP, completion และ diagnostic ในตัว ส่วน plugin ที่จำเป็น (file tree, tree-sitter) ให้ Nix ติดตั้งแทน จึงไม่มี lazy.nvim/packer ให้ดูแล
- **ติดตั้งผ่าน Nix** — ได้ Neovim และ LSP เวอร์ชันเดียวกันทุกเครื่อง (macOS/Linux) ตามแนวคิด portable ใน [`CONTEXT.md`](../../CONTEXT.md)
- **`typescript-language-server`** — เลือกเพราะเป็น server มาตรฐานของ `ts_ls` ใน Neovim; ถ้าต้องการ server ตัวอื่น (เช่น `vtsls`) ให้ทำตามหัวข้อเพิ่ม language server ข้างบน

## ยังไม่ได้ตั้ง

- Plugin อื่นๆ (fuzzy finder, statusline, symbol outline ฯลฯ)

## ปัญหาที่เจอบ่อย

- **แก้ `init.lua` แล้วไม่มีผล** → config เป็น store symlink; รัน `home-manager switch` ก่อน
- **`nix build` / `home-manager switch` ไม่เจอ `nvim/init.lua`** → flake มองไม่เห็นไฟล์ที่ยังไม่ถูก track ใน git; รัน `git add -N nvim/init.lua` (หรือ `git add`)
- **พิมพ์ `typescript-language-server` ใน shell แล้ว command not found** → ตั้งใจให้เป็นแบบนี้ เพราะ LSP อยู่ใน PATH ของ `nvim` เท่านั้น
- **เปิดไฟล์ `.ts` แล้วไม่มี diagnostic** → รัน `:checkhealth vim.lsp` ดูว่ามี client `ts_ls` ไหม; ถ้าไม่มี ตรวจว่าไฟล์อยู่ในโปรเจกต์ที่มี `root_markers` อย่างใดอย่างหนึ่ง
