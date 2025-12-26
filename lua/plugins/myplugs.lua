return {
  {
    {
      "tpope/vim-surround",
      lazy = false,
    },
    {
      "HiPhish/rainbow-delimiters.nvim",
      lazy = false,
      priority = 110,
      strategy = {
        [''] = 'rainbow-delimiters.strategy.global',
        vim = 'rainbow-delimiters.strategy.local',
      },
      query = {
      [''] = 'rainbow-delimiters',
      lua = 'rainbow-blocks',
      },
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      lazy = false,
      ---@module "ibl"
      ---@type ibl.config
      opts = {
        scope = {
          enabled = false,
          char = "•",
          highlight = "IblScope",
          show_start = true,
          show_end = false,
        },
        indent = {
          char = "•",
        },
      },
    },
    {
      'Aasim-A/scrollEOF.nvim',
      event = { 'CursorMoved', 'WinScrolled' },
      opts = {
        pattern = '~',
      },
      config = function()
        require("scrollEOF").setup()
      end,
    },
    {
      'ThePrimeagen/vim-be-good'
    },
    {
      'alessio-vivaldelli/java-creator-nvim',
      ft = 'java',
      opts = {
        -- Default configuration
        keymaps = {
          java_new = "<leader>jn",
        },
        options = {
          auto_open = true,  -- Open file after creation
          java_version = 17  -- Minimum Java version
        },
        default_imports = {
          record = {"java.util.*;"}
        }
      }
    },
    {
      "eatgrass/maven.nvim",
      cmd = { "Maven", "MavenExec" },
      dependencies = "nvim-lua/plenary.nvim",
      config = function()
        local Job = require("plenary.job")

        local function get_main_class()
          local result = Job:new({
            command = "make",
            args = {'print-main-class'},
          }):sync()

          if result and result[1] then
            return vim.trim(result[1])
          else
            return nil
          end
        end

        require('maven').setup({
          executable="mvn",
          cwd = nil, -- work directory, default to `vim.fn.getcwd()`
          settings = nil, -- specify the settings file or use the default settings
          commands = { -- add custom goals to the command list
            { cmd = { "clean", "compile" }, desc = "clean then compile" },
            { cmd = { "dependency:resolve" }, desc = "Resolve Deps" },
            { cmd = { "clean", "compile", "assembly:single" }, desc = "Package to FAT jar" },
          },
        })
      end
    },
  },
}

