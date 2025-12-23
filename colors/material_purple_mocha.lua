-- Auto-generated Neovim colorscheme
-- Vibrant LSP-semantic based theme with Material You + Catppuccin Mocha

vim.cmd("hi clear")
vim.cmd("syntax reset")

vim.o.termguicolors = true
vim.g.colors_name = "material_purple_mocha"

local colors = {
  -- Base colors
  base = "#1E1E2E",
  mantle = "#191825",
  crust = "#12111B",

  -- Surface colors
  surface0 = "#323244",
  surface1 = "#46475A",
  surface2 = "#595B70",

  -- Overlay colors
  overlay0 = "#6E7086",
  overlay1 = "#81839C",
  overlay2 = "#9598B2",

  -- Text colors
  text = "#CED6F4",
  subtext1 = "#BBC2DE",
  subtext0 = "#A7ADC8",

  -- Accent colors (VIBRANT)
  rosewater = "#F2E0E4",
  flamingo = "#EBCEDC",
  pink = "#D8B5E1",
  mauve = "#C5A1F2",
  red = "#DB91D8",
  maroon = "#DAA4CE",
  peach = "#FEAEAD",
  yellow = "#EECEB8",
  green = "#71D2BB",
  teal = "#89D1E5",
  sky = "#A2D5FF",
  sapphire = "#90B7F7",
  blue = "#B5B5FF",
  lavender = "#C5B9FC",
}

local function hi(group, opts)
  local cmd = {"highlight", group}
  if opts.fg then table.insert(cmd, "guifg=" .. opts.fg) end
  if opts.bg then table.insert(cmd, "guibg=" .. opts.bg) end
  if opts.sp then table.insert(cmd, "guisp=" .. opts.sp) end
  if opts.style then table.insert(cmd, "gui=" .. opts.style) end
  if opts.link then
    vim.cmd(string.format("highlight! link %s %s", group, opts.link))
  else
    vim.cmd(table.concat(vim.tbl_flatten(cmd), " "))
  end
end

-- ============================================================================
-- BASE UI ELEMENTS
-- ============================================================================
hi("Normal", { fg = colors.text, bg = colors.base })
hi("NormalFloat", { fg = colors.text, bg = colors.mantle })
hi("FloatBorder", { fg = colors.base, bg = colors.mantle })
hi("FloatTitle", { fg = colors.mauve, bg = colors.base, style = "bold,italic" })

hi("Cursor", { fg = colors.base, bg = colors.text })
hi("CursorLine", { bg = colors.base })
hi("CursorColumn", { bg = colors.base })
hi("ColorColumn", { bg = "NONE" })
hi("CursorLineNr", { fg = colors.lavender, style = "bold" })
hi("LineNr", { fg = colors.overlay0 })
hi("LineNrAbove", { fg = colors.mauve })
hi("LineNrBelow", { fg = colors.mauve })
hi("SignColumn", { bg = colors.base })
hi("EndOfBuffer", { fg = colors.lavender })
hi("NonText", { fg = colors.lavender })

hi("StatusLine", { fg = colors.text, bg = colors.base })
hi("StatusLineNC", { fg = colors.overlay0, bg = colors.base })
hi("VertSplit", { fg = colors.surface0, bg = "NONE" })
hi("WinSeparator", { fg = colors.surface0, bg = "NONE" })

hi("Search", { fg = colors.base, bg = colors.mauve})
hi("IncSearch", { fg = colors.base, bg = colors.peach })
hi("CurSearch", { fg = colors.base, bg = colors.peach })
hi("Visual", { bg = colors.surface1 })
hi("VisualNOS", { bg = colors.surface1 })

hi("Pmenu", { fg = colors.text, bg = colors.base })
hi("PmenuSel", { fg = colors.base, bg = colors.surface1, style = "bold" })
hi("PmenuSbar", { bg = colors.base})
hi("PmenuThumb", { bg = colors.base })
hi("PmenuBorder", { fg = colors.lavender, bg = colors.base })

