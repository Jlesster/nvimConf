local M = {}

local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local color_file = state_dir .. "/quickshell/user/generated/material_colors.scss"
local colorscheme = "material_purple_mocha"

-- ------------------------------------------------------------------
-- Load colors from SCSS
-- ------------------------------------------------------------------
function M.load_colors()
  local file = io.open(color_file, "r")
  if not file then
    return nil
  end

  local colors = {}
  for line in file:lines() do
    local name, value = line:match("%$([%w_]+):%s*(#[%w]+)")
    if name and value then
      colors[name] = value
    end
  end
  file:close()

  return colors
end

-- ------------------------------------------------------------------
-- Apply terminal + UI colors
-- ------------------------------------------------------------------
function M.apply_colors()
  local colors = M.load_colors()
  if not colors or not colors.term0 then
    return
  end

  -- terminal colors - apply immediately, not in schedule
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = colors["term" .. i]
  end
end

-- ------------------------------------------------------------------
-- FULL reload (this fixes transparency + LSP issues)
-- ------------------------------------------------------------------
function M.reload()
  -- Apply terminal colors BEFORE the scheduled reload
  M.apply_colors()

  vim.schedule(function()
    vim.cmd("hi clear")
    vim.cmd("syntax reset")
    vim.cmd("colorscheme " .. colorscheme)

    -- Reassert transparency (CRITICAL)
    local transparent_groups = {
      -- Core editor / windows
      "Normal",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "EndOfBuffer",
      "VertSplit",
      "WinSeparator",
      "WinBar",
      "WinBarNC",
      "Title",

      -- Cursor / columns (IMPORTANT)
      "CursorLine",
      "CursorColumn",
      "ColorColumn",

      -- Status / tabline
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",

      -- Popup / completion
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "PmenuBorder",

      -- Completion item kinds (nvim-cmp)
      "CmpItemKindVariable",
      "CmpItemKindFunction",
      "CmpItemKindMethod",
      "CmpItemKindConstructor",
      "CmpItemKindClass",
      "CmpItemKindInterface",
      "CmpItemKindStruct",
      "CmpItemKindEnum",
      "CmpItemKindEnumMember",
      "CmpItemKindModule",
      "CmpItemKindProperty",
      "CmpItemKindField",
      "CmpItemKindTypeParameter",
      "CmpItemKindConstant",
      "CmpItemKindKeyword",
      "CmpItemKindSnippet",
      "CmpItemKindText",
      "CmpItemKindFile",
      "CmpItemKindFolder",
      "CmpItemKindColor",
      "CmpItemKindReference",
      "CmpItemKindOperator",
      "CmpItemKindUnit",
      "CmpItemKindValue",

      -- Completion text
      "CmpItemAbbr",
      "CmpItemAbbrDeprecated",
      "CmpItemAbbrMatch",
      "CmpItemAbbrMatchFuzzy",
      "CmpItemMenu",

      -- Which-key
      "WhichKey",
      "WhichKeyFloat",
      "WhichKeyTile",

      -- Neo-tree
      "NeoTreeTabActive",
      "NeoTreeTabInactive",
      "NeoTreeTabSeparatorActive",
      "NeoTreeTabSeparatorInactive",

      -- Render / markdown
      "RenderMarkdownCode",

      -- Bufferline / Barbar
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBuffer",
      "BufferLineBufferVisible",
      "BufferLineBufferSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorVisible",
      "BufferLineSeparatorSelected",

      "BufferCurrent",
      "BufferCurrentIndex",
      "BufferCurrentMod",
      "BufferCurrentSign",
      "BufferCurrentTarget",

      "BufferVisible",
      "BufferVisibleIndex",
      "BufferVisibleMod",
      "BufferVisibleSign",
      "BufferVisibleTarget",

      "BufferInactive",
      "BufferInactiveIndex",
      "BufferInactiveMod",
      "BufferInactiveSign",
      "BufferInactiveTarget",

      "BufferTabpages",
      "BufferTabpageFill",

      -- Devicons
      "BufferLineDevIconLua",
      "BufferLineDevIconDefault",

      -- Overseer
      "OverseerTask",
      "OverseerTaskBorder",
      "OverseerRunning",
      "OverseerSuccess",
      "OverseerCanceled",
      "OverseerFailure",
    }

    for _, group in ipairs(transparent_groups) do
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
      if ok then
        hl.bg = "NONE"
        vim.api.nvim_set_hl(0, group, hl)
      end
    end
  end)
end

-- ------------------------------------------------------------------
-- Setup file watcher
-- ------------------------------------------------------------------
function M.setup()
  -- Initial load - apply colors immediately
  M.apply_colors()

  -- Then do the full reload (which will apply colors again before scheduling)
  M.reload()

  -- Watch for file changes
  vim.loop.fs_event_start(
    vim.loop.new_fs_event(),
    color_file,
    {},
    function()
      M.reload()
    end
  )
end

return M
