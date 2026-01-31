-- Dev core
-- Plugins that are just there.

--    Sections:
--       ## TREE SITTER
--       -> nvim-treesitter                [syntax highlight]
--       -> render-markdown.nvim           [normal mode markdown]
--       -> checkmate.nvim                 [markdown toggle checks]
--       -> nvim-highlight-colors          [hex colors]

--       ## LSP
--       -> nvim-java                      [java support]
--       -> nvim-lspconfig                 [lsp default configs]
--       -> mason-lspconfig                [auto start lsp clients]
--       -> mason.nvim                     [lsp package manager]
--       -> none-ls                        [lsp server for formatters/linters]
--       -> none-ls-autoload.nvim          [auto start none-ls clients]
--       -> garbage-day                    [lsp garbage collector]
--       -> lazydev                        [lua lsp for nvim plugins]

--       ## AUTO COMPLETION
--       -> nvim-cmp                       [auto completion engine]
--       -> cmp-nvim-buffer                [auto completion buffer]
--       -> cmp-nvim-path                  [auto completion path]
--       -> cmp-nvim-lsp                   [auto completion lsp]
--       -> cmp-luasnip                    [auto completion snippets]

local utils = require("base.utils")

return {
  --  TREE SITTER ---------------------------------------------------------
  --  [syntax highlight]
  --  https://github.com/nvim-treesitter/nvim-treesitter
  --  https://github.com/windwp/nvim-treesitter-textobjects
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    event = "User BaseDefered",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    build = ":TSUpdate",
    opts = {
      auto_install = false, -- Currently bugged. Use [:TSInstall all] and [:TSUpdate all]

      highlight = {
        enable = true,
        disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      matchup = {
        enable = true,
        enable_quotes = true,
        disable = function(_, bufnr) return utils.is_big_file(bufnr) end,
      },
      incremental_selection = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["ik"] = { query = "@block.inner", desc = "inside block" },
            ["ac"] = { query = "@class.outer", desc = "around class" },
            ["ic"] = { query = "@class.inner", desc = "inside class" },
            ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
            ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
            ["af"] = { query = "@function.outer", desc = "around function " },
            ["if"] = { query = "@function.inner", desc = "inside function " },
            ["al"] = { query = "@loop.outer", desc = "around loop" },
            ["il"] = { query = "@loop.inner", desc = "inside loop" },
            ["aa"] = { query = "@parameter.outer", desc = "around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },
          },
          goto_next_end = {
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next parameter end" },
          },
          goto_previous_start = {
            ["[k"] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous parameter start" },
          },
          goto_previous_end = {
            ["[K"] = { query = "@block.outer", desc = "Previous block end" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous parameter end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [">K"] = { query = "@block.outer", desc = "Swap next block" },
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">A"] = { query = "@parameter.inner", desc = "Swap next parameter" },
          },
          swap_previous = {
            ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
            ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
            ["<A"] = { query = "@parameter.inner", desc = "Swap previous parameter" },
          },
        },
      },
    },
    config = function(_, opts)
      -- calling setup() here is necessary to enable conceal and some features.
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  --  render-markdown.nvim [normal mode markdown]
  --  https://github.com/MeanderingProgrammer/render-markdown.nvim
  --  While on normal mode, markdown files will display highlights.
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown" },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      heading = {
        sign = false,
        icons = require("base.utils").get_icon("RenderMarkdown"),
        width = "block",
      },
      code = {
        sign = false,
        width = 'block', -- use 'language' if colorcolumn is important for you.
        right_pad = 1,
      },
      dash = {
        width = 79
      },
      pipe_table = {
        style = 'full', -- use 'normal' if colorcolumn is important for you.
      },
    },
  },

  --  checkmate.nvim [markdown toogle checks]
  --  https://github.com/bngarren/checkmate.nvim
  {
    'bngarren/checkmate.nvim',
    event = "User BaseDefered", -- Note: This plugin do not support 'BufEnter'
    opts = {
      files = { "*.md" },
      keys = { -- TODO: Move to the keymappings file.
        ["g-"] = {
          rhs = "<cmd>Checkmate toggle<CR>",
          desc = "Markdown - Toggle check",
          modes = { "n", "v" },
        },
        ["g*"] = {
          rhs = "<cmd>Checkmate create<CR>",
          desc = "Markdown - Add new check",
          modes = { "n", "v" },
        },
      },
    },
  },

  --  [hex colors]
  --  https://github.com/brenoprata10/nvim-highlight-colors
  {
    "brenoprata10/nvim-highlight-colors",
    event = "User BaseFile",
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

  --  LSP -------------------------------------------------------------------

  -- nvim-java [java support]
  -- https://github.com/nvim-java/nvim-java
  -- Reliable jdtls support. Must go before lsp-config and mason-lspconfig.
{
  "nvim-java/nvim-java",
  ft = { "java" },
  dependencies = {
    "nvim-java/lua-async-await",
    "nvim-java/nvim-java-core",
    "nvim-java/nvim-java-test",
    "nvim-java/nvim-java-dap",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-jdtls",
  },
  config = function()
    require('java').setup({
      spring_boot_tools = {
        enable = false,
      },
      jdk = {
        auto_install = true,
      },
      java_home = vim.fn.expand('~/.sdkman/candidates/java/current'),
      notifications = {
        dap = false,
      },
      root_markers = {
        'settings.gradle',
        'settings.gradle.kts',
        'pom.xml',
        'build.gradle',
        'mvnw',
        'gradlew',
        'build.gradle.kts',
        '.git',
      },
      verification = {
        invalid_order = false,
        duplicate_setup_calls = false,
      },
    })

    -- NOW setup lspconfig with all your settings
    local jdtls_setup = {
      handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = "rounded",
        }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = "rounded",
        }),
      },
      settings = {
        java = {
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
            updateSnapshots = true,
          },
          implementationCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          format = {
            enabled = true,
            settings = {
              url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
              profile = "GoogleStyle",
            },
          },
          signatureHelp = {
            enabled = true,
            description = {
              enabled = true,
            },
          },
          contentProvider = { preferred = 'fernflower' },
          sources = {
            organizeImports = {
              starThreshold = 1,
              staticStarThreshold = 1,
            },
          },
          completion = {
            favoriteStaticMembers = {
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.lwjgl.glfw.GLFW.*",
              "org.lwjgl.opengl.GL11.*",
              "org.lwjgl.opengl.GL20.*",
              "org.lwjgl.opengl.GL30.*",
              "org.lwjgl.opengl.GL33.*",
              "org.lwjgl.opengl.GL45.*",
              "org.lwjgl.vulkan.VK10.*",
              "org.lwjgl.system.MemoryUtil.*",
              "org.lwjgl.system.MemoryStack.*",
              "imgui.ImGui.*",
              "imgui.flag.ImGuiWindowFlags.*",
              "imgui.flag.ImGuiCol.*",
              "imgui.type.ImBoolean.*",
              "imgui.type.ImInt.*",
              "imgui.type.ImFloat.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "sun.*",
              "jdk.*",
            },
            importOrder = {
              "java",
              "javax",
              "org.lwjgl",
              "imgui",
              "org",
              "com",
            },
          },
          configuration = {
            detectJdksAtStart = true,
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = vim.fn.expand("~/.sdkman/candidates/java/8.0.432-tem"),
                default = false,
              },
              {
                name = "JavaSE-11",
                path = vim.fn.expand("~/.sdkman/candidates/java/11.0.25-tem"),
                default = false,
              },
              {
                name = "JavaSE-17",
                path = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-tem"),
                default = false,
              },
              {
                name = "JavaSE-21",
                path = vim.fn.expand("~/.sdkman/candidates/java/21.0.5-tem"),
                default = true,
              },
            },
            updateBuildConfiguration = "automatic",
          },
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
          referenceCodeLens = {
            enabled = true,
          },
          saveActions = {
            organizeImports = true,
          },
          server = {
            launchMode = "Standard",
          },
          autobuild = {
            enabled = true,
          },
          project = {
            referencedLibraries = {
              "lib/**/*.jar",
              "${env:HOME}/.m2/repository/org/lwjgl/**/*.jar",
              "${env:HOME}/.m2/repository/io/github/spair/**/*.jar",
              "libs/joml/**/*.jar",
            },
          },
          templates = {
            fileHeader = {
              "/**",
              " * ${file_name}",
              " *",
              " * @author ${user}",
              " * @date ${date}",
              " */",
            },
            typeComment = {},
          },
          trace = {
            server = "off",
          },
          import = {
            gradle = {
              enabled = true,
              wrapper = {
                enabled = true,
              },
              version = nil,
              home = nil,
              java = {
                home = nil,
              },
              offline = {
                enabled = false,
              },
              arguments = nil,
              jvmArguments = nil,
              user = {
                home = nil,
              },
            },
            maven = {
              enabled = true,
              downloadSources = true,
              updateSnapshots = true,
            },
            exclusions = {
              "**/node_modules/**",
              "**/.metadata/**",
              "**/archetype-resources/**",
              "**/META-INF/maven/**",
            },
          },
          lombok = {
            enabled = false,
          },
        },
      },
      init_options = {
        extendedClientCapabilities = {
          progressReportProvider = true,
          classFileContentsSupport = true,
          generateToStringPromptSupport = true,
          hashCodeEqualsPromptSupport = true,
          advancedExtractRefactoringSupport = true,
          advancedOrganizeImportsSupport = true,
          generateConstructorsPromptSupport = true,
          generateDelegateMethodsPromptSupport = true,
          resolveAdditionalTextEditsSupport = true,
          moveRefactoringSupport = true,
          overrideMethodsPromptSupport = true,
          inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
        },
      },
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      flags = {
        debounce_text_changes = 150,
        allow_incremental_sync = true,
      },
    }

    require('lspconfig').jdtls.setup(jdtls_setup)
  end
},
  --  nvim-lspconfig [lsp default configs]
  --  https://github.com/neovim/nvim-lspconfig
  --  This plugin is just a dependency for other plugins.
  --  It provides default configs for the lsp servers available on mason.
  {
    "neovim/nvim-lspconfig",
    event = "User BaseFile",
    dependencies = "nvim-java/nvim-java",
  },

  -- mason-lspconfig [auto start lsp clients]
  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- This plugin auto start the lsp clients installed by Mason.
