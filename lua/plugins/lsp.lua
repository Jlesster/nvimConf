return {
  {
    'mason-org/mason.nvim',
    opts = {
      registries = { 'github:mason-org/mason-registry' },
      providers = { 'mason.providers.registry-api', 'mason.providers.client' },
      ui = { border = 'single', width = 0.8, height = 0.9 },
    },
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = { 'DrKJeff16/wezterm-types' },
    opts = { library = { { path = 'wezterm-types', mods = { 'wezterm' } } } },
  },

  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed = {
        -- 'lua_ls',
        -- 'gopls',
        -- 'clangd',
        -- 'gradle_ls',
        -- 'jsonls',
        -- 'yamlls',
        -- 'taplo',
        -- 'bashls',
        -- 'mesonlsp',
        -- 'neocmake',
        -- 'rust_analyzer',
      },
      automatic_installation = false,
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = { 'mason-org/mason.nvim', 'mason-org/mason-lspconfig.nvim' },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      vim.diagnostic.config({
        virtual_text = { prefix = '●', spacing = 4, source = 'if_many' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.HINT] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'single', source = true, header = '', prefix = '' },
      })
      local hint_abbrevs = {
        renderer = 'rndr',
        srcrect = 'src',
        dstrect = 'dst',
        viewport_w = 'vp_w',
        viewport_h = 'vp_h',
        texture = 'tex',
        width = 'W',
        height = 'H',
        title = 'Ti',
        posX = 'X',
        posY = 'Y',
        posZ = 'Z',
        position = 'pos',
        center = 'ctr',
        radius = 'rds',
        color = 'clr',
        colour = 'clr',
        fontSize = 'fs',
        text = 'txt',
        r = 'r',
        g = 'g',
        b = 'b',
        solid = 'sol',
        emitsLight = 'lit',
        lightLevel = 'lvl',
        name = 'nm',
        transparent = 'trns',
        collidable = 'col',
        hardness = 'hrd',
        resistance = 'res',
        value = 'val',
        target = 'tgt',
        source = 'src',
        index = 'idx',
        count = 'n',
        size = 'sz',
        offset = 'off',
        enabled = 'en',
        callback = 'cb',
        buffer = 'buf',
        window = 'win',
        game = 'gm',
      }
      local function abbrev_label(label)
        if type(label) == 'string' then
          local name = label:match('^(.-):%s*$')
            or label:match('^(.-):$')
            or label:match('^(.-)%s+$')
            or label
          local abbrev = hint_abbrevs[name]
          if abbrev then
            return label:match(':') and (abbrev .. ':') or abbrev
          end
          return label
        elseif type(label) == 'table' then
          for _, part in ipairs(label) do
            if part.value then
              local name = part.value:match('^(.-):%s*$')
                or part.value:match('^(.-):$')
                or part.value:match('^(.-)%s+$')
                or part.value
              local abbrev = hint_abbrevs[name]
              if abbrev then
                part.value = part.value:match(':') and (abbrev .. ':') or abbrev
              end
            end
          end
          return label
        end
        return label
      end
      local _orig = vim.lsp.handlers['textDocument/inlayHint']
      vim.lsp.handlers['textDocument/inlayHint'] = function(
        err,
        result,
        ctx,
        config
      )
        if result then
          local by_line, filtered = {}, {}
          for _, hint in ipairs(result) do
            local line = hint.position.line
            by_line[line] = (by_line[line] or 0) + 1
            hint.label = abbrev_label(hint.label)
            if by_line[line] <= 5 then
              filtered[#filtered + 1] = hint
            end
          end
          result = filtered
        end
        _orig(err, result, ctx, config)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          if
            client and client:supports_method('textDocument/documentHighlight')
          then
            local hl =
              vim.api.nvim_create_augroup('UserLspHL_' .. buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = buf,
              group = hl,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd('CursorMoved', {
              buffer = buf,
              group = hl,
              callback = vim.lsp.buf.clear_references,
            })
          end

          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end

          if client and client.name == 'rust-analyzer' then
            local function map(lhs, cmd, desc)
              vim.keymap.set(
                'n',
                lhs,
                cmd,
                { buffer = buf, silent = true, desc = desc }
              )
            end
            map('<leader>rc', function()
              vim.cmd.edit('Cargo.toml')
            end, 'Open Cargo.toml')
            map('<leader>rf', function()
              vim.cmd('!cargo clippy')
            end, 'Cargo clippy')
          end
        end,
      })

      local function gradle_ls_cmd()
        local s = vim.fn.stdpath('data')
          .. '/mason/packages/gradle-language-server/gradle-language-server/bin/gradle-language-server'
        return vim.fn.executable(s) == 1 and { s }
          or { 'gradle-language-server' }
      end

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
        on_new_config = function(config, root_dir)
          local home = vim.env.HOME
          local cfgs = {
            [home .. '/.config/hypr'] = home .. '/.config/lua_ls/hypr.json',
            [home .. '/.config/nvim'] = home .. '/.config/lua_ls/nvim.json',
          }
          for dir, cfg in pairs(cfgs) do
            if root_dir == dir or root_dir:sub(1, #dir + 1) == dir .. '/' then
              config.cmd = { 'lua-language-server', '--configpath', cfg }
              return
            end
          end
        end,
        settings = {
          Lua = {
            diagnostics = { globals = { 'Snacks', 'vim' } },
            workspace = {
              checkThirdParty = false,
              maxPreload = 1000,
              preloadFileSize = 150,
            },
            hint = {
              enable = true,
              setType = true,
              paramType = false,
              paramName = 'Disable',
              semicolon = 'Disable',
              arrayIndex = 'Disable',
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config('qml-language-server', {
        cmd = { 'qml-language-server' },
        filetypes = { 'qml' },
        root_markers = { '.git', { 'shell.qml', 'qmldir' } },
      })

      vim.lsp.config('nil_ls', {
        cmd = { 'nil' },
        filetypes = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
        settings = {
          ['nil'] = {
            formatting = { command = { 'nixfmt' } },
          },
        },
      })

      local nixd_hint_timers = {}

      local function debounce_nixd_inlay_hint(bufnr)
        local timer = nixd_hint_timers[bufnr]
        if timer then
          timer:stop()
        else
          timer = vim.uv.new_timer()
          nixd_hint_timers[bufnr] = timer
        end

        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

        timer:start(
          300,
          0,
          vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end)
        )
      end

      vim.lsp.config('nixd', {
        cmd = { 'nixd' },
        filetypes = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
        settings = {
          nixd = {
            nixpkgs = {
              expr = 'import (builtins.getFlake "/home/jless/.flake").inputs.nixpkgs { }',
            },
            formatting = {
              command = { 'nixfmt' },
            },
            options = {
              nixos = {
                expr = '(builtins.getFlake "/home/jless/.flake").nixosConfigurations.jless.options',
              },
              ['home-manager'] = {
                expr = '(builtins.getFlake "/home/jless/.flake").nixosConfigurations.jless.options.home-manager.users.type.getSubOptions []',
              },
            },
          },
        },
        on_attach = function(client, bufnr)
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })

          vim.api.nvim_create_autocmd(
            { 'TextChanged', 'TextChangedI', 'InsertLeave' },
            {
              buffer = bufnr,
              callback = function()
                debounce_nixd_inlay_hint(bufnr)
              end,
            }
          )

          vim.api.nvim_create_autocmd('BufDelete', {
            buffer = bufnr,
            once = true,
            callback = function()
              local timer = nixd_hint_timers[bufnr]
              if timer then
                timer:stop()
                timer:close()
                nixd_hint_timers[bufnr] = nil
              end
            end,
          })

          debounce_nixd_inlay_hint(bufnr)
        end,
      })

      vim.lsp.config('gopls', {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              constantValues = true,
              rangeVariableTypes = true,
            },
            codelenses = {
              generate = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
            },
          },
        },
      })

      vim.lsp.config('clangd', {
        capabilities = capabilities,
        cmd = {
          'clangd',
          '--background-index',
          '--background-index-priority=low',
          '--experimental-modules-support',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--header-insertion-decorators',
          '--completion-style=detailed',
          '--fallback-style=llvm',
          '--compile-commands-dir=builddir-linux',
          '--pch-storage=memory',
          '--offset-encoding=utf-16',
          '--rename-file-limit=0',
          '--function-arg-placeholders=0',
          '--all-scopes-completion',
          '--limit-results=0',
          '--limit-references=0',
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      vim.lsp.config('kmp_lsp', {
        capabilities = capabilities,
        cmd = { 'kmp-lsp' },
        filetypes = { 'kotlin' },
        root_markers = {
          'build.gradle',
          'build.gradle.kts',
          'settings.gradle',
          'settings.gradle.kts',
          '.git',
        },
      })

      vim.lsp.config('gradle_ls', {
        capabilities = capabilities,
        cmd = gradle_ls_cmd(),
        filetypes = { 'groovy', 'kotlin' },
        root_markers = {
          'gradlew',
          'gradlew.bat',
          'build.gradle',
          'build.gradle.kts',
          'settings.gradle',
          'settings.gradle.kts',
        },
        init_options = {
          settings = {
            gradleHome = vim.env.GRADLE_HOME or '',
            gradleVersion = vim.env.GRADLE_VERSION or '',
            gradleJavaHome = vim.env.JAVA_HOME or '',
            gradleUserHome = vim.fn.expand('~/.gradle'),
            wrapperEnabled = true,
          },
        },
      })

      vim.lsp.config('jsonls', {
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })
      vim.lsp.config('yamlls', {
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = { enable = false, url = '' },
            schemas = require('schemastore').yaml.schemas(),
            validate = true,
            hover = true,
            completion = true,
          },
        },
      })
      vim.lsp.config('taplo', {
        capabilities = capabilities,
        settings = {
          evenBetterToml = {
            schema = { enabled = true },
            formatter = {
              arrayTrailingComma = true,
              arrayAutoExpand = true,
              arrayAutoCollapse = true,
              compactArrays = true,
              columnWidth = 80,
              trailingNewline = true,
              reorderKeys = false,
            },
          },
        },
      })
      vim.lsp.config('bashls', {
        capabilities = capabilities,
        filetypes = { 'sh', 'bash', 'zsh' },
        settings = {
          bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command|.zsh)',
            includeAllWorkspaceSymbols = true,
            shellcheckArguments = '--shell=bash',
          },
        },
      })
      vim.lsp.config('mesonlsp', {
        capabilities = capabilities,
        root_markers = { 'meson.build', 'meson_options.txt', '.git' },
        settings = {
          mesonlsp = {
            others = {
              inlayHints = true,
              linting = true,
            },
          },
        },
      })
      vim.lsp.config('neocmake', {
        capabilities = capabilities,
        root_markers = { 'CMakeLists.txt', 'CMakePresets.json', '.git' },
        init_options = { buildDirectory = 'build', semanticTokens = true },
        settings = { neocmake = { inlayHints = { enable = true } } },
      })
      vim.lsp.config('gdscript', {
        cmd = { 'nc', 'localhost', '6005' },
        filetypes = { 'gdscript', 'gd' },
        root_markers = { 'project.godot' },
      })

      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
              buildScripts = { enable = true },
              targetDir = true,
            },
            semanticHighlighting = {
              operator = { enable = true },
              punctuation = { enable = true },
            },
            checkOnSave = true,
            check = {
              command = 'clippy',
              extraArgs = {
                '--',
                '-W',
                'clippy::all',
                '-A',
                'clippy::module_name_repetitions',
                '-A',
                'clippy::missing_errors_doc',
                '-A',
                'clippy::missing_panics_doc',
                '-A',
                'clippy::must_use_candidate',
              },
            },
            procMacro = { enable = true },
            assist = { emitMustUse = true, expressionFillDefault = 'todo' },
            diagnostics = {
              enable = true,
              experimental = { enable = false },
              stylistic = false,
              disabled = { 'unlinked-file' },
            },
            hover = {
              actions = {
                enable = true,
                implementations = { enable = true },
                references = { enable = true },
                run = { enable = true },
                debug = { enable = false },
              },
              memoryLayout = {
                enable = true,
                size = 'both',
                alignment = 'both',
                niches = true,
              },
            },
            imports = { granularity = { group = 'crate' }, prefix = 'self' },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = false },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = 'never' },
              lifetimeElisionHints = { enable = 'skip_trivial' },
              parameterHints = { enable = false },
              typeHints = { enable = true },
              closureParameterHints = { enable = false },
              discriminantHints = { enable = 'fieldless' },
              implicitDrops = { enable = true },
            },
          },
        },
      })

      vim.lsp.enable({
        'nixd',
        'nil_ls',
        'lua_ls',
        'kmp_lsp',
        'gdscript',
        'gopls',
        'clangd',
        'gradle_ls',
        'jsonls',
        'yamlls',
        'taplo',
        'bashls',
        'mesonlsp',
        'dcm',
        'neocmake',
        'qml-language-server',
        'rust_analyzer',
      })
    end,
  },

  { 'mfussenegger/nvim-jdtls', ft = 'java' },
  { 'b0o/schemastore.nvim', lazy = true },

  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
  },

  {
    'lewis6991/hover.nvim',
    lazy = false,
    config = function()
      require('hover').setup({
        providers = {
          'linus.providers.main',
          'hover.providers.lsp',
          'hover.providers.diagnostic',
          'hover.providers.dap',
          'hover.providers.fold_preview',
          'hover.providers.man',
        },
        preview_opts = { border = 'single', stylize_markdown = true },
        preview_window = false,
        title = true,
        mouse_providers = { 'LSP' },
        mouse_delay = 1000,
      })
    end,
  },

  {
    dir = '~/Code/lua/Linus.nvim',
    dependencies = { 'lewis6991/hover.nvim' },
    ft = { 'java', 'go', 'c', 'cpp' },
    config = function()
      require('linus').setup({ max_width = 120, max_height = 60, debug = false })
    end,
  },
}
