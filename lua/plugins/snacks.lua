return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input        = { enabled = true },
      picker       = {
        enabled = true,
        win = {
          border = "single",
        },
      },
      terminal     = {
        enabled = true,
        win = {
          style = "terminal",
          border = "single",
        },
      },
      select       = { enabled = true },
      notifier     = {
        enabled = true,
        timeout = 3000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        style = "compact",
      },
      bigfile      = { enabled = true },
      indent       = {
        enabled = false,
        only_scope = true,
        only_current = true,
        animate = {
          enabled = true,
        },
      },
      scope        = {
        enabled = false,
        cursor = false,
        char = "│",
        treesitter = { enabled = true },
      },
      scroll       = {
        enabled = false,
        animate = {
          duration = { step = 50, total = 250 },
          easing = "linear",
        },
      },
      statuscolumn = { enabled = false },
      words        = { enabled = true },
      zen          = {
        enabled = true,
        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
        },
        zoom = {
          width = 0.8,
          height = 0.9,
        },
      },
      git          = { enabled = true },
      gitbrowse    = { enabled = true },
      lazygit      = {
        enabled = true,
        configure = true,
        theme = {
          activeBorderColor = { fg = "Special" },
          inactiveBorderColor = { fg = "Comment" },
        },
      },
      bufdelete    = { enabled = true },
      scratch      = {
        enabled = true,
        name = "Scratch",
        ft = "markdown",
        icon = "󱓧",
        root = vim.fn.stdpath("data") .. "/scratch",
        autowrite = true,
        filekey = {
          cwd = true,
          branch = true,
          count = true,
        },
        win = {
          width = 100,
          height = 30,
          bo = { filetype = "markdown" },
          minimal = false,
          noautocmd = false,
        },
        win_by_ft = {
          lua = {
            keys = {
              ["source"] = {
                "<cr>",
                function(self)
                  local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                  Snacks.debug.run({ buf = self.buf, name = name })
                end,
                desc = "Source buffer",
                mode = { "n", "x" },
              },
            },
          },
        },
      },
      quickfile    = { enabled = true }, -- Fast file opening
      rename       = { enabled = true }, -- Better file rename
      toggle       = {
        enabled = true,
        which_key = true,
        notify = true,
      },
      dashboard    = {
        enabled = true,
        preset = {
          header = [[
          ⠀ ⣿⠙⣦⠀⠀⠀⠀⠀⠀⣀⣤⡶⠛⠁
          ⠀⠀⠀⠀⢻⠀⠈⠳⠀⠀⣀⣴⡾⠛⠁⣠⠂⢠⠇
          ⠀⠀⠀⠀⠈⢀⣀⠤⢤⡶⠟⠁⢀⣴⣟⠀⠀⣾
          ⠀⠀⠀⠠⠞⠉⢁⠀⠉⠀⢀⣠⣾⣿⣏⠀⢠⡇
          ⠀⠀⡰⠋⠀⢰⠃⠀⠀⠉⠛⠿⠿⠏⠁⠀⣸⠁
            ⠀⣄⠀⠀⠏⣤⣤⣀⡀⠀⠀⠀⠀⠀⠾⢯⣀
            ⠀⣻⠃⠀⣰⡿⠛⠁⠀⠀⠀⢤⣀⡀⠀⠺⣿⡟⠛⠁
          ⠀⡠⠋⡤⠠⠋⠀⠀⢀⠐⠁⠀⠈⣙⢯⡃⠀⢈⡻⣦
          ⢰⣷⠇⠀⠀⠀⢀⡠⠃⠀⠀⠀⠀⠈⠻⢯⡄⠀⢻⣿⣷
          ⠉⠲⣶⣶⢾⣉⣐⡚⠋⠀⠀⠀⠀⠀⠘⠀⠀⡎⣿⣿⡇
          ⠀⠀⠀⠀⣸⣿⣿⣿⣷⡄⠀⠀⢠⣿⣴⠀⠀⣿⣿⣿⣧
          ⠀⠀⢀⣴⣿⣿⣿⣿⣿⠇⠀⢠⠟⣿⠏⢀⣾⠟⢸⣿⡇
          ⠀⢠⣿⣿⣿⣿⠟⠘⠁⢠⠜⢉⣐⡥⠞⠋⢁⣴⣿⣿⠃
          ⠀⣾⢻⣿⣿⠃⠀⠀⡀⢀⡄⠁⠀⠀⢠⡾⠁⢠⣾⣿⠃
    ⠀⠃⢸⣿⡇⠀⢠⣾⡇⢸⡇⠀⠀⠀⡞
⠀⠀⠈⢿⡇⡰⠋⠈⠙⠂⠙⠢
⠈⢧
          ]],
          -- stylua: ignore
          --@type snacks.dashboard.Item[]
          keys = {
            { icon = "󰈙 ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󰮳 ", key = "e", desc = "Recent Files", action = function() Snacks.picker.recent() end },
            { icon = "󰪶 ", key = "r", desc = "Yazi", action = ":Yazi", enabled = vim.fn.executable("ya") == 1 },
            { icon = "󰮗 ", key = "s", desc = "Sessions", action = ":SessionManager! load_session" },
            { icon = " ", key = "p", desc = "Projects", action = function() Snacks.picker.projects() end },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                Snacks.picker.files({
                  cwd = vim.fn.stdpath(
                    'config')
                })
              end
            },
            { icon = "󰅚 ", key = "q", desc = "Quit", action = ":qa" }
          }
        },
        sections = {
          { section = "header" },
          { section = "keys",   gap = 1, padding = 1, },
          { section = "startup" },
        },
        formats = {
          key = function(item)
            return { { "[", hl = "SnacksDashboardSpecial" }, { item.key, hl = "SnacksDashboardKey" }, { "]", hl = "SnacksDashboardSpecial" } }
          end,
        },
      },
    },

    config = function(_, opts)
      require("snacks").setup(opts)
    end
  },
}
