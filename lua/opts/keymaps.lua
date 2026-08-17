local map = vim.keymap.set

local function get_root()
	local buf_path = vim.api.nvim_buf_get_name(0)
	local buf_dir = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or vim.uv.cwd()
	local out = vim.fn.system("git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel")
	return vim.v.shell_error == 0 and vim.trim(out) or buf_dir
end

local function telescope(picker, opts)
	return function()
		require("telescope.builtin")[picker](opts or {})
	end
end

-- ─── Escape ───────────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>", { desc = "Exit insert" })
map("i", "<C-BS>", "<C-W>", { desc = "Delete word" })
map("n", "<ESC>", function()
	vim.cmd("nohlsearch")
end, { desc = "Clear highlights" })

-- ─── Terminal ─────────────────────────────────────────────────────────────────
map("t", "<C-h>", "<cmd>silent! wincmd h<cr>", { desc = "Term → left" })
map("t", "<C-j>", "<cmd>silent! wincmd j<cr>", { desc = "Term → down" })
map("t", "<C-k>", "<cmd>silent! wincmd k<cr>", { desc = "Term → up" })
map("t", "<C-l>", "<cmd>silent! wincmd l<cr>", { desc = "Term → right" })

-- ─── Movement ─────────────────────────────────────────────────────────────────
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "0", "^", { desc = "First non-blank" })
map("n", "G", "G$", { desc = "Last line end" })
map("n", "<C-a>", ":<C-u>normal! gg0vG$<CR>", { desc = "Select all" })

