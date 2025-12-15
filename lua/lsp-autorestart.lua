-- LSP Auto-Restart
-- Automatically restarts LSP clients that crash or quit unexpectedly
-- with safeguards against infinite restart loops and server-level restart management

local M = {}

-- Configuration
local config = {
  max_restarts = 3,           -- Maximum restart attempts per server
  restart_window = 60000,     -- Time window in ms (1 minute)
  cooldown_period = 5000,     -- Cooldown before attempting restart (5 seconds)
  blacklist = {               -- Clients to never auto-restart
    "null-ls",
    "copilot",
    "spring-boot",
  },
  -- LSP to filetype/workspace mappings
  lsp_context = {
    jdtls = { filetypes = { "java" }, workspace_indicators = { "pom.xml", "build.gradle", ".gradle" } },
    clangd = { filetypes = { "c", "cpp", "objc", "objcpp" }, workspace_indicators = { "compile_commands.json", ".clangd", "CMakeLists.txt" } },
    rust_analyzer = { filetypes = { "rust" }, workspace_indicators = { "Cargo.toml", "Cargo.lock" } },
    pyright = { filetypes = { "python" }, workspace_indicators = { "pyproject.toml", "setup.py", "requirements.txt" } },
    gopls = { filetypes = { "go" }, workspace_indicators = { "go.mod", "go.sum" } },
    tsserver = { filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }, workspace_indicators = { "package.json", "tsconfig.json" } },
  },
}

-- State tracking (now per LSP server, not per buffer)
local restart_history = {}    -- Track restart attempts per server
local pending_restarts = {}   -- Track pending restart timers per server
local server_detach_count = {} -- Track detach events per server to restart only once

-- Helper: Check if buffer is valid and loaded
local function is_valid_buffer(bufnr)
  return bufnr
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buftype == ""
end

-- Helper: Find workspace root by looking for indicators
local function find_workspace_root(bufnr, indicators)
  local bufpath = vim.api.nvim_buf_get_name(bufnr)
  if bufpath == "" then return nil end

  local bufdir = vim.fn.fnamemodify(bufpath, ":h")

  -- Search upwards for workspace indicators
  local current = bufdir
  while current ~= "/" and current ~= "" do
    for _, indicator in ipairs(indicators) do
      local indicator_path = current .. "/" .. indicator
      if vim.fn.filereadable(indicator_path) == 1 or vim.fn.isdirectory(indicator_path) == 1 then
        return current
      end
    end
    current = vim.fn.fnamemodify(current, ":h")
  end

  return nil
end

-- Helper: Check if LSP is appropriate for current buffer context
local function is_lsp_appropriate_for_buffer(bufnr, client_name)
  local filetype = vim.bo[bufnr].filetype

  -- Check if we have context rules for this LSP
  local context = config.lsp_context[client_name]
  if not context then
    -- No context rules defined, allow by default (fallback to lspconfig)
    return true
  end

  -- Check filetype match
  local filetype_match = false
  if context.filetypes then
    for _, ft in ipairs(context.filetypes) do
      if ft == filetype then
        filetype_match = true
        break
      end
    end
  end

  -- If filetype doesn't match, LSP is not appropriate
  if not filetype_match then
    return false
  end

  -- Check workspace indicators if defined
  if context.workspace_indicators and #context.workspace_indicators > 0 then
    local workspace_root = find_workspace_root(bufnr, context.workspace_indicators)
    if not workspace_root then
      -- No workspace found, but filetype matches - allow for standalone files
      return true
    end
  end

  return true
end

-- Helper: Find any valid buffer that needs this LSP
local function find_buffer_for_lsp(client_name)
  local context = config.lsp_context[client_name]
  if not context or not context.filetypes then
    return nil
  end

  -- Get all loaded buffers
  local buffers = vim.api.nvim_list_bufs()

  for _, bufnr in ipairs(buffers) do
    if is_valid_buffer(bufnr) then
      local filetype = vim.bo[bufnr].filetype

      -- Check if buffer filetype matches LSP
      for _, ft in ipairs(context.filetypes) do
        if ft == filetype then
          -- Check if LSP is appropriate for this specific buffer
          if is_lsp_appropriate_for_buffer(bufnr, client_name) then
            return bufnr
          end
        end
      end
    end
  end

  return nil
end

-- Helper: Check if filetype has LSP support
local function has_lsp_config(filetype)
  if not filetype or filetype == "" then return false end

  -- Check if mason-lspconfig or lspconfig has a config for this filetype
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then return false end

  -- Get all available server configs
  local configs = require("lspconfig.util").available_servers()
  for _, server in ipairs(configs) do
    local server_config = lspconfig[server]
    if server_config and server_config.filetypes then
      for _, ft in ipairs(server_config.filetypes) do
        if ft == filetype then return true end
      end
    end
  end

  return false
end

-- Helper: Check if client is blacklisted
local function is_blacklisted(client_name)
  for _, name in ipairs(config.blacklist) do
    if client_name == name then return true end
  end
  return false
end

-- Helper: Check if restart limit reached (now per server)
local function can_restart(client_name)
  local history = restart_history[client_name]

  if not history then return true end

  local now = vim.loop.now()

  -- Clean up old entries outside the restart window
  local recent_restarts = {}
  for _, timestamp in ipairs(history) do
    if now - timestamp < config.restart_window then
      table.insert(recent_restarts, timestamp)
    end
  end

  restart_history[client_name] = recent_restarts

  -- Check if we've exceeded max restarts
  return #recent_restarts < config.max_restarts
