-- ============================================================================
-- FILE: ftplugin/java.lua
-- Java LSP configuration using nvim-jdtls
-- Place this in: ~/.config/nvim/ftplugin/java.lua
-- ============================================================================

-- Only load once per buffer
if vim.b.did_ftplugin_java then
  return
end
vim.b.did_ftplugin_java = true

local ok, jdtls = pcall(require, 'jdtls')
if not ok then
  vim.notify('nvim-jdtls not found', vim.log.levels.ERROR)
  return
end

-- Find root directory
local root_markers = {
  'gradlew', 'mvnw', '.git', 'pom.xml',
  'build.gradle', 'build.gradle.kts',
}
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  return
end

-- Workspace directory
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name
vim.fn.mkdir(workspace_dir, 'p')

-- Mason paths
local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local config_dir = mason_path .. '/config_linux'
local plugins_dir = mason_path .. '/plugins'
local lombok_jar = mason_path .. '/lombok.jar'

-- Check if lombok exists
local has_lombok = vim.fn.filereadable(lombok_jar) == 1

-- Find launcher jar
local launcher_path = vim.fn.glob(plugins_dir .. '/org.eclipse.equinox.launcher_*.jar')
if launcher_path == '' then
  vim.notify('jdtls launcher not found. Install via :Mason', vim.log.levels.ERROR)
  return
end

-- Get bundles for debugging (optional)
local bundles = {}
local function add_bundle_dir(dir)
  if vim.fn.isdirectory(dir) == 1 then
    for _, bundle in ipairs(vim.split(vim.fn.glob(dir .. '/*.jar'), '\n')) do
      if bundle ~= '' then
        table.insert(bundles, bundle)
      end
    end
  end
end

-- Add java-debug-adapter if installed
add_bundle_dir(vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter/extension/server')
-- Add java-test if installed
add_bundle_dir(vim.fn.stdpath('data') .. '/mason/packages/java-test/extension/server')

-- Get capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Attach function
local on_attach = function(client, bufnr)
  -- Call global on_attach first if exists
  if _G.lsp_on_attach then
    _G.lsp_on_attach(client, bufnr)
  end

  -- Enable semantic tokens and ensure they work with Treesitter
  if client.server_capabilities.semanticTokensProvider then
    -- Configure semantic token highlights to complement Treesitter
    vim.api.nvim_set_hl(0, '@lsp.type.class.java', { link = '@type' })
    vim.api.nvim_set_hl(0, '@lsp.type.interface.java', { link = '@type' })
    vim.api.nvim_set_hl(0, '@lsp.type.enum.java', { link = '@type' })
    vim.api.nvim_set_hl(0, '@lsp.type.method.java', { link = '@function.method' })
    vim.api.nvim_set_hl(0, '@lsp.type.variable.java', { link = '@variable' })
    vim.api.nvim_set_hl(0, '@lsp.type.parameter.java', { link = '@parameter' })
    vim.api.nvim_set_hl(0, '@lsp.type.property.java', { link = '@property' })
    vim.api.nvim_set_hl(0, '@lsp.type.namespace.java', { link = '@namespace' })
    vim.api.nvim_set_hl(0, '@lsp.type.annotation.java', { link = '@attribute' })

    -- Start semantic tokens
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end

  -- Java-specific keymaps
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set('n', '<leader>jo', jdtls.organize_imports,
    vim.tbl_extend("force", opts, { desc = "Java: Organize Imports" }))
  vim.keymap.set('n', '<leader>jv', jdtls.extract_variable,
    vim.tbl_extend("force", opts, { desc = "Java: Extract Variable" }))
  vim.keymap.set('v', '<leader>jv', [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]],
    vim.tbl_extend("force", opts, { desc = "Java: Extract Variable" }))
  vim.keymap.set('n', '<leader>jc', jdtls.extract_constant,
    vim.tbl_extend("force", opts, { desc = "Java: Extract Constant" }))
  vim.keymap.set('v', '<leader>jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
    vim.tbl_extend("force", opts, { desc = "Java: Extract Method" }))
