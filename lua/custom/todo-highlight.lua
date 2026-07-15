-- lua/custom/todo-highlight.lua

local M = {}

local ns = vim.api.nvim_create_namespace('bracket_todo_pill')

M.keywords = {
  FIXME = { color = 'error', alt = { 'FIXME', 'FIX', 'BUG', 'FIXIT', 'ISSUE' } },
  ERROR = { color = 'error', alt = { 'ERROR' } },
  TODO = { color = 'info' },
  HACK = { color = 'warning' },
  WARN = { color = 'warning', alt = { 'WARNING', 'XXX' } },
  PERF = { color = 'default', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
  NOTE = { color = 'hint', alt = { 'INFO' } },
  TEST = { color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
}

M.palette = {
  error = { fg = '#f38ba8', bg = '#1e1e2e' },
  warning = { fg = '#f9e2af', bg = '#1e1e2e' },
  info = { fg = '#89b4fa', bg = '#1e1e2e' },
  hint = { fg = '#94e2d5', bg = '#1e1e2e' },
  test = { fg = '#a6e3a1', bg = '#1e1e2e' },
  default = { fg = '#cba6f7', bg = '#1e1e2e' },
}

local alias_lookup = {}

local function build_alias_lookup()
  alias_lookup = {}
  for kw, def in pairs(M.keywords) do
    local hl_group = 'BracketTodo' .. kw
    alias_lookup[kw] = { display = kw, hl = hl_group, kw = kw }
    if def.alt then
      for _, alt in ipairs(def.alt) do
        alias_lookup[alt] = { display = kw, hl = hl_group, kw = kw }
      end
    end
  end
end

local function define_highlights()
  for kw, def in pairs(M.keywords) do
    local pal = M.palette[def.color] or M.palette.default
    vim.api.nvim_set_hl(0, 'BracketTodo' .. kw, {
      fg = pal.fg,
      bg = pal.bg,
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'BracketTodoLine' .. kw, {
      fg = pal.fg,
      bg = 'NONE',
    })
  end
end

local function is_comment(bufnr, row, col)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if ok and parser then
    local ok_hl, captures =
      pcall(vim.treesitter.get_captures_at_pos, bufnr, row, col)
    if ok_hl then
      for _, cap in ipairs(captures) do
        if cap.capture:match('comment') then
          return true
        end
      end
      return false
    end
  end
  local syn_id = vim.fn.synID(row + 1, col + 1, true)
  return vim.fn.synIDattr(vim.fn.synIDtrans(syn_id), 'name') == 'Comment'
end

local function find_matches(bufnr, row, line)
  local matches = {}
  local search_from = 1

  -- We search for the opening bracket first, then validate the rest of the pair
  while true do
    local s = line:find('%[', search_from)
    if not s then
      break
    end

    -- Look for the closing bracket after the opening one
    local e = line:find('%]', s)
    if not e then
      search_from = s + 1
      break -- No more closing brackets in the line
    end

    -- Extract the content between brackets
    local content = line:sub(s + 1, e - 1)

    -- VALIDATION:
    -- 1. Content must be uppercase letters only
    -- 2. Content must be a known keyword in our alias_lookup
    if content:match('^%u+$') then
      local entry = alias_lookup[content]
      if entry then
        table.insert(matches, {
          col_start = s - 1,
          col_end = e,
          word = content,
          entry = entry,
          is_comment = is_comment(bufnr, row, s - 1),
        })
      end
    end

    search_from = e + 1
  end
  return matches
end

function M.refresh(bufnr, line_start, line_end)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  line_start = line_start or 0
  line_end = line_end or -1
  vim.api.nvim_buf_clear_namespace(
    bufnr,
    ns,
    line_start,
    line_end == -1 and -1 or line_end
  )

  local lines = vim.api.nvim_buf_get_lines(bufnr, line_start, line_end, false)

  for i, line in ipairs(lines) do
    local row = line_start + i - 1
    local matches = find_matches(bufnr, row, line)
    local row_tinted = false

    for _, m in ipairs(matches) do
      if m.is_comment then
        -- STRICT RANGE: Only the [KEYWORD] part is highlighted
        vim.api.nvim_buf_set_extmark(bufnr, ns, row, m.col_start, {
          end_col = m.col_end,
          hl_group = m.entry.hl,
          hl_mode = 'combine',
        })

        if not row_tinted then
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
            line_hl_group = 'BracketTodoLine' .. m.entry.kw,
          })
          row_tinted = true
        end
      end
    end
  end
end

local debounce_timer = nil
local function schedule_refresh(bufnr)
  if debounce_timer then
    debounce_timer:stop()
    debounce_timer:close()
  end
  debounce_timer = vim.uv.new_timer()
  debounce_timer:start(
    60,
    0,
    vim.schedule_wrap(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        M.refresh(bufnr)
      end
    end)
  )
end

function M.setup(opts)
  opts = opts or {}
  if opts.keywords then
    M.keywords = vim.tbl_deep_extend('force', M.keywords, opts.keywords)
  end
  if opts.palette then
    M.palette = vim.tbl_deep_extend('force', M.palette, opts.palette)
  end
  build_alias_lookup()
  define_highlights()

  local group = vim.api.nvim_create_augroup('BracketTodoPill', { clear = true })
  vim.api.nvim_create_autocmd(
    'ColorScheme',
    { group = group, callback = define_highlights }
  )
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
    group = group,
    callback = function(args)
      M.refresh(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd(
    { 'TextChanged', 'TextChangedI', 'InsertLeave' },
    {
      group = group,
      callback = function(args)
        schedule_refresh(args.buf)
      end,
    }
  )

  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        M.refresh(buf)
      end
    end
  end)
end

return M