-- In your 3-dev-core.lua, update the mason-lspconfig config:

{
  "mason-org/mason-lspconfig.nvim",
  dependencies = { "neovim/nvim-lspconfig", "nvim-java/nvim-java", "mfussenegger/nvim-jdtls" },
  event = "User BaseFile",
  config = function()
    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          if server_name == "jdtls" then
            return
          end
          require("lspconfig")[server_name].setup({})
        end,
      },
    })

    require("base.utils").apply_lsp_diagnostic_defaults()

    local utils = require("base.utils")
    if utils.diagnostics_enum and utils.diagnostics_enum[vim.g.diagnostics_mode] then
      local config = vim.tbl_deep_extend("force",
        utils.diagnostics_enum[vim.g.diagnostics_mode],
        {
          virtual_text = {
            prefix = '◆',
            wrap = true,
          },
        }
      )
      vim.diagnostic.config(config)
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client and client.name then
          -- Apply standard LSP mappings
          require("base.utils").apply_user_lsp_mappings(client.name, bufnr)

          -- Apply Java-specific mappings directly here
          if client.name == "jdtls" then
            vim.api.nvim_buf_call(bufnr, function()
              vim.opt_local.virtualedit = ""
            end)
            local has_jdtls, jdtls = pcall(require, 'jdtls')
            if not has_jdtls then
              Snacks.notify("nvim-jdtls not avaliable", vim.log.levels.WARN)
              return
            end

            local opts = { buffer = bufnr, silent = true }

            -- Organize imports
            vim.keymap.set('n', '<leader>jo', function()
              require('jdtls').organize_imports()
            end, vim.tbl_extend('force', opts, { desc = "Organize imports" }))

            -- Extract variable
            vim.keymap.set('n', '<leader>jv', function()
              require('jdtls').extract_variable()
            end, vim.tbl_extend('force', opts, { desc = "Extract variable" }))

            vim.keymap.set('x', '<leader>jv', function()
              require('jdtls').extract_variable(true)
            end, vim.tbl_extend('force', opts, { desc = "Extract variable" }))

            -- Extract constant
            vim.keymap.set('n', '<leader>jc', function()
              require('jdtls').extract_constant()
            end, vim.tbl_extend('force', opts, { desc = "Extract constant" }))

            vim.keymap.set('x', '<leader>jc', function()
              require('jdtls').extract_constant(true)
            end, vim.tbl_extend('force', opts, { desc = "Extract constant" }))

            -- Extract method
            vim.keymap.set('x', '<leader>jm', function()
              require('jdtls').extract_method(true)
            end, vim.tbl_extend('force', opts, { desc = "Extract method" }))

            -- Update project config
            vim.keymap.set('n', '<leader>ju', function()
              require('jdtls').update_project_config()
            end, vim.tbl_extend('force', opts, { desc = "Update project config" }))

            -- JShell
            vim.keymap.set('n', '<leader>js', function()
              require('jdtls').jshell()
            end, vim.tbl_extend('force', opts, { desc = "Open JShell" }))

            -- Test nearest method
            vim.keymap.set('n', '<leader>jt', function()
              require('jdtls').test_nearest_method()
            end, vim.tbl_extend('force', opts, { desc = "Test nearest method" }))

            -- Test class
            vim.keymap.set('n', '<leader>jT', function()
              require('jdtls').test_class()
            end, vim.tbl_extend('force', opts, { desc = "Test class" }))

          end
        end
      end,
    })
  end,
},

  --  mason [lsp package manager]
  --  https://github.com/mason-org/mason.nvim
  --  https://github.com/zeioth/mason-extra-cmds
  {
    "mason-org/mason.nvim",
    dependencies = { "zeioth/mason-extra-cmds", opts = {} },
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
      "MasonUpdateAll", -- this cmd is provided by mason-extra-cmds
    },
    opts = {
      registries = {
        "github:nvim-java/mason-registry",
        "github:mason-org/mason-registry",
      },
      ui = {
        icons = {
          package_installed = require("base.utils").get_icon("MasonInstalled"),
          package_uninstalled = require("base.utils").get_icon("MasonUninstalled"),
          package_pending = require("base.utils").get_icon("MasonPending"),
        },
      },
    }
  },

  -- none-ls-autoload.nvim [auto start none-ls clients]
  -- https://github.com/zeioth/mason-none-ls.nvim
  -- This plugin auto start the none-ls clients installed by Mason.
  {
    "zeioth/none-ls-autoload.nvim",
    event = "User BaseFile",
    dependencies = {
      "mason-org/mason.nvim",
      "zeioth/none-ls-external-sources.nvim"
    },
    opts = {
      -- Here you can add support for sources not oficially suppored by none-ls.
      external_sources = {
        -- diagnostics
        'none-ls-external-sources.diagnostics.cpplint',
        'none-ls-external-sources.diagnostics.eslint',
        'none-ls-external-sources.diagnostics.eslint_d',
        'none-ls-external-sources.diagnostics.flake8',
        'none-ls-external-sources.diagnostics.luacheck',
        'none-ls-external-sources.diagnostics.psalm',
        'none-ls-external-sources.diagnostics.yamllint',

        -- formatting
        'none-ls-external-sources.formatting.autopep8',
        'none-ls-external-sources.formatting.beautysh',
        'none-ls-external-sources.formatting.easy-coding-standard',
        'none-ls-external-sources.formatting.eslint',
        'none-ls-external-sources.formatting.eslint_d',
        'none-ls-external-sources.formatting.jq',
        'none-ls-external-sources.formatting.latexindent',
        'none-ls-external-sources.formatting.reformat_gherkin',
        'none-ls-external-sources.formatting.rustfmt',
        'none-ls-external-sources.formatting.standardrb',
        'none-ls-external-sources.formatting.yq',
      },
    },
  },

  -- none-ls [lsp server for formatters/linters]
  -- https://github.com/nvimtools/none-ls.nvim
  -- None-ls is a special lsp server capable of running formatters, and linters.
  {
    "nvimtools/none-ls.nvim",
    event = "User BaseFile",
    opts = function()
      local builtin_sources = require("null-ls").builtins

      -- You can customize your 'builtin sources' and 'external sources' here.
      builtin_sources.formatting.shfmt.with({
        command = "shfmt",
        args = { "-i", "2", "-filename", "$FILENAME" },
      })
    end
  },

  --  garbage-day.nvim [lsp garbage collector]
  --  https://github.com/zeioth/garbage-day.nvim
  {
    "zeioth/garbage-day.nvim",
    event = "User BaseFile",
    opts = {
      aggressive_mode = false,
      excluded_lsp_clients = {
        "null-ls", "jdtls", "marksman", "lua_ls"
      },
      grace_period = (60 * 15),
      wakeup_delay = 3000,
      notifications = false,
      retries = 3,
      timeout = 1000,
    }
  },

  --  lazy.nvim [lua lsp for nvim plugins]
  --  https://github.com/folke/lazydev.nvim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = function(_, opts)
      opts.library = {
        -- Any plugin you wanna have LSP autocompletion for, add it here.
        -- in 'path', write the name of the plugin directory.
        -- in 'mods', write the word you use to require the module.
        -- in 'words' write words that trigger loading a lazydev path (optionally).
        { path = "lazy.nvim", mods = { "lazy" } },
        { path = "yazi.nvim", mods = { "yazi" } },
        { path = "project.nvim", mods = { "project_nvim", "telescope" } },
        { path = "trim.nvim", mods = { "trim" } },
        { path = "stickybuf.nvim", mods = { "stickybuf" } },
        { path = "mini.bufremove", mods = { "mini.bufremove" } },
        { path = "smart-splits.nvim", mods = { "smart-splits" } },
        { path = "toggleterm.nvim", mods = { "toggleterm" } },
        { path = "neovim-session-manager.nvim", mods = { "session_manager" } },
        { path = "nvim-spectre", mods = { "spectre" } },
        { path = "neo-tree.nvim", mods = { "neo-tree" } },
        { path = "nui.nvim", mods = { "nui" } },
        { path = "nvim-ufo", mods = { "ufo" } },
        { path = "promise-async", mods = { "promise-async" } },
        { path = "nvim-neoclip.lua", mods = { "neoclip", "telescope" } },
        { path = "zen-mode.nvim", mods = { "zen-mode" } },
        { path = "vim-suda", mods = { "suda" } }, -- has vimscript
        { path = "vim-matchup", mods = { "matchup", "match-up", "treesitter-matchup" } }, -- has vimscript
        { path = "hop.nvim", mods = { "hop", "hop-treesitter", "hop-yank" } },
        { path = "nvim-autopairs", mods = { "nvim-autopairs" } },
        { path = "lsp_signature", mods = { "lsp_signature" } },
        { path = "nvim-lightbulb", mods = { "nvim-lightbulb" } },
        { path = "hot-reload.nvim", mods = { "hot-reload" } },
        { path = "distroupdate.nvim", mods = { "distroupdate" } },

        { path = "tokyonight.nvim", mods = { "tokyonight" } },
        { path = "astrotheme", mods = { "astrotheme" } },
        { path = "alpha-nvim", mods = { "alpha" } },
        { path = "heirline-components.nvim", mods = { "heirline-components" } },
        { path = "telescope.nvim", mods = { "telescope" } },
        { path = "telescope-undo.nvim", mods = { "telescope", "telescope-undo" } },
        { path = "telescope-fzf-native.nvim", mods = { "telescope", "fzf_lib"  } },
        { path = "noice.nvim", mods = { "noice", "telescope" } },
        { path = "nvim-web-devicons", mods = { "nvim-web-devicons" } },
        { path = "lspkind.nvim", mods = { "lspkind" } },
        { path = "nvim-scrollbar", mods = { "scrollbar" } },
        { path = "highlight-undo.nvim", mods = { "highlight-undo" } },
        { path = "which-key.nvim", mods = { "which-key" } },

        { path = "nvim-treesitter", mods = { "nvim-treesitter" } },
        { path = "nvim-ts-autotag", mods = { "nvim-ts-autotag" } },
        { path = "nvim-treesitter-textobjects", mods = { "nvim-treesitter", "nvim-treesitter-textobjects" } },
        { path = "markdown.nvim", mods = { "render-markdown" } },
        { path = "nvim-highlight-colors", mods = { "nvim-highlight-colors" } },
        { path = "nvim-java", mods = { "java" } },
        { path = "nvim-lspconfig", mods = { "lspconfig" } },
        { path = "mason-lspconfig.nvim", mods = { "mason-lspconfig" } },
        { path = "mason.nvim", mods = { "mason", "mason-core", "mason-registry", "mason-vendor" } },
        { path = "mason-extra-cmds", mods = { "masonextracmds" } },
        { path = "none-ls-autoload.nvim", mods = { "none-ls-autoload" } },
        { path = "none-ls.nvim", mods = { "null-ls" } },
        { path = "lazydev.nvim", mods = { "" } },
        { path = "garbage-day.nvim", mods = { "garbage-day" } },
        { path = "nvim-cmp", mods = { "cmp" } },
        { path = "cmp_luasnip", mods = { "cmp_luasnip" } },
        { path = "cmp-buffer", mods = { "cmp_buffer" } },
        { path = "cmp-path", mods = { "cmp_path" } },
        { path = "cmp-nvim-lsp", mods = { "cmp_nvim_lsp" } },

        { path = "LuaSnip", mods = { "luasnip" } },
        { path = "friendly-snippets", mods = { "snippets" } }, -- has vimscript
        { path = "NormalSnippets", mods = { "snippets" } }, -- has vimscript
        { path = "telescope-luasnip.nvim", mods = { "telescop" } },
        { path = "gitsigns.nvim", mods = { "gitsigns" } },
        { path = "vim-fugitive", mods = { "fugitive" } }, -- has vimscript
        { path = "aerial.nvim", mods = { "aerial", "telescope", "lualine", "resession" } },
        { path = "litee.nvim", mods = { "litee" } },
        { path = "litee-calltree.nvim", mods = { "litee" } },
        { path = "dooku.nvim", mods = { "dooku" } },
        { path = "markdown-preview.nvim", mods = { "mkdp" } }, -- has vimscript
        { path = "markmap.nvim", mods = { "markmap" } },
        { path = "neural", mods = { "neural" } },
        { path = "guess-indent.nvim", mods = { "guess-indent" } },
        { path = "compiler.nvim", mods = { "compiler" } },
        { path = "overseer.nvim", mods = { "overseer", "lualine", "neotest", "resession", "cmp_overseer" } },
        { path = "nvim-dap", mods = { "dap" } },
        { path = "nvim-nio", mods = { "nio" } },
        { path = "nvim-dap-ui", mods = { "dapui" } },
        { path = "cmp-dap", mods = { "cmp_dap" } },
        { path = "mason-nvim-dap.nvim", mods = { "mason-nvim-dap" } },

        { path = "one-small-step-for-vimkind", mods = { "osv" } },
        { path = "neotest-dart", mods = { "neotest-dart" } },
        { path = "neotest-dotnet", mods = { "neotest-dotnet" } },
        { path = "neotest-elixir", mods = { "neotest-elixir" } },
        { path = "neotest-golang", mods = { "neotest-golang" } },
        { path = "neotest-java", mods = { "neotest-java" } },
        { path = "neotest-jest", mods = { "neotest-jest" } },
        { path = "neotest-phpunit", mods = { "neotest-phpunit" } },
        { path = "neotest-python", mods = { "neotest-python" } },
        { path = "neotest-rust", mods = { "neotest-rust" } },
        { path = "neotest-zig", mods = { "neotest-zig" } },
        { path = "nvim-coverage.nvim", mods = { "coverage" } },
        { path = "gutentags_plus", mods = { "gutentags_plus" } }, -- has vimscript
        { path = "vim-gutentags", mods = { "vim-gutentags" } }, -- has vimscript

        -- To make it work exactly like neodev, you can add all plugins
        -- without conditions instead like this but it will load slower
        -- on startup and consume ~1 Gb RAM:
        -- vim.fn.stdpath "data" .. "/lazy",

        -- You can also add libs.
        { path = "luvit-meta/library", mods = { "vim%.uv" } },
      }
    end,
    specs = { { "Bilal2453/luvit-meta", lazy = true } },
  },

  --  AUTO COMPLETION --------------------------------------------------------
  --  Auto completion engine [autocompletion engine]
  --  https://github.com/hrsh7th/nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "saadparwaiz1/cmp_luasnip"},
      { "hrsh7th/cmp-buffer"} ,
      { "hrsh7th/cmp-path" },
      { "onsails/lspkind.nvim" },
      { "brenoprata10/nvim-highlight-colors" },
    },
    event = "InsertEnter",
    opts = function()
      -- ensure dependencies exist
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind_loaded, lspkind = pcall(require, "lspkind")

    -- Setup colorful CmpKind highlights
    local function setup_cmp_kind_highlights()
      local kind_colors = {
        Text          = "#A6E3A1",  -- Green
        Method        = "#F5C2E7",  -- Pink
        Function      = "#CBA6F7",  -- Purple/Lavender
        Constructor   = "#F9E2AF",  -- Yellow
        Field         = "#89DCEB",  -- Sky blue
        Variable      = "#F38BA8",  -- Red
        Class         = "#FAB387",  -- Peach/Orange
        Interface     = "#94E2D5",  -- Teal
        Module        = "#B4BEFE",  -- Lavender
        Property      = "#89DCEB",  -- Sky blue
        Unit          = "#A6E3A1",  -- Green
        Value         = "#FAB387",  -- Peach
        Enum          = "#F9E2AF",  -- Yellow
        Keyword       = "#F5C2E7",  -- Pink
        Snippet       = "#94E2D5",  -- Teal
        Color         = "#F38BA8",  -- Red
        File          = "#89B4FA",  -- Blue
        Reference     = "#F5C2E7",  -- Pink
        Folder        = "#89B4FA",  -- Blue
        EnumMember    = "#A6E3A1",  -- Green
        Constant      = "#FAB387",  -- Peach
        Struct        = "#CBA6F7",  -- Purple
        Event         = "#F38BA8",  -- Red
        Operator      = "#89DCEB",  -- Sky blue
        TypeParameter = "#F9E2AF",  -- Yellow
      }

      for kind, color in pairs(kind_colors) do
        vim.api.nvim_set_hl(0, "CmpKind" .. kind, { fg = color })
      end
    end

    setup_cmp_kind_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = setup_cmp_kind_highlights,
    })

      -- border opts
      local border_opts = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      }
      local cmp_config_window = (
        vim.g.lsp_round_borders_enabled and cmp.config.window.bordered(border_opts)
      ) or cmp.config.window

      -- helper

      return {
        enabled = function() -- disable in certain cases on dap.
          local is_prompt = vim.bo.buftype == "prompt"
          local is_dap_prompt = utils.is_available("cmp-dap")
              and vim.tbl_contains(
                { "dap-repl", "dapui_watches", "dapui_hover" }, vim.bo.filetype)
          if is_prompt and not is_dap_prompt then
            return false
          else
            return vim.g.cmp_enabled
          end
        end,
        window = {
          completion = {
            scrolloff = 0,
            col_offset = -3,
            side_padding = 1,
            max_height = math.floor(vim.o.lines * 9.3),
            relative = 'cursor',
            anchor = 'SW';
          },
        },
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = 'menu,menuone,noinsert,noselect',
        },
        experimental = {
          ghost_text = false,
        },
        performance = {
          debounce = 150,
          throttle = 150,
          fetching_timeout = 200,
          confirm_resolve_timeout = 80,
          async_budget = 1,
          max_view_entries = 50,
        },
        view = {
          entries = { name = 'custom', selection_order = 'near_cursor' }
        },