end

-- JDTLS config
local cmd = {
  'java',

  '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  '-Dosgi.bundles.defaultStartLevel=4',
  '-Declipse.product=org.eclipse.jdt.ls.core.product',
  '-Dlog.protocol=true',
  '-Dlog.level=ALL',
  '-Xms1g',
  '-Xmx2g',
  '--add-modules=ALL-SYSTEM',
  '--add-opens', 'java.base/java.util=ALL-UNNAMED',
  '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
}

-- Add Lombok if available
if has_lombok then
  table.insert(cmd, '-javaagent:' .. lombok_jar)
end

-- Add remaining cmd arguments
vim.list_extend(cmd, {
  '-jar', launcher_path,
  '-configuration', config_dir,
  '-data', workspace_dir,
})

local config = {
  cmd = cmd,

  root_dir = root_dir,
  capabilities = capabilities,
  on_attach = on_attach,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
        updateSnapshots = true,
      },
      implementationCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      signatureHelp = {
        enabled = true,
      },
      contentProvider = {
        preferred = 'fernflower'
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.Assert.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.lwjgl.glfw.GLFW.*",
          "org.lwjgl.opengl.GL11.*",
          "org.lwjgl.opengl.GL20.*",
          "org.lwjgl.opengl.GL30.*",
          "org.lwjgl.opengl.GL33.*",
          "org.lwjgl.opengl.GL45.*",
          "org.lwjgl.vulkan.VK10.*",
          "org.lwjgl.system.MemoryUtil.*",
          "org.lwjgl.system.MemoryStack.*",
          "imgui.ImGui.*",
          "imgui.flag.ImGuiWindowFlags.*",
          "imgui.flag.ImGuiCol.*",
          "imgui.type.ImBoolean.*",
          "imgui.type.ImInt.*",
          "imgui.type.ImFloat.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "sun.*",
          "jdk.*",
        },
        importOrder = {
          "java",
          "javax",
          "org.lwjgl",
          "imgui",
          "org",
          "com",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = vim.fn.expand("~/.sdkman/candidates/java/8.0.432-tem"),
          },
          {
            name = "JavaSE-11",
            path = vim.fn.expand("~/.sdkman/candidates/java/11.0.25-tem"),
          },
          {
            name = "JavaSE-17",
            path = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-tem"),
          },
          {
            name = "JavaSE-21",
            path = vim.fn.expand("~/.sdkman/candidates/java/21.0.5-tem"),
          },
        },
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "single",
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "single",
    }),
  },
}

-- Start jdtls
jdtls.start_or_attach(config)

-- Command to check if both highlighting methods are active (for debugging)
vim.api.nvim_create_user_command('JavaHighlightStatus', function()
  local buf = vim.api.nvim_get_current_buf()
  local ts_ok, ts_highlight = pcall(require, 'nvim-treesitter.highlight')
  local ts_enabled = false

  -- Check if Treesitter is enabled more safely
  if ts_ok then
    -- Try different methods to check if enabled
    if type(ts_highlight.is_enabled) == 'function' then
      ts_enabled = ts_highlight.is_enabled(buf)
    else
      -- Fallback: check if highlighter exists
      local highlighter_ok, ts_highlighter = pcall(require, 'vim.treesitter.highlighter')
      if highlighter_ok and ts_highlighter.active then
        ts_enabled = ts_highlighter.active[buf] ~= nil
      end
    end
  end

  -- Check for semantic tokens
  local clients = vim.lsp.get_clients({ bufnr = buf })
  local semantic_active = false
  for _, client_item in ipairs(clients) do
    if client_item.server_capabilities.semanticTokensProvider then
      semantic_active = true
      break
    end
  end

  print(string.format(
    "Treesitter: %s | Semantic Tokens: %s",
    ts_enabled and "✓ Active" or "✗ Inactive",
    semantic_active and "✓ Active" or "✗ Inactive"
  ))
end, {})
