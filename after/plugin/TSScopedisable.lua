local groups = {
  "@scope",
  "@scope.block",
  "TSNodeUnmatched",
  "@indent",
}

for _, g in ipairs(groups) do
  pcall(vim.api.nvim_set_hl, 0, g, { fg = "NONE", bg = "NONE" })
end
