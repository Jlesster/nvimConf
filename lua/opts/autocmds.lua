local indent_grp = vim.api.nvim_create_augroup('UserIndent', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = indent_grp,
  pattern = {
    'nix',
    'lua',
    'json',
    'jsonc',
    'xml',
    'html',
    'css',
    'qml',
    'scss',
    'yaml',
    'toml',
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'svelte',
    'vue',
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Hide toggleterm buffers from the buffer list
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('HideTermBufs', { clear = true }),
  pattern = 'toggleterm',
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
  end,
})

-- Trim trailing whitespace on save (except special bufs)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('TrimWhitespace', { clear = true }),
  callback = function()
    if vim.bo.buftype == '' then
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd([[keeppatterns %s/\s\+$//e]])
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end
  end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('RestoreCursor', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = indent_grp,
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = 'g0,l1,j1,J1'
  end,
})
