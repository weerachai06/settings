-- Minimal config: native LSP (Neovim 0.11+), no plugin manager.
-- The language server binaries come from `programs.neovim.extraPackages` in home.nix.

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})
vim.lsp.enable("ts_ls")

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
  end,
})
