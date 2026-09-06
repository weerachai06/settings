/**
 * OpenCode V2 plugin: bridge to Kiro via its ACP agent (`kiro-cli acp`).
 *
 * IMPORTANT: this targets OpenCode V2 (opencode2 / @opencode-ai/plugin "beta").
 * V1 plugins do not load in V2 and vice versa -- this rewrite uses V2's
 * Plugin.define({ setup }) lifecycle and ctx.tool.transform tool registry,
 * per https://opencode.ai/v2/docs/build/plugins (beta as of Aug 2026, so the
 * shape below may drift with future opencode2 releases).
 *
 * What this does
 * ----------------
 * Spawns `kiro-cli acp` as a subprocess, speaks ACP (newline-delimited
 * JSON-RPC 2.0) to it as the *client*, and exposes a `kiro_prompt` tool that
 * any OpenCode agent can call to delegate a task to Kiro. Kiro's streamed
 * text is forwarded live via `tool.progress()` (a V2-only capability -- V1
 * tools could only return a final result). Kiro's own file read/write
 * requests and permission requests are answered so it can actually act.
 *
 * Prerequisites
 * ----------------
 * 1. Kiro CLI installed and authenticated: https://kiro.dev/docs/cli/setup/
 * 2. `kiro-cli` on PATH, or set KIRO_CLI_PATH to the full binary path.
 * 3. OpenCode V2 (opencode2) with the beta plugin API.
 *
 * Install (OpenCode V2)
 * ----------------
 * Place at .opencode/plugins/kiro-acp/index.ts (auto-loaded), or reference
 * it explicitly with the plural `plugins` field in opencode.jsonc:
 *   { "plugins": ["./plugins/kiro-acp"] }
 * Note the V2 field is `plugins`, not the V1 `plugin`.
 *
 * Configuration (env vars)
 * ----------------
 * - KIRO_CLI_PATH      Full path to kiro-cli if not on PATH.
 * - KIRO_AUTO_APPROVE  "true" (default) auto-approves Kiro's own permission
 *                       requests (file writes, shell commands run by Kiro,
 *                       etc). "false" auto-DENIES them instead.
 * - KIRO_SMART_APPROVE "false" (default). If "true", instead of the naive
 *                       allow/deny switch above, each Kiro permission
 *                       request is judged by an LLM call through
 *                       `ctx.generate.text` and approved/denied based on
 *                       that judgement. This is still fully automatic, not
 *                       a human-in-the-loop prompt -- see the caveat below.
 * - KIRO_JUDGE_MODEL   Which model judges permission requests under
 *                       KIRO_SMART_APPROVE, as "providerID/id" (e.g.
 *                       "anthropic/claude-opus-4-6"). Defaults to OpenCode's
 *                       own configured default model. Can also be set via
 *                       the plugin's `options.judgeModel` in opencode.jsonc.
 *
 * Model selection for Kiro itself
 * ----------------
 * The `kiro.prompt` tool takes an optional `model` argument, and `kiro.models`
 * lists what Kiro currently reports as available (via ACP's `session/new` /
 * `session/set_model`, params confirmed as `{ sessionId, modelId }`). This is
 * Kiro's own model catalog (e.g. "auto", "claude-opus-4.6"), independent of
 * OpenCode's provider/model config -- it only affects what Kiro uses to
 * answer prompts sent through this bridge.
 *
 * Caveat: no real human-in-the-loop prompt for Kiro's internal actions
 * ----------------
 * OpenCode V2 exposes `ctx.permission.list/get/reply` to inspect and reply
 * to permission requests, and a `permission.evaluate` hook to intervene in
 * decisions OpenCode's own core is already making for its native tools
 * (read/edit/shell/etc). As documented today, there is no plugin API to
 * originate a brand-new interactive "ask the human and block until they
 * click" prompt for actions a *custom* tool performs internally -- which is
 * what Kiro's own file writes/shell calls are, from OpenCode's point of
 * view. So this bridge can auto-approve, auto-deny, or auto-judge with an
 * LLM, but it cannot yet pop OpenCode's real permission dialog and wait for
 * you to click "allow" purely for Kiro-internal actions. If OpenCode adds
 * a `ctx.permission.create()`-style API later, swap it in at
 * `handlePermissionRequest` below.
 *
 * Security note
 * ----------------
 * With KIRO_AUTO_APPROVE=true (the default) and KIRO_SMART_APPROVE=false,
 * Kiro can write/overwrite any file it can reach and run any command it
 * decides to run, with no check on this side beyond a regex. Prefer
 * KIRO_SMART_APPROVE=true, or KIRO_AUTO_APPROVE=false, outside a sandbox
 * you fully trust.
 */

