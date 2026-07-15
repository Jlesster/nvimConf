return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      formatters = {
        clang_format = {
          prepend_args = function(_, ctx)
            if ctx.filename:match('%.hpp$') then
              return { '--assume-filename=.cpp' }
            end
            return {}
          end,
        },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        hpp = { 'clang_format' },
        java = { 'clang_format' },
        rust = { 'rustfmt' },
        go = { 'gofumpt' },
        nix = { 'nixfmt' },
        qml = { 'qmlformat' },
        meson = { 'meson' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        sh = { 'beautysh' },
        bash = { 'beautysh' },
        zsh = { 'beautysh' },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].buftype ~= '' then
          return
        end
        return { timeout_ms = 500, lsp_format = 'never' }
      end,
    },
  },
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = { 'neovim/nvim-lspconfig', 'L3MON4D3/LuaSnip' },
    opts = {
      keymap = {
        preset = 'none',
        ['<C-Space>'] = { 'show', 'fallback' },
        ['<S-CR>'] = {
          function(cmp)
            cmp.accept({
              callback = function()
                vim.schedule(function()
                  local line = vim.api.nvim_get_current_line()
                  if
                    line:match('private:')
                    or line:match('public:')
                    or line:match('protected:')
                  then
                    vim.cmd('normal! ==')
                    vim.cmd('startinsert!')
                  end
                end)
              end,
            })
            return true
          end,
          'fallback',
        },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        list = { selection = { preselect = true } },
        menu = { border = 'single' },
        documentation = { auto_show = true, window = { border = 'single' } },
        ghost_text = { enabled = true },
      },
      snippets = {
        preset = 'luasnip',
        expand = function(snippet)
          require('luasnip').lsp_expand(snippet)
        end,
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      cmdline = {
        keymap = {
          ['<Tab>'] = {
            'show_and_insert_or_accept_single',
            'select_next',
            'fallback',
          },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
          ['<C-e>'] = { 'cancel', 'fallback' },
          ['<S-CR>'] = { 'accept', 'fallback' },
          ['<C-Space>'] = { 'show', 'fallback' },
        },
        completion = { menu = { auto_show = true } },
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == '/' or t == '?' then
            return { 'buffer' }
          end
          if t == ':' then
            return { 'cmdline', 'path' }
          end
          return {}
        end,
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
  },
}
