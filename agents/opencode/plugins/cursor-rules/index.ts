/**
 * cursor-rules — OpenCode V2 plugin ที่อ่าน rules/*.md แบบ Cursor-style
 * คือ inject rule ที่ globs pattern match กับไฟล์ที่ LLM กำลังจะแตะ
 *
 * พอร์ตจาก V1 (V1 plugin API ใช้กับ V2 ไม่ได้ — ดู https://opencode.ai/v2/docs/migrate-v1):
 * - V1 inject ผ่าน "tool.execute.before" แล้วแก้ output.system ของ tool call นั้น
 * - V2 hook ตัว tool แก้ได้แค่ input แก้ system ไม่ได้ จึงเปลี่ยนเป็นเก็บ path
 *   ของไฟล์ที่ read/edit/write ไว้ แล้ว inject rules ที่ match ผ่าน session.hook("context")
 *   ก่อนทุก model call แทน (behavior ใกล้เคียงกัน แต่ inject ต่อ model call ไม่ใช่ต่อ tool call)
 *
 * วาง plugin นี้ที่ (dotfiles จะ symlink ให้แล้วผ่าน home-manager):
 *   - ~/.config/opencode/plugins/cursor-rules/index.ts  (global — อันนี้)
 *   - .opencode/plugins/cursor-rules/index.ts           (project-level)
 *
 * โครงสร้าง rules/*.md ที่รองรับ (Cursor format):
 *   ---
 *   globs: "src/**\/*.ts"          ← string หรือ array ก็ได้
 *   alwaysApply: false             ← ถ้า true จะโหลดทุกครั้ง
 *   description: "TypeScript rules"
 *   ---
 *   # เนื้อหา rule ...
 */

import { Plugin } from "@opencode-ai/plugin"
import { readFileSync, readdirSync, statSync, existsSync } from "fs"
import { isAbsolute, join, relative } from "path"
import { Glob } from "bun"

// ─── Types ────────────────────────────────────────────────────────────────────

interface RuleFrontmatter {
  globs?: string | string[];
  alwaysApply?: boolean;
  description?: string;
}