-- Completion menu kind highlights (nvim-cmp)
hi("CmpItemKindVariable", { fg = colors.text, bg = "NONE" })
hi("CmpItemKindFunction", { fg = colors.blue, bg = "NONE" })
hi("CmpItemKindMethod", { fg = colors.blue, bg = "NONE" })
hi("CmpItemKindConstructor", { fg = colors.sapphire, bg = "NONE" })
hi("CmpItemKindClass", { fg = colors.yellow, bg = "NONE" })
hi("CmpItemKindInterface", { fg = colors.yellow, bg = "NONE" })
hi("CmpItemKindStruct", { fg = colors.yellow, bg = "NONE" })
hi("CmpItemKindEnum", { fg = colors.peach, bg = "NONE" })
hi("CmpItemKindEnumMember", { fg = colors.teal, bg = "NONE" })
hi("CmpItemKindModule", { fg = colors.sapphire, bg = "NONE" })
hi("CmpItemKindProperty", { fg = colors.teal, bg = "NONE" })
hi("CmpItemKindField", { fg = colors.teal, bg = "NONE" })
hi("CmpItemKindTypeParameter", { fg = colors.flamingo, bg = "NONE" })
hi("CmpItemKindConstant", { fg = colors.teal, bg = "NONE" })
hi("CmpItemKindKeyword", { fg = colors.mauve, bg = "NONE" })
hi("CmpItemKindSnippet", { fg = colors.pink, bg = "NONE" })
hi("CmpItemKindText", { fg = colors.green, bg = "NONE" })
hi("CmpItemKindFile", { fg = colors.blue, bg = "NONE" })
hi("CmpItemKindFolder", { fg = colors.blue, bg = "NONE" })
hi("CmpItemKindColor", { fg = colors.peach, bg = "NONE" })
hi("CmpItemKindReference", { fg = colors.peach, bg = "NONE" })
hi("CmpItemKindOperator", { fg = colors.sky, bg = "NONE" })
hi("CmpItemKindUnit", { fg = colors.peach, bg = "NONE" })
hi("CmpItemKindValue", { fg = colors.peach, bg = "NONE" })

-- Completion item highlights
hi("CmpItemAbbr", { fg = colors.text, bg = "NONE" })
hi("CmpItemAbbrDeprecated", { fg = colors.overlay0, bg = "NONE", style = "strikethrough" })
hi("CmpItemAbbrMatch", { fg = colors.blue, bg = "NONE", style = "bold" })
hi("CmpItemAbbrMatchFuzzy", { fg = colors.blue, bg = "NONE" })
hi("CmpItemMenu", { fg = colors.subtext0, bg = "NONE", style = "italic" })

hi("TabLine", { fg = colors.subtext0, bg = colors.mantle })
hi("TabLineFill", { bg = colors.base })
hi("TabLineSel", { fg = colors.mauve, bg = colors.base })

-- ============================================================================
-- TREESITTER BASE SYNTAX (Fallbacks when LSP not available)
-- ============================================================================
hi("@variable", { fg = colors.text })
hi("@variable.builtin", { fg = colors.red, style = "italic" })
hi("@variable.parameter", { fg = colors.maroon, style = "italic" })
hi("@variable.member", { fg = colors.teal })

hi("@constant", { fg = colors.teal })
hi("@constant.builtin", { fg = colors.red, style = "italic" })
hi("@constant.macro", { fg = colors.sapphire })

hi("@module", { fg = colors.sapphire, style = "italic" })
hi("@label", { fg = colors.sapphire })

hi("@string", { fg = colors.green })
hi("@string.escape", { fg = colors.pink })
hi("@string.regexp", { fg = colors.pink })
hi("@character", { fg = colors.teal })
hi("@character.special", { fg = colors.pink })

hi("@number", { fg = colors.peach })
hi("@number.float", { fg = colors.peach })
hi("@boolean", { fg = colors.peach })

