-- ============================================================================
-- RECOMMENDED: Use nvim-jdtls instead of nvim-java (more stable)
-- Place this in: ~/.config/nvim/ftplugin/java.lua
-- ============================================================================

-- Disable built-in Java syntax highlighting (use Treesitter instead)
vim.cmd([[syntax clear]])

local jdtls = require('jdtls')

-- Find root directory
local root_markers = {
  'gradlew', 'mvnw', '.git', 'pom.xml',
  'build.gradle', 'build.gradle.kts',
  'settings.gradle', 'settings.gradle.kts'
}
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  vim.notify('Could not find Java project root', vim.log.levels.WARN)
  return
end

-- Workspace directory
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

-- Get capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Attach function
local on_attach = function(client, bufnr)
  -- Enable semantic tokens
  if client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.start(bufnr, client.id)
  end

  -- Call global on_attach if exists
  if _G.lsp_on_attach then
    _G.lsp_on_attach(client, bufnr)
  end

  -- Java-specific keymaps
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set('n', '<leader>jo', jdtls.organize_imports,
    vim.tbl_extend("force", opts, { desc = "Java: Organize Imports" }))
  vim.keymap.set('n', '<leader>jt', jdtls.test_class,
    vim.tbl_extend("force", opts, { desc = "Java: Test Class" }))
  vim.keymap.set('n', '<leader>jn', jdtls.test_nearest_method,
    vim.tbl_extend("force", opts, { desc = "Java: Test Method" }))
  vim.keymap.set('n', '<leader>jx', jdtls.extract_variable,
    vim.tbl_extend("force", opts, { desc = "Java: Extract Variable" }))
  vim.keymap.set('v', '<leader>jx', [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]],
    vim.tbl_extend("force", opts, { desc = "Java: Extract Variable" }))
  vim.keymap.set('n', '<leader>jc', jdtls.extract_constant,
    vim.tbl_extend("force", opts, { desc = "Java: Extract Constant" }))
  vim.keymap.set('v', '<leader>jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
    vim.tbl_extend("force", opts, { desc = "Java: Extract Method" }))
end

-- JDTLS config
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_linux',
    '-data', workspace_dir,
  },

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
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      signatureHelp = {
        enabled = true,
        description = {
          enabled = true,
        },
      },
      contentProvider = { preferred = 'fernflower' },
      sources = {
        organizeImports = {
          starThreshold = 1,
          staticStarThreshold = 1,
        },
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
      configuration = {
        detectJdksAtStart = true,
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = vim.fn.expand("~/.sdkman/candidates/java/8.0.432-tem"),
            default = false,
          },
          {
            name = "JavaSE-11",
            path = vim.fn.expand("~/.sdkman/candidates/java/11.0.25-tem"),
            default = false,
          },
          {
            name = "JavaSE-17",
            path = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-tem"),
            default = false,
          },
          {
            name = "JavaSE-21",
            path = vim.fn.expand("~/.sdkman/candidates/java/21.0.5-tem"),
            default = true,
          },
        },
        updateBuildConfiguration = "automatic",
      },
      inlayHints = {
        parameterNames = {
          enabled = "all",
        },
      },
      saveActions = {
        organizeImports = true,
      },
      autobuild = {
        enabled = true,
      },
      project = {
        referencedLibraries = {
          "lib/**/*.jar",
          "${env:HOME}/.m2/repository/org/lwjgl/**/*.jar",
          "${env:HOME}/.m2/repository/io/github/spair/**/*.jar",
          "libs/joml/**/*.jar",
        },
      },
      import = {
        gradle = {
          enabled = true,
          wrapper = {
            enabled = true,
          },
        },
        maven = {
          enabled = true,
          downloadSources = true,
          updateSnapshots = true,
        },
        exclusions = {
          "**/node_modules/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/maven/**",
        },
      },
    },
  },

  init_options = {
    extendedClientCapabilities = {
      progressReportProvider = true,
      classFileContentsSupport = true,
      generateToStringPromptSupport = true,
      hashCodeEqualsPromptSupport = true,
      advancedExtractRefactoringSupport = true,
      advancedOrganizeImportsSupport = true,
      generateConstructorsPromptSupport = true,
      generateDelegateMethodsPromptSupport = true,
      resolveAdditionalTextEditsSupport = true,
      moveRefactoringSupport = true,
      overrideMethodsPromptSupport = true,
      inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
    },
  },

  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "rounded",
    }),
  },
}

-- Start jdtls
jdtls.start_or_attach(config)
