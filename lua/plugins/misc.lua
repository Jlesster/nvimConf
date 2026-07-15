return {
  {
    'vyfor/cord.nvim',
    build = ':Cord update',
    lazy  = false,
    opts  = {
      usercmds = true,
      timer    = { interval = 1500, reset_on_idle = false, reset_on_change = false },
      editor   = { client = 'neovim', tooltip = 'The One True Editor' },
      display  = { theme = 'minecraft', flavor = 'dark' },
      lsp      = { show_problem_count = true, severity = 1 },
      idle     = { enabled = true, show_status = true, timeout = 300000, text = 'AFK in the Nether', tooltip = 'Gone mining' },
      text = {
        viewing  = function(opts) return 'Viewing '  .. opts.filename end,
        editing  = function(opts) return 'Editing '  .. opts.filename end,
        file_browser   = 'Browsing files',
        plugin_manager = 'Managing plugins',
        lsp_manager    = 'Configuring LSP',
        vcs            = 'Committing crimes',
        workspace = function(opts) return 'In ' .. opts.workspace end,
      },
      buttons = { { label = 'Source', url = 'https://github.com/Jlesster/nvimConf' } },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    lazy  = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({ install_dir = vim.fn.stdpath('data')..'/site' })
      require('nvim-treesitter').install({
        'bash','html','javascript','json','lua','markdown','markdown_inline',
        'ron','python','query','meson','go','rust','c','cpp','java',
        'regex','toml','tsx','typescript','vim','vimdoc','yaml',
      })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'bash','html','javascript','go','ron','rust','c','cpp','java',
          'meson','json','lua','markdown','python','query','toml',
          'typescript','typescriptreact','vim','yaml',
        },
        callback = function(args) pcall(vim.treesitter.start, args.buf) end,
      })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    lazy    = false,
    cmd     = { 'ToggleTerm', 'TermExec' },
    config  = function()
      require('toggleterm').setup({
        start_in_insert = true,
        persist_mode    = true,
        persist_size    = true,
        close_on_exit   = true,
        auto_scroll     = true,
        direction       = 'float',
        float_opts      = { border = 'rounded', winblend = 0 },
      })

      local Terminal = require('toggleterm.terminal').Terminal
      local terminals_by_dir = {}

      local function current_project_dir()
        local git = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        if vim.v.shell_error == 0 and git and git ~= '' then return git end
        return vim.fn.getcwd()
      end

      local function get_project_term()
        local dir = current_project_dir()
        if not terminals_by_dir[dir] then
          terminals_by_dir[dir] = Terminal:new({ hidden=true, direction='float', dir=dir, float_opts={ border='rounded' } })
        end
        return terminals_by_dir[dir]
      end

      function _G.toggle_term() get_project_term():toggle() end

      local lazygit = Terminal:new({
        cmd = 'lazygit', hidden = true, direction = 'float',
        dir = current_project_dir(), float_opts = { border = 'rounded' },
      })
      function _G.toggle_lazygit()
        lazygit.dir = current_project_dir()
        lazygit:toggle()
      end
    end,
  },
  {
    'Jlesster/marvin',
    lazy = false,
    ft   = { 'java', 'kotlin', 'xml' },
    cmd  = { 'Maven','MavenExec','MavenClean','MavenTest','MavenPackage','MavenNew' },
    config = function()
      require('marvin').setup({
        maven_command = 'mvn',
        ui_backend    = 'toggleterm',
        terminal      = { position = 'float', size = 0.8, close_on_success = true },
        quickfix      = { auto_open = true, height = 10 },
        java          = { enable = false },
        keymaps = {
          run_goal    = '<leader>Mg', clean      = '<leader>Mc',
          test        = '<leader>Mt', package    = '<leader>Mp',
          install     = '<leader>Mi', new_project = '<leader>Mn',
          new_java    = '<leader>Mj',
        },
      })
    end,
  },
}
