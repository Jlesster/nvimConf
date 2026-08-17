local indent_grp = vim.api.nvim_create_augroup('UserIndent', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = indent_grp,
  pattern = {
    'nix',
    'lua',
    'json',
    'jsonc',
    'html',
    'css',
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
    vim.opt_local.cinoptions = 'g0,l1,j1,J1,N-s'
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    io.write('\x1b[>1u')
  end,
})
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    io.write('\x1b[<u')
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'kotlin',
  callback = function()
    vim.treesitter.start()
  end,
})

vim.api.nvim_create_autocmd({ 'WinClosed', 'WinResized' }, {
  callback = function(ev)
    local f = io.open('/tmp/marvin_panel_trace.log', 'a')
    if not f then
      return
    end
    f:write(
      string.format(
        '[%s] %s match=%s\n',
        os.date('%H:%M:%S'),
        ev.event,
        tostring(ev.match)
      )
    )
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      local ok, b = pcall(vim.api.nvim_win_get_buf, w)
      if ok then
        local ok2, wd = pcall(vim.api.nvim_win_get_width, w)
        local ok3, ht = pcall(vim.api.nvim_win_get_height, w)
        f:write(
          string.format(
            '    win=%d buf=%d bt=[%s] w=%s h=%s\n',
            w,
            b,
            vim.bo[b].buftype,
            ok2 and wd or '?',
            ok3 and ht or '?'
          )
        )
      end
    end
    f:close()
  end,
})
