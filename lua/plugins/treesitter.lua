-- Treesitter configuration
local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,  -- CRITICAL: Must NOT be lazy-loaded
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
  },
  config = function()
    -- Setup nvim-treesitter with custom install directory
    require('nvim-treesitter').setup({
      install_dir = vim.fn.stdpath('data') .. '/site',
    })

    -- Install parsers for all your languages
    -- This runs asynchronously, so it won't block startup
    require('nvim-treesitter').install({
      -- Core languages
      'java',
      'lua',
      'vim',
      'vimdoc',
      'query',

      -- Web development
      'javascript',
      'typescript',
      'tsx',
      'html',
      'css',
      'json',
      'yaml',

      -- Systems programming
      'c',
      'cpp',
      'rust',
      'zig',
      'go',

      -- Scripting
      'python',
      'bash',
      'fish',

      -- Markup/Config
      'markdown',
      'markdown_inline',
      'toml',
      'xml',

      -- Other
      'regex',
      'comment',
    })

    -- =========================================================================
    -- HIGHLIGHTING
    -- =========================================================================
    -- Enable treesitter highlighting for all installed languages
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'vim', 'python', 'javascript', 'typescript', 'tsx',
        'html', 'css', 'json', 'yaml', 'bash', 'fish', 'markdown',
        'c', 'cpp', 'rust', 'zig', 'go', 'toml', 'xml',
      },
      callback = function()
        vim.treesitter.start()
      end,
    })

    -- =========================================================================
    -- FOLDING
    -- =========================================================================
    -- Enable treesitter-based folding
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'python', 'javascript', 'typescript',
        'c', 'cpp', 'rust', 'go',
      },
      callback = function()
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
        vim.wo[0][0].foldenable = false  -- Don't fold by default
        vim.wo[0][0].foldlevel = 99      -- Open all folds by default
      end,
    })

    -- =========================================================================
    -- INDENTATION (Experimental)
    -- =========================================================================
    -- Enable treesitter-based indentation
    -- Note: This is experimental and may not work perfectly for all languages
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'lua', 'python', 'javascript', 'typescript',
        'html', 'css', 'json', 'yaml',
      },
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- =========================================================================
    -- TEXTOBJECTS (requires nvim-treesitter-textobjects)
    -- =========================================================================
    -- Enhanced text objects for functions, classes, etc.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'python', 'javascript', 'typescript',
        'c', 'cpp', 'rust', 'go',
      },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Select function outer
        vim.keymap.set({'x', 'o'}, 'af', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@function.outer', 'textobjects')
        end, { buffer = bufnr, desc = 'Select around function' })

        -- Select function inner
        vim.keymap.set({'x', 'o'}, 'if', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@function.inner', 'textobjects')
        end, { buffer = bufnr, desc = 'Select inside function' })

        -- Select class outer
        vim.keymap.set({'x', 'o'}, 'ac', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@class.outer', 'textobjects')
        end, { buffer = bufnr, desc = 'Select around class' })

        -- Select class inner
        vim.keymap.set({'x', 'o'}, 'ic', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@class.inner', 'textobjects')
        end, { buffer = bufnr, desc = 'Select inside class' })

        -- Select parameter/argument
        vim.keymap.set({'x', 'o'}, 'ia', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@parameter.inner', 'textobjects')
        end, { buffer = bufnr, desc = 'Select inside parameter' })

        -- Select conditional
        vim.keymap.set({'x', 'o'}, 'ii', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@conditional.inner', 'textobjects')
        end, { buffer = bufnr, desc = 'Select inside conditional' })

        -- Select loop
        vim.keymap.set({'x', 'o'}, 'il', function()
          require('nvim-treesitter.textobjects.select').select_textobject('@loop.inner', 'textobjects')
        end, { buffer = bufnr, desc = 'Select inside loop' })
      end,
    })

    -- =========================================================================
    -- NAVIGATION (Jump to next/previous function, class, etc.)
    -- =========================================================================
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'python', 'javascript', 'typescript',
        'c', 'cpp', 'rust', 'go',
      },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Jump to next function
        vim.keymap.set('n', ']f', function()
          require('nvim-treesitter.textobjects.move').goto_next_start('@function.outer')
        end, { buffer = bufnr, desc = 'Next function start' })

        -- Jump to previous function
        vim.keymap.set('n', '[f', function()
          require('nvim-treesitter.textobjects.move').goto_previous_start('@function.outer')
        end, { buffer = bufnr, desc = 'Previous function start' })

        -- Jump to next class
        vim.keymap.set('n', ']c', function()
          require('nvim-treesitter.textobjects.move').goto_next_start('@class.outer')
        end, { buffer = bufnr, desc = 'Next class start' })

        -- Jump to previous class
        vim.keymap.set('n', '[c', function()
          require('nvim-treesitter.textobjects.move').goto_previous_start('@class.outer')
        end, { buffer = bufnr, desc = 'Previous class start' })

        -- Jump to next parameter
        vim.keymap.set('n', ']a', function()
          require('nvim-treesitter.textobjects.move').goto_next_start('@parameter.inner')
        end, { buffer = bufnr, desc = 'Next parameter' })

        -- Jump to previous parameter
        vim.keymap.set('n', '[a', function()
          require('nvim-treesitter.textobjects.move').goto_previous_start('@parameter.inner')
        end, { buffer = bufnr, desc = 'Previous parameter' })
      end,
    })

    -- =========================================================================
    -- SWAP (Swap function parameters, etc.)
    -- =========================================================================
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'python', 'javascript', 'typescript',
        'c', 'cpp', 'rust', 'go',
      },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Swap parameter with next
        vim.keymap.set('n', '<leader>sa', function()
          require('nvim-treesitter.textobjects.swap').swap_next('@parameter.inner')
        end, { buffer = bufnr, desc = 'Swap parameter with next' })

        -- Swap parameter with previous
        vim.keymap.set('n', '<leader>sA', function()
          require('nvim-treesitter.textobjects.swap').swap_previous('@parameter.inner')
        end, { buffer = bufnr, desc = 'Swap parameter with previous' })

        -- Swap function with next
        vim.keymap.set('n', '<leader>sf', function()
          require('nvim-treesitter.textobjects.swap').swap_next('@function.outer')
        end, { buffer = bufnr, desc = 'Swap function with next' })

        -- Swap function with previous
        vim.keymap.set('n', '<leader>sF', function()
          require('nvim-treesitter.textobjects.swap').swap_previous('@function.outer')
        end, { buffer = bufnr, desc = 'Swap function with previous' })
      end,
    })

    -- =========================================================================
    -- INCREMENTAL SELECTION
    -- =========================================================================
    -- Incrementally select larger syntax regions
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'java', 'lua', 'python', 'javascript', 'typescript',
        'c', 'cpp', 'rust', 'go', 'html', 'css',
      },
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Init selection
        vim.keymap.set('n', '<C-space>', function()
          require('nvim-treesitter.incremental_selection').init_selection()
        end, { buffer = bufnr, desc = 'Init selection' })

        -- Increment selection
        vim.keymap.set('x', '<C-space>', function()
          require('nvim-treesitter.incremental_selection').node_incremental()
        end, { buffer = bufnr, desc = 'Increment selection' })

        -- Decrement selection
        vim.keymap.set('x', '<BS>', function()
          require('nvim-treesitter.incremental_selection').node_decremental()
        end, { buffer = bufnr, desc = 'Decrement selection' })

        -- Scope incremental
        vim.keymap.set('x', '<C-S-space>', function()
          require('nvim-treesitter.incremental_selection').scope_incremental()
        end, { buffer = bufnr, desc = 'Increment to scope' })
      end,
    })

    -- =========================================================================
    -- CONTEXT (Show context at top of screen)
    -- =========================================================================
    -- Setup nvim-treesitter-context
    local context_ok, context = pcall(require, 'treesitter-context')
    if context_ok then
      context.setup({
        enable = true,
        max_lines = 3,            -- How many lines the window should span
        min_window_height = 20,   -- Minimum editor window height to enable context
        line_numbers = true,
        multiline_threshold = 1,  -- Maximum number of lines to show for a single context
        trim_scope = 'outer',     -- Which context lines to discard if max_lines is exceeded
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        separator = nil,          -- Separator between context and content
        zindex = 20,              -- The Z-index of the context window
      })

      -- Keybinding to jump to context
      vim.keymap.set('n', '[t', function()
        context.go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Jump to context' })
    end

    -- =========================================================================
    -- UTILITIES
    -- =========================================================================
    -- Show current node under cursor (useful for debugging queries)
    vim.keymap.set('n', '<leader>ti', ':Inspect<CR>', { desc = 'Inspect treesitter node' })
    vim.keymap.set('n', '<leader>tt', ':InspectTree<CR>', { desc = 'Show treesitter tree' })

    -- Toggle treesitter highlighting
    vim.keymap.set('n', '<leader>th', function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.treesitter.highlighter.active[bufnr] then
        vim.treesitter.stop(bufnr)
        vim.notify('Treesitter highlighting disabled', vim.log.levels.INFO)
      else
        vim.treesitter.start(bufnr)
        vim.notify('Treesitter highlighting enabled', vim.log.levels.INFO)
      end
    end, { desc = 'Toggle treesitter highlighting' })
  end,
}

-- Optional plugins
return {
  M,

  -- Context plugin
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 20,
      line_numbers = true,
      multiline_threshold = 1,
      trim_scope = 'outer',
      mode = 'cursor',
    },
  },

  -- Textobjects plugin
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