end

-- Helper: Record restart attempt (now per server)
local function record_restart(client_name)
  if not restart_history[client_name] then
    restart_history[client_name] = {}
  end

  table.insert(restart_history[client_name], vim.loop.now())
end

-- Helper: Clear pending restart for a server
local function clear_pending_restart(client_name)
  if pending_restarts[client_name] then
    vim.loop.timer_stop(pending_restarts[client_name])
    pending_restarts[client_name] = nil
  end
end

-- Helper: Start LSP client for buffer
local function start_lsp_client(bufnr, client_name)
  if not is_valid_buffer(bufnr) then return end

  local filetype = vim.bo[bufnr].filetype

  -- Special handling for Java (nvim-java)
  if filetype == "java" and client_name == "jdtls" then
    local ok, lspconfig = pcall(require, "lspconfig")
    if ok then
      lspconfig.jdtls.setup({})
    end
    return
  end

  -- Standard LSP client start
  local ok, lspconfig = pcall(require, "lspconfig")
  if ok and lspconfig[client_name] then
    -- Attach to the specific buffer
    vim.api.nvim_buf_call(bufnr, function()
      lspconfig[client_name].manager:try_add_wrapper(bufnr)
    end)
  end
end

-- Main restart function (now server-level)
local function attempt_restart(client_name, client_id)
  -- Check if client is blacklisted
  if is_blacklisted(client_name) then return end

  -- Find a buffer that needs this LSP
  local target_bufnr = find_buffer_for_lsp(client_name)

  if not target_bufnr then
    vim.notify(
      string.format(
        "No appropriate buffer found for LSP '%s'. Skipping restart.",
        client_name
      ),
      vim.log.levels.DEBUG
    )
    clear_pending_restart(client_name)
    return
  end

  -- Check if we can restart (not hit limit)
  if not can_restart(client_name) then
    vim.notify(
      string.format(
        "LSP '%s' restart limit reached. Manual restart required.",
        client_name
      ),
      vim.log.levels.WARN
    )
    clear_pending_restart(client_name)
    return
  end

  -- Check if client is already running
  local clients = vim.lsp.get_clients({ name = client_name })
  if #clients > 0 then
    clear_pending_restart(client_name)
    return
  end

  -- Record the restart attempt
  record_restart(client_name)

  -- Attempt to restart
  vim.notify(
    string.format("Restarting LSP '%s' (attaching to buffer %d)", client_name, target_bufnr),
    vim.log.levels.INFO
  )

  start_lsp_client(target_bufnr, client_name)
  clear_pending_restart(client_name)
end

-- Schedule a restart with cooldown (now server-level)
local function schedule_restart(client_name, client_id)
  -- Clear any existing pending restart
  clear_pending_restart(client_name)

  -- Schedule new restart
  local timer = vim.loop.new_timer()
  pending_restarts[client_name] = timer

  timer:start(config.cooldown_period, 0, vim.schedule_wrap(function()
    attempt_restart(client_name, client_id)
  end))
end

-- Setup function
function M.setup(opts)
  -- Merge user config
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end

  -- Listen for LspDetach events (when client stops)
  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("LspAutoRestart", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client_id = args.data.client_id

      -- Get client info before it's gone
      local client = vim.lsp.get_client_by_id(client_id)
      if not client then return end

      local client_name = client.name

      -- Initialize detach counter for this server if needed
      if not server_detach_count[client_name] then
        server_detach_count[client_name] = 0
      end

      -- Increment detach count
      server_detach_count[client_name] = server_detach_count[client_name] + 1

      -- Only schedule restart on the first detach event
      -- (This prevents multiple restart attempts when the server detaches from multiple buffers)
      if server_detach_count[client_name] == 1 then
        -- Schedule restart after cooldown
        schedule_restart(client_name, client_id)

        -- Reset the counter after a short delay (after all detach events have fired)
        vim.defer_fn(function()
          server_detach_count[client_name] = 0
        end, 100)
      end
    end,
  })

  -- Clean up when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("LspAutoRestartCleanup", { clear = true }),
    callback = function()
      -- Stop all pending restart timers
      for _, timer in pairs(pending_restarts) do
        vim.loop.timer_stop(timer)
      end
      pending_restarts = {}
    end,
  })

  vim.notify("LSP Auto-Restart enabled with server-level restart tracking", vim.log.levels.INFO)
end

-- Command to manually reset restart limits
vim.api.nvim_create_user_command("LspRestartReset", function(opts)
  if opts.args ~= "" then
    -- Reset specific client
    local client_name = opts.args
    restart_history[client_name] = nil
    vim.notify(
      string.format("Reset restart limit for '%s'", client_name),
      vim.log.levels.INFO
    )
  else
    -- Reset all
    restart_history = {}
    vim.notify("Reset all LSP restart limits", vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = function()
    local clients = vim.lsp.get_clients()
    local names = {}
    for _, client in ipairs(clients) do
      table.insert(names, client.name)
    end
    return names
  end,
  desc = "Reset LSP restart limits (optionally for specific server)",
})

return M
