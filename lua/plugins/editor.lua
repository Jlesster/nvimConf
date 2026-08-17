return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		dependencies = { "HiPhish/rainbow-delimiters.nvim" },
		config = function()
			local highlight = {
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			}

			local hooks = require("ibl.hooks")

			require("ibl").setup({
				indent = {
					char = "›",
				},
				scope = {
					enabled = true,
					char = "│",
					highlight = highlight,
				},
			})

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},
	{
		"Aasim-A/scrollEOF.nvim",
		event = { "CursorMoved", "WinScrolled" },
		opts = {
			pattern = "*",
			insert_mode = true,
			floating = false,
			disabled_filetypes = { "neo-tree", "terminal", "toggleterm", "Neotree" },
		},
	},
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		keys = {
			{
				"<leader>fR",
				function()
					require("grug-far").open({ transient = true })
				end,
				desc = "Search & replace (grug)",
			},
			{
				"<leader>fR",
				function()
					require("grug-far").open({
						transient = true,
						prefills = { search = vim.fn.expand("<cword>") },
					})
				end,
				mode = "v",
				desc = "Search & replace word (grug)",
			},
		},
		opts = {
			headerMaxWidth = 80,
			startInInsertMode = false,
			resultsSeparatorLineChar = "─",
			spinnerStates = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			attach_to_untracked = true,
			current_line_blame = false,
			preview_config = { border = "rounded" },
			on_attach = function(buf)
				local gs = package.loaded.gitsigns
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
				end
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next hunk")
				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Prev hunk")
				map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>ghs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk (range)")
				map("v", "<leader>ghr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk (range)")
				map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
				map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
				map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
				map("n", "<leader>ghb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
				map("n", "<leader>ghd", gs.diffthis, "Diff this")
				map("n", "<leader>ghD", function()
					gs.diffthis("~")
				end, "Diff this ~")
				map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
			end,
		},
	},

	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			keywords = { ... },
			highlight = {
				before = "",
				keyword = "bg",
				after = "fg",
				pattern = [[.*<(KEYWORDS)\s*:]], -- colon-only, leaves [TODO] alone visually
				comments_only = true,
			},
			search = {
				pattern = [[\b(KEYWORDS)\b]], -- default; \b already matches inside [TODO] for search/jump
			},
		},
		keys = {
			{
				"]T",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo",
			},
			{
				"[T",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Prev todo",
			},
			{
				"<leader>st",
				"<cmd>TodoTelescope<cr>",
				desc = "Search todos",
			},
			{
				"<leader>sT",
				"<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",
				desc = "Search TODO/FIX",
			},
		},
	},

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				surrounds = {
					["f"] = {
						add = function()
							local r = require("nvim-surround.config").get_input("Function name: ")
							if r then
								return { { r .. "(" }, { ")" } }
							end
						end,
						find = "[%w_]+%b()",
						delete = "^([%w_]+%()().-(%))()$",
						change = {
							target = "^([%w_]+%()().-(%))()$",
							replacement = function()
								local r = require("nvim-surround.config").get_input("Function name: ")
								if r then
									return { { r .. "(" }, { ")" } }
								end
							end,
						},
					},
					["c"] = {
						add = function()
							local lang = require("nvim-surround.config").get_input("Language (optional): ")
							if lang == "" then
								lang = nil
							end
							return { { "```" .. (lang or ""), "" }, { "", "```" } }
						end,
					},
					["t"] = {
						add = function()
							local tag = require("nvim-surround.config").get_input("Tag name: ")
							if tag then
								return { { "<" .. tag .. ">" }, { "</" .. tag .. ">" } }
							end
						end,
						find = "<[^>]+>.-</.->",
						delete = "^(<[^>]+>)().-(</[^>]+>)()$",
						change = {
							target = "^<([^>]+)().-</([^>]+)()$",
							replacement = function()
								local tag = require("nvim-surround.config").get_input("Tag name: ")
								if tag then
									return { { "<" .. tag .. ">" }, { "</" .. tag .. ">" } }
								end
							end,
						},
					},
					["T"] = { add = { "{ ", " }" } },
					["m"] = { add = { "$", "$" } },
					["M"] = { add = { "$$", "$$" } },
					["/"] = {
						add = function()
							local cs = vim.bo.commentstring
							if cs == "" then
								cs = "# %s"
							end
							local left, right = cs:match("^(.*)%%s(.*)$")
							if not left then
								left, right = cs, ""
							end
							return { { left }, { right } }
						end,
					},
				},
				aliases = {
					["a"] = ">",
					["b"] = ")",
					["B"] = "}",
					["r"] = "]",
					["q"] = { '"', "'", "`" },
					["s"] = { "}", "]", ")", ">", "'", '"', "`" },
				},
				move_cursor = "begin",
				indent_lines = function()
					return vim.bo.buftype == ""
				end,
				highlight = { duration = 200 },
			})
			local map = vim.keymap.set
			map({ "n", "v" }, "ys", "<Plug>(nvim-surround-normal)")
			map("n", "yss", "<Plug>(nvim-surround-normal-cur)")
			map("n", "yS", "<Plug>(nvim-surround-normal-line)")
			map("n", "ySS", "<Plug>(nvim-surround-normal-cur-line)")
			map("i", "<C-g>s", "<Plug>(nvim-surround-insert)")
			map("i", "<C-g>S", "<Plug>(nvim-surround-insert-line)")
			map("v", "S", "<Plug>(nvim-surround-visual)")
			map("v", "gS", "<Plug>(nvim-surround-visual-line)")
			map("n", "ds", "<Plug>(nvim-surround-delete)")
			map("n", "cs", "<Plug>(nvim-surround-change)")
			map("n", "cS", "<Plug>(nvim-surround-change-line)")
		end,
	},

	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

	{
		"brenoprata10/nvim-highlight-colors",
		event = "BufReadPost",
		opts = {
			render = "background",
			virtual_symbol = "■",
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
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({
				preset = "classic",
				delay = 300,
				icons = { mappings = false },
				win = { border = "rounded" },
			})
			wk.add({
				{ "<leader>b", group = "[B]uffers" },
				{ "<leader>d", group = "[D]uplicate" },
				{ "<leader>D", group = "[D]ebug" },
				{ "<leader>e", group = "[E]xplorer" },
				{ "<leader>f", group = "[F]iles / Format" },
				{ "<leader>F", group = "[F]lutter" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>gh", group = "[G]it [H]unks" },
				{ "<leader>gt", group = "[G]it [T]oggle" },
				{ "<leader>l", group = "[L]SP" },
				{ "<leader>lt", group = "[L]SP [T]oggle" },
				{ "<leader>lw", group = "[L]SP [W]orkspace" },
				{ "<leader>m", group = "[M]arvin" },
				{ "<leader>M", group = "[M]aven" },
				{ "<leader>q", group = "[Q]uit" },
				{ "<leader>r", group = "[R]oot" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]erminal / Toggle" },
				{ "<leader>u", group = "[U]I / Notifications" },
				{ "<leader>w", group = "[W]indow" },
				{ "<leader>x", group = "[X] Diagnostics" },
				{ "<leader>y", group = "[Y]azi" },
			})
		end,
	},

	{
		"mrjones2014/smart-splits.nvim",
		lazy = false,
		config = function()
			local ss = require("smart-splits")
			ss.setup({
				multiplexer_integration = "tmux",
				default_amount = 3,
				at_edge = "wrap",
			})
			vim.keymap.set("n", "<C-h>", ss.move_cursor_left)
			vim.keymap.set("n", "<C-j>", ss.move_cursor_down)
			vim.keymap.set("n", "<C-k>", ss.move_cursor_up)
			vim.keymap.set("n", "<C-l>", ss.move_cursor_right)
			vim.keymap.set("n", "<A-h>", ss.resize_left)
			vim.keymap.set("n", "<A-j>", ss.resize_down)
			vim.keymap.set("n", "<A-k>", ss.resize_up)
			vim.keymap.set("n", "<A-l>", ss.resize_right)
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown", "markdown_inline", "html" },
		opts = {
			buf_filter = function(buf)
				local ft = vim.bo[buf].filetype
				return ft == "markdown" or ft == "markdown_inline"
			end,
			enabled = true,
			file_types = { "markdown", "markdown_inline", "html" },
			render_modes = { "n", "c", "r" },
			anti_conceal = { enabled = false, above = 0, below = 0 },
			heading = {
				enabled = true,
				sign = false,
				position = "overlay",
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				width = "full",
				border = false,
				above = "▄",
				below = "▀",
				backgrounds = {
					"RenderMarkdownH1Bg",
					"RenderMarkdownH2Bg",
					"RenderMarkdownH3Bg",
					"RenderMarkdownH4Bg",
					"RenderMarkdownH5Bg",
					"RenderMarkdownH6Bg",
				},
				foregrounds = {
					"RenderMarkdownH1",
					"RenderMarkdownH2",
					"RenderMarkdownH3",
					"RenderMarkdownH4",
					"RenderMarkdownH5",
					"RenderMarkdownH6",
				},
			},
			code = {
				enabled = true,
				sign = false,
				style = "full",
				position = "left",
				language_pad = 1,
				width = "full",
				left_pad = 1,
				right_pad = 1,
				border = "thin",
				above = "▄",
				below = "▀",
				highlight = "RenderMarkdownCode",
				highlight_inline = "RenderMarkdownCodeInline",
			},
			bullet = {
				enabled = true,
				icons = { "●", "○", "◆", "◇" },
				right_pad = 1,
			},
			checkbox = {
				enabled = true,
				position = "inline",
				unchecked = { icon = "󰄱", highlight = "RenderMarkdownUnchecked" },
				checked = { icon = "󰱒", highlight = "RenderMarkdownChecked" },
				custom = {
					todo = {
						raw = "[-]",
						rendered = "󰥔",
						highlight = "RenderMarkdownTodo",
					},
				},
			},
			pipe_table = {
				enabled = true,
				style = "full",
				cell = "padded",
				border = {
					"┌",
					"┬",
					"┐",
					"├",
					"┼",
					"┤",
					"└",
					"┴",
					"┘",
					"│",
					"─",
				},
				alignment_indicator = "━",
				head = "RenderMarkdownTableHead",
				row = "RenderMarkdownTableRow",
				filler = "RenderMarkdownTableFill",
			},
			sign = { enabled = false },
			indent = { enabled = false },
			win_options = {
				conceallevel = { default = vim.o.conceallevel, rendered = 3 },
				concealcursor = { default = vim.o.concealcursor, rendered = "" },
			},
		},
	},
}
