return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    dependencies = { 'HiPhish/rainbow-delimiters.nvim' },
    config = function()
      local highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      }

      local hooks = require('ibl.hooks')

      require('ibl').setup({
        indent = {
          char = '›',
        },
        scope = {
          enabled = true,
          char = '│',
          highlight = highlight,
        },
      })

      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark
      )
    end,
  },
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
    opts = {
      pattern = '*',
      insert_mode = true,
      floating = false,
      disabled_filetypes = { 'neo-tree', 'terminal', 'toggleterm', 'Neotree' },
    },
  },
  {
    'nvim-mini/mini.files',
    version = false,
    lazy = false,
    opts = {
      content = {
        filter = (function()
          local cache_dir
          local cache = {}
          return function(entry)
            if vim.startswith(entry.name, '.') then
              return false
            end
            local parent = vim.fn.fnamemodify(entry.path, ':h')
            if parent ~= cache_dir then
              cache_dir = parent
              cache = {}
              local ok, entries = pcall(vim.fn.readdir, parent)
              if ok and #entries > 0 then
                local cmd = { 'git', '-C', parent, 'check-ignore' }
                for _, name in ipairs(entries) do
                  cmd[#cmd + 1] = name
                end
                local result = vim.fn.systemlist(cmd)
                if vim.v.shell_error == 0 then
                  for _, name in ipairs(result) do
                    cache[name] = true
                  end
                end
              end
            end
            return not cache[entry.name]
          end
        end)(),
      },
      mappings = {
        close = 'q',
        go_in = '',
        go_in_plus = 'l',
        go_out = 'h',
        go_out_plus = 'H',
        mark_goto = "'",
        mark_set = 'm',
        reset = '<BS>',
        reveal_cwd = '@',
        show_help = 'g?',
        synchronize = '<S-CR>',
        trim_left = '<',
        trim_right = '>',
      },
      options = {
        use_as_default_explorer = false,
        permanent_delete = false,
      },
      windows = {
        preview = true,
        max_number = 3,
        width_focus = 20,
        width_nofocus = 20,
        width_preview = 40,
      },
    },
    config = function(_, opts)
      local mf = require('mini.files')
      mf.setup(opts)

      local show_hidden = false

      local function toggle_hidden()
        show_hidden = not show_hidden
        if show_hidden then
          mf.refresh({
            content = {
              filter = function()
                return true
              end,
            },
          })
        else
          local state = mf.get_explorer_state()
          local dir
          if state then
            local cur_win = vim.api.nvim_get_current_win()
            for _, win in ipairs(state.windows) do
              if win.win_id == cur_win then
                dir = win.path
                break
              end
            end
            if not dir then
              dir = state.branch[state.depth_focus]
            end
          end
          local ignored
          if dir and vim.uv.fs_stat(dir) then
            local entries = vim.fn.readdir(dir)
            if #entries > 0 then
              local cmd = { 'git', '-C', dir, 'check-ignore' }
              for _, name in ipairs(entries) do
                cmd[#cmd + 1] = name
              end
              local result = vim.fn.systemlist(cmd)
              if vim.v.shell_error == 0 then
                ignored = {}
                for _, name in ipairs(result) do
                  ignored[name] = true
                end
              end
            end
          end

          mf.refresh({
            content = {
              filter = function(entry)
                if vim.startswith(entry.name, '.') then
                  return false
                end
                if ignored and ignored[entry.name] then
                  return false
                end
                return true
              end,
            },
          })
        end
      end

      local function open_here()
        local path = vim.api.nvim_buf_get_name(0)
        if path == '' or not vim.uv.fs_stat(path) then
          path = vim.uv.cwd()
        end
        mf.open(path, true)
      end

      local function open_cwd()
        mf.open(vim.uv.cwd(), true)
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(ev)
          local buf = ev.data.buf_id
          local map = function(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = desc })
          end

          -- hidden toggle
          map('zh', toggle_hidden, 'Toggle hidden files')

          -- open file in various ways, only on files (dirs handled by go_in = l)
          local function open_file(method)
            local entry = mf.get_fs_entry()
            if entry and entry.fs_type == 'file' then
              local path = entry.path
              mf.close()
              vim.schedule(function()
                vim.cmd((method or 'edit') .. ' ' .. vim.fn.fnameescape(path))
              end)
            end
          end

          map('<CR>', function()
            open_file('edit')
          end, 'Open file and close')
          map('s', function()
            open_file('split')
          end, 'Open in split')
          map('v', function()
            open_file('vsplit')
          end, 'Open in vsplit')
          map('t', function()
            open_file('tabedit')
          end, 'Open in tab')
        end,
      })

      vim.keymap.set('n', '-', open_here, { desc = 'mini.files: open at file' })
      vim.keymap.set(
        'n',
        '<leader>e',
        open_here,
        { desc = 'mini.files: open at file' }
      )
      vim.keymap.set(
        'n',
        '<leader>E',
        open_cwd,
        { desc = 'mini.files: open at cwd' }
      )
    end,
  },

  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>fR',
        function()
          require('grug-far').open({ transient = true })
        end,
        desc = 'Search & replace (grug)',
      },
      {
        '<leader>fR',
        function()
          require('grug-far').open({
            transient = true,
            prefills = { search = vim.fn.expand('<cword>') },
          })
        end,
        mode = 'v',
        desc = 'Search & replace word (grug)',
      },
    },
    opts = {
      headerMaxWidth = 80,
      startInInsertMode = false,
      resultsSeparatorLineChar = '─',
      spinnerStates = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      attach_to_untracked = true,
      current_line_blame = false,
      preview_config = { border = 'rounded' },
      on_attach = function(buf)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, 'Next hunk')
        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, 'Prev hunk')
        map('n', '<leader>ghs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>ghr', gs.reset_hunk, 'Reset hunk')
        map('v', '<leader>ghs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage hunk (range)')
        map('v', '<leader>ghr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset hunk (range)')
        map('n', '<leader>ghS', gs.stage_buffer, 'Stage buffer')
        map('n', '<leader>ghR', gs.reset_buffer, 'Reset buffer')
        map('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo stage hunk')
        map('n', '<leader>ghp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>ghb', function()
          gs.blame_line({ full = true })
        end, 'Blame line')
        map(
          'n',
          '<leader>gtb',
          gs.toggle_current_line_blame,
          'Toggle line blame'
        )
        map('n', '<leader>ghd', gs.diffthis, 'Diff this')
        map('n', '<leader>ghD', function()
          gs.diffthis('~')
        end, 'Diff this ~')
        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
      end,
    },
  },

  {
    'folke/todo-comments.nvim',
    event = 'BufReadPost',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      keywords = { ... },
      highlight = {
        before = '',
        keyword = 'bg',
        after = 'fg',
        pattern = [[.*<(KEYWORDS)\s*:]], -- colon-only, leaves [TODO] alone visually
        comments_only = true,
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]], -- default; \b already matches inside [TODO] for search/jump
      },
    },
    keys = {
      {
        ']T',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next todo',
      },
      {
        '[T',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Prev todo',
      },
      {
        '<leader>st',
        '<cmd>TodoTelescope<cr>',
        desc = 'Search todos',
      },
      {
        '<leader>sT',
        '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>',
        desc = 'Search TODO/FIX',
      },
    },
  },

  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({
        surrounds = {
          ['f'] = {
            add = function()
              local r =
                require('nvim-surround.config').get_input('Function name: ')
              if r then
                return { { r .. '(' }, { ')' } }
              end
            end,
            find = '[%w_]+%b()',
            delete = '^([%w_]+%()().-(%))()$',
            change = {
              target = '^([%w_]+%()().-(%))()$',
              replacement = function()
                local r =
                  require('nvim-surround.config').get_input('Function name: ')
                if r then
                  return { { r .. '(' }, { ')' } }
                end
              end,
            },
          },
          ['c'] = {
            add = function()
              local lang = require('nvim-surround.config').get_input(
                'Language (optional): '
              )
              if lang == '' then
                lang = nil
              end
              return { { '```' .. (lang or ''), '' }, { '', '```' } }
            end,
          },
          ['t'] = {
            add = function()
              local tag =
                require('nvim-surround.config').get_input('Tag name: ')
              if tag then
                return { { '<' .. tag .. '>' }, { '</' .. tag .. '>' } }
              end
            end,
            find = '<[^>]+>.-</.->',
            delete = '^(<[^>]+>)().-(</[^>]+>)()$',
            change = {
              target = '^<([^>]+)().-</([^>]+)()$',
              replacement = function()
                local tag =
                  require('nvim-surround.config').get_input('Tag name: ')
                if tag then
                  return { { '<' .. tag .. '>' }, { '</' .. tag .. '>' } }
                end
              end,
            },
          },
          ['T'] = { add = { '{ ', ' }' } },
          ['m'] = { add = { '$', '$' } },
          ['M'] = { add = { '$$', '$$' } },
          ['/'] = {
            add = function()
              local cs = vim.bo.commentstring
              if cs == '' then
                cs = '# %s'
              end
              local left, right = cs:match('^(.*)%%s(.*)$')
              if not left then
                left, right = cs, ''
              end
              return { { left }, { right } }
            end,
          },
        },
        aliases = {
          ['a'] = '>',
          ['b'] = ')',
          ['B'] = '}',
          ['r'] = ']',
          ['q'] = { '"', "'", '`' },
          ['s'] = { '}', ']', ')', '>', "'", '"', '`' },
        },
        move_cursor = 'begin',
        indent_lines = function()
          return vim.bo.buftype == ''
        end,
        highlight = { duration = 200 },
      })
      local map = vim.keymap.set
      map({ 'n', 'v' }, 'ys', '<Plug>(nvim-surround-normal)')
      map('n', 'yss', '<Plug>(nvim-surround-normal-cur)')
      map('n', 'yS', '<Plug>(nvim-surround-normal-line)')
      map('n', 'ySS', '<Plug>(nvim-surround-normal-cur-line)')
      map('i', '<C-g>s', '<Plug>(nvim-surround-insert)')
      map('i', '<C-g>S', '<Plug>(nvim-surround-insert-line)')
      map('v', 'S', '<Plug>(nvim-surround-visual)')
      map('v', 'gS', '<Plug>(nvim-surround-visual-line)')
      map('n', 'ds', '<Plug>(nvim-surround-delete)')
      map('n', 'cs', '<Plug>(nvim-surround-change)')
      map('n', 'cS', '<Plug>(nvim-surround-change-line)')
    end,
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },

  {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufReadPost',
    opts = {
      render = 'background',
      virtual_symbol = '■',
      enable_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_ansi = true,
      enable_xterm256 = true,
      enable_xtermTrueColor = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup({
        preset = 'classic',
        delay = 300,
        icons = { mappings = false },
        win = { border = 'rounded' },
      })
      wk.add({
        { '<leader>b', group = '[B]uffers' },
        { '<leader>d', group = '[D]uplicate' },
        { '<leader>e', group = '[E]xplorer' },
        { '<leader>f', group = '[F]iles / Format' },
        { '<leader>F', group = '[F]lutter' },
        { '<leader>g', group = '[G]it' },
        { '<leader>gh', group = '[G]it [H]unks' },
        { '<leader>gt', group = '[G]it [T]oggle' },
        { '<leader>l', group = '[L]SP' },
        { '<leader>lt', group = '[L]SP [T]oggle' },
        { '<leader>lw', group = '[L]SP [W]orkspace' },
        { '<leader>m', group = '[M]arvin' },
        { '<leader>M', group = '[M]aven' },
        { '<leader>q', group = '[Q]uit' },
        { '<leader>r', group = '[R]oot' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]erminal / Toggle' },
        { '<leader>u', group = '[U]I / Notifications' },
        { '<leader>w', group = '[W]indow' },
        { '<leader>x', group = '[X] Diagnostics' },
        { '<leader>y', group = '[Y]azi' },
      })
    end,
  },

  {
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    config = function()
      local ss = require('smart-splits')
      ss.setup({
        multiplexer_integration = 'tmux',
        default_amount = 3,
        at_edge = 'wrap',
      })
      vim.keymap.set('n', '<C-h>', ss.move_cursor_left)
      vim.keymap.set('n', '<C-j>', ss.move_cursor_down)
      vim.keymap.set('n', '<C-k>', ss.move_cursor_up)
      vim.keymap.set('n', '<C-l>', ss.move_cursor_right)
      vim.keymap.set('n', '<A-h>', ss.resize_left)
      vim.keymap.set('n', '<A-j>', ss.resize_down)
      vim.keymap.set('n', '<A-k>', ss.resize_up)
      vim.keymap.set('n', '<A-l>', ss.resize_right)
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = { 'markdown', 'markdown_inline', 'html' },
    opts = {
      buf_filter = function(buf)
        local ft = vim.bo[buf].filetype
        return ft == 'markdown' or ft == 'markdown_inline'
      end,
      enabled = true,
      file_types = { 'markdown', 'markdown_inline', 'html' },
      render_modes = { 'n', 'c', 'r' },
      anti_conceal = { enabled = false, above = 0, below = 0 },
      heading = {
        enabled = true,
        sign = false,
        position = 'overlay',
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        width = 'full',
        border = false,
        above = '▄',
        below = '▀',
        backgrounds = {
          'RenderMarkdownH1Bg',
          'RenderMarkdownH2Bg',
          'RenderMarkdownH3Bg',
          'RenderMarkdownH4Bg',
          'RenderMarkdownH5Bg',
          'RenderMarkdownH6Bg',
        },
        foregrounds = {
          'RenderMarkdownH1',
          'RenderMarkdownH2',
          'RenderMarkdownH3',
          'RenderMarkdownH4',
          'RenderMarkdownH5',
          'RenderMarkdownH6',
        },
      },
      code = {
        enabled = true,
        sign = false,
        style = 'full',
        position = 'left',
        language_pad = 1,
        width = 'full',
        left_pad = 1,
        right_pad = 1,
        border = 'thin',
        above = '▄',
        below = '▀',
        highlight = 'RenderMarkdownCode',
        highlight_inline = 'RenderMarkdownCodeInline',
      },
      bullet = {
        enabled = true,
        icons = { '●', '○', '◆', '◇' },
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
        position = 'inline',
        unchecked = { icon = '󰄱', highlight = 'RenderMarkdownUnchecked' },
        checked = { icon = '󰱒', highlight = 'RenderMarkdownChecked' },
        custom = {
          todo = {
            raw = '[-]',
            rendered = '󰥔',
            highlight = 'RenderMarkdownTodo',
          },
        },
      },
      pipe_table = {
        enabled = true,
        style = 'full',
        cell = 'padded',
        border = {
          '┌',
          '┬',
          '┐',
          '├',
          '┼',
          '┤',
          '└',
          '┴',
          '┘',
          '│',
          '─',
        },
        alignment_indicator = '━',
        head = 'RenderMarkdownTableHead',
        row = 'RenderMarkdownTableRow',
        filler = 'RenderMarkdownTableFill',
      },
      sign = { enabled = false },
      indent = { enabled = false },
      win_options = {
        conceallevel = { default = vim.o.conceallevel, rendered = 3 },
        concealcursor = { default = vim.o.concealcursor, rendered = '' },
      },
    },
  },

  {
    'mikavilpas/yazi.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>y', '<cmd>Yazi<cr>', desc = 'Yazi (cwd)' },
      { '<leader>Y', '<cmd>Yazi cwd<cr>', desc = 'Yazi (project root)' },
    },
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.85,
      yazi_floating_window_border = 'rounded',
    },
  },
}