hi("@function", { fg = colors.blue, style = "bold" })
hi("@function.builtin", { fg = colors.blue, style = "italic" })
hi("@function.macro", { fg = colors.mauve })
hi("@function.method", { fg = colors.blue, style = "bold" })

hi("@constructor", { fg = colors.sapphire })
hi("@operator", { fg = colors.teal })

hi("@keyword", { fg = colors.mauve, style = "bold" })
hi("@keyword.function", { fg = colors.mauve, style = "bold" })
hi("@keyword.operator", { fg = colors.mauve })
hi("@keyword.return", { fg = colors.pink, style = "bold" })

hi("@type", { fg = colors.yellow })
hi("@type.builtin", { fg = colors.yellow, style = "italic" })
hi("@type.qualifier", { fg = colors.mauve, style = "italic" })

hi("@property", { fg = colors.teal })
hi("@attribute", { fg = colors.yellow, style = "italic" })
hi("@namespace", { fg = colors.sapphire, style = "italic" })

hi("@punctuation.delimiter", { fg = colors.overlay2 })
hi("@punctuation.bracket", { fg = colors.overlay2 })
hi("@punctuation.special", { fg = colors.sky })

hi("@comment", { fg = colors.pink, italic = true })
hi("@comment.todo", { fg = colors.yellow, bg = colors.surface0, style = "bold" })
hi("@comment.note", { fg = colors.blue, bg = colors.surface0, style = "bold" })
hi("@comment.warning", { fg = colors.peach, bg = colors.surface0, style = "bold" })
hi("@comment.error", { fg = colors.red, bg = colors.surface0, style = "bold" })

hi("@tag", { fg = colors.mauve })
hi("@tag.attribute", { fg = colors.teal, style = "italic" })
hi("@tag.delimiter", { fg = colors.overlay2 })

-- ============================================================================
-- LSP SEMANTIC TOKENS (Primary highlighting - overrides Treesitter)
-- ============================================================================

-- Variables and Parameters
hi("@lsp.type.variable", { fg = colors.text })
hi("@lsp.type.parameter", { fg = colors.maroon, style = "italic" })
hi("@lsp.typemod.variable.readonly", { fg = colors.teal })
hi("@lsp.typemod.variable.declaration", { fg = colors.flamingo, style = "italic" })
hi("@lsp.typemod.variable.static", { fg = colors.flamingo })
hi("@lsp.typemod.variable.global", { fg = colors.flamingo })

-- Properties and Fields
hi("@lsp.type.property", { fg = colors.text })
hi("@lsp.typemod.property.static", { fg = colors.teal, style = "italic" })
hi("@lsp.typemod.property.static.java", { fg = colors.red, style = "italic,bold" })

-- Functions and Methods
hi("@lsp.type.function", { fg = colors.blue, style = "bold" })
hi("@lsp.type.method", { fg = colors.sapphire, style = "bold" })
hi("@lsp.typemod.function.static", { fg = colors.sky, style = "bold" })
hi("@lsp.typemod.method.static", { fg = colors.sapphire, style = "bold" })

-- Types and Classes
hi("@lsp.type.class", { fg = colors.yellow, style = "bold" })
hi("@lsp.type.interface", { fg = colors.yellow, style = "italic" })
hi("@lsp.type.struct", { fg = colors.yellow })
hi("@lsp.type.enum", { fg = colors.peach })
hi("@lsp.type.enumMember", { fg = colors.teal })
hi("@lsp.type.type", { fg = colors.yellow })
hi("@lsp.type.typeParameter", { fg = colors.flamingo, style = "italic" })

-- Namespaces and Modules
hi("@lsp.type.namespace", { fg = colors.sapphire, style = "italic" })
hi("@lsp.type.namespace.java", { fg = colors.sapphire, style = "italic" })
hi("@lsp.mod.importDeclaration", { fg = colors.yellow, style = "italic" })
hi("@lsp.mod.importDeclaration.java", { fg = colors.yellow, style = "italic" })
hi("@lsp.typemod.namespace.importDeclaration.java", { fg = colors.yellow, style = "italic" })

