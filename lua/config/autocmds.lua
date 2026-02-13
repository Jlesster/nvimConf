local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "help",
    "lspinfo",
    "man",
    "qf",
    "query",
    "checkhealth",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories when saving
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- User events for lazy loading
autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "BaseDefered" })
  end,
})

autocmd("BufReadPost", {
  group = augroup("base_file", { clear = true }),
  callback = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "BaseFile" })
  end,
})

-- Disable features in large files
autocmd("BufReadPre", {
  group = augroup("disable_large_file_features", { clear = true }),
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > vim.g.big_file.size then
      vim.b[args.buf].large_file = true
      vim.diagnostic.disable(args.buf)
      vim.cmd("syntax clear")
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.breakindent = false
      vim.opt_local.colorcolumn = ""
      vim.opt_local.statuscolumn = ""
      vim.opt_local.signcolumn = "no"
      vim.opt_local.foldcolumn = "0"
    end
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when terminal is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Wrap and check for spell in text filetypes
autocmd("FileType", {
  group = augroup("wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
  group = augroup("json_conceal", { clear = true }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Go indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.bo.indentexpr = ""
    vim.bo.cindent = true
    vim.bo.smartindent = false
    vim.bo.autoindent = true
    vim.bo.cinoptions = "(4,u4,U1,w1"
  end,
})

-- C/C++ indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp" },
  callback = function()
    vim.bo.cindent = true
    vim.bo.cinoptions = "(4,u4,U1,w1"
  end,
})

-- Python indentation (simple, Python is straightforward)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.bo.smartindent = true
    vim.bo.autoindent = true
  end,
})

-- Lua, JS, TS indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.bo.smartindent = true
    vim.bo.autoindent = true
  end,
})
