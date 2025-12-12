local M = {}

function M.load_colors()
  local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
  local color_file = state_dir .. "/quickshell/user/generated/material_colors.scss"

  local file = io.open(color_file, "r")
  if not file then
    print("Could not open color file: " .. color_file)
    return nil
  end

  local colors = {}
  for line in file:lines() do
    -- Parse SCSS variables: $term0: #282828;
    local name, value = line:match("%$([%w_]+):%s*([#%w]+)")
    if name and value then
      colors[name] = value
    end
  end
  file:close()

  return colors
end

function M.apply_colors()
  local colors = M.load_colors()
  if not colors then
    return
  end

  -- Only apply if we have terminal colors
  if not colors.term0 then
    print("No terminal colors found in color file")
    return
  end

  -- Set terminal colors
  vim.g.terminal_color_0 = colors.term0
  vim.g.terminal_color_1 = colors.term1
  vim.g.terminal_color_2 = colors.term2
  vim.g.terminal_color_3 = colors.term3
  vim.g.terminal_color_4 = colors.term4
  vim.g.terminal_color_5 = colors.term5
  vim.g.terminal_color_6 = colors.term6
  vim.g.terminal_color_7 = colors.term7
  vim.g.terminal_color_8 = colors.term8
  vim.g.terminal_color_9 = colors.term9
  vim.g.terminal_color_10 = colors.term10
  vim.g.terminal_color_11 = colors.term11
  vim.g.terminal_color_12 = colors.term12
  vim.g.terminal_color_13 = colors.term13
  vim.g.terminal_color_14 = colors.term14
  vim.g.terminal_color_15 = colors.term15

  -- Refresh any open terminal buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buftype == 'terminal' then
        -- Trigger a redraw for terminal buffers
        vim.api.nvim_buf_call(buf, function()
          vim.cmd('redraw!')
        end)
      end
    end
  end

  print("Terminal colors applied!")
end

function M.setup()
  -- Apply colors immediately
  M.apply_colors()

  -- Watch for color file changes
  local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
  local color_file = state_dir .. "/quickshell/user/generated/material_colors.scss"

  -- Reload on focus gained or when entering nvim
  vim.api.nvim_create_autocmd({"FocusGained", "VimEnter"}, {
    callback = function()
      M.apply_colors()
    end,
  })

  -- Create a command to manually reload colors
  vim.api.nvim_create_user_command('ReloadColors', function()
    M.apply_colors()
  end, {})
end

return M
