-- Java Language Server Configuration
local M = {}

M.setup = function()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    vim.notify("nvim-jdtls not found!", vim.log.levels.ERROR)
    return
  end

  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  local root_dir = require("jdtls.setup").find_root(root_markers)
  if not root_dir then return end

  local home = os.getenv("HOME")
  local workspace_dir = home .. "/.local/share/nvim/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
  local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  local config_path = jdtls_path .. "/config_linux"
  local plugins_path = jdtls_path .. "/plugins"
  local lombok_path = jdtls_path .. "/lombok.jar"
  
  local launcher_jar = vim.fn.glob(plugins_path .. "/org.eclipse.equinox.launcher_*.jar")
  
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      "-Xmx2g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-javaagent:" .. lombok_path,
      "-jar", launcher_jar,
      "-configuration", config_path,
      "-data", workspace_dir,
    },
    root_dir = root_dir,
    settings = {
      java = {
        eclipse = { downloadSources = true },
        configuration = { updateBuildConfiguration = "interactive" },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        format = { enabled = true },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      require("lsp.handlers").on_attach(client, bufnr)
      
      local opts = { noremap = true, silent = true, buffer = bufnr }
      local keymap = vim.keymap.set
      
      keymap("n", "<leader>jo", function() require("jdtls").organize_imports() end, 
        vim.tbl_extend("force", opts, { desc = "Organize imports" }))
      keymap("v", "<leader>jv", function() require("jdtls").extract_variable() end,
        vim.tbl_extend("force", opts, { desc = "Extract variable" }))
      keymap("v", "<leader>jm", function() require("jdtls").extract_method() end,
        vim.tbl_extend("force", opts, { desc = "Extract method" }))
      keymap("n", "<leader>jg", function() require("jdtls").code_action(false, "source") end,
        vim.tbl_extend("force", opts, { desc = "Generate code" }))
      keymap("n", "<leader>jt", function() require("jdtls").test_class() end,
        vim.tbl_extend("force", opts, { desc = "Test class" }))
      
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end,
    init_options = {
      bundles = {},
      extendedClientCapabilities = extendedClientCapabilities,
    },
  }

  jdtls.start_or_attach(config)
end

return M

