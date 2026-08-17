-- ~/.config/nvim/lsp/gscode.lua
return {
  cmd = { 'dotnet', vim.fn.expand('~/.local/share/gscode/GSCode.NET.dll') },
  filetypes = { 'gsc' },
  root_markers = { '.git' },
}
