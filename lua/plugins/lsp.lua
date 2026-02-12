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
        border = "rounded",
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

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- LSP keymaps (applied on attach)
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Enable semantic tokens if available
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
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

        -- Diagnostics (lspsaga handles these)
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

        -- Toggle inlay hints (if you added lsp-inlayhints plugin)
        if client.supports_method("textDocument/inlayHint") then
          vim.keymap.set("n", "<leader>th", function()
            require("lsp-inlayhints").toggle()
          end, { buffer = bufnr, desc = "Toggle Inlay Hints" })
        end
      end

      -- Enhanced capabilities with nvim-cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Diagnostic signs
      local signs = {
        Error = " ",
        Warn = " ",
        Hint = "󰌵 ",
        Info = " "
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Force borders on all LSP handlers
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "rounded" }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "rounded" }
      )

      -- Store config globally for mason-lspconfig to use
      _G.lsp_on_attach = on_attach
      _G.lsp_capabilities = capabilities
    end,
  },

  -- Mason LSP Config bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require("lspconfig")

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
              },
              checkOnSave = {
                command = "clippy",
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
          on_attach = function(client, bufnr)
            if _G.lsp_on_attach then
              _G.lsp_on_attach(client, bufnr)
            end
            if client.server_capabilities.semanticTokensProvider then
              vim.lsp.semantic_tokens.start(bufnr, client.id)
            end
          end,
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
            local config = {
              on_attach = _G.lsp_on_attach,
              capabilities = _G.lsp_capabilities,
            }

            if server_configs[server_name] then
              config = vim.tbl_deep_extend("force", config, server_configs[server_name])
            end

            lspconfig[server_name].setup(config)
          end,

          -- Skip jdtls (handled by ftplugin)
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

  -- Java LSP
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
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
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<S-CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "path",     priority = 500 },
        }, {
          { name = "buffer", keyword_length = 3, priority = 250 },
        }),

        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }),
        },

        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
          }),
        },

        experimental = {
          ghost_text = true,
        },
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
          border = "rounded",
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
          enable = false, -- Disabled since we're using navic in lualine
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
          border = "rounded",
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
        border = "rounded",
      },
      hint_enable = false,
      floating_window_above_cur_line = true,
      toggle_key = "<C-k>",
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
        border = "rounded",
        show_title = true,
        win_height = 15,
      },
    },
  },

  -- Formatting
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
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        yaml = { "prettier" },
        markdown = { { "prettierd", "prettier" } },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
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
        "stylua", "prettier", "prettierd", "black", "isort",
        "gofmt", "goimports", "rustfmt",
        "eslint_d", "pylint", "golangcilint", "markdownlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}
