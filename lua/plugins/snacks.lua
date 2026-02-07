return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      picker = { enabled = true },
      terminal = { enabled = true },
      notifier = { enabled = true },
      bigfile = { enabled = true },
      indent = {
        enabled = true,
        char = " ",
        only_scope = false,
        only_current = true,
        animate = {
          enabled = true,
        },
      },
      scope = {
        enabled = true,
        cursor = false,
        char = "│",
        treesitter = { enabled = true },
      },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      local function sync_scope_colors()
        local rainbow_hls = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        }

        for i, hl_name in ipairs(rainbow_hls) do
          local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
          if hl.fg then
            vim.api.nvim_set_hl(0, 'SnacksIndentScope' .. i, {
              fg = hl.fg,
              bold = true
            })
          end
        end

        local first_hl = vim.api.nvim_get_hl(0, { name = rainbow_hls[1], link = false })
        if first_hl.fg then
          vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
            fg = first_hl.fg,
            bold = true
          })
        end
      end

      -- FINAL: Support both braces and Lua keywords
      local function update_scope_color()
        local cursor_line = vim.fn.line('.')
        local cursor_col = vim.fn.col('.')
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.bo.filetype
        local is_lua = (filetype == 'lua')

        -- Helper to get rainbow highlight with wider search for keywords
        local function get_rainbow_hl(line_num, col, is_keyword)
          local search_start, search_end
          if is_lua and is_keyword then
            -- For Lua keywords, search wider range
            search_start = math.max(0, col - 5)
            search_end = col + 20
          else
            -- For braces/parens, exact or small range
            search_start = math.max(0, col - 2)
            search_end = col + 2
          end

          local extmarks = vim.api.nvim_buf_get_extmarks(
            bufnr, -1,
            {line_num - 1, search_start},
            {line_num - 1, search_end},
            {details = true}
          )

          for _, extmark in ipairs(extmarks) do
            local details = extmark[4]
            if details and details.hl_group and details.hl_group:match("^RainbowDelimiter") then
              return details.hl_group
            end
          end
          return nil
        end

        -- First check: is there an opening delimiter on the current line?
        local current_line_text = vim.fn.getline(cursor_line)
        local current_line_hl = nil
        local has_immediate_close = false

        if is_lua then
          -- Check for Lua keywords (if, for, while, function, repeat)
          local keywords = {
            {pattern = '%f[%w_]if%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]for%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]while%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]function%f[^%w_]', closer = 'end'},
            {pattern = '%f[%w_]repeat%f[^%w_]', closer = 'until'},
          }

          for _, kw in ipairs(keywords) do
            local kw_start, kw_end = current_line_text:find(kw.pattern)
            if kw_start then
              -- Check if 'end' appears after this keyword on same line
              local closer_pattern = '%f[%w_]' .. kw.closer .. '%f[^%w_]'
              local closer_pos = current_line_text:find(closer_pattern, kw_end + 1)
              if closer_pos then
                has_immediate_close = true
              else
                current_line_hl = get_rainbow_hl(cursor_line, kw_start, true)
                if current_line_hl then break end
              end
            end
          end

          -- Also check for braces and parens in Lua (prioritize braces)
          if not current_line_hl then
            -- First pass: look for opening braces
            for col = 1, #current_line_text do
              if current_line_text:sub(col, col) == '{' then
                local close_pos = current_line_text:find('}', col + 1, true)
                if close_pos then
                  has_immediate_close = true
                else
                  current_line_hl = get_rainbow_hl(cursor_line, col, false)
                end
                break
              end
            end

            -- Second pass: if no braces, look for opening parens
            if not current_line_hl and not has_immediate_close then
              for col = 1, #current_line_text do
                if current_line_text:sub(col, col) == '(' then
                  local close_pos = current_line_text:find(')', col + 1, true)
                  if close_pos then
                    has_immediate_close = true
                  else
                    current_line_hl = get_rainbow_hl(cursor_line, col, false)
                  end
                  break
                end
              end
            end
          end
        else
          -- Non-Lua: just check for braces and parens (prioritize braces)
          -- First pass: look for opening braces
          for col = 1, #current_line_text do
            if current_line_text:sub(col, col) == '{' then
              local close_pos = current_line_text:find('}', col + 1, true)
              if close_pos then
                has_immediate_close = true
              else
                current_line_hl = get_rainbow_hl(cursor_line, col, false)
              end
              break
            end
          end

          -- Second pass: if no braces, look for opening parens
          if not current_line_hl and not has_immediate_close then
            for col = 1, #current_line_text do
              if current_line_text:sub(col, col) == '(' then
                local close_pos = current_line_text:find(')', col + 1, true)
                if close_pos then
                  has_immediate_close = true
                else
                  current_line_hl = get_rainbow_hl(cursor_line, col, false)
                end
                break
              end
            end
          end
        end

        -- If there's a delimiter on current line that opens a real scope, use its color
        if current_line_hl and not has_immediate_close then
          local hl = vim.api.nvim_get_hl(0, { name = current_line_hl, link = false })
          if hl.fg then
            vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
              fg = hl.fg,
              bold = true
            })
            return
          end
        end

        -- Otherwise, find the parent scope
        local stack = {}

        for line_num = 1, cursor_line - 1 do  -- Only scan BEFORE current line
          local line = vim.fn.getline(line_num)

          if is_lua then
            -- Lua: scan for both keywords and braces
            local i = 1
            while i <= #line do
              -- Check for keywords at current position
              local found_keyword = false

              -- Check for scope-opening keywords (if/for/while/function)
              local keywords = {
                {pattern = '%f[%w_]if%f[^%w_]'},
                {pattern = '%f[%w_]for%f[^%w_]'},
                {pattern = '%f[%w_]while%f[^%w_]'},
                {pattern = '%f[%w_]function%f[^%w_]'},
                {pattern = '%f[%w_]repeat%f[^%w_]'},
              }

              for _, kw in ipairs(keywords) do
                local kw_start, kw_end = line:find(kw.pattern, i)
                if kw_start == i then
                  local hl_name = get_rainbow_hl(line_num, i, true)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'keyword'
                  })
                  i = kw_end + 1
                  found_keyword = true
                  break
                end
              end

              if not found_keyword then
                local char = line:sub(i, i)

                -- Check for 'end' keyword
                local end_start, end_end = line:find('%f[%w_]end%f[^%w_]', i)
                if end_start == i then
                  if #stack > 0 and stack[#stack].type == 'keyword' then
                    table.remove(stack)
                  end
                  i = end_end + 1
                -- Check for 'until' keyword (closes 'repeat')
                elseif line:find('%f[%w_]until%f[^%w_]', i) == i then
                  if #stack > 0 and stack[#stack].type == 'keyword' then
                    table.remove(stack)
                  end
                  local _, until_end = line:find('%f[%w_]until%f[^%w_]', i)
                  i = until_end + 1
                -- Check for braces and parens
                elseif char == '{' then
                  local hl_name = get_rainbow_hl(line_num, i, false)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'brace'
                  })
                  i = i + 1
                elseif char == '}' then
                  -- Find and remove the most recent brace
                  for i = #stack, 1, -1 do
                    if stack[i].type == 'brace' then
                      table.remove(stack, i)
                      break
                    end
                  end
                  i = i + 1
                elseif char == '(' then
                  local hl_name = get_rainbow_hl(line_num, i, false)
                  table.insert(stack, {
                    line = line_num,
                    col = i,
                    hl = hl_name,
                    type = 'paren'
                  })
                  i = i + 1
                elseif char == ')' then
                  -- Find and remove the most recent paren
                  for i = #stack, 1, -1 do
                    if stack[i].type == 'paren' then
                      table.remove(stack, i)
                      break
                    end
                  end
                  i = i + 1
                else
                  i = i + 1
                end
              end
            end
          else
            -- Non-Lua: just scan for braces and parens
            for col = 1, #line do
              local char = line:sub(col, col)

              if char == '{' then
                local hl_name = get_rainbow_hl(line_num, col, false)
                table.insert(stack, {
                  line = line_num,
                  col = col,
                  hl = hl_name,
                  type = 'brace'
                })
              elseif char == '}' then
                -- Find and remove the most recent brace
                for i = #stack, 1, -1 do
                  if stack[i].type == 'brace' then
                    table.remove(stack, i)
                    break
                  end
                end
              elseif char == '(' then
                local hl_name = get_rainbow_hl(line_num, col, false)
                table.insert(stack, {
                  line = line_num,
                  col = col,
                  hl = hl_name,
                  type = 'paren'
                })
              elseif char == ')' then
                -- Find and remove the most recent paren
                for i = #stack, 1, -1 do
                  if stack[i].type == 'paren' then
                    table.remove(stack, i)
                    break
                  end
                end
              end
            end
          end
        end

        -- Use the parent scope (prioritize braces/keywords over parens)
        if #stack > 0 then
          local top = nil

          -- First, look for the most recent brace or keyword
          for i = #stack, 1, -1 do
            if stack[i].type == 'brace' or stack[i].type == 'keyword' then
              top = stack[i]
              break
            end
          end

          -- If no brace or keyword found, use the most recent item (likely a paren)
          if not top then
            for i = #stack, 1, -1 do
              if stack[i].type == 'paren' then
                top = stack[i]
                break
              end
            end
          end

          -- Final fallback: just use the last item
          if not top then
            top = stack[#stack]
          end

          if top and top.hl and top.hl:match("^RainbowDelimiter") then
            local hl = vim.api.nvim_get_hl(0, { name = top.hl, link = false })
            if hl.fg then
              vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
                fg = hl.fg,
                bold = true
              })
              return
            end
          end
        end

        -- Fallback: indent-based coloring
        local current_indent = vim.fn.indent('.')
        local shiftwidth = vim.bo.shiftwidth
        if shiftwidth == 0 then shiftwidth = 2 end

        local indent_level = math.floor(current_indent / shiftwidth)
        local color_index = (indent_level % 7) + 1
        local target_hl = 'SnacksIndentScope' .. color_index

        local hl = vim.api.nvim_get_hl(0, { name = target_hl, link = false })
        if hl.fg then
          vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
            fg = hl.fg,
            bold = true
          })
        end
      end

      vim.api.nvim_create_autocmd({"ColorScheme"}, {
        callback = function()
          vim.defer_fn(sync_scope_colors, 50)
        end
      })

      local timer = nil
      vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter"}, {
        callback = function()
          if timer then
            vim.fn.timer_stop(timer)
          end
          timer = vim.fn.timer_start(1, function()
            pcall(update_scope_color)
            timer = nil
          end)
        end
      })

      for _, delay in ipairs({100, 300, 500, 1000}) do
        vim.defer_fn(function()
          pcall(sync_scope_colors)
          pcall(update_scope_color)
        end, delay)
      end
    end
  },
  --hack to only show scope lines for curr scope
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    lazy = false,
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      scope = {
        enabled = false,
        char = "",
        highlight = "IblScope",
        show_start = true,
        show_end = false,
      },
      indent = {
        char = "•",
        highlight = "IblIndent"
      },
    },
  },
}