import { Plugin } from "@opencode-ai/plugin"
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process"
import { readFile, writeFile } from "node:fs/promises"
import path from "node:path"

const KIRO_BIN = process.env.KIRO_CLI_PATH || "kiro-cli"
const AUTO_APPROVE = (process.env.KIRO_AUTO_APPROVE ?? "true").toLowerCase() !== "false"
const SMART_APPROVE = (process.env.KIRO_SMART_APPROVE ?? "false").toLowerCase() === "true"

type GenerateText = (input: {
  model: { providerID: string; id: string }
  prompt: string
}) => Promise<{ text: string }>

interface PendingCall {
  resolve: (value: any) => void
  reject: (err: Error) => void
}

class KiroAcpClient {
  private proc: ChildProcessWithoutNullStreams | null = null
  private buffer = ""
  private nextId = 0
  private pending = new Map<number, PendingCall>()
  private sessionId: string | null = null
  private initialized = false
  private currentModelId: string | null = null
  private availableModels: Array<{ modelId: string; name?: string }> = []
  private onChunk: ((text: string) => void) | null = null
  private onActivity: ((line: string) => void) | null = null

  constructor(
    private readonly cwd: string,
    private readonly generateText: GenerateText,
    private readonly judgeModel: { providerID: string; id: string },
  ) {}

  // ---------- process / transport ----------

  private ensureProcess() {
    if (this.proc) return
    this.proc = spawn(KIRO_BIN, ["acp"], { cwd: this.cwd, stdio: ["pipe", "pipe", "pipe"] })
    this.proc.stdout.on("data", (chunk: Buffer) => this.onStdout(chunk.toString("utf8")))
    this.proc.stderr.on("data", () => {
      // Kiro logs go to stderr; set KIRO_LOG_LEVEL=debug and capture manually if needed.
    })
    this.proc.on("exit", (code) => {
      const err = new Error(`kiro-cli acp exited unexpectedly (code ${code})`)
      for (const call of this.pending.values()) call.reject(err)
      this.pending.clear()
      this.proc = null
      this.sessionId = null
      this.initialized = false
    })
    this.proc.on("error", (err) => {
      for (const call of this.pending.values()) call.reject(err)
      this.pending.clear()
    })
  }

  private onStdout(text: string) {
    this.buffer += text
    let nl: number
    while ((nl = this.buffer.indexOf("\n")) >= 0) {
      const line = this.buffer.slice(0, nl).trim()
      this.buffer = this.buffer.slice(nl + 1)
      if (!line) continue
      let msg: any
      try {
        msg = JSON.parse(line)
      } catch {
        continue
      }
      this.dispatch(msg)
    }
  }

  private write(msg: unknown) {
    this.proc!.stdin.write(JSON.stringify(msg) + "\n")
  }

  // ---------- incoming message routing ----------

  private dispatch(msg: any) {
    const isResponse = msg.id !== undefined && ("result" in msg || "error" in msg)
    const isRequestFromKiro = msg.id !== undefined && msg.method !== undefined
    const isNotification = msg.id === undefined && msg.method !== undefined

    if (isResponse) {
      const call = this.pending.get(msg.id)
      if (!call) return
      this.pending.delete(msg.id)
      if (msg.error) call.reject(new Error(msg.error.message || "ACP error"))
      else call.resolve(msg.result)
      return
    }

    if (isRequestFromKiro) {
      this.handleIncomingRequest(msg.method, msg.params).then(
        (result) => this.write({ jsonrpc: "2.0", id: msg.id, result }),
        (err: Error) =>
          this.write({ jsonrpc: "2.0", id: msg.id, error: { code: -32000, message: err.message } }),
      )
      return
    }

    if (isNotification) this.handleNotification(msg.method, msg.params)
  }

  // Requests Kiro sends TO the client (us), which we must answer.
  private async handleIncomingRequest(method: string, params: any): Promise<any> {
    switch (method) {
      case "fs/read_text_file": {
        const filePath = this.resolvePath(params.path)
        const content = await readFile(filePath, "utf8")
        if (params.line != null || params.limit != null) {
          const lines = content.split("\n")
          const start = (params.line ?? 1) - 1
          const end = params.limit != null ? start + params.limit : undefined
          return { content: lines.slice(Math.max(start, 0), end).join("\n") }
        }
        return { content }
      }
      case "fs/write_text_file": {
        const filePath = this.resolvePath(params.path)
        await writeFile(filePath, params.content, "utf8")
        return {}
      }
      case "session/request_permission":
        return this.handlePermissionRequest(params)
      default:
        throw new Error(`Unsupported ACP request from Kiro: ${method}`)
    }
  }

