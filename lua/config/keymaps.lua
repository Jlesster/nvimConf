-- Keymaps Configuration (Organized by Category)
local keymap = vim.keymap.set

-- ============================================================================
-- BASIC EDITING
-- ============================================================================

-- Better escape
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("i", "<C-BS>", "<C-W>", { desc = "Enable CTRL+backspace to delete" })

-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting
keymap("n", "<", "<gv", { desc = "Unindent line" })
keymap("n", ">", ">gv", { desc = "Indent line" })
keymap("v", "<", "<gv", { desc = "Unindent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

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

-- Comment toggle
keymap("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
keymap("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- ============================================================================
-- NAVIGATION & MOVEMENT
-- ============================================================================

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

-- Fast navigation
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

-- Select all
keymap("n", "<C-a>", "gg0vG$", { desc = "Visually select all" })

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

-- ============================================================================
-- WINDOW MANAGEMENT (<leader>w)
-- ============================================================================

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
keymap("n", "<leader>w|", ":vsplit<CR>", { desc = "Vertical split" })
keymap("n", "<leader>w-", ":split<CR>", { desc = "Horizontal split" })
keymap("n", "<leader>wm", function()
  vim.ui.select(
    { "Vertical Split", "Horizontal Split", "Cancel" },
    { prompt = "Create Split:" },
    function(choice)
      if choice == "Vertical Split" then
        vim.cmd("vsplit")
      elseif choice == "Horizontal Split" then
        vim.cmd("split")
      end
    end
  )
end, { desc = "Split menu" })
keymap("n", "<leader>wc", function() vim.cmd("silent! close") end, { desc = "Close window" })

-- ============================================================================
-- FILE OPERATIONS (<leader>f)
-- ============================================================================

-- Browse Neovim config directory
keymap("n", "<leader>fa", function()
  Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Browse Neovim config" })

-- Browse Hyprland config directory
keymap("n", "<leader>fA", function()
  Snacks.picker.files({ cwd = "~/.config/hypr" })
end, { desc = "Browse Hyprland config" })

keymap("n", "<C-s>", ":w!<CR>", { desc = "Force write" })
keymap("n", "<leader>fs", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>fS", ":w!<CR>", { desc = "Force save file" })
keymap("n", "<leader>fn", ":enew<CR>", { desc = "New file" })
keymap("n", "<leader>fW", function()
  Snacks.input({
    prompt = "Sudo Password",
    icon = " ",
    secret = true,
  }, function(password)
    if password and password ~= "" then
      local filepath = vim.fn.expand("%:p")
      if filepath == "" then
        Snacks.notify("No file to save", { level = "warn" })
        return
      end

      local tmpfile = vim.fn.tempname()
      vim.cmd("silent! write! " .. vim.fn.fnameescape(tmpfile))

      vim.system(
        { "sh", "-c", string.format(
          "echo %s | sudo -S cp %s %s",
          vim.fn.shellescape(password),
          vim.fn.shellescape(tmpfile),
          vim.fn.shellescape(filepath)
        ) },
        { text = true },
        vim.schedule_wrap(function(result)
          vim.fn.delete(tmpfile)

          if result.code == 0 then
            vim.cmd("edit!")
            vim.bo.modified = false
            Snacks.notify("File saved with sudo ✓", { level = "info" })
          else
            Snacks.notify("Failed to save with sudo (wrong password?)", { level = "error" })
          end
        end)
      )
    end
  end)
end, { desc = "Write with sudo" })
keymap("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
keymap("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
keymap("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep in files" })
keymap("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Find word under cursor" })

-- ============================================================================
-- BUFFER MANAGEMENT (<leader>b)
-- ============================================================================

keymap("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete buffer" })
keymap("n", "<leader>bw", ":q<CR>", { desc = "Close Window" })
keymap("n", "<leader>c", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
keymap("n", "<leader>bD", function() Snacks.bufdelete.other() end, { desc = "Delete other buffers" })
keymap("n", "<leader>ba", function() Snacks.bufdelete.all() end, { desc = "Delete all buffers" })
keymap("n", "<leader>bp", function() Snacks.picker.buffers() end, { desc = "Pick buffer" })
keymap("n", "<leader>bb", function() Snacks.picker.buffers() end, { desc = "List buffers" })
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Prev Buffer" })

-- ============================================================================
-- SEARCH/FIND (<leader>s)
-- ============================================================================

keymap("n", "<leader>sf", function() Snacks.picker.files() end, { desc = "Find files" })
keymap("n", "<leader>sr", function() Snacks.picker.recent() end, { desc = "Recent files" })
keymap("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep in files" })
keymap("n", "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Find word" })
keymap("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Search in buffer" })
keymap("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help tags" })
keymap("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
keymap("n", "<leader>sc", function() Snacks.picker.commands() end, { desc = "Commands" })
keymap("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
keymap("n", "<leader>sn", function() Snacks.notifier.show_history() end, { desc = "Notification history" })

-- ============================================================================
-- EXPLORER/TREE (<leader>e)
-- ============================================================================

keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Neo-Tree" })
keymap("n", "<leader>r", ":Yazi <CR>", { desc = "Yazi" })

-- ============================================================================
-- QUICK TOGGLES (<leader>t)
-- ============================================================================

keymap("n", "<leader>te", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>i", ":AerialToggle<CR>", { desc = "Toggle Aerial" })
keymap("n", "<leader>tc", function()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
end, { desc = "Toggle conceal" })
keymap("n", "<leader>ts", function()
  vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle spell check" })
keymap("n", "<leader>tw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle wrap" })
keymap("n", "<leader>tz", function()
  if pcall(require, "zen-mode") then
    require("zen-mode").toggle()
  end
end, { desc = "Toggle Zen Mode" })
keymap("n", "<leader>tt", function()
  vim.ui.select(
    { "Float Terminal", "Horizontal Terminal", "Vertical Terminal", "Cancel" },
    { prompt = "Terminal Type:" },
    function(choice)
      if choice == "Float Terminal" then
        Snacks.terminal()
      elseif choice == "Horizontal Terminal" then
        Snacks.terminal(nil, { win = { position = "bottom", height = 0.3 } })
      elseif choice == "Vertical Terminal" then
        Snacks.terminal(nil, { win = { position = "right", width = 0.4 } })
      end
    end
  )
end, { desc = "Toggle terminal menu" })
keymap("n", "<leader>th", function() Snacks.terminal(nil, { win = { position = "bottom", height = 0.3 } }) end,
  { desc = "Terminal horizontal" })
keymap("n", "<leader>tv", function() Snacks.terminal(nil, { win = { position = "right", width = 0.4 } }) end,
  { desc = "Terminal vertical" })

-- Quick terminal toggles
keymap("n", "<F7>", function() Snacks.terminal(nil, { win = { position = "float" } }) end, { desc = "Toggle terminal" })
keymap("t", "<F7>", "<cmd>close<cr>", { desc = "Close terminal" })
keymap("n", "<C-'>", function() Snacks.terminal(nil, { win = { position = "float" } }) end, { desc = "Toggle terminal" })
keymap("t", "<C-'>", "<cmd>close<cr>", { desc = "Close terminal" })

-- Terminal navigation
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal left window navigation" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal down window navigation" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal up window navigation" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal right window navigation" })

-- ============================================================================
-- AI ASSISTANTS (<leader>a for AI, <leader>o for OpenCode)
-- ============================================================================

-- OpenCode
keymap("n", "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end,
  { desc = "Ask about this" })
keymap("x", "<leader>aa", function() require("opencode").ask("@this: ", { submit = true }) end,
  { desc = "Ask about selection" })
keymap("n", "<leader>aA", function() require("opencode").ask() end, { desc = "Ask (free-form)" })
keymap("n", "<leader>as", function() require("opencode").select() end, { desc = "Select action" })
keymap("x", "<leader>as", function() require("opencode").select() end, { desc = "Select action" })
keymap("n", "<leader>ao", function() require("opencode").toggle() end, { desc = "Toggle OpenCode" })
keymap("t", "<leader>ao", function() require("opencode").toggle() end, { desc = "Toggle OpenCode" })
keymap("n", "<leader>al", function() require("opencode").prompt("explain @this") end, { desc = "Explain code" })
keymap("x", "<leader>al", function() require("opencode").prompt("explain @this") end, { desc = "Explain selection" })
keymap("n", "<leader>ar", function() require("opencode").prompt("review @this") end, { desc = "Review code" })
keymap("x", "<leader>ar", function() require("opencode").prompt("review @this") end, { desc = "Review selection" })
keymap("n", "<leader>af", function() require("opencode").prompt("fix @diagnostics") end, { desc = "Fix diagnostics" })
keymap("n", "<leader>an", function() require("opencode").prompt("document @this") end, { desc = "Document code" })
keymap("x", "<leader>an", function() require("opencode").prompt("document @this") end, { desc = "Document selection" })
keymap("n", "<leader>at", function() require("opencode").prompt("test @this") end, { desc = "Generate tests" })
keymap("x", "<leader>at", function() require("opencode").prompt("test @this") end,
  { desc = "Generate tests for selection" })
keymap("n", "<leader>ap", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize code" })
keymap("x", "<leader>ap", function() require("opencode").prompt("optimize @this") end, { desc = "Optimize selection" })
keymap("n", "<leader>aw", function() require("opencode").prompt("@this") end, { desc = "Add context" })
keymap("x", "<leader>aw", function() require("opencode").prompt("@this") end, { desc = "Add selection" })
keymap("n", "<leader>aS", function() require("opencode").command("session.new") end, { desc = "New session" })
keymap("n", "<leader>aL", function() require("opencode").command("session.list") end, { desc = "List sessions" })
keymap("n", "<leader>ai", function() require("opencode").command("session.interrupt") end, { desc = "Interrupt" })

-- Quick opencode terminal toggle
keymap("n", "<C-;>", function()
  Snacks.terminal("opencode", {
    win = {
      position = "float",
      width = 0.9,
      height = 0.9,
    }
  })
end, { desc = "Toggle OpenCode terminal" })

-- Codeium
keymap("n", "<leader>ac", function() vim.cmd("Codeium Chat") end, { desc = "Open chat" })
keymap("n", "<leader>ae", function() vim.cmd("Codeium Enable") end, { desc = "Enable Codeium" })
keymap("n", "<leader>ad", function() vim.cmd("Codeium Disable") end, { desc = "Disable Codeium" })
keymap("n", "<leader>aT", function() vim.cmd("Codeium Toggle") end, { desc = "Toggle Codeium" })
keymap("n", "<leader>am", function()
  vim.ui.select(
    { "Open Chat", "Enable", "Disable", "Toggle", "Cancel" },
    { prompt = "Codeium Actions:" },
    function(choice)
      if choice == "Open Chat" then
        vim.cmd("Codeium Chat")
      elseif choice == "Enable" then
        vim.cmd("Codeium Enable")
      elseif choice == "Disable" then
        vim.cmd("Codeium Disable")
      elseif choice == "Toggle" then
        vim.cmd("Codeium Toggle")
      end
    end
  )
end, { desc = "AI" })

-- ============================================================================
-- LSP (<leader>l)
-- ============================================================================

keymap("n", "<leader>la", "<cmd>Lspsaga code_action<CR>", { desc = "Code action" })
keymap("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })
keymap("n", "<leader>lf", function() vim.lsp.buf.format() end, { desc = "Format" })
keymap("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line diagnostics" })
keymap("n", "<leader>li", ":LspInfo<CR>", { desc = "LSP info" })
keymap("n", "<leader>lR", ":LspRestart<CR>", { desc = "Restart LSP" })
keymap("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Outline" })

-- LSP Navigation
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to definition" })
keymap("n", "gD", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
keymap("n", "gi", "<cmd>Lspsaga finder imp<CR>", { desc = "Go to implementation" })
keymap("n", "gr", "<cmd>Lspsaga finder ref<CR>", { desc = "Go to references" })
keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Go to type definition" })
keymap("n", "gT", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek type definition" })
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover documentation" })
keymap("n", "<C-k>", "<cmd>Lspsaga signature_help<CR>", { desc = "Signature help" })

-- Diagnostics
keymap("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous diagnostic" })
keymap("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next diagnostic" })
keymap("n", "[e", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error" })
keymap("n", "]e", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })
keymap("n", "<leader>lb", "<cmd>Lspsaga show_buf_diagnostics<CR>", { desc = "Buffer diagnostics" })
keymap("n", "<leader>lD", "<cmd>Lspsaga show_workspace_diagnostics<CR>", { desc = "Workspace diagnostics" })

-- ============================================================================
-- GIT (<leader>g)
-- ============================================================================

keymap("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })
keymap("n", "<leader>gb", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").blame_line({ full = true })
  end
end, { desc = "Blame line" })
keymap("n", "<leader>gB", function() Snacks.picker.git_branches() end, { desc = "Branches" })
keymap("n", "<leader>gc", function() Snacks.picker.git_log() end, { desc = "Commits" })
keymap("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Status" })
keymap("n", "<leader>gd", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").diffthis()
  end
end, { desc = "Diff this" })
keymap("n", "<leader>gp", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").preview_hunk()
  end
end, { desc = "Preview hunk" })
keymap("n", "<leader>gr", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").reset_hunk()
  end
end, { desc = "Reset hunk" })
keymap("n", "<leader>gR", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").reset_buffer()
  end
end, { desc = "Reset buffer" })
keymap("n", "<leader>gS", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").stage_hunk()
  end
end, { desc = "Stage hunk" })
keymap("n", "<leader>gu", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").undo_stage_hunk()
  end
end, { desc = "Undo stage hunk" })

-- Git hunk navigation
keymap("n", "]g", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").next_hunk()
  end
end, { desc = "Next git hunk" })
keymap("n", "[g", function()
  if pcall(require, "gitsigns") then
    require("gitsigns").prev_hunk()
  end
end, { desc = "Previous git hunk" })

-- ============================================================================
-- DEBUGGER (<leader>d)
-- ============================================================================

keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
keymap("n", "<leader>dB", function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
    if condition then
      require("dap").set_breakpoint(condition)
    end
  end)
end, { desc = "Conditional breakpoint" })
keymap("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
keymap("n", "<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to cursor" })
keymap("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<leader>do", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<leader>dO", function() require("dap").step_out() end, { desc = "Step out" })
keymap("n", "<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
keymap("n", "<leader>dr", function() require("dap").restart_frame() end, { desc = "Restart" })
keymap("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
keymap("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle UI" })
keymap("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })
keymap("n", "<leader>de", function()
  vim.ui.input({ prompt = "Expression: " }, function(expr)
    if expr then
      require("dapui").eval(expr)
    end
  end)
end, { desc = "Evaluate expression" })
keymap("x", "<leader>de", function() require("dapui").eval() end, { desc = "Evaluate selection" })
keymap("n", "<leader>dm", function()
  vim.ui.select(
    { "Continue/Start", "Pause", "Stop", "Restart", "Toggle Breakpoint", "Clear Breakpoints", "Cancel" },
    { prompt = "Debug Actions:" },
    function(choice)
      if choice == "Continue/Start" then
        require("dap").continue()
      elseif choice == "Pause" then
        require("dap").pause()
      elseif choice == "Stop" then
        require("dap").terminate()
      elseif choice == "Restart" then
        require("dap").restart_frame()
      elseif choice == "Toggle Breakpoint" then
        require("dap").toggle_breakpoint()
      elseif choice == "Clear Breakpoints" then
        require("dap").clear_breakpoints()
      end
    end
  )
end, { desc = "Debug menu" })

-- Function keys for debugging
keymap("n", "<F5>", function() require("dap").continue() end, { desc = "Continue" })
keymap("n", "<F10>", function() require("dap").step_over() end, { desc = "Step over" })
keymap("n", "<F11>", function() require("dap").step_into() end, { desc = "Step into" })
keymap("n", "<F12>", function() require("dap").step_out() end, { desc = "Step out" })

-- ============================================================================
-- JAVA (<leader>j)
-- ============================================================================

keymap("n", "<leader>jo", function()
  if vim.bo.filetype == "java" then
    require("jdtls").organize_imports()
  end
end, { desc = "Organize imports" })
keymap("n", "<leader>jv", function()
  if vim.bo.filetype == "java" then
    require("jdtls").extract_variable()
  end
end, { desc = "Extract variable" })
keymap("x", "<leader>jv", function()
  if vim.bo.filetype == "java" then
    require("jdtls").extract_variable(true)
  end
end, { desc = "Extract variable" })
keymap("n", "<leader>jc", function()
  if vim.bo.filetype == "java" then
    require("jdtls").extract_constant()
  end
end, { desc = "Extract constant" })
keymap("x", "<leader>jc", function()
  if vim.bo.filetype == "java" then
    require("jdtls").extract_constant(true)
  end
end, { desc = "Extract constant" })
keymap("x", "<leader>jm", function()
  if vim.bo.filetype == "java" then
    require("jdtls").extract_method(true)
  end
end, { desc = "Extract method" })
keymap("n", "<leader>jt", function()
  if vim.bo.filetype == "java" then
    require("jdtls").test_class()
  end
end, { desc = "Test class" })
keymap("n", "<leader>jn", function()
  if vim.bo.filetype == "java" then
    require("jdtls").test_nearest_method()
  end
end, { desc = "Test method" })

-- ============================================================================
-- COMPILER & BUILD (<leader>m)
-- ============================================================================

keymap("n", "<leader>mm", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<leader>mr", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<leader>mt", ":CompilerToggleResults<CR>", { desc = "Toggle results" })
keymap("n", "<F6>", ":CompilerOpen<CR>", { desc = "Open compiler" })
keymap("n", "<S-F6>", ":CompilerRedo<CR>", { desc = "Compiler redo" })
keymap("n", "<S-F7>", ":CompilerToggleResults<CR>", { desc = "Toggle results" })
keymap("n", "<F8>", ":OverseerToggle<CR>", { desc = "Toggle Overseer" })

-- ============================================================================
-- HOME SCREEN
-- ============================================================================

keymap("n", "<leader>h", function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins > 1 and vim.api.nvim_get_option_value("filetype", {}) == "neo-tree" then
    vim.fn.win_gotoid(wins[2])
  end
  Snacks.dashboard()
end, { desc = "Home screen" })

-- ============================================================================
-- AUTOCOMMANDS FOR SPECIAL KEYMAPS
-- ============================================================================

-- Make q close help, man, quickfix, dap floats
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
