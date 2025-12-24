-- lua/dynamic-colors.lua
-- ZERO-FLASH dynamic theme loader

local M = {}
local transition = require("material-transition")

local state_dir = os.getenv("XDG_STATE_HOME")
  or (os.getenv("HOME") .. "/.local/state")

local scss_file = state_dir .. "/quickshell/user/generated/material_colors.scss"
local theme_file = vim.fn.stdpath("config")
  .. "/colors/material_purple_mocha.lua"

local is_transitioning = false

-- ------------------------------------------------------------
-- Transparency invariants
-- ------------------------------------------------------------
local transparent_groups = {
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
      "CursorLine",
      "CursorColumn",
      "ColorColumn",
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "PmenuBorder",
      "TelescopePromptBorder",
      "TelescopeResultsBorder",
      "TelescopePreviewBorder",
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
      "CmpItemAbbr",
      "CmpItemAbbrDeprecated",
      "CmpItemAbbrMatch",
      "CmpItemAbbrMatchFuzzy",
      "CmpItemMenu",
      "WhichKey",
      "WhichKeyFloat",
      "WhichKeyTitle",
      "NeoTreeTabActive",
      "NeoTreeTabInactive",
      "NeoTreeTabSeparatorActive",
      "NeoTreeTabSeparatorInactive",
      "RenderMarkdownCode",
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
      "BufferLineDevIconLua",
      "BufferLineDevIconDefault",
      "OverseerTask",
      "OverseerTaskBorder",
      "OverseerRunning",
      "OverseerSuccess",
      "OverseerCanceled",
      "OverseerFailure",
}

local function enforce_transparency()
  for _, g in ipairs(transparent_groups) do
    local ok = pcall(function()
      local hl = vim.api.nvim_get_hl(0, { name = g })
      hl.bg = "NONE"
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, g, hl)
    end)
    if not ok then
      -- Silently fail for groups that don't exist yet
    end
  end
end

-- ------------------------------------------------------------
-- Parse theme file as DATA
-- ------------------------------------------------------------
local function load_theme()
  local f = io.open(theme_file, "r")
  if not f then return end
  local lines = {}
  for l in f:lines() do table.insert(lines, l) end
  f:close()

  local colors, highlights = {}, {}

  for _, l in ipairs(lines) do
    local k, v = l:match("^%s*([%w_]+)%s*=%s*\"(#[%x]+)\"")
    if k and v then colors[k] = v end

    local g, body = l:match('hi%("([^"]+)",%s*{(.-)}')
    if g then
      local spec = {}
      spec.fg = body:match("fg%s*=%s*colors%.([%w_]+)")
      spec.bg = body:match("bg%s*=%s*colors%.([%w_]+)")
      spec.style = body:match('style%s*=%s*"([^"]+)"')
      highlights[g] = spec
    end
  end

  return colors, highlights
end

local function apply_highlights(colors, highlights)
  for group, spec in pairs(highlights) do
    local hl = {}
    if spec.fg then hl.fg = colors[spec.fg] end
    if spec.bg then hl.bg = colors[spec.bg] end
    if spec.style then
      for f in spec.style:gmatch("[^,]+") do hl[f] = true end
    end
    vim.api.nvim_set_hl(0, group, hl)
  end
end

-- ------------------------------------------------------------
-- Reload (NO :colorscheme)
-- ------------------------------------------------------------
function M.reload()
  if is_transitioning then return end
  is_transitioning = true

  local colors, highlights = load_theme()
  if not colors then
    is_transitioning = false
    return
  end

  local from = {}
  for _, g in ipairs({ "Normal", "StatusLine", "TabLine" }) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = g })
    if ok and hl.bg then
      from[g] = { bg = string.format("#%06X", hl.bg) }
    end
  end

  apply_highlights(colors, highlights)
  enforce_transparency()

  local to = {}
  for g, _ in pairs(from) do
    local spec = highlights[g]
    if spec and spec.bg then
      to[g] = { bg = colors[spec.bg] }
    end
  end

  transition.run(from, to, {
    steps = 20,
    delay = 10,
    on_done = function()
      enforce_transparency()
      is_transitioning = false
    end,
  })
end

function M.setup()
  -- Initial load with delay to ensure plugins are ready
  vim.defer_fn(function()
    M.reload()
  end, 100)

  -- File watcher using vim.loop (compatible with older Neovim)
  local uv = vim.loop
  local fs = uv.new_fs_event()
  local timer = uv.new_timer()

  uv.fs_event_start(fs, scss_file, {}, function()
    timer:stop()
    timer:start(200, 0, vim.schedule_wrap(M.reload))
  end)

  -- Add autocmd to reapply on Neo-tree open
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "neo-tree",
    callback = function()
      vim.defer_fn(enforce_transparency, 50)
    end,
  })
end

return M
