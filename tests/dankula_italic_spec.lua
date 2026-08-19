-- tests/dankula_italic_spec.lua
-- Headless: nvim --headless -u NONE -c "luafile tests/dankula_italic_spec.lua" -c "q"
-- Exits 0 iff every assertion passes, 1 otherwise.

-- Locate the config root. Parse `vim.v.argv` for the luafile argument.
local function find_config_root()
  for i = 1, #vim.v.argv do
    if vim.v.argv[i] == 'luafile' and vim.v.argv[i + 1] then
      local p = vim.v.argv[i + 1]
      if not p:match('^/') then
        p = vim.fn.getcwd() .. '/' .. p
      end
      return (p:gsub('/tests/[^/]+$', ''))
    end
  end
  return vim.fn.getcwd()
end

local config_root = find_config_root()
vim.opt.runtimepath:prepend(config_root)
dofile(config_root .. '/colors/dankula.lua')
assert(vim.g.colors_name == 'wallpaper',
  'colorscheme wallpaper did not load — got ' .. tostring(vim.g.colors_name)
  .. ' (config_root=' .. config_root .. ')')

local pass, fail = 0, 0
local function expect_italic(group, want_bold)
  local function fetch()
    return vim.api.nvim_get_hl(0, { name = group, link = false })
  end
  local hl = fetch()
  if not hl or vim.tbl_isempty(hl) then
    pcall(vim.cmd.colorscheme, 'dankula')
    hl = fetch()
  end
  local ok_i = hl and hl.italic == true
  local ok_b = (want_bold == nil) or (hl and hl.bold == want_bold)
  if ok_i and ok_b then
    pass = pass + 1
  else
    fail = fail + 1
    print(string.format(
      'FAIL  %-50s italic=%s bold=%s want_bold=%s',
      group,
      hl and tostring(hl.italic) or 'nil',
      hl and tostring(hl.bold) or 'nil',
      tostring(want_bold)
    ))
  end
end

-- ─── §A Vim legacy syntax ────────────────────────────────────────────────────
expect_italic('Function')
expect_italic('Label')
expect_italic('PreProc')
expect_italic('Include')
expect_italic('Define')
expect_italic('Macro')
expect_italic('PreCondit')
expect_italic('Type')
expect_italic('StorageClass')
expect_italic('Structure')
expect_italic('Typedef')
expect_italic('javaTypedef')
expect_italic('Special')
expect_italic('Tag')

-- ─── §B Treesitter ───────────────────────────────────────────────────────────
expect_italic('@variable.parameter')
expect_italic('@constant.macro')
expect_italic('@function')
expect_italic('@function.macro')
expect_italic('@function.method')
expect_italic('@constructor')
expect_italic('@keyword.function')
expect_italic('@keyword.import')
expect_italic('@keyword.return')
expect_italic('@keyword.modifier')
expect_italic('@type.definition')
expect_italic('@type.qualifier')
expect_italic('@attribute')
expect_italic('@property')
expect_italic('@field')                 -- new
expect_italic('@module')
expect_italic('@namespace')
expect_italic('@label')

-- ─── §C LSP base (italic only) ───────────────────────────────────────────────
expect_italic('@lsp.type.class')
expect_italic('@lsp.type.decorator')
expect_italic('@lsp.type.enum')
expect_italic('@lsp.type.enumMember')
expect_italic('@lsp.type.function')
expect_italic('@lsp.type.interface')
expect_italic('@lsp.type.macro')
expect_italic('@lsp.type.method')
expect_italic('@lsp.type.namespace')
expect_italic('@lsp.type.parameter')
expect_italic('@lsp.type.property')
expect_italic('@lsp.type.struct')
expect_italic('@lsp.type.type')
expect_italic('@lsp.type.typeParameter')
expect_italic('@lsp.type.lifetime')

-- ─── §C′ LSP base (italic only — base modifiers were not bold in the file) ──
expect_italic('@lsp.mod.static')
expect_italic('@lsp.mod.defaultLibrary')
expect_italic('@lsp.typemod.method.defaultLibrary')

-- ─── §D Rust ────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.namespace.rust')
expect_italic('@lsp.type.enum.rust')
expect_italic('@lsp.type.enumMember.rust')
expect_italic('@lsp.type.struct.rust')
expect_italic('@lsp.type.macro.rust')
expect_italic('@lsp.type.function.rust')
expect_italic('@lsp.type.method.rust')
expect_italic('@lsp.type.parameter.rust')
expect_italic('@lsp.type.property.rust')
expect_italic('@lsp.mod.static.rust')
expect_italic('@lsp.mod.unsafe.rust')
expect_italic('@lsp.typemod.function.static.rust')
expect_italic('@lsp.typemod.function.associated.rust')
expect_italic('@lsp.typemod.method.static.rust')
expect_italic('@lsp.typemod.variable.static.rust')
expect_italic('@lsp.typemod.variable.readonly.rust')
expect_italic('@lsp.typemod.variable.mutable.rust')
expect_italic('@lsp.typemod.struct.readonly.rust')
expect_italic('@lsp.typemod.macro.unsafe.rust')

