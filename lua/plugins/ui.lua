return {
  {
    'Bekaboo/dropbar.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      icons = {
        kinds = {
          symbols = {
            Array = '󰅪 ',
            Boolean = ' ',
            BreakStatement = '󰙧 ',
            Call = '󰃷 ',
            CaseStatement = '󱃙 ',
            Class = ' ',
            Color = '󰏘 ',
            Constant = '󰏿 ',
            Constructor = '󰡢 ',
            ContinueStatement = '-> ',
            Copilot = ' ',
            Declaration = '󰙠 ',
            Delete = '󰩺 ',
            DoStatement = '󰑖 ',
            Enum = ' ',
            EnumMember = '󰖆 ',
            Event = ' ',
            Field = ' ',
            File = '󰈔 ',
            Folder = '󰉋 ',
            ForStatement = '󰑖 ',
            Function = '󰊕 ',
            Identifier = '󰀫 ',
            IfStatement = '󰇉 ',
            Interface = ' ',
            Keyword = '󰌋 ',
            List = '󰅪 ',
            Log = '󰦪 ',
            Lsp = ' ',
            Macro = '󰁌 ',
            MarkdownH1 = '󰉫 ',
            MarkdownH2 = '󰉬 ',
            MarkdownH3 = '󰉭 ',
            MarkdownH4 = '󰉮 ',
            MarkdownH5 = '󰉯 ',
            MarkdownH6 = '󰉰 ',
            Method = '󰆧 ',
            Module = '󰏗 ',
            Namespace = '󰅩 ',
            Null = '󰢤 ',
            Number = '󰎠 ',
            Object = '󰅩 ',
            Operator = '󰆕 ',
            Package = '󰆦 ',
            Property = ' ',
            Reference = '󰦾 ',
            Regex = '󰑑 ',
            Repeat = '󰑖 ',
            Scope = '󰅩 ',
            Specifier = '󰦪 ',
            Statement = '󰅩 ',
            String = '󰉾 ',
            Struct = ' ',
            SwitchStatement = '󰺟 ',
            Terminal = ' ',
            Type = ' ',
            TypeParameter = '󰆩 ',
            Unit = ' ',
            Value = '󰎠 ',
            Variable = '󰀫 ',
            WhileStatement = '󰑖 ',
          },
        },
        ui = {
          bar = { separator = ' > ', extends = '...' },
          menu = { separator = ' ', indicator = ' ' },
        },
      },
      bar = {
        enable = function(buf, win)
          return vim.bo[buf].buftype == ''
            and vim.api.nvim_win_get_config(win).relative == ''
            and vim.bo[buf].filetype ~= 'minifiles'
        end,
        update_debounce = 100,
        sources = function(buf, _)
          local sources = require('dropbar.sources')
          local utils = require('dropbar.utils')
          if vim.bo[buf].ft == 'markdown' then
            return { sources.markdown }
          end
          if vim.bo[buf].buftype == 'terminal' then
            return { sources.terminal }
          end
          return {
            utils.source.fallback({ sources.lsp, sources.treesitter }),
          }
        end,
        padding = { left = 1, right = 1 },
        pick = { pivots = 'abcdefghijklmnopqrstuvwxyz' },
      },
      menu = {
        keymaps = {
          ['<CR>'] = function()
            local menu = require('dropbar.api').get_current_dropbar_menu()
            if menu then
              menu:fuzzy_find_open()
            end
          end,
          ['<Esc>'] = function()
            local menu = require('dropbar.api').get_current_dropbar_menu()
            if menu then
              menu:close()
            end
          end,
          ['q'] = function()
            local menu = require('dropbar.api').get_current_dropbar_menu()
            if menu then
              menu:close()
            end
          end,
          ['j'] = function()
            local menu = require('dropbar.api').get_current_dropbar_menu()
            if menu then
              menu:navigate(1)
            end
          end,
          ['k'] = function()
            local menu = require('dropbar.api').get_current_dropbar_menu()
            if menu then
              menu:navigate(-1)
            end
          end,
        },
      },
    },
    keys = {
      {
        '<leader>bp',
        function()
          require('dropbar.api').pick()
        end,
        desc = 'Dropbar pick',
      },
    },
  },
  {
    'rcarriga/nvim-notify',
    lazy = false,
    opts = {
      background_colour = '#1e1e2e',
      render = 'compact',
      stages = 'fade',
      timeout = 3000,
      max_width = 60,
      icons = {
        ERROR = ' ',
        WARN = ' ',
        INFO = ' ',
        DEBUG = ' ',
        TRACE = '✎ ',
      },
    },
    config = function(_, opts)
      local notify = require('notify')
      notify.setup(opts)
      vim.notify = notify
    end,
  },
  {
    'folke/twilight.nvim',
    cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
    keys = { { '<leader>tT', '<cmd>Twilight<cr>', desc = 'Toggle twilight' } },
    opts = {
      dimming = {
        alpha = 0.25,
        color = { 'Normal', '#ffffff' },
        inactive = false,
      },
      context = 15,
      treesitter = true,
      expand = {
        'function',
        'method',
        'table',
        'if_statement',
        'for_statement',
        'while_statement',
        'method_definition',
        'function_definition',
        'class_definition',
      },
    },
  },
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local bl = require('bufferline')
      bl.setup({
        options = {
          mode = 'buffers',
          themable = true,
          numbers = function(opts)
            local els = require('bufferline').get_elements()
            if els and els.elements then
              for i, el in ipairs(els.elements) do
                if el.id == opts.id then
                  return tostring(i)
                end
              end
            end
            return tostring(opts.ordinal)
          end,
          indicator = { style = 'none' },
          buffer_close_icon = '',
          modified_icon = 'o',
          close_icon = '',
          left_trunc_marker = '<-',
          right_trunc_marker = '->',
          max_name_length = 20,
          max_prefix_length = 6,
          truncate_names = true,
          tab_size = 5,
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = false,
          show_duplicate_prefix = true,
          separator_style = { '', '' },
          always_show_bufferline = true,
          persist_buffer_sort = false,
          custom_filter = function(buf)
            return vim.bo[buf].buftype ~= 'terminal'
          end,
          sort_by = function(a, b)
            local ae, be = a.extension or '', b.extension or ''
            if ae ~= be then
              return ae < be
            end
            return (a.path or a.name or '') < (b.path or b.name or '')
          end,
          offsets = {
            {
              filetype = 'MarvinExplorer',
              text = '  explorer',
              text_align = 'left',
              separator = false,
            },
          },
        },
      })

      vim.keymap.set(
        'n',
        '<S-l>',
        '<cmd>BufferLineCycleNext<cr>',
        { desc = 'Next buffer' }
      )
      vim.keymap.set(
        'n',
        '<S-h>',
        '<cmd>BufferLineCyclePrev<cr>',
        { desc = 'Prev buffer' }
      )
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, function()
          bl.go_to(i, true)
        end, { desc = 'Buffer ' .. i })
      end
      vim.keymap.set('n', '<leader>$', function()
        bl.go_to(-1, true)
      end, { desc = 'Last buffer' })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local dankula = require('dankula')
      local p = dankula.colors

      local theme = {
        normal = {
          a = { fg = p.lavender, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.lavender, bg = p.surface0, gui = 'bold' },
        },
        insert = {
          a = { fg = p.teal, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.teal, bg = p.surface0, gui = 'bold' },
        },
        visual = {
          a = { fg = p.yellow, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.yellow, bg = p.surface0, gui = 'bold' },
        },
        replace = {
          a = { fg = p.red, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.red, bg = p.surface0, gui = 'bold' },
        },
        command = {
          a = { fg = p.blue, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.blue, bg = p.surface0, gui = 'bold' },
        },
        terminal = {
          a = { fg = p.sky, bg = p.surface0, gui = 'bold' },
          b = { fg = p.text, bg = p.surface0 },
          c = { fg = p.lavender, bg = p.crust },
          x = { fg = p.lavender, bg = p.crust },
          y = { fg = p.lavender, bg = p.crust },
          z = { fg = p.sky, bg = p.surface0, gui = 'bold' },
        },
        inactive = {
          a = { fg = p.surface2, bg = p.crust },
          b = { fg = p.surface2, bg = p.crust },
          c = { fg = p.surface2, bg = p.base },
          x = { fg = p.surface2, bg = p.crust },
          y = { fg = p.surface2, bg = p.crust },
          z = { fg = p.surface2, bg = p.crust },
        },
      }

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ''
        end
        local names = {}
        for _, c in ipairs(clients) do
          if c.name ~= 'null-ls' and c.name ~= 'copilot' then
            names[#names + 1] = c.name
          end
        end
        return #names > 0 and ('LSP:' .. table.concat(names, ',')) or ''
      end

      local marvin = require('marvin.statusbar').lualine_component

      local function macro_recording()
        local reg = vim.fn.reg_recording()
        return reg ~= '' and ('REC @' .. reg) or ''
      end

      require('lualine').setup({
        options = {
          theme = theme,
          globalstatus = true,
          section_separators = { left = '', right = '' },
          component_separators = { left = '|', right = '|' },
          disabled_filetypes = { statusline = { 'neo-tree' } },
        },
        sections = {
          lualine_a = {
            {
              'mode',
              fmt = function(s)
                return s:sub(1, 1)
              end,
              padding = { left = 2, right = 1 },
            },
          },
          lualine_b = {
            { 'branch', icon = '' },
            {
              'diff',
              symbols = { added = '+', modified = '~', removed = '-' },
              colored = true,
            },
          },
          lualine_c = {
            { marvin },
            { macro_recording, color = { fg = '#f38ba8' } },
            { lsp_clients },
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              symbols = { error = 'E:', warn = 'W:', info = 'I:', hint = 'H:' },
              colored = true,
              always_visible = false,
            },
            { 'filetype', colored = true, icon_only = false },
          },
          lualine_y = { { 'progress', padding = { left = 1, right = 1 } } },
          lualine_z = { { 'location', padding = { left = 1, right = 2 } } },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      })

      if dankula.transparent and dankula.apply_transparent then
        dankula.apply_transparent(true)
      end
    end,
  },

  -- ── Rainbow delimiters ────────────────────────────────────────────────
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = 'BufReadPost',
    config = function()
      local rd = require('rainbow-delimiters')
      vim.g.rainbow_delimiters = {
        strategy = { [''] = rd.strategy['global'] },
        query = { [''] = 'rainbow-delimiters', lua = 'rainbow-blocks' },
        priority = { [''] = 110 },
        highlight = {
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
          'RainbowDelimiterBlue',
          'RainbowDelimiterYellow',
          'RainbowDelimiterRed',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
        },
      }
    end,
  },
}
