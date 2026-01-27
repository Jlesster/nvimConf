-- lua/ui/cursorline-indent.lua
-- Highlights the indent character on the current line with a different color

local M = {}

local ns = vim.api.nvim_create_namespace("cursorline_indent")

local function clear_highlights()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local function highlight_current_line_indent()
  clear_highlights()

  local line = vim.fn.line(".") - 1  -- 0-indexed
  local text = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]

  if not text then return end

  -- Find indent characters (spaces or tabs converted to visual columns)
  local indent_end = text:match("^%s+")
  if not indent_end then return end

  local indent_len = #indent_end

  -- Highlight each indent position where ibl would show a character
  local shiftwidth = vim.bo.shiftwidth
  if shiftwidth == 0 then shiftwidth = vim.bo.tabstop end
end

function M.setup()
  -- Update on cursor move
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = highlight_current_line_indent,
  })

  -- Update on buffer enter
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      vim.defer_fn(highlight_current_line_indent, 10)
    end,
  })

  -- Initial highlight
  vim.defer_fn(highlight_current_line_indent, 10)
end

return M