interface ParsedRule {
  filePath: string;
  frontmatter: RuleFrontmatter;
  content: string; // เนื้อหาหลัง strip frontmatter แล้ว
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/** Parse YAML frontmatter แบบ minimal (ไม่ต้องลง yaml library) */
function parseFrontmatter(raw: string): {
  meta: RuleFrontmatter;
  body: string;
} {
  const FM_REGEX = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/;
  const match = raw.match(FM_REGEX);

  if (!match) return { meta: {}, body: raw };

  const [, yamlBlock, body] = match;
  const meta: RuleFrontmatter = {};

  for (const line of yamlBlock.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx === -1) continue;

    const key = line.slice(0, colonIdx).trim();
    const val = line.slice(colonIdx + 1).trim();

    if (key === "globs") {
      // รองรับ: globs: "*.ts"  หรือ  globs: ["*.ts", "*.tsx"]
      if (val.startsWith("[")) {
        meta.globs = val
          .slice(1, -1)
          .split(",")
          .map((s) => s.trim().replace(/['"]/g, ""))
          .filter(Boolean);
      } else {
        meta.globs = val.replace(/['"]/g, "");
      }
    } else if (key === "alwaysApply") {
      meta.alwaysApply = val === "true";
    } else if (key === "description") {
      meta.description = val.replace(/['"]/g, "");
    }
  }

  return { meta, body: body.trim() };
}

/** หา .md files ทั้งหมดใน directory (recursive) */
function collectMdFiles(dir: string): string[] {
  if (!existsSync(dir)) return [];

  const results: string[] = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      results.push(...collectMdFiles(full));
    } else if (entry.endsWith(".md") || entry.endsWith(".mdc")) {
      results.push(full);
    }
  }
  return results;
}

/** โหลดและ parse rules ทั้งหมดจาก rulesDir */
function loadRules(rulesDir: string): ParsedRule[] {
  const files = collectMdFiles(rulesDir);
  const rules: ParsedRule[] = [];

  for (const filePath of files) {
    try {
      const raw = readFileSync(filePath, "utf-8");
      const { meta, body } = parseFrontmatter(raw);
      rules.push({ filePath, frontmatter: meta, content: body });
    } catch {
      console.error(`failed to parse rule: ${filePath}`);
      // skip ไฟล์ที่อ่านไม่ได้
    }
  }

  return rules;
}

/** ตรวจว่า targetPath match globs patterns ไหม (ใช้ Bun.Glob — built-in, ไม่ต้องลง dependency) */
function matchesGlobs(targetPath: string, globs?: string | string[]): boolean {
  if (!globs) return false;

  const patterns = Array.isArray(globs) ? globs : [globs];
  return patterns.some((pattern) => new Glob(pattern).match(targetPath));
}

// ─── Plugin ───────────────────────────────────────────────────────────────────

export default Plugin.define({
  id: "cursor-rules",
  async setup(ctx) {
    // global plugin จะถูกโหลด per-location — directory คือ project/worktree ที่เปิด
    const worktree = ctx.location.directory;
    const rulesDir = join(worktree, "rules");

    // โหลด rules ครั้งเดียวตอน init (cache ไว้ในหน่วยความจำ)
    let cachedRules: ParsedRule[] = loadRules(rulesDir);
    let lastLoad = Date.now();
    const CACHE_TTL_MS = 30_000; // reload ทุก 30 วิ (ไม่มี file watching — เช็คแบบ TTL)

    function getRules(): ParsedRule[] {
      // simple TTL cache — ไม่ต้อง watch file system
      if (Date.now() - lastLoad > CACHE_TTL_MS) {
        cachedRules = loadRules(rulesDir);
        lastLoad = Date.now();
      }
      return cachedRules;
    }

    /** ไฟล์ (path สัมพัทธ์จาก worktree) ที่แตะด้วย read/edit/write — แยกตาม session
     *  (tool hook ของ session ทุกตัวยิงมาที่ background service เดียวกัน) */
    const touchedBySession = new Map<string, Set<string>>();

    function touchedFor(sessionID: string): Set<string> {
      let set = touchedBySession.get(sessionID);
      if (!set) touchedBySession.set(sessionID, (set = new Set()));
      return set;
    }

    // ชื่อ tool + input field (`path`) ตรวจกับ opencode2 beta แล้ว — patch ใส่แค่
    // patchText (ไม่มี path ให้ track) จึงไม่รวม
    const FILE_TOOLS = ["read", "edit", "write"];

    /** จับ path ของไฟล์ที่ tool กำลังจะแตะ (แทน output.system ของ V1 ที่ใช้ไม่ได้แล้ว) */
    const toolHook = await ctx.tool.hook("execute.before", (event) => {
      if (!FILE_TOOLS.includes(event.tool)) return;

      const input = event.input as { path?: string } | undefined;
      const filePath = input?.path;
      if (!filePath) return;

      const abs = isAbsolute(filePath) ? filePath : join(worktree, filePath);
      const rel = relative(worktree, abs);
      if (rel.startsWith("..")) return; // อยู่นอก worktree — ไม่สน
      touchedFor(event.sessionID).add(rel);
    });

    /** inject rules ที่ match เข้าไปใน system context ก่อนทุก model call */
    const contextHook = await ctx.session.hook("context", (event) => {
      const touched = touchedFor(event.sessionID);

      const matched = getRules().filter((rule) => {
        // alwaysApply: true → โหลดทุกครั้ง
        if (rule.frontmatter.alwaysApply === true) return true;
        // ไม่มี globs → ไม่ inject (ให้ใช้ instructions config แทน)
        if (!rule.frontmatter.globs) return false;
        // ตรวจ glob match กับไฟล์ที่ session นี้แตะ
        return [...touched].some((path) => matchesGlobs(path, rule.frontmatter.globs));
      });
      if (matched.length === 0) return;

      console.log(
        `[cursor-rules] injecting ${matched.length} rule(s) for ${touched.size} touched file(s)`,
      );

      event.system.push({ type: "text", text: formatRules(matched) });
    });

    /** Format rules เป็น string สำหรับ inject */
    function formatRules(rules: ParsedRule[]): string {
      return rules
        .map((r) => {
          const label =
            r.frontmatter.description ?? relative(worktree, r.filePath);
          return `<!-- rule: ${label} -->\n${r.content}`;
        })
        .join("\n\n---\n\n");
    }

    return () => {
      void toolHook.dispose();
      void contextHook.dispose();
    };
  },
});