-- Macros and Preprocessor
hi("@lsp.type.macro", { fg = colors.sapphire })
hi("@lsp.typemod.macro.globalScope", { fg = colors.sapphire })
hi("@lsp.typemod.macro.globalScope.cpp", { fg = colors.sapphire })

-- Decorators and Annotations
hi("@lsp.type.decorator", { fg = colors.yellow, style = "italic" })
hi("@lsp.type.annotation", { fg = colors.yellow, style = "italic" })

-- Keywords (when LSP provides them)
hi("@lsp.type.keyword", { fg = colors.mauve, style = "bold" })
hi("@lsp.typemod.keyword.controlFlow", { fg = colors.pink, style = "bold" })

-- ============================================================================
-- DIAGNOSTIC
-- ============================================================================
hi("DiagnosticError", { fg = colors.red })
hi("DiagnosticWarn", { fg = colors.yellow })
hi("DiagnosticInfo", { fg = colors.blue })
hi("DiagnosticHint", { fg = colors.teal })
hi("DiagnosticOk", { fg = colors.green })

hi("DiagnosticVirtualTextError", { fg = colors.red, bg = colors.base })
hi("DiagnosticVirtualTextWarn", { fg = colors.yellow, bg = colors.base })
hi("DiagnosticVirtualTextInfo", { fg = colors.blue, bg = colors.base })
hi("DiagnosticVirtualTextHint", { fg = colors.teal, bg = colors.base })

hi("DiagnosticUnderlineError", { sp = colors.red, style = "undercurl" })
hi("DiagnosticUnderlineWarn", { sp = colors.yellow, style = "undercurl" })
hi("DiagnosticUnderlineInfo", { sp = colors.blue, style = "undercurl" })
hi("DiagnosticUnderlineHint", { sp = colors.teal, style = "undercurl" })

-- ============================================================================
-- LSP REFERENCES
-- ============================================================================
hi("LspReferenceText", { bg = colors.surface1 })
hi("LspReferenceRead", { bg = colors.surface1 })
hi("LspReferenceWrite", { bg = colors.surface1, style = "bold" })

-- ============================================================================
-- PLUGIN: TELESCOPE
-- ============================================================================
hi("TelescopeBorder", { fg = colors.lavender, bg = colors.mantle })
hi("TelescopePromptBorder", { fg = colors.mauve, bg = colors.base})
hi("TelescopeResultsBorder", { fg = colors.lavender, bg = colors.base })
hi("TelescopePreviewBorder", { fg = colors.lavender, bg = colors.base })
hi("TelescopeSelection", { fg = colors.surface0, bg = colors.mauve, style = "bold" })
hi("TelescopeSelectionCaret", { fg = colors.mauve, bg = colors.surface0 })
hi("TelescopeMatching", { fg = colors.blue })

-- ============================================================================
-- PLUGIN: NVIM-TREE / NEO-TREE
-- ============================================================================
hi("NvimTreeNormal", { fg = colors.text, bg = colors.base })
hi("NvimTreeFolderIcon", { fg = colors.mauve })
hi("NvimTreeFolderName", { fg = colors.sapphire })
hi("NvimTreeOpenedFolderName", { fg = colors.blue, bold = true })
hi("NeoTreeIndentMarker", { fg = colors.overlay0 })
hi("NvimTreeGitDirty", { fg = colors.yellow })
hi("NvimTreeGitNew", { fg = colors.green })
hi("NvimTreeGitDeleted", { fg = colors.red })