  private async handlePermissionRequest(params: any) {
    const options: Array<{ optionId: string; kind?: string }> = params?.options ?? []
    const allowOption = () => options.find((o) => /allow|accept|approve/i.test(o.optionId)) ?? options[0]
    const denyOption = () => options.find((o) => /reject|deny|cancel/i.test(o.optionId)) ?? options[0]
    const label = params?.toolCall?.title ?? params?.toolCall?.kind ?? "a tool call"

    if (SMART_APPROVE) {
      const verdict = await this.judgeWithModel(params, label)
      this.onActivity?.(`[kiro] smart-approve verdict "${verdict}" for: ${label}`)
      const chosen = verdict === "allow" ? allowOption() : denyOption()
      return { outcome: { outcome: "selected", optionId: chosen?.optionId } }
    }

    if (!AUTO_APPROVE) {
      this.onActivity?.(`[kiro] permission denied (KIRO_AUTO_APPROVE=false): ${label}`)
      return { outcome: { outcome: "selected", optionId: denyOption()?.optionId } }
    }

    this.onActivity?.(`[kiro] auto-approved: ${label}`)
    return { outcome: { outcome: "selected", optionId: allowOption()?.optionId } }
  }

  private async judgeWithModel(params: any, label: string): Promise<"allow" | "deny"> {
    try {
      const { text } = await this.generateText({
        model: this.judgeModel,
        prompt:
          "Kiro (an AI coding agent) wants to perform this action inside a repository:\n" +
          `${label}\n\nFull request: ${JSON.stringify(params?.toolCall ?? params).slice(0, 2000)}\n\n` +
          'Reply with exactly one word, "allow" or "deny". Deny anything that deletes files, ' +
          "touches credentials/secrets, modifies files outside the project, or runs a destructive " +
          "or network-exfiltrating shell command. Allow routine reads/edits/builds/tests.",
      })
      return /^\s*allow/i.test(text) ? "allow" : "deny"
    } catch {
      return "deny" // fail closed if the judge call itself fails
    }
  }

  private resolvePath(p: string) {
    return path.isAbsolute(p) ? p : path.join(this.cwd, p)
  }

  // Notifications Kiro pushes without expecting a reply (streamed content, tool progress).
  private handleNotification(method: string, params: any) {
    if (method !== "session/notification") return
    const update = params?.update
    const kind = update?.sessionUpdate ?? update?.type
    switch (kind) {
      case "agent_message_chunk":
      case "AgentMessageChunk": {
        const text = update?.content?.text ?? update?.text
        if (text) this.onChunk?.(text)
        break
      }
      case "tool_call":
      case "ToolCall":
        this.onActivity?.(`tool call: ${update?.title ?? update?.name ?? "unknown"}`)
        break
      case "tool_call_update":
      case "ToolCallUpdate":
        if (update?.status) this.onActivity?.(`tool ${update.status}: ${update?.title ?? ""}`)
        break
      default:
        break
    }
  }

  // ---------- outgoing calls ----------

  private call(method: string, params: unknown): Promise<any> {
    this.ensureProcess()
    const id = this.nextId++
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject })
      this.write({ jsonrpc: "2.0", id, method, params })
    })
  }

  private async initializeIfNeeded() {
    if (this.initialized) return
    await this.call("initialize", {
      protocolVersion: 1,
      clientCapabilities: { fs: { readTextFile: true, writeTextFile: true }, terminal: false },
      clientInfo: { name: "opencode-kiro-bridge", version: "0.3.0" },
    })
    this.initialized = true
  }

  private async ensureSession() {
    await this.initializeIfNeeded()
    if (this.sessionId) return this.sessionId
    const result = await this.call("session/new", { cwd: this.cwd, mcpServers: [] })
    this.sessionId = result.sessionId
    this.currentModelId = result.models?.currentModelId ?? null
    this.availableModels = result.models?.availableModels ?? []
    return this.sessionId
  }

  /** List of model IDs Kiro reported as available for this session (populated after first use). */
  async listModels(): Promise<{ current: string | null; available: Array<{ modelId: string; name?: string }> }> {
    await this.ensureSession()
    return { current: this.currentModelId, available: this.availableModels }
  }

  private async setModel(modelId: string) {
    const sessionId = await this.ensureSession()
    await this.call("session/set_model", { sessionId, modelId })
    this.currentModelId = modelId
  }

  async prompt(text: string, onProgress: (line: string) => void, model?: string): Promise<string> {
    const sessionId = await this.ensureSession()
    if (model && model !== this.currentModelId) {
      await this.setModel(model)
      onProgress(`[kiro] switched model to ${model}`)
    }
    let collected = ""
    this.onChunk = (chunk) => {
      collected += chunk
      onProgress(chunk)
    }
    this.onActivity = (line) => onProgress(`[kiro] ${line}`)
    try {
      await this.call("session/prompt", { sessionId, content: [{ type: "text", text }] })
    } finally {
      this.onChunk = null
      this.onActivity = null
    }
    return collected.trim() || "(Kiro responded with no text content)"
  }

  dispose() {
    this.proc?.kill()
    this.proc = null
  }
}

