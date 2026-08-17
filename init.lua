require("opts.options")
require("opts.lazy")
require("opts.keymaps")
require("opts.autocmds")
require("custom.todo-highlight").setup()

vim.filetype.add({
	pattern = {
		[".*/tmux/.*%.conf"] = "tmux",
		[".*/%.config/tmux/.*%.conf"] = "tmux",
	},
})
