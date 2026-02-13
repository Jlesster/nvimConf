-- ============================================================================
-- FILE: lua/plugins/lsp.lua
-- Enhanced LSP configuration with additional plugins
-- ============================================================================

return {
  -- Mason: LSP/DAP/Linter/Formatter installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "single",
        width = 0.8,
        height = 0.8,
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
  },

  -- Java support
  -- NOTE: Java LSP configuration is handled in ftplugin/java.lua
  {
    "nvim-java/nvim-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "nvim-treesitter/nvim-treesitter", -- Ensure Treesitter loads first
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "nvim-java/nvim-java",
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- LSP keymaps (applied on attach)
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Enable semantic tokens for Java only
        if client.server_capabilities.semanticTokensProvider then
          if client.name == "jdtls" then
            vim.lsp.semantic_tokens.start(bufnr, client.id)
          end
        end

        -- Highlight symbol under cursor
        if client.server_capabilities.documentHighlightProvider then
          local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_group })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
          })
        end

        -- Navigation keymaps
        vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

        -- Documentation
        vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)

        -- Diagnostics
        vim.keymap.set("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
        vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
        vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)

        -- Jump to errors specifically
        vim.keymap.set("n", "[e", function()
          require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end, opts)
        vim.keymap.set("n", "]e", function()
          require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
        end, opts)

        -- Workspace folders
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)

        -- Toggle inlay hints
        if client.supports_method("textDocument/inlayHint") then
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, { buffer = bufnr, desc = "Toggle Inlay Hints" })
        end

        -- Java-specific keymaps
        if client.name == "jdtls" then
          vim.keymap.set("n", "<leader>jo", function()
            require('java').runner.built_in.run_app()
          end, vim.tbl_extend("force", opts, { desc = "Java: Run App" }))

          vim.keymap.set("n", "<leader>jt", function()
            require('java').test.run_current_class()
          end, vim.tbl_extend("force", opts, { desc = "Java: Test Class" }))
        end
      end

      -- Enhanced capabilities with nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- Show severity icons
          format = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN] = " ",
              [vim.diagnostic.severity.INFO] = " ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
            }
            return icons[diagnostic.severity] .. diagnostic.message
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "single",
          source = "always",
          header = "",
          prefix = "",
          focusable = false,
          -- Show code and source
          format = function(diagnostic)
            return string.format(
              "%s [%s]",
              diagnostic.message,
              diagnostic.source or diagnostic.code
            )
          end,
        },
      })

      -- Force borders on all LSP handlers
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "single"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "single" }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "single" }
      )

      -- Store config globally for mason-lspconfig to use
      _G.lsp_on_attach = on_attach
      _G.lsp_capabilities = capabilities
    end,
  },

  -- LSP Configuration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Server-specific configurations
      local server_configs = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },

        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },

        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },

        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
              checkOnSave = {
                command = "clippy",
                extraArgs = { "--all", "--", "-W", "clippy::all" },
              },
              procMacro = {
                enable = true,
              },
              inlayHints = {
                bindingModeHints = { enable = true },
                closingBraceHints = { minLines = 10 },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "skip_trivial" },
                typeHints = { enable = true },
              },
            },
          },
        },

        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
              semanticTokens = true,
            },
          },
        },

        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
          },
        },

        jsonls = {
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
              },
            },
          },
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "gopls",
          "clangd",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "tailwindcss",
          "emmet_ls",
        },
        automatic_installation = true,
        handlers = {
          -- Default handler
          function(server_name)
            -- Use pcall to safely require lspconfig
            local ok, lspconfig = pcall(require, "lspconfig")
            if not ok then
              vim.notify("lspconfig not available", vim.log.levels.ERROR)
              return
            end

            local config = {
              on_attach = _G.lsp_on_attach,
              capabilities = _G.lsp_capabilities,
            }

            if server_configs[server_name] then
              config = vim.tbl_deep_extend("force", config, server_configs[server_name])
            end

            lspconfig[server_name].setup(config)
          end,

          -- Skip jdtls (handled by ftplugin/java.lua)
          ["jdtls"] = function() end,
        },
      })
    end,
  },

  -- JSON/YAML schemas
  {
    "b0o/schemastore.nvim",
    lazy = true,
    ft = { "json", "jsonc", "yaml" },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- IMPROVED MAPPINGS
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),

          -- Better Enter behavior - don't auto-select
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false, -- Only confirm explicitly selected items
          }),

          -- Shift+Enter auto-selects first item
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          }),

          -- Super Tab with snippet jumping
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Vim-style navigation
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),

        -- SMARTER SOURCES WITH LIMITS
        sources = cmp.config.sources({
          {
            name = "nvim_lsp",
            priority = 1000,
            max_item_count = 20,
            -- Group completions by kind
            group_index = 1,
          },
          {
            name = "luasnip",
            priority = 750,
            max_item_count = 10,
            group_index = 1,
          },
          {
            name = "path",
            priority = 500,
            max_item_count = 10,
            group_index = 2,
          },
        }, {
          {
            name = "buffer",
            priority = 250,
            keyword_length = 3,
            max_item_count = 5,
            group_index = 3,
            -- Search all visible buffers
            option = {
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end
            }
          },
        }),

        -- ENHANCED FORMATTING
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            show_labelDetails = true,

            before = function(entry, vim_item)
              -- Customize menu
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                buffer = "[Buf]",
                path = "[Path]",
              })[entry.source.name]

              return vim_item
            end,
          }),
        },

        window = {
          completion = cmp.config.window.bordered({
            border = "single",
            winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "single",
            winhighlight = "Normal:CmpDoc",
          }),
        },

        -- PERFORMANCE SETTINGS
        performance = {
          debounce = 60,
          throttle = 30,
          fetching_timeout = 500,
          max_view_entries = 30,
        },

        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },

        -- SORTING - prioritize closer matches
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })

      vim.api.nvim_create_autocmd("CompleteDone", {
        group = vim.api.nvim_create_augroup("CmpAutoImport", { clear = true }),
        callback = function()
          local completed_item = vim.v.completed_item
          if completed_item and completed_item.user_data then
            local lsp_item = completed_item.user_data.nvim and
                completed_item.user_data.nvim.lsp and
                completed_item.user_data.nvim.lsp.completion_item
            if lsp_item and lsp_item.additionalTextEdits then
              local client = vim.lsp.get_active_clients()[1]
              if client then
                vim.lsp.util.apply_text_edits(
                  lsp_item.additionalTextEdits,
                  vim.api.nvim_get_current_buf(),
                  client.offset_encoding or "utf-16"
                )
              end
            end
          end
        end,
      })

      -- Cmdline setup
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
  },

  -- LSP UI enhancements
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "single",
          title = true,
          winblend = 0,
          expand = "",
          collapse = "",
          code_action = "",
          incoming = " ",
          outgoing = " ",
          hover = " ",
          kind = {},
        },
        hover = {
          max_width = 0.6,
          max_height = 0.8,
          open_link = "gx",
        },
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          max_width = 0.7,
          max_height = 0.6,
          text_hl_follow = false,
          border_follow = true,
          keys = {
            exec_action = "o",
            quit = "q",
            expand_or_jump = "<CR>",
            quit_in_show = { "q", "<ESC>" },
          },
        },
        code_action = {
          num_shortcut = true,
          show_server_name = false,
          extend_gitsigns = true,
          only_in_cursor = true,
          keys = {
            quit = { "q", "<ESC>" },
            exec = "<CR>",
          },
        },
        lightbulb = {
          enable = false,
        },
        beacon = {
          enable = true,
          frequency = 7,
        },
        scroll_preview = {
          scroll_down = "<C-f>",
          scroll_up = "<C-b>",
        },
        request_timeout = 2000,
        finder = {
          max_height = 0.5,
          keys = {
            jump_to = "p",
            expand_or_jump = "o",
            vsplit = "s",
            split = "i",
            tabe = "t",
            quit = { "q", "<ESC>" },
          },
        },
        symbol_in_winbar = {
          enable = false,
          separator = " › ",
          hide_keyword = true,
          show_file = true,
          folder_level = 2,
          color_mode = true,
        },
        rename = {
          quit = "<C-c>",
          exec = "<CR>",
          in_select = true,
        },
        outline = {
          win_position = "right",
          win_width = 30,
          preview_width = 0.4,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          keys = {
            expand_or_jump = "o",
            quit = "q",
          },
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- LSP progress notifications
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
          border = "single",
        },
      },
      progress = {
        display = {
          done_icon = "✓",
        },
      },
    },
  },

  -- Function signatures
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      handler_opts = {
        border = "single",
      },
      hint_enable = true, -- Enable parameter hints
      hint_prefix = "󰊕 ",
      hint_scheme = "Comment",
      floating_window_above_cur_line = true,
      toggle_key = "<C-k>",
      select_signature_key = "<C-n>",
      move_cursor_key = "<C-p>",
      auto_close_after = 5, -- Auto close after 5 seconds
      max_height = 12,
      max_width = 80,
      transparency = 10,
    },
  },

  -- Breadcrumbs (will be shown in lualine)
  {
    "SmiteshP/nvim-navic",
    event = "LspAttach",
    opts = {
      separator = " > ",
      highlight = true,
      depth_limit = 5,
      lazy_update_context = true,
    },
    config = function(_, opts)
      require("nvim-navic").setup(opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, args.buf)
          end
        end,
      })
    end,
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = {
        border = "single",
        show_title = true,
        win_height = 15,
      },
    },
  },

  -- ============================================================================
  -- Conform.nvim Configuration with clang-format
  -- ============================================================================

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        -- Use clang-format for C-family and Java
        c = { "clang-format" },
        cpp = { "clang-format" },
        java = { "clang-format" },

        -- clang-format also supports these (optional)
        javascript = { "clang-format" },
        typescript = { "clang-format" },

        -- Keep other formatters as-is
        lua = { "stylua" },
        python = { "isort", "black" },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettier" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },

        -- If you want the old {{ }} behavior for JavaScript/TypeScript:
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      },

      format_on_save = function(bufnr)
        -- Disable for these filetypes
        local ignore_filetypes = { "sql", "markdown" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return
        end

        -- Disable if file is too large (> 100KB)
        local max_filesize = 100 * 1024
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max_filesize then
          return
        end

        return {
          timeout_ms = 1000,
          lsp_fallback = true,
        }
      end,

      -- Custom formatter configurations
      formatters = {
        -- Configure clang-format to use your .clang-format file
        ["clang-format"] = {
          command = "clang-format",
          args = {
            -- Will automatically find .clang-format in current dir or parent dirs
            -- Or specify explicitly: "--style=file:/path/to/.clang-format"
            "--style=file",
            "--assume-filename", "$FILENAME",
          },
          stdin = true,
        },

        -- Keep your other formatter configs
        black = {
          prepend_args = { "--fast", "--line-length", "100" },
        },
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python = { "pylint" },
        go = { "golangcilint" },
        markdown = { "markdownlint" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Tool installer for formatters/linters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "prettier",
        "prettierd",
        "black",
        "clang-format",
        "isort",
        "gofmt",
        "goimports",
        "rustfmt",
        "eslint_d",
        "pylint",
        "golangcilint",
        "markdownlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}