/**
 * Resolve the model used to judge Kiro's permission requests when
 * KIRO_SMART_APPROVE=true. Priority: plugin option `judgeModel` (as
 * "providerID/id") > KIRO_JUDGE_MODEL env var (same format) > OpenCode's
 * own configured default model.
 */
async function resolveJudgeModel(ctx: any): Promise<{ providerID: string; id: string }> {
  const raw = ctx.options?.judgeModel ?? process.env.KIRO_JUDGE_MODEL
  if (typeof raw === "string" && raw.includes("/")) {
    const [providerID, id] = raw.split("/")
    return { providerID, id }
  }
  const fallback = await ctx.catalog.model.default()
  return fallback ?? { providerID: "anthropic", id: "claude-sonnet-4-6" }
}

export default Plugin.define({
  id: "kiro-acp",
  async setup(ctx) {
    const judgeModel = await resolveJudgeModel(ctx)
    const client = new KiroAcpClient(ctx.location.directory, (input) => ctx.generate.text(input), judgeModel)

    const registration = await ctx.tool.transform((editor) => {
      editor.namespace({
        name: "kiro",
        description: "Delegate tasks to Kiro (AWS's agentic coding assistant) over ACP.",
      })
      editor.add({
        name: "prompt",
        description:
          "Send a prompt/task to Kiro (running as `kiro-cli acp`) and stream its response. " +
          "Kiro can read/write files in this project and run its own tools; its permission " +
          `requests are handled by this bridge (mode: ${SMART_APPROVE ? `LLM smart-approve via ${judgeModel.providerID}/${judgeModel.id}` : AUTO_APPROVE ? "auto-approve" : "auto-deny"}). ` +
          "Call the `kiro_models` tool first if you need to see which model IDs Kiro currently offers.",
        input: {
          type: "object",
          properties: {
            prompt: { type: "string", description: "The prompt or task to hand off to Kiro" },
            model: {
              type: "string",
              description:
                'Optional Kiro model ID to switch to before prompting (e.g. "claude-opus-4.6", "auto"). ' +
                "See the kiro_models tool for valid values. Omit to keep using the session's current model.",
            },
          },
          required: ["prompt"],
          additionalProperties: false,
        },
        execute: async (input, tool) => {
          const { prompt, model } = input as { prompt: string; model?: string }
          try {
            const text = await client.prompt(
              prompt,
              (line) => void tool.progress({ status: line }),
              model,
            )
            return { content: text }
          } catch (err) {
            return {
              content:
                `Failed to reach Kiro via ACP: ${(err as Error).message}. ` +
                "Check that kiro-cli is installed, authenticated, and on PATH (or set KIRO_CLI_PATH).",
            }
          }
        },
      })
      editor.add({
        name: "models",
        description: "List the model IDs Kiro currently offers for this session, and which one is active.",
        input: { type: "object", properties: {}, additionalProperties: false },
        execute: async () => {
          try {
            const { current, available } = await client.listModels()
            const lines = available.length
              ? available.map((m) => `- ${m.modelId}${m.name ? ` (${m.name})` : ""}${m.modelId === current ? " [current]" : ""}`)
              : ["(Kiro did not report any model list; try passing a model ID directly and see if it's accepted.)"]
            return { content: [`Current model: ${current ?? "unknown"}`, "", ...lines].join("\n") }
          } catch (err) {
            return { content: `Failed to reach Kiro via ACP: ${(err as Error).message}` }
          }
        },
      })
    })

    return () => {
      void registration.dispose()
      client.dispose()
    }
  },
})