map("n", "gg", function()
	if vim.v.count > 0 then
		vim.cmd("normal! " .. vim.v.count .. "gg")
	else
		vim.cmd("normal! gg0")
	end
end, { desc = "First line" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up center" })
map("n", "n", "nzzzv", { desc = "Next result center" })
map("n", "N", "Nzzzv", { desc = "Prev result center" })

-- ─── Move lines ───────────────────────────────────────────────────────────────
map("n", "<S-A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<S-A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<S-A-j>", ":m '>+1<CR>gv=gv", { desc = "Move sel down" })
map("v", "<S-A-k>", ":m '<-2<CR>gv=gv", { desc = "Move sel up" })

-- ─── Indent ───────────────────────────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Unindent" })
map("v", ">", ">gv", { desc = "Indent" })

-- ─── Clipboard ────────────────────────────────────────────────────────────────
map("n", "c", '"_c', { desc = "Change (no yank)" })
map("n", "C", '"_C', { desc = "Change EOL (no yank)" })
map("x", "c", '"_c', { desc = "Change (no yank)" })
map("x", "C", '"_C')
map("x", "x", '"_x', { desc = "Delete (no yank)" })
map("x", "p", "P", { desc = "Paste (no yank replaced)" })
map("x", "P", "p", { desc = "Paste (yank replaced)" })

local function smart_delete(fallback)
	return function()
		if vim.fn.col(".") == 1 and vim.fn.getline("."):match("^%s*$") then
			vim.api.nvim_feedkeys('"_dd', "n", false)
			vim.api.nvim_feedkeys("$", "n", false)
		else
			vim.api.nvim_feedkeys('"_' .. fallback, "n", false)
		end
	end
end
map("n", "x", smart_delete("x"), { desc = "Del char (no yank)" })
map("n", "X", smart_delete("X"), { desc = "Del before (no yank)" })

-- ─── Comment ──────────────────────────────────────────────────────────────────
map("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- ─── Splits ───────────────────────────────────────────────────────────────────
map("n", "|", ":vsplit<CR>", { desc = "Vertical split" })
map("n", "\\", ":split<CR>", { desc = "Horizontal split" })

-- ─── Quickfix ─────────────────────────────────────────────────────────────────
map("n", "]q", ":cnext<CR>", { desc = "Next qf" })
map("n", "[q", ":cprev<CR>", { desc = "Prev qf" })

-- ─── Diagnostics ──────────────────────────────────────────────────────────────
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
map("n", "]e", function()
	vim.diagnostic.jump({
		count = 1,
		float = true,
		severity = vim.diagnostic.severity.ERROR,
	})
end, { desc = "Next error" })
map("n", "[e", function()
	vim.diagnostic.jump({
		count = -1,
		float = true,
		severity = vim.diagnostic.severity.ERROR,
	})
end, { desc = "Prev error" })

-- ─── LSP ──────────────────────────────────────────────────────────────────────
map("n", "gd", telescope("lsp_definitions"), { desc = "Definition" })
map("n", "gD", telescope("lsp_declarations"), { desc = "Declaration" })
map("n", "gr", telescope("lsp_references", { show_line = false }), { desc = "References" })
map("n", "gi", telescope("lsp_implementations"), { desc = "Implementation" })
map("n", "gy", telescope("lsp_type_definitions"), { desc = "Type definition" })

map("n", "K", function()
	require("hover").hover()
end, { desc = "Hover" })
map("n", "gK", function()
	require("hover").hover_switch("previous")
end, { desc = "Hover prev" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- ─── [b] Buffers ──────────────────────────────────────────────────────────────
map("n", "<leader>bb", telescope("buffers"), { desc = "List buffers" })
map("n", "<leader>b/", telescope("current_buffer_fuzzy_find"), { desc = "Fuzzy buffer lines" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bw", ":q<CR>", { desc = "Close window" })
map("n", "<leader>bo", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype ~= "terminal" then
			pcall(vim.api.nvim_buf_delete, buf, { force = false })
		end
	end
end, { desc = "Delete other buffers" })

-- ─── [d] Duplicate ────────────────────────────────────────────────────────────
map("n", "<leader>dl", "yyp", { desc = "Duplicate line" })
map("v", "<leader>dl", "y'>p", { desc = "Duplicate selection" })

-- ─── [F] Flutter Tools ────────────────────────────────────────────────
map("n", "<leader>F", function()
	require("telescope").load_extension("flutter")
end, { desc = "Flutter tools" })
-- ─── [f] Files / Find / Format ────────────────────────────────────────────────
map("n", "<C-s>", "<cmd>silent! w!<CR>", { desc = "Force write" })
map("n", "<leader>fs", "<cmd>silent! w<CR>", { desc = "Save" })
map("n", "<leader>fS", "<cmd>silent! w!<CR>", { desc = "Force save" })
map("n", "<leader>fn", "<cmd>silent! enew<CR>", { desc = "New file" })

map("n", "<leader>ff", telescope("find_files"), { desc = "Find files (cwd)" })
map("n", "<leader>fF", function()
	require("telescope.builtin").find_files({ cwd = get_root() })
end, { desc = "Find files (root)" })
map("n", "<leader>fr", telescope("oldfiles"), { desc = "Recent files" })
map("n", "<leader>fg", telescope("live_grep"), { desc = "Grep (cwd)" })
map("n", "<leader>fG", function()
	require("telescope.builtin").live_grep({ cwd = get_root() })
end, { desc = "Grep (root)" })
map("n", "<leader>fw", telescope("grep_string"), { desc = "Grep word (cwd)" })
map("n", "<leader>fW", function()
	require("telescope.builtin").grep_string({ cwd = get_root() })
end, { desc = "Grep word (root)" })
map("n", "<leader>fh", telescope("help_tags"), { desc = "Help tags" })
map("n", "<leader>fk", telescope("keymaps"), { desc = "Keymaps" })
map("n", "<leader>fc", telescope("commands"), { desc = "Commands" })
map("n", "<leader>fo", telescope("vim_options"), { desc = "Vim options" })

map("n", "<leader>fy", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Yanked: " .. path)
end, { desc = "Yank file path" })
map("n", "<leader>fY", function()
	local path = vim.fn.expand("%:t")
	vim.fn.setreg("+", path)
	vim.notify("Yanked: " .. path)
end, { desc = "Yank file name" })

map({ "n", "v" }, "<leader>fm", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>fM", function()
	require("conform").format({ async = false, lsp_format = "fallback" })
	vim.cmd("write")
end, { desc = "Format + save" })
map("n", "<leader>fR", function()
	require("grug-far").open({ transient = true })
end, { desc = "Search & replace" })

-- ─── [g] Git ──────────────────────────────────────────────────────────────────
map("n", "<leader>gg", function()
	_G.toggle_lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gs", telescope("git_status"), { desc = "Git status" })
map("n", "<leader>gb", telescope("git_branches"), { desc = "Git branches" })
map("n", "<leader>gc", telescope("git_commits"), { desc = "Git log" })
map("n", "<leader>gC", telescope("git_bcommits"), { desc = "Git log (buffer)" })
map("n", "<leader>gS", telescope("git_stash"), { desc = "Git stash" })

-- ─── [l] LSP ──────────────────────────────────────────────────────────────────
map("n", "<leader>la", vim.lsp.buf.code_action, {
	desc = "Code action",
})
map("v", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action (range)" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>li", telescope("lsp_incoming_calls"), { desc = "Incoming calls" })
map("n", "<leader>lo", telescope("lsp_outgoing_calls"), { desc = "Outgoing calls" })
map("n", "<leader>ld", telescope("diagnostics", { bufnr = 0 }), { desc = "Buffer diagnostics" })
map("n", "<leader>lD", telescope("diagnostics"), { desc = "Workspace diagnostics" })
map("n", "<leader>lS", telescope("lsp_document_symbols"), { desc = "Document symbols" })
map("n", "<leader>lw", telescope("lsp_workspace_symbols"), { desc = "Workspace symbols" })
map("n", "<leader>lf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, { desc = "Add ws folder" })
map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove ws folder" })
map("n", "<leader>lwl", function()
	vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List ws folders" })
map("n", "<leader>lI", "<cmd>LspInfo<cr>", { desc = "LSP info" })
map("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "LSP restart" })
map("n", "<leader>lti", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
end, { desc = "Toggle inlay hints" })
map("n", "<leader>ltd", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ─── [m] Marvin ───────────────────────────────────────────────────────────────
map("n", "<leader>mm", ":Marvin<CR>", { desc = "Marvin" })
map("n", "<leader>mj", ":Jason<CR>", { desc = "Jason" })
map("n", "<F2>", ":MarvinExplorer<CR>", { desc = "Marvin Explorer" })
map("n", "-", ":MarvinExplorer<CR>", { desc = "Marvin Explorer" })
map("n", "<F4>", ":Marvin<CR>", { desc = "Marvin" })
map("n", "<F5>", ":Jason<CR>", { desc = "Jason" })
map("n", "<F6>", ":JasonConsole<CR>", { desc = "Jason Console" })
map("n", "<F7>", ":JasonRunConsole<CR>", { desc = "Jason Run Hist" })
map("n", "<F8>", ":JasonTerm<CR>", { desc = "Jason Terminal" })
map("t", "<F8>", ":JasonTerm<CR>", { desc = "Jason Terminal" })

-- ─── [q] Quit ─────────────────────────────────────────────────────────────────
map("n", "<leader>qq", ":qa<CR>", { desc = "Quit all" })
map("n", "<leader>qQ", ":qa!<CR>", { desc = "Force quit" })
map("n", "<leader>qw", ":wqa<CR>", { desc = "Save and quit" })

-- ─── [r] Root ─────────────────────────────────────────────────────────────────
map("n", "<leader>rc", function()
	local root = get_root()
	vim.cmd("cd " .. root)
	vim.notify("cwd → " .. root)
end, { desc = "cd to git root" })

-- ─── [s] Search (telescope) ───────────────────────────────────────────────────
map("n", "<leader>sf", telescope("find_files"), { desc = "Smart find" })
map("n", "<leader>sb", telescope("buffers"), { desc = "Buffers" })
map("n", "<leader>sg", telescope("live_grep"), { desc = "Grep" })
map("n", "<leader>sh", telescope("help_tags"), { desc = "Help" })
map("n", "<leader>sk", telescope("keymaps"), { desc = "Keymaps" })
map("n", "<leader>sc", telescope("colorscheme"), { desc = "Colorschemes" })
map("n", "<leader>sl", telescope("loclist"), { desc = "Location list" })
map("n", "<leader>s/", telescope("search_history"), { desc = "Search history" })
map("n", "<leader>s:", telescope("command_history"), { desc = "Command history" })
map("n", "<leader>sp", telescope("spell_suggest"), { desc = "Spell suggest" })
map("n", "<leader>sn", telescope("treesitter"), { desc = "Treesitter nodes" })
map("n", "<leader>ss", "<cmd>Telescope resume<cr>", { desc = "Resume picker" })
map("n", "<leader>sq", telescope("quickfix"), { desc = "Quickfix" })
map("n", "<leader>sm", telescope("marks"), { desc = "Marks" })
map("n", "<leader>sj", telescope("jumplist"), { desc = "Jumplist" })
map("n", "<leader>sr", telescope("registers"), { desc = "Registers" })
map("n", "<leader>sR", telescope("oldfiles"), { desc = "Recent files" })
map("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Todos" })
map("n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", { desc = "TODO/FIX" })

-- ─── [t] Terminal / Toggle ────────────────────────────────────────────────────
map("n", "<leader>tz", function()
	Snacks.zen()
end, { desc = "Zen mode" })
map("n", "<leader>tt", ":ToggleTerm direction=float dir=%:p:h<CR>i", { desc = "Terminal (float)" })
map("n", "<leader>th", ":ToggleTerm size=12 direction=horizontal dir=%:p:h<CR>i", { desc = "Terminal (h)" })
map("n", "<leader>tv", ":ToggleTerm size=80 direction=vertical dir=%:p:h<CR>i", { desc = "Terminal (v)" })
map({ "n", "t" }, "<C-\\>", function()
	local closing = vim.bo.buftype == "terminal"
	toggle_term()
	if not closing then
		vim.schedule(function()
			vim.cmd("startinsert")
		end)
	end
end, { desc = "Toggle terminal" })
map("n", "<leader>tg", function()
	_G.toggle_lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>tc", function()
	vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
end, { desc = "Toggle conceal" })
map("n", "<leader>ts", function()
	vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle spell" })
map("n", "<leader>tw", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle wrap" })
map("n", "<leader>tn", function()
	vim.opt.number = not vim.opt.number:get()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle numbers" })

-- ─── [w] Windows ──────────────────────────────────────────────────────────────
map("n", "<leader>wv", ":vsplit<CR>", { desc = "Vsplit" })
map("n", "<leader>w-", ":split<CR>", { desc = "Split" })
map("n", "<leader>wc", ":close<CR>", { desc = "Close win" })
map("n", "<leader>wo", ":only<CR>", { desc = "Only win" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize" })
map("n", "<leader>wh", "<C-w>h")
map("n", "<leader>wj", "<C-w>j")
map("n", "<leader>wk", "<C-w>k")
map("n", "<leader>wl", "<C-w>l")
map("n", "<leader>w+", ":resize +2<CR>", { desc = "Height +2" })
map("n", "<leader>w_", ":resize -2<CR>", { desc = "Height -2" })
map("n", "<leader>w>", ":vertical resize +2<CR>", { desc = "Width +2" })
map("n", "<leader>w<", ":vertical resize -2<CR>", { desc = "Width -2" })
