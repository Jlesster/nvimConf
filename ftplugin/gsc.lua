local opt = vim.opt_local
local map = vim.keymap.set

-- ── Indentation ───────────────────────────────────────────────────────────────
-- GSC convention is tabs, 4-wide (matches what Treyarch's own scripts use)
opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.cindent = true

-- ── Comment string ────────────────────────────────────────────────────────────
opt.commentstring = '// %s'

-- ── Folding ───────────────────────────────────────────────────────────────────
opt.foldmethod = 'syntax'
opt.foldlevel = 99 -- open by default, fold with zc/zm

-- ── gd: jump to function definition in workspace ──────────────────────────────
-- Greps for the function name under cursor across all .gsc/.csc files.
-- Falls back to quickfix list if multiple matches (pick with :cn/:cp).
map('n', 'gd', function()
  local word = vim.fn.expand('<cword>')
  -- Match either T6 style:  functionName(  or T7 style:  function functionName(
  local pattern = [[\(^function\s\+\)\?]] .. word .. [[\s*(]]
  vim.fn.setqflist({})
  -- vimgrep across workspace; silently ignore no-match
  local ok = pcall(
    vim.cmd,
    'silent vimgrep /' .. pattern .. '/gj **/*.gsc **/*.csc **/*.gsh'
  )
  if not ok then
    vim.notify(
      "gsc: no definition found for '" .. word .. "'",
      vim.log.levels.WARN
    )
    return
  end
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify(
      "gsc: no definition found for '" .. word .. "'",
      vim.log.levels.WARN
    )
  elseif #qf == 1 then
    vim.cmd('cfirst')
  else
    vim.cmd('cfirst')
    vim.cmd('copen')
  end
end, { buffer = true, desc = 'GSC: go to function definition' })

-- ── gr: find all usages in workspace ─────────────────────────────────────────
map('n', 'gr', function()
  local word = vim.fn.expand('<cword>')
  vim.fn.setqflist({})
  local ok = pcall(
    vim.cmd,
    'silent vimgrep /' .. word .. '/gj **/*.gsc **/*.csc **/*.gsh'
  )
  if not ok or #vim.fn.getqflist() == 0 then
    vim.notify(
      "gsc: no references found for '" .. word .. "'",
      vim.log.levels.WARN
    )
    return
  end
  vim.cmd('copen')
end, { buffer = true, desc = 'GSC: find all references' })

-- ── K: open modme/zeroy wiki for keyword under cursor ────────────────────────
map('n', 'K', function()
  local word = vim.fn.expand('<cword>')
  local url = 'https://wiki.modme.co/wiki/black_ops_3/scripting/'
    .. word
    .. '.html'
  vim.ui.open(url)
end, { buffer = true, desc = 'GSC: open modme wiki for keyword' })
