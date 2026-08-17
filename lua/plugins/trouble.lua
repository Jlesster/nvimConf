return {
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    opts = {
      auto_close = false, -- stays docked; doesn't vanish when you jump
      auto_preview = true,
      focus = true,
      warn_no_results = false,
      open_no_results = true,
      win = { size = 12 },
      preview = {
        type = 'split',
        relative = 'win',
        position = 'right',
        size = 0.5,
      },
      modes = {
        diagnostics = {
          mode = 'diagnostics',
          win = { position = 'bottom', size = 12 },
        },
        symbols = {
          mode = 'lsp_document_symbols',
          focus = false,
          win = { position = 'right', size = 40 },
        },
        lsp_all = {
          mode = 'lsp',
          win = { position = 'bottom', size = 14 },
        },
      },
    },
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (workspace)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Diagnostics (buffer)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle<cr>',
        desc = 'Symbols outline',
      },
      {
        '<leader>xl',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location list',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix list',
      },
      {
        '<leader>xL',
        '<cmd>Trouble lsp_all toggle<cr>',
        desc = 'LSP references/defs (docked)',
      },
      {
        '<leader>xt',
        '<cmd>Trouble todo toggle<cr>',
        desc = 'Todos',
      },
      {
        '<leader>xT',
        '<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<cr>',
        desc = 'Todo/Fix only',
      },
      {
        ']x',
        function()
          require('trouble').next({ skip_groups = true, jump = true })
        end,
        desc = 'Next trouble item',
      },
      {
        '[x',
        function()
          require('trouble').prev({ skip_groups = true, jump = true })
        end,
        desc = 'Prev trouble item',
      },
    },
  },
}
