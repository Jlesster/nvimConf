return {
  {
    "echasnovski/mini.indentscope",
    lazy = false,
    priority = 1000,
    config = function()
      local indentscope = require("mini.indentscope")

      -- Setup with options
      indentscope.setup({
        enabled = true,
        symbol = "╎",
        options = { try_as_border = true },
        draw = {
          delay = 30,
          animation = indentscope.gen_animation.quadratic({ duration = 50 }),
        },
      })

      -- Scan a line for any rainbow delimiter color
      local function scan_line_for_rainbow(bufnr, line)
        if line < 1 then return nil end

        local line_text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
        if not line_text then return nil end

        -- Scan every character on the line
        for col = 0, #line_text - 1 do
          local synid = vim.fn.synID(line, col + 1, 1)
          local hl_name = vim.fn.synIDattr(synid, "name")

          if hl_name and hl_name:find("RainbowDelimiter") then
            local hl_ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name, link = false })
            if hl_ok and hl.fg then
              return hl.fg
            end
          end
        end

        return nil
      end

      -- Find which line actually has the opening delimiter for a scope
      local function find_opening_delimiter_line(bufnr, scope_start_row, scope_start_col, target_line)
        -- The scope might start on a specific line, but we need to find where the actual
        -- opening delimiter is. For "draw = {", the { is on the same line.
        -- Try a few lines around the scope start

        local lines_to_check = {
          scope_start_row + 1, -- The actual start line (1-indexed)
          scope_start_row,     -- One line before (in case of edge case)
          scope_start_row + 2, -- One line after
        }

        -- Also make sure we check the line right before the target
        if target_line > 1 and not vim.tbl_contains(lines_to_check, target_line - 1) then
          table.insert(lines_to_check, target_line - 1)
        end

        for _, line in ipairs(lines_to_check) do
          if line >= 1 then
            local color = scan_line_for_rainbow(bufnr, line)
            if color then return color end
          end
        end

        return nil
      end

      -- Get the rainbow color at the cursor's actual scope level using treesitter
      local function get_scope_delimiter_color(bufnr, target_line)
        local cursor = vim.api.nvim_win_get_cursor(0)
        local cursor_line = cursor[1] - 1
        local cursor_col = cursor[2]

        -- Try to use treesitter to find the containing node
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
        if not ok or not parser then return nil end

        local tree = parser:parse()[1]
        if not tree then return nil end

        local root = tree:root()
        local node = root:descendant_for_range(cursor_line, cursor_col, cursor_line, cursor_col)

        if not node then return nil end

        -- Scope types that define blocks
        local scope_types = {
          "function_declaration",
          "function_definition",
          "if_statement",
          "for_statement",
          "while_statement",
          "repeat_statement",
          "table_constructor",
          "arguments",
          "parenthesized_expression",
          "do_statement",
        }

        -- Find ALL parent scopes with their start and end lines
        local scopes = {}
        local current = node:parent()
        while current do
          local node_type = current:type()

          -- Check if this is a scope-defining node
          local is_scope = false
          for _, stype in ipairs(scope_types) do
            if node_type == stype or node_type:find(stype) then
              is_scope = true
              break
            end
          end

          if is_scope then
            local start_row, start_col, end_row, end_col = current:range()

            -- Only consider multiline scopes
            if end_row > start_row then
              table.insert(scopes, {
                node = current,
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                type = node_type
              })
            end
          end

          current = current:parent()
        end

        -- Find the SMALLEST scope that contains the target line
        local best_scope = nil
        local best_size = math.huge

        for _, scope in ipairs(scopes) do
          local scope_start = scope.start_row + 1 -- Convert to 1-indexed
          local scope_end = scope.end_row + 1

          -- Check if this scope contains the target line
          -- IMPORTANT: For the scope bar, target_line is where it starts rendering (inside the scope)
          -- So we want scopes where: scope_start <= target_line <= scope_end
          if scope_start <= target_line and target_line <= scope_end then
            local size = scope_end - scope_start
            -- Pick the smallest (most specific) scope
            if size < best_size then
              best_size = size
              best_scope = scope
            end
          end
        end

        if best_scope then
          -- Look for the opening delimiter around the scope's start
          return find_opening_delimiter_line(bufnr, best_scope.start_row, best_scope.start_col, target_line)
        end

        return nil
      end

      -- Get color for scope
      local function get_scope_color(bufnr, top)
        -- Use treesitter to find the smallest scope containing the target line
        local color = get_scope_delimiter_color(bufnr, top)
        if color then return color end

        -- Aggressive fallback: scan multiple lines around the scope
        for offset = 0, -3, -1 do
          local line = top + offset
          if line >= 1 then
            color = scan_line_for_rainbow(bufnr, line)
            if color then return color end
          end
        end

        -- Last resort: indent-based calculation
        local indent = vim.fn.indent(top)
        local shiftwidth = vim.bo[bufnr].shiftwidth
        if shiftwidth == 0 then shiftwidth = vim.bo[bufnr].tabstop end
        if shiftwidth == 0 then shiftwidth = 2 end
        local level = math.floor(indent / shiftwidth)

        local rainbow_hls = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        }

        -- Adjust level to better match nesting
        level = math.max(0, level - 1)
        local color_index = (level % #rainbow_hls) + 1
        local hl_name = rainbow_hls[color_index]

        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name, link = false })
        if ok and hl.fg then
          return hl.fg
        end

        return nil
      end

      local last_scope = nil
      local function update_scope_color()
        local bufnr = vim.api.nvim_get_current_buf()
        local scope = indentscope.get_scope()
        if not scope or not scope.body then return end

        local scope_id = scope.body.top .. ":" .. scope.body.bottom
        if last_scope == scope_id then return end
        last_scope = scope_id

        local fg = get_scope_color(bufnr, scope.body.top)

        if fg then
          vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = fg, bold = true })
        end
      end

      -- Update on cursor move / buffer enter / colorscheme
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
        callback = function()
          vim.schedule(update_scope_color)
        end,
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.schedule(update_scope_color)
        end,
      })

      -- Initial update after short delay
      vim.defer_fn(function()
        vim.schedule(update_scope_color)
      end, 100)
    end,
  },
}
