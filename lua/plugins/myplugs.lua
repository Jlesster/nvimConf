return {
  {
    {
      "tpope/vim-surround",
      lazy = false,
    },
    {
      "HiPhish/rainbow-delimiters.nvim",
      lazy = false,
      priority = 110,
      config = function()
        local rainbow_delimiters = require('rainbow-delimiters')

        vim.g.rainbow_delimiters = {
          strategy = {
            [''] = rainbow_delimiters.strategy['global'],
            vim = rainbow_delimiters.strategy['local'],
          },
          query = {
            [''] = 'rainbow-delimiters',
            lua = 'rainbow-blocks',
          },
          highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow',
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
          },
        }
      end,
    },
    {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    config = function()
      -- Helper function to get colors from highlight groups
      local function get_hl_colors(hl_name)
        local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
        return {
          fg = hl.fg and string.format("#%06x", hl.fg) or nil,
          bg = hl.bg and string.format("#%06x", hl.bg) or nil,
          gui = hl.bold and 'bold' or nil,
        }
      end

      -- Build theme dynamically from highlight groups
      local function build_theme()
        return {
          normal = {
            a = get_hl_colors('lualine_a_normal'),
            b = get_hl_colors('lualine_b_normal'),
            c = get_hl_colors('lualine_c_normal'),
            x = get_hl_colors('lualine_x_normal'),
            y = get_hl_colors('lualine_y_normal'),
            z = get_hl_colors('lualine_z_normal'),
          },
          insert = {
            a = get_hl_colors('lualine_a_insert'),
            b = get_hl_colors('lualine_b_insert'),
            c = get_hl_colors('lualine_c_insert'),
            x = get_hl_colors('lualine_x_insert'),
            y = get_hl_colors('lualine_y_insert'),
            z = get_hl_colors('lualine_z_insert'),
          },
          visual = {
            a = get_hl_colors('lualine_a_visual'),
            b = get_hl_colors('lualine_b_visual'),
            c = get_hl_colors('lualine_c_visual'),
            x = get_hl_colors('lualine_x_visual'),
            y = get_hl_colors('lualine_y_visual'),
            z = get_hl_colors('lualine_z_visual'),
          },
          replace = {
            a = get_hl_colors('lualine_a_replace'),
            b = get_hl_colors('lualine_b_replace'),
            c = get_hl_colors('lualine_c_replace'),
            x = get_hl_colors('lualine_x_replace'),
            y = get_hl_colors('lualine_y_replace'),
            z = get_hl_colors('lualine_z_replace'),
          },
          command = {
            a = get_hl_colors('lualine_a_command'),
            b = get_hl_colors('lualine_b_command'),
            c = get_hl_colors('lualine_c_command'),
            x = get_hl_colors('lualine_x_command'),
            y = get_hl_colors('lualine_y_command'),
            z = get_hl_colors('lualine_z_command'),
          },
          inactive = {
            a = get_hl_colors('lualine_a_inactive'),
            b = get_hl_colors('lualine_b_inactive'),
            c = get_hl_colors('lualine_c_inactive'),
          },
        }
      end


      -- Custom LSP component
      local function lsp_status()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end

        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
        end

        return " " .. table.concat(client_names, ", ")
      end

      require('lualine').setup({
        options = {
          theme = build_theme(),
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          icon = '',  -- Neovim logo,
          refresh = { statusline = 100, },
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'alpha', 'dashboard' },
          },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(mode)
                  local map = {
                    ['NORMAL'] = 'N',
                    ['INSERT'] = 'I',
                    ['VISUAL'] = 'V',
                    ['V-LINE'] = 'VI',
                    ['V-BLOCK'] = 'VB',
                    ['SELECT'] = 'S',
                    ['S-LINE'] = 'S',
                    ['S-BLOCK'] = 'SB',
                    ['REPLACE'] = 'R',
                    ['COMMAND'] = 'C',
                    ['TERMINAL'] = 'T',
                  }
                return map[mode] or mode:sub(1, 1)
              end,
            }
          },
          lualine_b = {
            {
              'branch',
              icon = '',
            },
            {
              'diff',
              icon = false,
              on_click = function()
                vim.cmd('TermExec cmd="lazygit && exit" direction=float go_back=0')
                vim.defer_fn(function()
                  vim.cmd('startinsert!')
                end, 200)
              end,
              symbols = { added = ' ', modified = ' ', removed = ' ' },
            },
          },
          lualine_c = {
            {
              'filename',
              path = 1, -- relative path
              icon = false,
              fmt = function(name)
                -- max characters for the whole path
                local max = 30

                if #name <= max then
                  return name
                end

                -- keep filename, truncate directories
                local sep = package.config:sub(1,1)
                local parts = vim.split(name, sep)

                if #parts <= 1 then
                  return name:sub(1, max - 1) .. '…'
                end

                local filename = table.remove(parts)
                local dir = table.concat(parts, sep)

                local available = max - (#filename + 2) -- "/…/"
                if available <= 0 then
                  return filename
                end

                return dir:sub(1, available) .. '…' .. sep .. filename
              end,
              -- Click to open system file browser in current directory
              on_click = function()
                -- Get the directory of current file
                local file_dir = vim.fn.expand('%:p:h')

                -- Detect OS and use appropriate command
                local open_cmd
                if vim.fn.has('mac') == 1 then
                  open_cmd = 'open'  -- macOS
                elseif vim.fn.has('win32') == 1 then
                  open_cmd = 'explorer'  -- Windows
                else
                  open_cmd = 'xdg-open'  -- Linux
                end

                -- Open in background without blocking
                vim.fn.jobstart({open_cmd, file_dir}, {detach = true})
              end,
            }
          },
          lualine_x = {
            {
              lsp_status,
              icon = "",
              color = { gui = "none" },
              on_click = function()
                vim.cmd('LspInfo')
              end,
            },
            {
              'diagnostics',
              icon = false,
              sources = { 'nvim_diagnostic' },
              symbols = { error = ' ', warn = '●', info = '', hint = ' ' },
              on_click = function()
                  require('telescope.builtin').diagnostics()
              end,
            },
            {
              'filetype',
              colored = false,
              icon_only = true,
            },
          },
          lualine_y = {
            {
              'progress',
              icon = false,
            }
          },
          lualine_z = {
            {
              'location',
              icon = false,
            }
          }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        extensions = { 'neo-tree', 'lazy', 'mason', 'toggleterm' }
      })
    end,
    },
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
        },
      },
    },
    {
      'Aasim-A/scrollEOF.nvim',
      event = { 'CursorMoved', 'WinScrolled' },
      opts = {
        pattern = '~',
      },
      config = function()
        require("scrollEOF").setup()
      end,
    },
    {
      'ThePrimeagen/vim-be-good'
    },
    {
      'alessio-vivaldelli/java-creator-nvim',
      ft = 'java',
      opts = {
        -- Default configuration
        keymaps = {
          java_new = "<leader>jN",
        },
        options = {
          auto_open = true,  -- Open file after creation
          java_version = 21  -- Minimum Java version
        },
        default_imports = {
          record = {"java.util.*;"}
        }
      }
    },
    {
      "eatgrass/maven.nvim",
      cmd = { "Maven", "MavenExec" },
      dependencies = "nvim-lua/plenary.nvim",
      config = function()
        local Job = require("plenary.job")

        local function get_main_class()
          local result = Job:new({
            command = "make",
            args = {'print-main-class'},
          }):sync()

          if result and result[1] then
            return vim.trim(result[1])
          else
            return nil
          end
        end

        require('maven').setup({
          executable="mvn",
          cwd = nil, -- work directory, default to `vim.fn.getcwd()`
          settings = nil, -- specify the settings file or use the default settings
          commands = { -- add custom goals to the command list
            { cmd = { "clean", "compile" }, desc = "clean then compile" },
            { cmd = { "dependency:resolve" }, desc = "Resolve Deps" },
            { cmd = { "clean", "compile", "assembly:single" }, desc = "Package to FAT jar" },
          },
        })
      end
    },
  },
  {
    "ariedov/android-nvim",
    config = function()
      -- OPTIONAL: specify android sdk directory
      -- vim.g.android_sdk = "~/Library/Android/sdk"
      require('android-nvim').setup()
    end
  },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim",  -- Ensure rainbow loads first
      {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
          -- For opencode
          input = { enabled = true },
          picker = { enabled = true },
          terminal = { enabled = true },

          -- Replacements
          notifier = { enabled = true },    -- replaces nvim-notify
          bigfile = { enabled = true },     -- bonus feature
          indent = {
            enabled = true,
          },
          scope = {
            enabled = true,
            cursor = false,
            treesitter = {
              enabled = true,
            },
          },
          scroll = {                        -- replaces mini.animate
            enabled = false,
            animate = {
              duration = { step = 15, total = 250 },
              easing = "linear",
            },
          },

          -- Bonus features you might like:
          statuscolumn = { enabled = true }, -- prettier line numbers
          words = { enabled = true },        -- highlight word under cursor
          zen = { enabled = true },          -- zen mode
        },
        config = function(_, opts)
          require("snacks").setup(opts)

          -- Sync scope colors with rainbow delimiters dynamically based on indent level
          local function sync_scope_colors()
            -- Rainbow delimiter colors in order
            local rainbow_hls = {
              'RainbowDelimiterRed',
              'RainbowDelimiterYellow',
              'RainbowDelimiterBlue',
              'RainbowDelimiterOrange',
              'RainbowDelimiterGreen',
              'RainbowDelimiterViolet',
              'RainbowDelimiterCyan',
            }

            -- Create highlight groups for each indent level
            for i, hl_name in ipairs(rainbow_hls) do
              local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
              if hl.fg then
                -- Create numbered scope highlights that snacks will cycle through
                vim.api.nvim_set_hl(0, 'SnacksIndentScope' .. i, {
                  fg = hl.fg,
                  bold = true
                })
              end
            end

            -- Also set the base SnacksIndentScope (fallback)
            local first_hl = vim.api.nvim_get_hl(0, { name = rainbow_hls[1], link = false })
            if first_hl.fg then
              vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
                fg = first_hl.fg,
                bold = true
              })
            end
          end

          -- Function to find the opening bracket line and read its color
          local function update_scope_color()
            local cursor_line = vim.fn.line('.')
            local current_indent = vim.fn.indent(cursor_line)

            -- First check if the CURRENT line has an opening bracket
            -- If so, use that bracket's color (we're on the line that starts the scope)
            local current_line_text = vim.fn.getline(cursor_line)
            for col = #current_line_text, 1, -1 do
              local char = current_line_text:sub(col, col)
              if char:match("[%{%[%(]") then
                -- Found a bracket on current line!
                local synID = vim.fn.synID(cursor_line, col, 1)
                local hl_name = vim.fn.synIDattr(synID, "name")

                if hl_name and hl_name:match("^RainbowDelimiter") then
                  local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
                  if hl.fg then
                    vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
                      fg = hl.fg,
                      bold = true
                    })
                    return
                  end
                end
              end
            end

            -- If no bracket on current line, find the immediate parent line
            local parent_indent = nil
            local parent_line = nil

            for line_num = cursor_line - 1, math.max(1, cursor_line - 100), -1 do
              local line = vim.fn.getline(line_num)

              -- Skip empty lines
              if line:match("%S") then
                local line_indent = vim.fn.indent(line_num)

                -- Found first line with less indentation
                if line_indent < current_indent then
                  parent_indent = line_indent
                  parent_line = line_num

                  -- Look for the LAST opening bracket on this line
                  local last_bracket_col = nil

                  for col = #line, 1, -1 do
                    local char = line:sub(col, col)
                    if char:match("[%{%[%(]") then
                      last_bracket_col = col
                      break
                    end
                  end

                  -- If we found a bracket, read its color
                  if last_bracket_col then
                    local synID = vim.fn.synID(line_num, last_bracket_col, 1)
                    local hl_name = vim.fn.synIDattr(synID, "name")

                    if hl_name and hl_name:match("^RainbowDelimiter") then
                      -- Found a rainbow delimiter! Use its color
                      local hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
                      if hl.fg then
                        vim.api.nvim_set_hl(0, 'SnacksIndentScope', {
                          fg = hl.fg,
                          bold = true
                        })
                        return
                      end
                    end
                  end

                  -- Found parent line, stop searching
                  break
                end
              end
            end

            -- Fallback: use indent-based coloring
            local shiftwidth = vim.bo.shiftwidth
            if shiftwidth == 0 then shiftwidth = 2 end

            local indent_level = parent_indent and math.floor(parent_indent / shiftwidth) or 0
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

          -- Run on ColorScheme change and on startup with multiple retries
          vim.api.nvim_create_autocmd({"ColorScheme"}, {
            callback = function()
              vim.defer_fn(sync_scope_colors, 50)
            end
          })

          -- Update on cursor move with minimal debouncing
          local timer = nil
          vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI", "BufEnter"}, {
            callback = function()
              if timer then
                vim.fn.timer_stop(timer)
              end
              timer = vim.fn.timer_start(5, function()
                update_scope_color()
                timer = nil
              end)
            end
          })

          -- Try multiple times on startup since plugins load asynchronously
          vim.defer_fn(function()
            sync_scope_colors()
            update_scope_color()
          end, 100)
          vim.defer_fn(function()
            sync_scope_colors()
            update_scope_color()
          end, 300)
          vim.defer_fn(function()
            sync_scope_colors()
            update_scope_color()
          end, 500)
        end
      }
    },
    config = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = "snacks",
          snacks = {
            auto_close = true,
            win = {
              position = "left",  -- or "left", "right", "top"
              width = 0.3,         -- 30% of screen height
              enter = false,        -- Stay in editor after opening
              wo = {
                winbar = "",
              },
              bo = {
                filetype = "opencode_terminal",
              },
            },
          },
        }
      }
    end,
  }
}

