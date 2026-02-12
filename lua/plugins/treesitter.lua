return {
  'nvim-treesitter/nvim-treesitter',
  event = { "BufReadPost", "BufNewFile" }, -- Lazy load for better startup
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
  },
  config = function()
    require('nvim-treesitter.config').setup({
      -- Only install what you actually use
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "javascript", "typescript", "tsx", "html", "css", "json",
        "python", "bash", "markdown", "markdown_inline",
        "java", "go", "rust", "c", "cpp",
      },

      -- Performance optimizations
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- CRITICAL for performance
        disable = function(lang, buf)
          local max_filesize = 1024 * 1024         -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },

      -- Disable features you don't need
      indent = { enable = false }, -- Often buggy, LSP handles formatting
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          node_decremental = "<BS>",
        },
      },

      -- Keep only essential text objects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })

    -- Context with minimal overhead
    local context_ok, context = pcall(require, 'treesitter-context')
    if context_ok then
      context.setup({
        enable = true,
        max_lines = 3,
        min_window_height = 20,
        trim_scope = 'outer',
        mode = 'cursor',
      })
    end
  end,
}
