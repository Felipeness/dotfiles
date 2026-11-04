-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- ── General ───────────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Disable unused providers (removes checkhealth warnings) ─────────
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ── LazyVim Extras Config ─────────────────────────────────────────────
vim.g.lazyvim_prettier_needs_config = true -- only format if prettier config exists
vim.g.lazyvim_eslint_auto_format = true -- eslint auto-fix on save
vim.g.lazyvim_python_lsp = "basedpyright" -- better pyright fork

-- ── Editor ────────────────────────────────────────────────────────────
local opt = vim.opt

opt.clipboard = "unnamedplus" -- sync with system clipboard
opt.number = true -- line numbers
opt.relativenumber = true -- relative line numbers
opt.cursorline = true -- highlight current line
opt.signcolumn = "yes" -- always show sign column
opt.wrap = false -- no line wrap (toggle with <leader>uw)
opt.scrolloff = 8 -- lines above/below cursor
opt.sidescrolloff = 8 -- columns left/right of cursor
opt.tabstop = 2 -- tab = 2 spaces
opt.shiftwidth = 2 -- indent = 2 spaces
opt.expandtab = true -- spaces instead of tabs
opt.smartindent = true -- auto indent
opt.ignorecase = true -- case insensitive search
opt.smartcase = true -- unless uppercase typed
opt.undofile = true -- persistent undo
opt.undolevels = 10000 -- max undo levels
opt.updatetime = 200 -- faster completion
opt.timeoutlen = 300 -- faster which-key popup
opt.splitbelow = true -- split down
opt.splitright = true -- split right
opt.termguicolors = true -- true color
opt.conceallevel = 2 -- for markdown rendering
opt.pumblend = 10 -- popup transparency
opt.pumheight = 10 -- popup max items
opt.showmode = false -- mode shown in statusline
opt.confirm = true -- confirm before closing unsaved
opt.spelllang = { "en", "pt_br" } -- spell check languages
opt.fillchars = { eob = " ", diff = "╱" }

-- ── Shell (Windows) ───────────────────────────────────────────────────
if vim.fn.has("win32") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
end
