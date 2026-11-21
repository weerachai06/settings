-- Minimal config: native LSP (Neovim 0.11+), no plugin manager.
-- The language server binaries come from `programs.neovim.extraPackages` in home.nix.

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})
vim.lsp.enable("ts_ls")

vim.diagnostic.config({ virtual_text = true })

-- Syntax highlighting: grammars come from programs.neovim.plugins in home.nix.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "lua" },
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})

-- Sidebar file explorer
vim.g.mapleader = " "
require("nvim-web-devicons").setup()
require("nvim-tree").setup({
  view = { width = 32 },
  diagnostics = { enable = true },
  renderer = { highlight_git = "name" },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in tree" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf })
  end,
})
