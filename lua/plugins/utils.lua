return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_port = "8888"
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
    end,
  },
  {
    "NMAC427/guess-indent.nvim",
    lazy = false,
    opts = {
      auto_cmd = true,
      override_editorconfig = false,
      filetype_exclude = {
        "netrw",
        "tutor",
        "snacks_dashboard",
        "neo-tree",
        "lazy",
        "mason",
      },
      buftype_exclude = {
        "help",
        "nofile",
        "terminal",
        "prompt",
      },
    },
    config = function(_, opts)
      require('guess-indent').setup(opts)

      -- Only set BASIC indent settings, let treesitter handle indentexpr
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust" },
        callback = function()
          -- Rust: 4 spaces, let Treesitter handle indentexpr
          vim.bo.expandtab = true
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
          -- Don't clear indentexpr - let Treesitter handle it
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
          -- Python: 4 spaces
          vim.bo.expandtab = true
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go" },
        callback = function()
          -- Go: tabs (Go standard)
          vim.bo.expandtab = false
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "yaml", "cpp", "c", "h", "hpp", "java" },
        callback = function()
          -- Most languages: 2 spaces
          vim.bo.expandtab = true
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
        end,
      })
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    lazy = false,
    cmd = { "HighlightColors" }, -- followed by 'On' / 'Off' / 'Toggle'
    opts = {
      enabled_named_colors = false,
      render = 'virtual',
      virtual_symbol = '■',
      ---@usage 'inline'|'eol'|'eow'
      virtual_symbol_position = 'inline',
      enable_tailwind = true,
    },
  },
  {
    "mikavilpas/yazi.nvim",
    event = "User BaseDefered",
    cmd = { "Yazi", "Yazi cwd", "Yazi toggle" },
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.71
    },
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        enable_check_bracket_line = false, -- Don't check if bracket is in same line
      })

      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
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
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
        keymaps = {
          -- Default keymaps (vim-surround compatible)
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },

        -- Surround characters (extend defaults)
        surrounds = {
          -- Default surrounds include: (, ), {, }, [, ], <, >, ', ", `, etc.

          -- Add custom Lua function surround
          ["f"] = {
            add = function()
              local result = require("nvim-surround.config").get_input("Enter the function name: ")
              if result then
                return { { result .. "(" }, { ")" } }
              end
            end,
            find = "[%w_]+%b()",
            delete = "^([%w_]+%()().-(%))()$",
            change = {
              target = "^([%w_]+%()().-(%))()$",
              replacement = function()
                local result = require("nvim-surround.config").get_input("Enter the function name: ")
                if result then
                  return { { result .. "(" }, { ")" } }
                end
              end,
            },
          },

          -- Add markdown code block surround
          ["c"] = {
            add = function()
              local lang = require("nvim-surround.config").get_input("Enter language (optional): ")
              if lang == "" then lang = nil end
              return {
                { "```" .. (lang or ""), "" },
                { "",                    "```" }
              }
            end,
          },

          -- Add HTML/JSX tag surround
          ["t"] = {
            add = function()
              local tag = require("nvim-surround.config").get_input("Enter tag name: ")
              if tag then
                return { { "<" .. tag .. ">" }, { "</" .. tag .. ">" } }
              end
            end,
            find = "<[^>]+>.-</.->",
            delete = "^(<[^>]+>)().-(</[^>]+>)()$",
            change = {
              target = "^<([^>]+)().-</([^>]+)()$",
              replacement = function()
                local tag = require("nvim-surround.config").get_input("Enter tag name: ")
                if tag then
                  return { { "<" .. tag .. ">" }, { "</" .. tag .. ">" } }
                end
              end,
            },
          },

          -- Add Lua table surround
          ["T"] = {
            add = { "{ ", " }" },
          },

          -- Add LaTeX math surround
          ["m"] = {
            add = { "$", "$" },
          },

          -- Add LaTeX display math surround
          ["M"] = {
            add = { "$$", "$$" },
          },

          -- Add comment surround (language-aware)
          ["/"] = {
            add = function()
              local cs = vim.bo.commentstring
              if cs == "" then cs = "# %s" end
              local left, right = cs:match("^(.*)%%s(.*)$")
              if not left then
                left = cs
                right = ""
              end
              return { { left }, { right } }
            end,
          },

          -- Invalid surround (shows error)
          invalid_key_behavior = {
            add = function()
              vim.notify("Invalid surround key", vim.log.levels.ERROR)
            end,
          },
        },

        -- Aliases for convenience
        aliases = {
          -- Bracket aliases
          ["a"] = ">", -- <a>ngle brackets
          ["b"] = ")", -- (b)rackets
          ["B"] = "}", -- {B}races
          ["r"] = "]", -- [r]ectangular brackets

          -- Quote aliases
          ["q"] = { '"', "'", "`" }, -- any (q)uote

          -- Custom aliases
          ["s"] = { "}", "]", ")", ">", "'", '"', "`" }, -- any (s)urround
        },

        -- Move cursor after operations
        move_cursor = "begin", -- or "end" or false

        -- Indent after adding surround
        indent_lines = function(start, stop)
          local b = vim.bo
          -- Only re-indent if the buffer is not a special buffer
          if b.buftype ~= "" then
            return false
          end
          return true
        end,

        -- Highlight on yank (optional, complements your setup)
        highlight = {
          duration = 200,
        },
      })

      -- Additional keymaps for enhanced workflow (optional)
      local keymap = vim.keymap.set

      -- Quick surround with common pairs
      keymap("v", "<leader>s(", "S)", { desc = "Surround with ()" })
      keymap("v", "<leader>s{", "S}", { desc = "Surround with {}" })
      keymap("v", "<leader>s[", "S]", { desc = "Surround with []" })
      keymap("v", "<leader>s<", "S>", { desc = "Surround with <>" })
      keymap("v", '<leader>s"', 'S"', { desc = 'Surround with ""' })
      keymap("v", "<leader>s'", "S'", { desc = "Surround with ''" })
      keymap("v", "<leader>s`", "S`", { desc = "Surround with ``" })

      -- Function and tag shortcuts
      keymap("v", "<leader>sf", "Sf", { desc = "Surround with function()" })
      keymap("v", "<leader>st", "St", { desc = "Surround with tag" })
      keymap("v", "<leader>sc", "Sc", { desc = "Surround with code block" })
      keymap("v", "<leader>s/", "S/", { desc = "Surround with comment" })

      -- Surround menu (using vim.ui.select for consistency with your config)
      keymap("v", "<leader>sm", function()
        vim.ui.select(
          {
            "() - Parentheses",
            "{} - Braces",
            "[] - Brackets",
            "<> - Angle Brackets",
            '"" - Double Quotes',
            "'' - Single Quotes",
            "`` - Backticks",
            "f - Function",
            "t - HTML Tag",
            "c - Code Block",
            "/ - Comment",
            "Cancel"
          },
          { prompt = "Surround with:" },
          function(choice)
            if not choice or choice == "Cancel" then return end

            local surround_map = {
              ["() - Parentheses"] = ")",
              ["{} - Braces"] = "}",
              ["[] - Brackets"] = "]",
              ["<> - Angle Brackets"] = ">",
              ['"" - Double Quotes'] = '"',
              ["'' - Single Quotes"] = "'",
              ["`` - Backticks"] = "`",
              ["f - Function"] = "f",
              ["t - HTML Tag"] = "t",
              ["c - Code Block"] = "c",
              ["/ - Comment"] = "/",
            }

            local key = surround_map[choice]
            if key then
              vim.cmd("normal! S" .. key)
            end
          end
        )
      end, { desc = "Surround menu" })

      -- Normal mode surround menu (for surrounding word/WORD)
      keymap("n", "<leader>sm", function()
        vim.ui.select(
          {
            "() - Parentheses",
            "{} - Braces",
            "[] - Brackets",
            "<> - Angle Brackets",
            '"" - Double Quotes',
            "'' - Single Quotes",
            "`` - Backticks",
            "f - Function",
            "t - HTML Tag",
            "c - Code Block",
            "/ - Comment",
            "Cancel"
          },
          { prompt = "Surround word with:" },
          function(choice)
            if not choice or choice == "Cancel" then return end

            local surround_map = {
              ["() - Parentheses"] = ")",
              ["{} - Braces"] = "}",
              ["[] - Brackets"] = "]",
              ["<> - Angle Brackets"] = ">",
              ['"" - Double Quotes'] = '"',
              ["'' - Single Quotes"] = "'",
              ["`` - Backticks"] = "`",
              ["f - Function"] = "f",
              ["t - HTML Tag"] = "t",
              ["c - Code Block"] = "c",
              ["/ - Comment"] = "/",
            }

            local key = surround_map[choice]
            if key then
              vim.cmd("normal! ysiw" .. key)
            end
          end
        )
      end, { desc = "Surround word menu" })
    end,
  },
  {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = true,
  },
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaRead", "SudaWrite" },
  },
}
