return {

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local themes = require('telescope.themes')

      telescope.setup({
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          entry_prefix = ' ',
          sorting_strategy = 'ascending',
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              prompt_position = 'top',
              preview_width = 0.55,
              results_width = 0.45,
            },
            width = 0.87,
            height = 0.80,
          },
          border = true,
          borderchars = {
            '─',
            '│',
            '─',
            '│',
            '╭',
            '╮',
            '╯',
            '╰',
          },
          mappings = {
            i = {
              ['<Esc>'] = actions.close,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<Tab>'] = actions.toggle_selection
                + actions.move_selection_next,
              ['<S-Tab>'] = actions.toggle_selection
                + actions.move_selection_previous,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-v>'] = actions.select_vertical,
              ['<C-t>'] = actions.select_tab,
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
            },
            n = {
              ['q'] = actions.close,
              ['<Esc>'] = actions.close,
              ['j'] = actions.move_selection_next,
              ['k'] = actions.move_selection_previous,
              ['gg'] = actions.move_to_top,
              ['G'] = actions.move_to_bottom,
              ['<CR>'] = actions.select_default,
              ['s'] = actions.select_horizontal,
              ['v'] = actions.select_vertical,
              ['t'] = actions.select_tab,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
            },
          },
          file_ignore_patterns = {
            '.git/',
            'subprojects/',
            'node_modules/',
            'dist/',
            'build/',
            'target/',
            '.next/',
            'coverage/',
            '.cache/',
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git/',
          },
        },
        pickers = {
          find_files = {
            find_command = {
              'fd',
              '--type',
              'f',
              '--hidden',
              '--follow',
              '--exclude',
              '.git',
            },
          },
          buffers = {
            sort_mru = true,
            ignore_current_buffer = false,
            mappings = {
              i = { ['<C-x>'] = actions.delete_buffer },
              n = { ['x'] = actions.delete_buffer },
            },
          },
          colorschemes = { enable_preview = true },
          lsp_references = { show_line = false, fname_width = 60 },
          lsp_definitions = { show_line = false },
          lsp_implementations = { show_line = false },
          lsp_type_definitions = { show_line = false },
          lsp_document_symbols = { symbol_width = 50 },
          lsp_workspace_symbols = { symbol_width = 50 },
          diagnostics = { bufnr = 0 },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          ['ui-select'] = {
            themes.get_dropdown(),
          },
        },
      })

      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },
}