hi("NeoTreeGitStaged", { fg = colors.red })
hi("NeoTreeFileIcon", { fg = colors.mauve })
hi("NeoTreeDirectoryIcon", { fg = colors.mauve })
hi("NeoTreeDirectoryName", { fg = colors.lavender })
hi("NeoTreeExpander", { fg = colors.lavender })
hi("NeoTreeFileNameOpened", { fg = colors.red })
hi("NeoTreeTabActive", { fg = colors.mauve, bg = colors.base })
hi("NeoTreeTabInactive", { fg = colors.overlay0, bg = colors.base })
hi("NeoTreeCursorLine", { fg = colors.red })
hi("NeoTreeTabSeparatorActive", { fg = colors.surface0, bg = "NONE" })
hi("NeoTreeTabSeparatorInactive", { fg = colors.surface0, bg = "NONE" })

-- ============================================================================
-- PLUGIN: INDENT-BLANKLINE
-- ============================================================================
hi("IblIndent", { fg = colors.lavender })
hi("IblScope", { fg = colors.mauve })

-- ============================================================================
-- PLUGIN: WHICH-KEY
-- ============================================================================
hi("WhichKey", { fg = colors.mauve, bg = "NONE" })
hi("WhichKeyGroup", { fg = colors.blue })
hi("WhichKeyDesc", { fg = colors.text })
hi("WhichKeySeparator", { fg = colors.mauve })
hi("WhichKeyFloat", { bg = colors.base })
hi("WhichKeyTile", { bg = colors.base })

-- ============================================================================
-- PLUGIN: NOTIFY
-- ============================================================================
hi("NotifyBackground", { bg = colors.base })
hi("NotifyERRORBorder", { fg = colors.red })
hi("NotifyWARNBorder", { fg = colors.yellow })
hi("NotifyINFOBorder", { fg = colors.blue })
hi("NotifyDEBUGBorder", { fg = colors.overlay0 })
hi("NotifyTRACEBorder", { fg = colors.teal })
hi("NotifyERRORIcon", { fg = colors.red })
hi("NotifyWARNIcon", { fg = colors.yellow })
hi("NotifyINFOIcon", { fg = colors.blue })
hi("NotifyDEBUGIcon", { fg = colors.overlay0 })
hi("NotifyTRACEIcon", { fg = colors.teal })
hi("NotifyERRORTitle", { fg = colors.red })
hi("NotifyWARNTitle", { fg = colors.yellow })
hi("NotifyINFOTitle", { fg = colors.blue })
hi("NotifyDEBUGTitle", { fg = colors.overlay0 })
hi("NotifyTRACETitle", { fg = colors.teal })

-- ============================================================================
-- PLUGIN: RAINBOW DELIMITERS
-- ============================================================================
hi("RainbowDelimiterRed", { fg = colors.red })
hi("RainbowDelimiterOrange", { fg = colors.peach })
hi("RainbowDelimiterYellow", { fg = colors.yellow })
hi("RainbowDelimiterGreen", { fg = colors.green })
hi("RainbowDelimiterCyan", { fg = colors.teal })
hi("RainbowDelimiterBlue", { fg = colors.sky })
hi("RainbowDelimiterViolet", { fg = colors.mauve })

-- ============================================================================
-- PLUGIN: RENDER-MARKDOWN
-- ============================================================================
hi("RenderMarkdownCode", { bg = "NONE" })

-- ============================================================================
-- PLUGIN: BUFFERLINE / BARBAR
-- ============================================================================
hi("BufferLineFill", { bg = "NONE" })
hi("BufferLineBackground", { fg = colors.overlay0, bg = "NONE" })
hi("BufferLineBuffer", { fg = colors.overlay0, bg = "NONE" })
hi("BufferLineBufferVisible", { fg = colors.text, bg = "NONE" })
hi("BufferLineBufferSelected", { fg = colors.mauve, bg = "NONE", style = "bold" })
hi("BufferLineTab", { fg = colors.overlay0, bg = "NONE" })
hi("BufferLineTabSelected", { fg = colors.mauve, bg = "NONE", style = "bold" })
hi("BufferLineSeparator", { fg = colors.surface0, bg = "NONE" })
hi("BufferLineSeparatorVisible", { fg = colors.surface0, bg = "NONE" })
hi("BufferLineSeparatorSelected", { fg = colors.surface0, bg = "NONE" })

