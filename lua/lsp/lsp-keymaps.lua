local M = {}

function M.setup(client, bufnr)
  local keymap = vim.keymap.set
  local opts = { buffer = bufnr, silent = true }

  -- Diagnostics
  keymap("n", "gl", vim.diagnostic.open_float, opts)
  keymap("n", "[d", vim.diagnostic.goto_prev, opts)
  keymap("n", "]d", vim.diagnostic.goto_next, opts)

  -- Navigation
  keymap("n", "gd", vim.lsp.buf.definition, opts)
  keymap("n", "gD", vim.lsp.buf.declaration, opts)
  keymap("n", "gI", vim.lsp.buf.implementation, opts)
  keymap("n", "gr", vim.lsp.buf.references, opts)
  keymap("n", "K", vim.lsp.buf.hover, opts)

  -- Actions
  keymap("n", "<leader>la", vim.lsp.buf.code_action, opts)
  keymap("n", "<leader>lr", vim.lsp.buf.rename, opts)
  keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
end

return M
