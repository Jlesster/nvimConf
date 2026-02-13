local opt = vim.opt

-- Leader keys (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- UI Settings
opt.number = true
opt.relativenumber = true
-- opt.signcolumn = "yes:2"
opt.cursorline = true
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false
opt.cmdheight = 0
opt.laststatus = 3 -- global statusline
opt.pumheight = 10
opt.winminwidth = 5
opt.splitkeep = "screen"
opt.fillchars = { eob = " " } -- Remove ~ from empty lines
opt.conceallevel = 0 -- Hide concealed text unless cursor on line
opt.concealcursor = "" -- Show concealed text in all modes on cursor line
opt.list = true -- Show some invisible characters
opt.listchars = { tab = "  ", trail = " ", nbsp = " " } -- Characters for whitespace
opt.showbreak = "↪ " -- Character to show for wrapped lines
opt.numberwidth = 1 -- Width of number column
opt.showtabline = 2 -- Always show tabline
opt.statuscolumn = '%s%{v:relnum?printf("%4d",v:relnum):printf("%d",v:lnum)} '

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.autoindent = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.formatoptions = "jcroqlnt" -- Better formatting options
opt.grepformat = "%f:%l:%c:%m" -- Format for :grep
opt.grepprg = "rg --vimgrep"   -- Use ripgrep for :grep
opt.inccommand = "split"       -- Preview substitutions in split
opt.jumpoptions = "view"       -- Preserve view when jumping
opt.autowrite = true           -- Auto write before running commands
opt.confirm = true             -- Confirm to save changes before exiting

-- Session options
opt.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"
opt.formatexpr = "v:lua.vim.lsp.formatexpr()" -- Use LSP for gq formatting
opt.tagfunc = "v:lua.vim.lsp.tagfunc"         -- Use LSP for tag jumping

-- Fold
opt.foldmethod = "expr" -- Use treesitter for folding

-- Better diff
opt.diffopt:append("algorithm:patience") -- Better diff algorithm
opt.diffopt:append("indent-heuristic")   -- Better diff heuristic

opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false  -- Don't fold by default
opt.foldlevelstart = 99 -- Start with all folds open

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true
opt.wildmode = "longest:full,full"             -- Command-line completion mode
opt.wildignore = "*.o,*.obj,*.pyc,*.swp,*.bak" -- Ignore these in completion
opt.path:append("**")                          -- Search into subfolders

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.equalalways = false -- Don't auto-resize windows

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = true
opt.backup = false
opt.writebackup = false

-- Undo and History
opt.undolevels = 10000                    -- Maximum undo levels
opt.shada = { "'100", "<50", "s10", "h" } -- Better shada settings

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append("c")

-- File encoding
opt.fileencoding = "utf-8"

-- Diagnostics (LSP)
vim.g.diagnostics_mode = 3 -- 0=off, 1=status only, 2=virtual text off, 3=all on

-- Clipboard
opt.clipboard = "unnamedplus"

-- Mouse
opt.mouse = "a"

-- Big File Detection (enhance your existing one)
vim.g.big_file = {
  size = 1024 * 1024, -- 1MB (you have 100KB)
  lines = 10000,
}

-- Grep
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Additional useful globals
vim.g.markdown_recommended_style = 0  -- Fix markdown indentation
vim.g.autoformat = true               -- Enable auto-formatting
vim.g.root_lsp_ignore = { "copilot" } -- LSP servers to ignore for root detection

-- Disable built-in plugins
local disabled_built_ins = {
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