-- Barbar plugin
hi("BufferCurrent", { fg = colors.text, bg = "NONE", style = "bold" })
hi("BufferCurrentIndex", { fg = colors.mauve, bg = "NONE" })
hi("BufferCurrentMod", { fg = colors.yellow, bg = "NONE" })
hi("BufferCurrentSign", { fg = colors.mauve, bg = "NONE" })
hi("BufferCurrentTarget", { fg = colors.red, bg = "NONE" })
hi("BufferVisible", { fg = colors.text, bg = "NONE" })
hi("BufferVisibleIndex", { fg = colors.overlay0, bg = "NONE" })
hi("BufferVisibleMod", { fg = colors.yellow, bg = "NONE" })
hi("BufferVisibleSign", { fg = colors.overlay0, bg = "NONE" })
hi("BufferVisibleTarget", { fg = colors.red, bg = "NONE" })
hi("BufferInactive", { fg = colors.overlay0, bg = "NONE" })
hi("BufferInactiveIndex", { fg = colors.overlay0, bg = "NONE" })
hi("BufferInactiveMod", { fg = colors.yellow, bg = "NONE" })
hi("BufferInactiveSign", { fg = colors.overlay0, bg = "NONE" })
hi("BufferInactiveTarget", { fg = colors.red, bg = "NONE" })
hi("BufferTabpages", { fg = colors.mauve, bg = "NONE", style = "bold" })
hi("BufferTabpageFill", { bg = "NONE" })

-- Overseer (task runner) - often appears in bufferline
hi("OverseerTask", { fg = colors.blue, bg = "NONE" })
hi("OverseerTaskBorder", { fg = colors.blue, bg = "NONE" })
hi("OverseerRunning", { fg = colors.yellow, bg = "NONE" })
hi("OverseerSuccess", { fg = colors.green, bg = "NONE" })
hi("OverseerCanceled", { fg = colors.overlay0, bg = "NONE" })
hi("OverseerFailure", { fg = colors.red, bg = "NONE" })

-- Additional top bar highlights (in case it's something else)
hi("WinBar", { fg = colors.text, bg = "NONE" })
hi("WinBarNC", { fg = colors.overlay0, bg = "NONE" })
hi("Title", { fg = colors.blue, bg = "NONE" })
hi("BufferLineDevIconLua", { bg = "NONE" })
hi("BufferLineDevIconDefault", { bg = "NONE" })


-- ============================================================================
-- TEXT
-- ============================================================================
hi("Comment", { fg = colors.pink })
hi("Constant", { fg = colors.teal })
-- ============================================================================
-- PLUGIN: ALPHA (Dashboard)
-- ============================================================================
hi("AlphaIconNew", { fg = colors.blue })
hi("AlphaIconRecent", { fg = colors.pink })
hi("AlphaIconYazi", { fg = colors.peach })
hi("AlphaIconSessions", { fg = colors.green })
hi("AlphaIconProjects", { fg = colors.mauve })
hi("AlphaIconQuit", { fg = colors.red })

-- ============================================================================
-- TRANSPARENCY REASSERTION (CRITICAL)
-- ============================================================================
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
  "NvimTreeNormal",
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

  "TelescopePromptBorder",
  "TelescopeResultsBorder",
  "TelescopePreviewBorder",
  "DiagnosticVirtualTextError",
  "DiagnosticVirtualTextWarn",
  "DiagnosticVirtualTextInfo",
  "DiagnosticVirtualTextHint",
    }

for _, group in ipairs(transparent_groups) do
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
  if ok then
    hl.bg = "NONE"
    vim.api.nvim_set_hl(0, group, hl)
  end
end

