-- Keymaps Configuration
local keymap = vim.keymap.set

-- Better escape
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("i", "<C-BS>", "<C-W>", { desc = "Enable CTRL+backspace to delete" })

-- Save and quit
keymap("n", "<C-s>", ":w!<CR>", { desc = "Force write" })
keymap("n", "<leader>q", function()
  local choice = vim.fn.confirm("Do you really want to exit nvim?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.cmd('confirm quit')
  end
end, { desc = "Quit" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Save" })
keymap("n", "<leader>n", ":enew<CR>", { desc = "New file" })
keymap("n", "<leader>W", function() vim.cmd("SudaWrite") end, { desc = "Save as Sudo" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Resize split up" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Resize split down" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize split left" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize split right" })

-- Splits
keymap("n", "|", ":vsplit<CR>", { desc = "Vertical Split" })
keymap("n", "\\", ":split<CR>", { desc = "Horizontal Split" })

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap("n", "<leader>ba", ":wa<CR>", { desc = "Write all changed buffers" })
keymap("n", "<leader>c", '<cmd>Bdelete<CR>', { desc = "Close buffer" })
keymap("n", "<leader>bw", function() vim.cmd("silent! close") end, { desc = "Close window" })

-- Tab navigation
keymap("n", "]t", ":tabnext<CR>", { desc = "Next tab" })
keymap("n", "[t", ":tabprevious<CR>", { desc = "Previous tab" })

-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Unindent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

-- Keep centered
keymap("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap("n", "n", "nzzzv", { desc = "Next search result centered" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Improved movement
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move cursor down" })
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move cursor up" })
keymap("n", "0", "^", { desc = "Go to first character of line" })

-- Improved gg/G
keymap("n", "gg", function()
  if vim.v.count > 0 then
    vim.cmd("normal! " .. vim.v.count .. "gg")
  else
    vim.cmd("normal! gg0")
  end
end, { desc = "Go to first line and first position" })

keymap("n", "G", "G$", { desc = "Go to last line and last position" })

-- Select all
keymap("n", "<C-a>", "gg0vG$", { desc = "Visually select all" })

-- Clipboard operations
keymap("n", "c", '"_c', { desc = "Change without yanking" })
keymap("n", "C", '"_C', { desc = "Change without yanking" })
keymap("x", "c", '"_c', { desc = "Change without yanking" })
keymap("x", "C", '"_C', { desc = "Change without yanking" })

-- Smart x - delete blank lines and characters without yanking
keymap("n", "x", function()
  if vim.fn.col "." == 1 then
    local line = vim.fn.getline "."
    if line:match "^%s*$" then
      vim.api.nvim_feedkeys('"_dd', "n", false)
      vim.api.nvim_feedkeys("$", "n", false)
    else
      vim.api.nvim_feedkeys('"_x', "n", false)
    end
  else
    vim.api.nvim_feedkeys('"_x', "n", false)
  end
end, { desc = "Delete character without yanking" })

keymap("n", "X", function()
  if vim.fn.col "." == 1 then
    local line = vim.fn.getline "."
    if line:match "^%s*$" then
      vim.api.nvim_feedkeys('"_dd', "n", false)
      vim.api.nvim_feedkeys("$", "n", false)
    else
      vim.api.nvim_feedkeys('"_X', "n", false)
    end
  else
    vim.api.nvim_feedkeys('"_X', "n", false)
  end
end, { desc = "Delete before character without yanking" })

keymap("x", "x", '"_x', { desc = "Delete without yanking" })

-- Better paste in visual mode
keymap("x", "p", "P", { desc = "Paste without yanking" })
keymap("x", "P", "p", { desc = "Paste and yank" })

-- Clear search highlighting
keymap("n", "<ESC>", function()
  if vim.fn.hlexists("Search") then
    vim.cmd("nohlsearch")
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<ESC>", true, true, true),
      "n",
      true
    )
  end
end, { desc = "Clear search highlighting" })

-- Comment toggle
keymap("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
keymap("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- Shifted movement keys - fast navigation
keymap("n", "<S-Down>", "7j", { desc = "Fast move down" })
keymap("n", "<S-Up>", "7k", { desc = "Fast move up" })

-- Page navigation (20% of buffer)
keymap("n", "<S-PageDown>", function()
  local current_line = vim.fn.line "."
  local total_lines = vim.fn.line "$"
  local target_line = current_line + 1 + math.floor(total_lines * 0.20)
  if target_line > total_lines then target_line = total_lines end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page down 20%" })

keymap("n", "<S-PageUp>", function()
  local current_line = vim.fn.line "."
  local target_line = current_line - 1 - math.floor(vim.fn.line "$" * 0.20)
  if target_line < 1 then target_line = 1 end
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page up 20%" })

-- File explorer (Neo-tree)
keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Telescope
keymap("n", "<leader>ff", ":Telescope live_grep<CR>", { desc = "Find words in project" })
keymap("n", "<leader>fF", ":Telescope live_grep hidden=false no_ignore=false<CR>", { desc = "Find words (no hidden)" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fB", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })
keymap("n", "<leader>fo", ":Telescope oldfiles<CR>", { desc = "Recent files" })
keymap("n", "<leader>fw", ":Telescope grep_string<CR>", { desc = "Find word under cursor" })
keymap("n", "<leader>f/", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current buffer" })
keymap("n", "<leader>fk", ":Telescope keymaps<CR>", { desc = "Find keymaps" })
keymap("n", "<leader>fv", ":Telescope registers<CR>", { desc = "Find vim registers" })
keymap("n", "<leader>ft", ":Telescope colorscheme enable_preview=true<CR>", { desc = "Find themes" })
keymap("n", "<leader>f'", ":Telescope marks<CR>", { desc = "Find marks" })
keymap("n", "<leader>fC", ":Telescope commands<CR>", { desc = "Find commands" })
keymap("n", "<leader>f<CR>", ":Telescope resume<CR>", { desc = "Resume previous search" })
keymap("n", "<leader>fp", function() vim.cmd("Telescope projects") end, { desc = "Find Project" })
keymap("n", "<leader>fa", function()
  require("telescope.builtin").find_files({
    prompt_title = "Config Files",
    search_dirs = { vim.fn.stdpath("config") },
    cwd = vim.fn.stdpath("config"),
    follow = true,
  })
end, { desc = "Find nvim config files" })

-- Git (Telescope)
keymap("n", "<leader>gb", ":Telescope git_branches<CR>", { desc = "Git branches" })
keymap("n", "<leader>gc", ":Telescope git_commits<CR>", { desc = "Git commits (repository)" })
keymap("n", "<leader>gC", ":Telescope git_bcommits<CR>", { desc = "Git commits (current file)" })
keymap("n", "<leader>gt", ":Telescope git_status<CR>", { desc = "Git status" })

-- Git client (LazyGit/GitUI)
keymap("n", "<leader>gg", function()
  local git_dir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
  if git_dir ~= "" then
    if vim.fn.executable("lazygit") == 1 then
      vim.cmd("ToggleTerm cmd='lazygit' direction=float")
    elseif vim.fn.executable("gitui") == 1 then
      vim.cmd("ToggleTerm cmd='gitui' direction=float")
    else
      vim.notify("No git UI found (install lazygit or gitui)", vim.log.levels.WARN)
    end
  else
    vim.notify("Not a git repository", vim.log.levels.WARN)
  end
end, { desc = "LazyGit/GitUI" })

-- Yazi file manager
keymap("n", "<leader>r", ":Yazi<CR>", { desc = "File browser" })

-- Terminal (ToggleTerm)
keymap("n", "<leader>tt", ":ToggleTerm direction=float<CR>", { desc = "Toggle terminal float" })
keymap("n", "<leader>th", ":ToggleTerm size=10 direction=horizontal<CR>", { desc = "Toggle terminal horizontal" })
keymap("n", "<leader>tv", ":ToggleTerm size=80 direction=vertical<CR>", { desc = "Toggle terminal vertical" })
keymap("n", "<F7>", ":1ToggleTerm dorection=float<CR>", { desc = "Toggle terminal" })
keymap("t", "<F7>", "<C-\\><C-n>:1ToggleTerm<CR>", { desc = "Toggle terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-'>", ":1ToggleTerm direction=float<CR>", { desc = "Toggle terminal" })
keymap("t", "<C-'>", "<C-\\><C-n>:1ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Terminal navigation
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal left window navigation" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal down window navigation" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal up window navigation" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal right window navigation" })

-- Compiler (if available)
keymap("n", "<leader>mm", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<leader>mr", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<leader>mt", ":CompilerToggleResults<CR>", { desc = "Compiler results" })
keymap("n", "<F6>", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<S-F6>", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<S-F7>", ":CompilerToggleResults<CR>", { desc = "Compiler toggle results" })
keymap("n", "<F8>", ":OverseerToggle<CR>", { desc = "Toggle Overseer" })

-- Debugger (DAP)
keymap("n", "<F5>", function() require("dap").continue() end, { desc = "Debugger: Start/Continue" })
keymap("n", "<S-F5>", function() require("dap").terminate() end, { desc = "Debugger: Stop" })
keymap("n", "<C-F5>", function() require("dap").restart_frame() end, { desc = "Debugger: Restart" })
keymap("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap("n", "<S-F9>", function()
  vim.ui.input({ prompt = "Condition: " }, function(condition)
    if condition then require("dap").set_breakpoint(condition) end
  end)
end, { desc = "Conditional breakpoint" })
keymap("n", "<F10>", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<S-F10>", function() require("dap").step_back() end, { desc = "Step back" })
keymap("n", "<F11>", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<S-F11>", function() require("dap").step_out() end, { desc = "Step out" })

-- DAP leader mappings
keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap("n", "<leader>dB", function() require("dap").clear_breakpoints() end, { desc = "Clear breakpoints" })
keymap("n", "<leader>dc", function() require("dap").continue() end, { desc = "Start/Continue" })
keymap("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step out" })
keymap("n", "<leader>dq", function() require("dap").close() end, { desc = "Close session" })
keymap("n", "<leader>dQ", function() require("dap").terminate() end, { desc = "Terminate session" })
keymap("n", "<leader>dr", function() require("dap").restart_frame() end, { desc = "Restart" })
keymap("n", "<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
keymap("n", "<leader>dR", function() require("dap").repl.toggle() end, { desc = "REPL" })

-- DAP UI
keymap("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })
keymap("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debugger hover" })
keymap("n", "<leader>dE", function()
  vim.ui.input({ prompt = "Expression: " }, function(expr)
    if expr then require("dapui").eval(expr, { enter = true }) end
  end)
end, { desc = "Evaluate expression" })
keymap("x", "<leader>dE", function() require("dapui").eval() end, { desc = "Evaluate selection" })

-- Aerial (code outline)
keymap("n", "<leader>i", function() require("aerial").toggle() end, { desc = "Toggle Aerial" })

-- Gitsigns
keymap("n", "]g", function() require("gitsigns").nav_hunk('next') end, { desc = "Next Git hunk" })
keymap("n", "[g", function() require("gitsigns").nav_hunk('prev') end, { desc = "Previous Git hunk" })
keymap("n", "<leader>gl", function() require("gitsigns").blame_line() end, { desc = "View Git blame" })
keymap("n", "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, { desc = "View full Git blame" })
keymap("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview Git hunk" })
keymap("n", "<leader>gh", function() require("gitsigns").reset_hunk() end, { desc = "Reset Git hunk" })
keymap("n", "<leader>gr", function() require("gitsigns").reset_buffer() end, { desc = "Reset Git buffer" })
keymap("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage Git hunk" })
keymap("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage Git buffer" })
keymap("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Unstage Git hunk" })
keymap("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "View Git diff" })

-- Code Folding (nvim-ufo)
keymap("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
keymap("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
keymap("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Fold less" })
keymap("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Fold more" })
keymap("n", "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, { desc = "Peek fold" })

-- OpenCode (AI assistant)
keymap("n", "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode about this" })
keymap("x", "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode about selection" })
keymap("n", "<leader>oA", function() require("opencode").ask() end, { desc = "Ask opencode (free-form)" })
keymap("n", "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action" })
keymap("x", "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action" })
keymap("n", "<leader>oo", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
keymap("t", "<leader>oo", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
keymap("n", "<leader>oe", function() require("opencode").prompt("explain @this") end, { desc = "Explain this code" })
keymap("x", "<leader>oe", function() require("opencode").prompt("explain @this") end, { desc = "Explain selection" })
keymap("n", "<leader>or", function() require("opencode").prompt("review @this") end, { desc = "Review this code" })
keymap("x", "<leader>or", function() require("opencode").prompt("review @this") end, { desc = "Review selection" })
keymap("n", "<leader>of", function() require("opencode").prompt("fix @diagnostics") end, { desc = "Fix diagnostics" })
keymap("n", "<leader>od", function() require("opencode").prompt("document @this") end, { desc = "Document this code" })
keymap("x", "<leader>od", function() require("opencode").prompt("document @this") end, { desc = "Document selection" })
keymap("n", "<leader>ot", function() require("opencode").prompt("test @this") end, { desc = "Generate tests" })
keymap("x", "<leader>ot", function() require("opencode").prompt("test @this") end, { desc = "Generate tests for selection" })
keymap("n", "<leader>op", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize this code" })
keymap("x", "<leader>op", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize selection" })
keymap("n", "<leader>oc", function() require("opencode").prompt("@this") end, { desc = "Add context to opencode" })
keymap("x", "<leader>oc", function() require("opencode").prompt("@this") end, { desc = "Add selection to opencode" })
keymap("n", "<leader>on", function() require("opencode").command("session.new") end, { desc = "New opencode session" })
keymap("n", "<leader>ol", function() require("opencode").command("session.list") end, { desc = "List opencode sessions" })
keymap("n", "<leader>oi", function() require("opencode").command("session.interrupt") end, { desc = "Interrupt opencode" })

-- Quick opencode terminal toggle
keymap("n", "<C-;>", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local opencode_term = Terminal:new({
    id = 2,
    cmd = "opencode",
    direction = "float",
    float_opts = {
      width = function() return math.floor(vim.o.columns * 0.9) end,
      height = function() return math.floor(vim.o.lines * 0.9) end,
    },
  })
  opencode_term:toggle()
end, { desc = "Toggle opencode terminal" })
keymap("t", "<C-;>", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local opencode_term = Terminal:new({
    id = 2,
    cmd = "opencode",
    direction = "float",
    float_opts = {
      width = function() return math.floor(vim.o.columns * 0.9) end,
      height = function() return math.floor(vim.o.lines * 0.9) end,
    },
  })
  opencode_term:toggle()
end, { desc = "Toggle opencode terminal" })

-- Alpha dashboard (home screen)
keymap("n", "<leader>h", function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins > 1 and vim.api.nvim_get_option_value("filetype", {}) == "neo-tree" then
    vim.fn.win_gotoid(wins[2])
  end
  require("alpha").start(false, require("alpha").default_config)
end, { desc = "Home screen" })

-- Special autocommands for q to close certain windows
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Make q close help, man, quickfix, dap floats",
  callback = function(args)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) then
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
    end
  end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
  desc = "Make q close command history (q: and q?)",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
  end,
})

-- Diagnostic keymaps
keymap("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
keymap("n", "gl", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
keymap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
keymap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
keymap("n", "<leader>lD", ":Telescope diagnostics<CR>", { desc = "Telescope diagnostics" })

-- LSP keymaps (only work when LSP is attached)
-- These are typically set up in your LSP config, but here are the basic ones:
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap("n", "gI", vim.lsp.buf.implementation, { desc = "Go to implementation" })
keymap("n", "gT", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
keymap("n", "gh", vim.lsp.buf.hover, { desc = "Hover help" })
keymap("n", "gH", vim.lsp.buf.signature_help, { desc = "Signature help" })
keymap("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
keymap("v", "<leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
keymap("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
keymap("v", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format selection" })
keymap("n", "<leader>li", ":LspInfo<CR>", { desc = "LSP info" })
keymap("n", "<leader>lL", ":LspRestart<CR>", { desc = "LSP restart" })
keymap("n", "<leader>ls", ":Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
keymap("n", "gs", ":Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
keymap("n", "<leader>lS", ":Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
keymap("n", "gS", ":Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