-- ─── §D Go ──────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.namespace.go')
expect_italic('@lsp.type.function.go')
expect_italic('@lsp.type.method.go')
expect_italic('@lsp.type.struct.go')
expect_italic('@lsp.type.parameter.go')
expect_italic('@lsp.type.property.go')
expect_italic('@lsp.type.macro.go')
expect_italic('@lsp.mod.static.go')
expect_italic('@lsp.typemod.function.exported.go', true)
expect_italic('@lsp.typemod.method.exported.go', true)
expect_italic('@lsp.typemod.type.exported.go', true)
expect_italic('@lsp.typemod.variable.exported.go', true)

-- ─── §D C ───────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.function.c')
expect_italic('@lsp.type.method.c')
expect_italic('@lsp.type.struct.c')
expect_italic('@lsp.type.enum.c')
expect_italic('@lsp.type.enumMember.c')
expect_italic('@lsp.type.macro.c')
expect_italic('@lsp.type.type.c')
expect_italic('@lsp.type.parameter.c')
expect_italic('@lsp.type.property.c')
expect_italic('@lsp.mod.static.c')
expect_italic('@lsp.typemod.function.static.c')
expect_italic('@lsp.typemod.variable.static.c')
expect_italic('@lsp.typemod.variable.readonly.c')
expect_italic('@lsp.typemod.macro.globalScope.c', true)

-- ─── §D C++ ─────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.namespace.cpp')
expect_italic('@lsp.type.class.cpp')
expect_italic('@lsp.type.struct.cpp')
expect_italic('@lsp.type.enum.cpp')
expect_italic('@lsp.type.enumMember.cpp')
expect_italic('@lsp.type.function.cpp')
expect_italic('@lsp.type.method.cpp')
expect_italic('@lsp.type.macro.cpp')
expect_italic('@lsp.type.property.cpp')
expect_italic('@lsp.type.parameter.cpp')
expect_italic('@lsp.type.type.cpp')
expect_italic('@lsp.mod.static.cpp')
expect_italic('@lsp.mod.virtual.cpp')
expect_italic('@lsp.mod.abstract.cpp')
expect_italic('@lsp.typemod.method.static.cpp')
expect_italic('@lsp.typemod.method.virtual.cpp')
expect_italic('@lsp.typemod.function.static.cpp')
expect_italic('@lsp.typemod.function.virtual.cpp')
expect_italic('@lsp.typemod.variable.static.cpp')
expect_italic('@lsp.typemod.variable.readonly.cpp')
expect_italic('@lsp.typemod.type.abstract.cpp')
expect_italic('@lsp.typemod.macro.globalScope.cpp', true)
expect_italic('@lsp.typemod.enumMember.defaultLibrary.cpp', true)

-- ─── §D Java ────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.namespace.java')
expect_italic('@lsp.type.class.java')
expect_italic('@lsp.type.interface.java')
expect_italic('@lsp.type.enum.java')
expect_italic('@lsp.type.enumMember.java')
expect_italic('@lsp.type.function.java')
expect_italic('@lsp.type.method.java')
expect_italic('@lsp.type.property.java')
expect_italic('@lsp.type.parameter.java')
expect_italic('@lsp.type.macro.java')
expect_italic('@lsp.mod.static.java')
expect_italic('@lsp.mod.abstract.java')
expect_italic('@lsp.typemod.method.static.java')
expect_italic('@lsp.typemod.method.abstract.java')
expect_italic('@lsp.typemod.class.abstract.java')
expect_italic('@lsp.typemod.property.static.java')
expect_italic('@lsp.typemod.variable.static.java')
expect_italic('@lsp.typemod.variable.readonly.java')
expect_italic('@lsp.typemod.variable.static.readonly.java', true)

-- ─── §D Zig ─────────────────────────────────────────────────────────────────
expect_italic('@lsp.type.namespace.zig')
expect_italic('@lsp.type.type.zig')
expect_italic('@lsp.type.struct.zig')
expect_italic('@lsp.type.enum.zig')
expect_italic('@lsp.type.enumMember.zig')
expect_italic('@lsp.type.union.zig')
expect_italic('@lsp.type.tagField.zig')
expect_italic('@lsp.type.field.zig')
expect_italic('@lsp.type.errorTag.zig')
expect_italic('@lsp.type.function.zig')
expect_italic('@lsp.type.method.zig')
expect_italic('@lsp.type.parameter.zig')
expect_italic('@lsp.type.decorator.zig')
expect_italic('@type.zig')
expect_italic('@variable.parameter.zig')
expect_italic('@keyword.import.zig')

-- ─── §D Meson ───────────────────────────────────────────────────────────────
expect_italic('@variable.meson')
expect_italic('@lsp.type.function.meson')
expect_italic('@lsp.type.method.meson')
expect_italic('@lsp.typemod.variable.readonly.meson')

print(string.format('PASS=%d FAIL=%d', pass, fail))
vim.cmd(fail == 0 and 'q' or 'cquit!')