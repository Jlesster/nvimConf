-- LSP Auto-Restart
-- Automatically restarts LSP clients that crash or quit unexpectedly
-- with safeguards against infinite restart loops

local M = {}

-- Configuration
local config = {
  max_restarts = 3,           -- Maximum restart attempts per buffer
  restart_window = 60000,     -- Time window in ms (1 minute)
  cooldown_period = 5000,     -- Cooldown before attempting restart (5 seconds)
  blacklist = {               -- Clients to never auto-restart
    "null-ls",
    "copilot",
  },
}

-- State tracking
local restart_history = {}    -- Track restart attempts per buffer/client
local pending_restarts = {}   -- Track pending restart timers

-- Helper: Check if buffer is valid and loaded
local function is_valid_buffer(bufnr)
  return bufnr
    and vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].buftype == ""
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

-- Helper: Get restart key for tracking
local function get_restart_key(bufnr, client_name)
  return string.format("%d:%s", bufnr, client_name)
end

-- Helper: Check if restart limit reached
local function can_restart(bufnr, client_name)
  local key = get_restart_key(bufnr, client_name)
  local history = restart_history[key]

  if not history then return true end

  local now = vim.loop.now()

  -- Clean up old entries outside the restart window
  local recent_restarts = {}
  for _, timestamp in ipairs(history) do
    if now - timestamp < config.restart_window then
      table.insert(recent_restarts, timestamp)
    end
  end

  restart_history[key] = recent_restarts

  -- Check if we've exceeded max restarts
  return #recent_restarts < config.max_restarts
end

-- Helper: Record restart attempt
local function record_restart(bufnr, client_name)
  local key = get_restart_key(bufnr, client_name)

  if not restart_history[key] then
    restart_history[key] = {}
  end

  table.insert(restart_history[key], vim.loop.now())
end

-- Helper: Clear pending restart for a buffer/client
local function clear_pending_restart(bufnr, client_name)
  local key = get_restart_key(bufnr, client_name)

  if pending_restarts[key] then
    vim.loop.timer_stop(pending_restarts[key])
    pending_restarts[key] = nil
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

-- Main restart function
local function attempt_restart(bufnr, client_name, client_id)
  -- Validate buffer
  if not is_valid_buffer(bufnr) then
    clear_pending_restart(bufnr, client_name)
    return
  end

  -- Check if client is blacklisted
  if is_blacklisted(client_name) then return end

  -- Check if filetype still needs LSP
  local filetype = vim.bo[bufnr].filetype
  if not has_lsp_config(filetype) then return end

  -- Check if we can restart (not hit limit)
  if not can_restart(bufnr, client_name) then
    vim.notify(
      string.format(
        "LSP '%s' restart limit reached for buffer %d. Manual restart required.",
        client_name,
        bufnr
      ),
      vim.log.levels.WARN
    )
    clear_pending_restart(bufnr, client_name)
    return
  end

  -- Check if client is already running on this buffer
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = client_name })
  if #clients > 0 then
    clear_pending_restart(bufnr, client_name)
    return
  end

  -- Record the restart attempt
  record_restart(bufnr, client_name)

  -- Attempt to restart
  vim.notify(
    string.format("Restarting LSP '%s' for buffer %d", client_name, bufnr),
    vim.log.levels.INFO
  )

  start_lsp_client(bufnr, client_name)
  clear_pending_restart(bufnr, client_name)
end

-- Schedule a restart with cooldown
local function schedule_restart(bufnr, client_name, client_id)
  local key = get_restart_key(bufnr, client_name)

  -- Clear any existing pending restart
  clear_pending_restart(bufnr, client_name)

  -- Schedule new restart
  local timer = vim.loop.new_timer()
  pending_restarts[key] = timer

  timer:start(config.cooldown_period, 0, vim.schedule_wrap(function()
    attempt_restart(bufnr, client_name, client_id)
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

      -- Only restart if buffer is still valid and client stopped unexpectedly
      if is_valid_buffer(bufnr) then
        -- Schedule restart after cooldown
        schedule_restart(bufnr, client_name, client_id)
      end
    end,
  })

  -- Clean up pending restarts when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("LspAutoRestartCleanup", { clear = true }),
    callback = function(args)
      local bufnr = args.buf

      -- Clear all pending restarts for this buffer
      for key, timer in pairs(pending_restarts) do
        if key:match("^" .. bufnr .. ":") then
          vim.loop.timer_stop(timer)
          pending_restarts[key] = nil
        end
      end

      -- Clear restart history for this buffer
      for key in pairs(restart_history) do
        if key:match("^" .. bufnr .. ":") then
          restart_history[key] = nil
        end
      end
    end,
  })

  vim.notify("LSP Auto-Restart enabled", vim.log.levels.INFO)
end

-- Command to manually reset restart limits
vim.api.nvim_create_user_command("LspRestartReset", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()

  if opts.args ~= "" then
    -- Reset specific client
    local client_name = opts.args
    local key = get_restart_key(bufnr, client_name)
    restart_history[key] = nil
    vim.notify(
      string.format("Reset restart limit for '%s' on buffer %d", client_name, bufnr),
      vim.log.levels.INFO
    )
  else
    -- Reset all for current buffer
    for key in pairs(restart_history) do
      if key:match("^" .. bufnr .. ":") then
        restart_history[key] = nil
      end
    end
    vim.notify("Reset all restart limits for current buffer", vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local names = {}
    for _, client in ipairs(clients) do
      table.insert(names, client.name)
    end
    return names
  end,
  desc = "Reset LSP restart limits (optionally for specific client)",
})

return M
