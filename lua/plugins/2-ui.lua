-- User interface
-- Plugins that make the user interface better.

--    Sections:
--       -> tokyonight                  [theme]
--       -> astrotheme                  [theme]
--       -> morta                       [theme]
--       -> eldritch                    [theme]
--       -> alpha-nvim                  [greeter]
--       -> nvim-notify                 [notifications]
--       -> mini.indentscope            [guides]
--       -> heirline-components.nvim    [ui components]
--       -> heirline                    [ui components]
--       -> telescope                   [search]
--       -> telescope-fzf-native.nvim   [search backend]
--       -> dressing.nvim               [better ui elements]
--       -> noice.nvim                  [better cmd/search line]
--       -> nvim-web-devicons           [icons | ui]
--       -> lspkind.nvim                [icons | lsp]
--       -> nvim-scrollbar              [scrollbar]
--       -> mini.animate                [animations]
--       -> highlight-undo              [highlights]
--       -> which-key                   [on-screen keybinding]

local utils = require("base.utils")
local is_windows = vim.fn.has('win32') == 1         -- true if on windows
local is_android = vim.fn.isdirectory('/data') == 1 -- true if on android

return {

  --  tokyonight [theme]
  --  https://github.com/folke/tokyonight.nvim
  {
    "folke/tokyonight.nvim",
    event = "User LoadColorSchemes",
    opts = {
      dim_inactive = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    }
  },

  --  astrotheme [theme]
  --  https://github.com/AstroNvim/astrotheme
  {
    "AstroNvim/astrotheme",
    event = "User LoadColorSchemes",
    opts = {
      palette = "astrodark",
      plugins = { ["dashboard-nvim"] = true },
    },
  },

  --  morta [theme]
  --  https://github.com/ssstba/morta.nvim
   {
     "philosofonusus/morta.nvim",
     event = "User LoadColorSchemes",
     opts = {}
   },

  --  eldritch [theme]
  --  https://github.com/eldritch-theme/eldritch.nvim
   {
     "eldritch-theme/eldritch.nvim",
     event = "User LoadColorSchemes",
     opts = {}
   },

  --  alpha-nvim [greeter]
  --  https://github.com/goolord/alpha-nvim
  {
    "goolord/alpha-nvim",
    cmd = "Alpha",
    -- setup header and buttonts
    opts = function()
      local dashboard = require("alpha.themes.dashboard")

      -- Header
      -- dashboard.section.header.val = {
      --   "                                                                     ",
      --   "       ████ ██████           █████      ██                     ",
      --   "      ███████████             █████                             ",
      --   "      █████████ ███████████████████ ███   ███████████   ",
      --   "     █████████  ███    █████████████ █████ ██████████████   ",
      --   "    █████████ ██████████ █████████ █████ █████ ████ █████   ",
      --   "  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
      --   " ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
      -- }
      -- dashboard.section.header.val = {
      --   '                                        ▟▙            ',
      --   '                                        ▝▘            ',
      --   '██▃▅▇█▆▖  ▗▟████▙▖   ▄████▄   ██▄  ▄██  ██  ▗▟█▆▄▄▆█▙▖',
      --   '██▛▔ ▝██  ██▄▄▄▄██  ██▛▔▔▜██  ▝██  ██▘  ██  ██▛▜██▛▜██',
      --   '██    ██  ██▀▀▀▀▀▘  ██▖  ▗██   ▜█▙▟█▛   ██  ██  ██  ██',
      --   '██    ██  ▜█▙▄▄▄▟▊  ▀██▙▟██▀   ▝████▘   ██  ██  ██  ██',
      --   '▀▀    ▀▀   ▝▀▀▀▀▀     ▀▀▀▀       ▀▀     ▀▀  ▀▀  ▀▀  ▀▀',
      -- }
      -- dashboard.section.header.val = {
      --   '                    ▟▙            ',
      --   '                    ▝▘            ',
      --   '██▃▅▇█▆▖  ██▄  ▄██  ██  ▗▟█▆▄▄▆█▙▖',
      --   '██▛▔ ▝██  ▝██  ██▘  ██  ██▛▜██▛▜██',
      --   '██    ██   ▜█▙▟█▛   ██  ██  ██  ██',
      --   '██    ██   ▝████▘   ██  ██  ██  ██',
      --   '▀▀    ▀▀     ▀▀     ▀▀  ▀▀  ▀▀  ▀▀',
      -- }
      -- Generated with https://www.fancytextpro.com/BigTextGenerator/Larry3D
      -- dashboard.section.header.val = {
      --   [[ __  __                  __  __                     ]],
      --   [[/\ \/\ \                /\ \/\ \  __                ]],
      --   [[\ \ `\\ \     __    ___ \ \ \ \ \/\_\    ___ ___    ]],
      --   [[ \ \ , ` \  /'__`\ / __`\\ \ \ \ \/\ \ /' __` __`\  ]],
      --   [[  \ \ \`\ \/\  __//\ \L\ \\ \ \_/ \ \ \/\ \/\ \/\ \ ]],
      --   [[   \ \_\ \_\ \____\ \____/ \ `\___/\ \_\ \_\ \_\ \_\]],
      --   [[    \/_/\/_/\/____/\/___/   `\/__/  \/_/\/_/\/_/\/_/]],
      -- }
      --  dashboard.section.header.val = {
      --   '                                                     ',
      --   '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
      --   '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
      --   '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
      --   '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      --   '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      --   '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      --   '                                                     ',
      -- }
      -- dashboard.section.header.val = {
      --   [[                __                ]],
      --   [[  ___   __  __ /\_\    ___ ___    ]],
      --   [[/' _ `\/\ \/\ \\/\ \ /' __` __`\  ]],
      --   [[/\ \/\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      --   [[\ \_\ \_\ \___/  \ \_\ \_\ \_\ \_\]],
      --   [[ \/_/\/_/\/__/    \/_/\/_/\/_/\/_/]],
      -- }

      if is_android then
        dashboard.section.header.val = {
          [[         __                ]],
          [[ __  __ /\_\    ___ ___    ]],
          [[/\ \/\ \\/\ \ /' __` __`\  ]],
          [[\ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
          [[ \ \___/  \ \_\ \_\ \_\ \_\]],
          [[  \/__/    \/_/\/_/\/_/\/_/]],
        }
      else
        dashboard.section.header.val = {
          [[  ⠀ ⣿⠙⣦⠀⠀⠀⠀⠀⠀⣀⣤⡶⠛⠁]],
          [[⠀⠀⠀⠀⢻⠀⠈⠳⠀⠀⣀⣴⡾⠛⠁⣠⠂⢠⠇]],
          [[⠀⠀⠀⠀⠈⢀⣀⠤⢤⡶⠟⠁⢀⣴⣟⠀⠀⣾]],
          [[⠀⠀⠀⠠⠞⠉⢁⠀⠉⠀⢀⣠⣾⣿⣏⠀⢠⡇]],
          [[⠀⠀⡰⠋⠀⢰⠃⠀⠀⠉⠛⠿⠿⠏⠁⠀⣸⠁]],
          [[ ⠀⣄⠀⠀⠏⣤⣤⣀⡀⠀⠀⠀⠀⠀⠾⢯⣀]],
          [[ ⠀⣻⠃⠀⣰⡿⠛⠁⠀⠀⠀⢤⣀⡀⠀⠺⣿⡟⠛⠁]],
          [[⠀⡠⠋⡤⠠⠋⠀⠀⢀⠐⠁⠀⠈⣙⢯⡃⠀⢈⡻⣦]],
          [[⢰⣷⠇⠀⠀⠀⢀⡠⠃⠀⠀⠀⠀⠈⠻⢯⡄⠀⢻⣿⣷]],
          [[⠉⠲⣶⣶⢾⣉⣐⡚⠋⠀⠀⠀⠀⠀⠘⠀⠀⡎⣿⣿⡇]],
          [[⠀⠀⠀⠀⣸⣿⣿⣿⣷⡄⠀⠀⢠⣿⣴⠀⠀⣿⣿⣿⣧]],
          [[⠀⠀⢀⣴⣿⣿⣿⣿⣿⠇⠀⢠⠟⣿⠏⢀⣾⠟⢸⣿⡇]],
          [[⠀⢠⣿⣿⣿⣿⠟⠘⠁⢠⠜⢉⣐⡥⠞⠋⢁⣴⣿⣿⠃]],
          [[⠀⣾⢻⣿⣿⠃⠀⠀⡀⢀⡄⠁⠀⠀⢠⡾⠁⢠⣾⣿⠃]],
          [[⠀⠃⢸⣿⡇⠀⢠⣾⡇⢸⡇⠀⠀⠀⡞]],
          [[⠀⠀⠈⢿⡇⡰⠋⠈⠙⠂⠙⠢]],
          [[⠀⠀⠀⠀⠈⢧]],
        }
      end


      local get_icon = require("base.utils").get_icon

      dashboard.section.header.opts.hl = "DashboardHeader"

      -- If yazi is not installed, don't show the button.
      local is_yazi_installed = vim.fn.executable("ya") == 1
      local yazi_button = dashboard.button("r", get_icon("GreeterYazi") .. " Yazi", "<cmd>Yazi<CR>")
      if not is_yazi_installed then yazi_button = nil end

      -- Buttons
      local buttons = {
        dashboard.button("n", get_icon("GreeterNew") .. " New", "<cmd>ene<CR>"),
        dashboard.button("e", get_icon("GreeterRecent") .. " Recent  ", "<cmd>Telescope oldfiles<CR>"),
        yazi_button,
        dashboard.button("s", get_icon("GreeterSessions") .. " Sessions", "<cmd>SessionManager! load_session<CR>"),
        dashboard.button("p", get_icon("GreeterProjects") .. " Projects", "<cmd>Telescope projects<CR>"),
        dashboard.button("", ""),
        dashboard.button("q", "   Quit", "<cmd>exit<CR>"),
      }

      -- Apply highlight groups to buttons
      buttons[1].opts.hl = "AlphaIconNew"
      buttons[1].opts.hl_shortcut = "AlphaShortcut"
      buttons[2].opts.hl = "AlphaIconRecent"
      buttons[2].opts.hl_shortcut = "AlphaShortcut"

      if yazi_button then
        buttons[3].opts.hl = "AlphaIconYazi"
        buttons[3].opts.hl_shortcut = "AlphaShortcut"
        buttons[4].opts.hl = "AlphaIconSessions"
        buttons[4].opts.hl_shortcut = "AlphaShortcut"
        buttons[5].opts.hl = "AlphaIconProjects"
        buttons[5].opts.hl_shortcut = "AlphaShortcut"
        buttons[7].opts.hl = "AlphaIconQuit"
        buttons[7].opts.hl_shortcut = "AlphaShortcut"
      else
        buttons[3].opts.hl = "AlphaIconSessions"
        buttons[3].opts.hl_shortcut = "AlphaShortcut"
        buttons[4].opts.hl = "AlphaIconProjects"
        buttons[4].opts.hl_shortcut = "AlphaShortcut"
        buttons[6].opts.hl = "AlphaIconQuit"
        buttons[6].opts.hl_shortcut = "AlphaShortcut"
      end

      dashboard.section.buttons.val = buttons

      -- Vertical margins
      dashboard.config.layout[1].val =
          vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.10) } -- Above header
      dashboard.config.layout[3].val =
          vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.10) } -- Above buttons

      -- Disable autocmd and return
      dashboard.config.opts.noautocmd = true
      return dashboard
    end,
    config = function(_, opts)
      -- Footer
      require("alpha").setup(opts.config)
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        desc = "Add Alpha dashboard footer",
        once = true,
        callback = function()
          local  footer_icon = require("base.utils").get_icon("GreeterPlug")
          local stats = require("lazy").stats()
          stats.real_cputime = not is_windows
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          opts.section.footer.val = {
            " ",
            " ",
            " ",
            "Loaded " .. stats.loaded .. " plugins " .. footer_icon .. " in " .. ms .. "ms",
            ".............................",
          }
          opts.section.footer.opts.hl = "DashboardFooter"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        -- Reapply colorscheme highlights
        vim.cmd("colorscheme material_purple_mocha")
      end,
      once = false, -- Keep reapplying on every Alpha open
    })
    end,
  },

  -- heirline-components.nvim [ui components]
  -- https://github.com/zeioth/heirline-components.nvim
  -- Collection of components to use on your heirline config.
  {
    "zeioth/heirline-components.nvim",
    opts = function()
      -- return different items depending of the value of `vim.g.fallback_icons_enabled`
      local function get_icons()
        if vim.g.fallback_icons_enabled then
          return require("base.icons.fallback_icons")
        else
          return require("base.icons.icons")
        end
      end

      -- opts
      return {
        icons = get_icons(),
        aerial = {
          enabled = false,
        },
      }
    end
  },

  --  heirline [ui components]
  --  https://github.com/rebelot/heirline.nvim
  --  Use it to customize the components of your user interface,
  --  Including tabline, winbar, statuscolumn, statusline.
  --  Be aware some components are positional. Read heirline documentation.
{
  "rebelot/heirline.nvim",
  dependencies = { "zeioth/heirline-components.nvim" },
  event = "User BaseDefered",
  opts = function()
    local lib = require("heirline-components.all")
    return {
      opts = {
        disable_winbar_cb = function(args)
          local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
              lib.condition.buffer_matches({
                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                filetype = {
                  "NvimTree",
                  "neo%-tree",
                  "dashboard",
                  "Outline",
                  "aerial",
                  "rnvimr",
                  "yazi"
                },
              }, args.buf)
          return is_disabled
        end,
      },
      tabline = {
        lib.component.tabline_conditional_padding(),
        lib.component.tabline_buffers(),
        lib.component.fill { hl = { bg = "tabline_bg" } },
        lib.component.tabline_tabpages()
      },
      winbar = {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        {
          condition = function() return not lib.condition.is_active() end,
          {
            lib.component.neotree(),
            lib.component.compiler_play(),
            lib.component.fill(),
            lib.component.compiler_redo(),
          },
        },
        {
          lib.component.neotree(),
          lib.component.compiler_play(),
          lib.component.fill(),
          lib.component.breadcrumbs(),
          lib.component.fill(),
          lib.component.compiler_redo(),
        }
      },
      statuscolumn = {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        lib.component.foldcolumn(),
        lib.component.numbercolumn(),
        lib.component.signcolumn(),
      } or nil,
    }
  end,
  config = function(_, opts)
    local heirline = require("heirline")
    local heirline_components = require("heirline-components.all")

    -- Setup
    heirline_components.init.subscribe_to_events()

    -- Get colors from your theme
    local theme_colors = {
      overlay0 = vim.fn.synIDattr(vim.fn.hlID("Comment"), "fg"),
      text = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg"),
      mauve = "#F493B5",  -- fallback
    }

    local colors = heirline_components.hl.get_colors()

    -- Force buffer colors
    colors.tabline_bg = "NONE"
    colors.buffer_bg = "NONE"
    colors.buffer_fg = theme_colors.overlay0 or colors.buffer_fg
    colors.buffer_visible_fg = theme_colors.text or colors.buffer_visible_fg
    colors.buffer_active_fg = theme_colors.mauve or colors.buffer_active_fg
    colors.mode_normal = "#C5A1F2"    -- mauve
    colors.mode_insert = "#69D1D1"    -- green
    colors.mode_visual = "#D693DF"    -- red/purple
    colors.mode_replace = "#F8AEC4"   -- peach
    colors.mode_command = "#EECDC3"   -- yellow

    heirline.load_colors(colors)
    heirline.setup(opts)

    -- Set up autocmd to reload on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(function()
          local new_colors = heirline_components.hl.get_colors()
          new_colors.tabline_bg = "NONE"
          new_colors.buffer_bg = "NONE"
          -- Get fresh colors from current theme
          local overlay0 = vim.fn.synIDattr(vim.fn.hlID("Comment"), "fg")
          if overlay0 ~= "" then
            new_colors.buffer_fg = overlay0
          end
          heirline.load_colors(new_colors)
          vim.cmd("redrawstatus!")
          vim.cmd("redrawtabline")
        end)
      end,
    })
  end,
},

  --  Telescope [search] + [search backend] dependency
  --  https://github.com/nvim-telescope/telescope.nvim
  --  https://github.com/nvim-telescope/telescope-fzf-native.nvim
  --  https://github.com/debugloop/telescope-undo.nvim
  --  NOTE: Normally, plugins that depend on Telescope are defined separately.
  --  But its Telescope extension is added in the Telescope 'config' section.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        cmd = "Telescope",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("make") == 1,
        build = "make",
      },
    },
    cmd = "Telescope",
    opts = function()
      local get_icon = require("base.utils").get_icon
      local actions = require("telescope.actions")
      local mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<ESC>"] = actions.close,
          ["<C-c>"] = false,
        },
        n = { ["q"] = actions.close },
      }
      return {
        defaults = {
          prompt_prefix = get_icon("PromptPrefix") .. " ",
          selection_caret = get_icon("PromptPrefix") .. " ",
          multi_icon = get_icon("PromptPrefix") .. " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.50,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = mappings,
        },
        extensions = {
          undo = {
            use_delta = true,
            side_by_side = true,
            vim_diff_opts = { ctxlen = 0 },
            entry_format = "󰣜 #$ID, $STAT, $TIME",
            layout_strategy = "horizontal",
            layout_config = {
              preview_width = 0.65,
            },
            mappings = {
              i = {
                ["<cr>"] = require("telescope-undo.actions").yank_additions,
                ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                ["<C-cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- Here we define the Telescope extension for all plugins.
      -- If you delete a plugin, you can also delete its Telescope extension.
      if utils.is_available("nvim-notify") then telescope.load_extension("notify") end
      if utils.is_available("telescope-fzf-native.nvim") then telescope.load_extension("fzf") end
      if utils.is_available("telescope-undo.nvim") then telescope.load_extension("undo") end
      if utils.is_available("project.nvim") then telescope.load_extension("projects") end
      if utils.is_available("LuaSnip") then telescope.load_extension("luasnip") end
      if utils.is_available("aerial.nvim") then telescope.load_extension("aerial") end
      if utils.is_available("nvim-neoclip.lua") then
        telescope.load_extension("neoclip")
        telescope.load_extension("macroscope")
      end
    end,
  },

  --  Noice.nvim [better cmd/search line]
  --  https://github.com/folke/noice.nvim
  --  We use it for:
  --  * cmdline: Display treesitter for :
  --  * search: Display a magnifier instead of /
  --
  --  We don't use it for:
  --  * LSP status: We use a heirline component for this.
  --  * Search results: We use a heirline component for this.
  {
    "folke/noice.nvim",
    event = "User BaseDefered",
    opts = function()
      local enable_conceal = false          -- Hide command text if true
      return {
        presets = { bottom_search = true }, -- The kind of popup used for /
        cmdline = {
          view = "cmdline",                 -- The kind of popup used for :
          format = {
            cmdline = { conceal = enable_conceal },
            search_down = { conceal = enable_conceal },
            search_up = { conceal = enable_conceal },
            filter = { conceal = enable_conceal },
            lua = { conceal = enable_conceal },
            help = { conceal = enable_conceal },
            input = { conceal = enable_conceal },
          }
        },

        -- Disable every other noice feature
        messages = { enabled = false },
        lsp = {
          hover = { enabled = false },
          signature = { enabled = false },
          progress = { enabled = false },
          message = { enabled = false },
          smart_move = { enabled = false },
        },
      }
    end
  },

  --  UI icons [icons - ui]
  --  https://github.com/nvim-tree/nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = not vim.g.fallback_icons_enabled,
    event = "User BaseDefered",
    opts = {
      override = {
        default_icon = {
          icon = require("base.utils").get_icon("DefaultFile")
        },
      },
    },
  },

  --  LSP icons [icons | lsp]
  --  https://github.com/onsails/lspkind.nvim
  {
    "onsails/lspkind.nvim",
    enabled = not vim.g.fallback_icons_enabled,
    opts = {
      mode = "symbol_text",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Copilot = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    config = function(_, opts)
      require("lspkind").init(opts)
    end,
  },

  --  nvim-scrollbar [scrollbar]
  --  https://github.com/petertriho/nvim-scrollbar
  {
    "petertriho/nvim-scrollbar",
    event = "User BaseFile",
    opts = {
      handlers = {
        gitsigns = true, -- gitsigns integration (display hunks)
        ale = true,      -- lsp integration (display errors/warnings)
        search = false,  -- hlslens integration (display search result)
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "alpha"
      },
    },
  },

  --  mini.animate [animations]
  --  https://github.com/nvim-mini/mini.animate
  --  HINT: if one of your personal keymappings fail due to mini.animate, try to
  --        disable it during the keybinding using vim.g.minianimate_disable = true
  {
    "nvim-mini/mini.animate",
    event = "User BaseFile",
    enabled = not is_android,
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs { "Up", "Down" } do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        open = { enable = false }, -- true causes issues on nvim-spectre
        resize = {
          timing = animate.gen_timing.linear { duration = 33, unit = "total" },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 50, unit = "total" },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
        cursor = {
          enable = true, -- We don't want cursor ghosting
          timing = animate.gen_timing.linear { duration = 26, unit = "total" },
          path = animate.gen_path.line(),  -- or try: angle(), walls()
        },
      }
    end,
  },

  --  highlight-undo
  --  https://github.com/tzachar/highlight-undo.nvim
  --  This plugin only flases on undo/redo.
  --  But we also have a autocmd to flash on yank.
  {
    "tzachar/highlight-undo.nvim",
    event = "User BaseDefered",
    opts = {
      duration = 150,
      hlgroup = "IncSearch",
    },
    config = function(_, opts)
      require("highlight-undo").setup(opts)

      -- Also flash on yank.
      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight yanked text",
        pattern = "*",
        callback = function()
          (vim.hl or vim.highlight).on_yank()
        end,
      })
    end,
  },

  --  which-key.nvim [on-screen keybindings]
  --  https://github.com/folke/which-key.nvim
  {
    "folke/which-key.nvim",
    event = "User BaseDefered",

    opts_extend = { "disable.ft", "disable.bt" },
    opts = {
      preset = "modern", -- "classic", "modern", or "helix"
      icons = {
        group = (vim.g.fallback_icons_enabled and "+") or "",
        rules = false,
        separator = "-",
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      require("base.utils").which_key_register()
      local get_icon = require("base.utils").get_icon
      require("which-key").add({
        { "<leader>j", group = get_icon("Java", true) .. " Java" },
        { "<leader>o", group = get_icon("AI", true) .. " OpenCode" },
      })
    end,
  },


} -- end of return
