-- lua/plugins/lsp.lua
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

        -- Set keybindings
        local keymap = vim.keymap.set

        keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        keymap("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
        keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
        keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
        keymap("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
        keymap("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Type definition" }))
        keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
        keymap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

        -- Diagnostic keymaps
        keymap("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
        keymap("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
        keymap("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
        keymap("n", "<leader>q", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostic list" }))

        -- Enable inlay hints if available
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          keymap("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
        end

        -- Enable semantic tokens if available
        if client.server_capabilities.semanticTokensProvider then
          vim.lsp.semantic_tokens.start(bufnr, client.id)
        end

        -- Highlight symbol under cursor
        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = bufnr,
            group = "lsp_document_highlight",
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = "lsp_document_highlight",
            callback = vim.lsp.buf.clear_references,
          })
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
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Hover window border
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

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
          "rust_analyzer",
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

            -- Merge with server-specific config if it exists
            if server_configs[server_name] then
              config = vim.tbl_deep_extend("force", config, server_configs[server_name])
            end

            lspconfig[server_name].setup(config)
          end,

          -- Skip jdtls (handled by ftplugin)
          ["jdtls"] = function()
            -- No-op, handled by nvim-jdtls in ftplugin/java.lua
          end,
        },
      })
    end,
  },

  -- JSON/YAML schemas (optional enhancement)
  {
    "b0o/schemastore.nvim",
    lazy = true,
    ft = { "json", "jsonc", "yaml" },
    config = function()
      -- Update jsonls and yamlls with schemastore if they're already running
      local lspconfig = require("lspconfig")
      local has_schemastore, schemastore = pcall(require, "schemastore")

      if has_schemastore then
        -- Update jsonls
        if lspconfig.jsonls then
          lspconfig.jsonls.setup({
            settings = {
              json = {
                schemas = schemastore.json.schemas(),
                validate = { enable = true },
              },
            },
          })
        end

        -- Update yamlls
        if lspconfig.yamlls then
          lspconfig.yamlls.setup({
            settings = {
              yaml = {
                schemaStore = {
                  enable = false,
                  url = "",
                },
                schemas = schemastore.yaml.schemas(),
              },
            },
          })
        end
      end
    end,
  },

  -- Java LSP (jdtls)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- jdtls setup is typically done in ftplugin/java.lua
      -- See the companion ftplugin file for full configuration
    end,
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

      -- Load VSCode-style snippets
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
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
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer", keyword_length = 3 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              return vim_item
            end,
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = {
          ghost_text = true,
        },
      })

      -- `/` cmdline setup
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- `:` cmdline setup
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
    opts = {
      ui = {
        border = "rounded",
        code_action = "",
      },
      lightbulb = {
        enable = false,
      },
      symbol_in_winbar = {
        enable = true,
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Show function signature as you type
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      bind = true,
      handler_opts = {
        border = "rounded",
      },
      hint_prefix = "󰏪 ",
    },
  },
}