formatting = {
  -- Custom view is weird about columns. This is the most reliable:
  -- We show icons by injecting them into abbr.
  fields = { "abbr", "menu" },

  format = function(entry, item)
    item.menu = ({
      nvim_lsp = "[LSP]",
      luasnip  = "[Snip]",
      buffer   = "[Buf]",
      path     = "[Path]",
      lazydev  = "[Lazy]",
    })[entry.source.name]

local ok_lspkind, lspkind = pcall(require, "lspkind")
if ok_lspkind then
  local symbol = lspkind.symbolic(item.kind, { mode = "symbol" }) or ""
  if symbol ~= "" then
    item.abbr = string.format("%s %s", symbol, item.abbr)
  end
end

-- IMPORTANT: with custom view, color must be applied to abbr
if not item.abbr_hl_group then
  item.abbr_hl_group = "CmpItemKind" .. item.kind
end

    local ok_hc, hc = pcall(require, "nvim-highlight-colors")
    if ok_hc then
      local hc_item = hc.format(entry, { kind = item.kind })

      if hc_item and hc_item.abbr_hl_group then
        item.abbr_hl_group = hc_item.abbr_hl_group

        if hc_item.abbr and hc_item.abbr ~= "" then
          if not item.abbr:find(hc_item.abbr, 1, true) then
            item.abbr = string.format("%s %s", hc_item.abbr, item.abbr)
          end
        end
      end
    end

    return item
  end,
},
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        duplicates = {
          nvim_lsp = 1,
          lazydev = 1,
          luasnip = 1,
          cmp_tabnine = 1,
          buffer = 1,
          path = 1,
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp_config_window,
          documentation = cmp_config_window,
        },
        mapping = {
          ["<PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          },
          ["<PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 8,
          },
          ["<C-PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<C-PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<S-PageUp>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<S-PageDown>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
            count = 16,
          },
          ["<Up>"] = cmp.mapping.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
          },
          ["<Down>"] = cmp.mapping.select_next_item {
            behavior = cmp.SelectBehavior.Select,
          },
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ["<CR>"] = cmp.mapping.confirm { select = false },
          ["<Tab>"] = cmp.mapping(function(fallback)
            fallback()
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
        },
        sources = cmp.config.sources {
          -- Note: Priority decides the order items appear.
          { name = "nvim_lsp", priority = 1000 },
          { name = "lazydev",  priority = 850 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "nvim_highlight_colors", priority = 400 },
          { name = "path",     priority = 250 },
        },
      }
    end,
  },

}
