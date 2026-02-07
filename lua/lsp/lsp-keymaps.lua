-- LSP Keymaps
-- Place this in ~/.config/nvim/lua/lsp/keymaps.lua

local M = {}

-- Helper function to check if a LSP client supports a method
local function supports_method(method, bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

-- Function to set up LSP keymaps for a buffer
function M.setup(client, bufnr)
  local keymap = vim.keymap.set
  local opts = { buffer = bufnr, silent = true }

  -- Diagnostics
  keymap("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Hover diagnostics" }))
  keymap("n", "gl", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Hover diagnostics" }))
  keymap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  keymap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

  -- LSP Info
  keymap("n", "<leader>li", "<cmd>LspInfo<cr>", vim.tbl_extend("force", opts, { desc = "LSP information" }))

  -- LSP Restart
  keymap("n", "<leader>lL", function()
    vim.cmd(':LspRestart')
    vim.notify("Restarted LSP", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "LSP restart" }))

  -- Code Actions
  keymap("n", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
  keymap("v", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))

  -- Codelens
  if supports_method("textDocument/codeLens", bufnr) then
    keymap("n", "<leader>ll", function()
      vim.lsp.codelens.run()
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end, vim.tbl_extend("force", opts, { desc = "LSP codelens run" }))

    -- Auto-refresh codelens
    vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
      buffer = bufnr,
      callback = function()
        if vim.g.codelens_enabled then
          vim.lsp.codelens.refresh({ bufnr = bufnr })
        end
      end,
      desc = "Refresh codelens",
    })
  end

  -- Formatting
  keymap("n", "<leader>lf", function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
  keymap("v", "<leader>lf", function()
    vim.lsp.buf.format({ bufnr = bufnr })
  end, vim.tbl_extend("force", opts, { desc = "Format selection" }))

  -- Create Format command
  vim.api.nvim_buf_create_user_command(
    bufnr,
    "Format",
    function() vim.lsp.buf.format({ bufnr = bufnr }) end,
    { desc = "Format file with LSP" }
  )

  -- Highlight references on cursor hold
  if supports_method("textDocument/documentHighlight", bufnr) then
    local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
      desc = "Highlight references when cursor holds",
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
      desc = "Clear references when cursor moves",
    })
  end

  -- Goto Definition / Declaration
  keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Goto definition" }))
  keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Goto declaration" }))

  -- Goto Implementation
  keymap("n", "gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Goto implementation" }))

  -- Goto Type Definition
  keymap("n", "gT", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Goto type definition" }))

  -- References
  keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
  keymap("n", "<leader>lR", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Hover references" }))

  -- Hover Documentation
  local hover_opts = vim.g.lsp_round_borders_enabled and { border = "rounded", silent = true } or { silent = true }
  keymap("n", "K", function()
    vim.lsp.buf.hover(hover_opts)
  end, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
  keymap("n", "gh", function()
    vim.lsp.buf.hover(hover_opts)
  end, vim.tbl_extend("force", opts, { desc = "Hover help" }))
  keymap("n", "<leader>lh", function()
    vim.lsp.buf.hover(hover_opts)
  end, vim.tbl_extend("force", opts, { desc = "Hover help" }))

  -- Signature Help
  keymap("n", "gH", function()
    vim.lsp.buf.signature_help(hover_opts)
  end, vim.tbl_extend("force", opts, { desc = "Signature help" }))
  keymap("n", "<leader>lH", function()
    vim.lsp.buf.signature_help(hover_opts)
  end, vim.tbl_extend("force", opts, { desc = "Signature help" }))

  -- Rename Symbol
  keymap("n", "<leader>lr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

  -- Workspace Symbol Search
  keymap("n", "<leader>lS", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Search workspace symbols" }))
  keymap("n", "gS", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", opts, { desc = "Search workspace symbols" }))

  -- Document Symbols (requires aerial or telescope)
  local aerial_available = pcall(require, "aerial")
  local telescope_available = pcall(require, "telescope")

  if telescope_available then
    keymap("n", "<leader>ls", function()
      if aerial_available then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
    keymap("n", "gs", function()
      if aerial_available then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))

    -- Override some mappings with telescope versions
    keymap("n", "gd", function() require("telescope.builtin").lsp_definitions() end, vim.tbl_extend("force", opts, { desc = "Goto definition" }))
    keymap("n", "gI", function() require("telescope.builtin").lsp_implementations() end, vim.tbl_extend("force", opts, { desc = "Goto implementation" }))
    keymap("n", "gr", function() require("telescope.builtin").lsp_references() end, vim.tbl_extend("force", opts, { desc = "References" }))
    keymap("n", "<leader>lR", function() require("telescope.builtin").lsp_references() end, vim.tbl_extend("force", opts, { desc = "Hover references" }))
    keymap("n", "gT", function() require("telescope.builtin").lsp_type_definitions() end, vim.tbl_extend("force", opts, { desc = "Goto type definition" }))

    -- Diagnostics with telescope
    keymap("n", "<leader>lD", function() require("telescope.builtin").diagnostics() end, vim.tbl_extend("force", opts, { desc = "Diagnostics" }))
  end

  -- Inlay Hints Toggle
  if vim.lsp.inlay_hint then
    keymap("n", "<leader>lI", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
  end
end

return M
