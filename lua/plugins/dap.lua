return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Continue',
      },
      {
        '<S-F5>',
        function()
          require('dap').terminate()
        end,
        desc = 'Debug: Stop',
      },
      {
        '<F9>',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle breakpoint',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step over',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step into',
      },
      {
        '<S-F11>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step out',
      },
      {
        '<leader>Db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle breakpoint',
      },
      {
        '<leader>DB',
        function()
          require('dap').set_breakpoint(
            require('dap.repl').input('Condition: ')
          )
        end,
        desc = 'Conditional breakpoint',
      },
      {
        '<leader>Dc',
        function()
          require('dap').continue()
        end,
        desc = 'Continue / start',
      },
      {
        '<leader>Dq',
        function()
          require('dap').terminate()
        end,
        desc = 'Stop',
      },
      {
        '<leader>Dr',
        function()
          require('dap').restart()
        end,
        desc = 'Restart',
      },
      {
        '<leader>Do',
        function()
          require('dap').step_over()
        end,
        desc = 'Step over',
      },
      {
        '<leader>Di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step into',
      },
      {
        '<leader>DO',
        function()
          require('dap').step_out()
        end,
        desc = 'Step out',
      },
      {
        '<leader>Dl',
        function()
          require('dap').run_last()
        end,
        desc = 'Run last',
      },
      {
        '<leader>Dp',
        function()
          require('dapui').eval(nil, { enter = true })
        end,
        mode = { 'n', 'v' },
        desc = 'Preview / eval',
      },
      {
        '<leader>Dw',
        function()
          require('dapui').elements.watches.add(
            require('dap.repl').input('Watch: ')
          )
        end,
        desc = 'Add watch',
      },
      {
        '<leader>Du',
        function()
          require('dapui').toggle()
        end,
        desc = 'Toggle UI',
      },
      {
        '<leader>DR',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dankula = require('dankula')
      local p = dankula.colors

      -- ── mason-nvim-dap: auto-install codelldb (C/C++/Rust) + delve (Go) ──
      require('mason-nvim-dap').setup({
        ensure_installed = { 'codelldb', 'delve' },
        automatic_installation = true,
        handlers = {}, -- use default handler for everything
      })

      -- ── dap-ui ──────────────────────────────────────────────────────────
      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.35 },
              { id = 'breakpoints', size = 0.15 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
            position = 'left',
            size = 45,
          },
          {
            elements = {
              { id = 'repl', size = 0.6 },
              { id = 'console', size = 0.4 },
            },
            position = 'bottom',
            size = 12,
          },
        },
        floating = { border = 'single' },
      })

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      require('nvim-dap-virtual-text').setup({
        commented = true,
        virt_text_pos = 'eol',
      })

      -- ── signs ───────────────────────────────────────────────────────────
      vim.fn.sign_define(
        'DapBreakpoint',
        { text = '●', texthl = 'DiagnosticError', linehl = '', numhl = '' }
      )
      vim.fn.sign_define(
        'DapBreakpointCondition',
        { text = '◆', texthl = 'DiagnosticWarn', linehl = '', numhl = '' }
      )
      vim.fn.sign_define(
        'DapLogPoint',
        { text = '◆', texthl = 'DiagnosticInfo', linehl = '', numhl = '' }
      )
      vim.fn.sign_define('DapStopped', {
        text = '▶',
        texthl = 'DiagnosticOk',
        linehl = 'CursorLine',
        numhl = 'DiagnosticOk',
      })
      vim.fn.sign_define(
        'DapBreakpointRejected',
        { text = '○', texthl = 'DiagnosticHint', linehl = '', numhl = '' }
      )

      vim.api.nvim_set_hl(0, 'DiagnosticOk', { fg = p.green })

      -- ── adapters ────────────────────────────────────────────────────────
      -- codelldb (C, C++, Rust) — installed via mason
      local mason_bin = vim.fn.stdpath('data') .. '/mason/bin/codelldb'
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = mason_bin,
          args = { '--port', '${port}' },
        },
      }

      local function codelldb_config(label)
        return {
          name = label or 'Launch',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        }
      end

      dap.configurations.cpp = { codelldb_config() }
      dap.configurations.c = { codelldb_config() }
      dap.configurations.rust = {
        codelldb_config('Launch (cargo build first)'),
      }

      -- Go — delve, via nvim-dap-go for the standard debug/test configs
      local ok_dapgo, dapgo = pcall(require, 'dap-go')
      if ok_dapgo then
        dapgo.setup()
      end
    end,
  },

  {
    'leoluz/nvim-dap-go',
    ft = 'go',
    opts = {},
  },
}
