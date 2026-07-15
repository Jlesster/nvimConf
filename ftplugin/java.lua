local jdtls = require('jdtls')

local mason_pkg = vim.fn.stdpath('data') .. '/mason/packages'
local bundles = {}

local java_debug = mason_pkg .. '/java-debug-adapter/extension/server'
if vim.fn.isdirectory(java_debug) == 1 then
  vim.list_extend(
    bundles,
    vim.split(
      vim.fn.glob(java_debug .. '/com.microsoft.java.debug.plugin-*.jar'),
      '\n',
      { trimempty = true }
    )
  )
end

local vscode_test = mason_pkg .. '/java-test/extension/server'
if vim.fn.isdirectory(vscode_test) == 1 then
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(vscode_test .. '/*.jar'), '\n', { trimempty = true })
  )
end

local buf_path = vim.api.nvim_buf_get_name(0)
local abs_path = vim.fn.fnamemodify(buf_path, ':p')

local root_dir = vim.fs.root(abs_path, {
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
  'mvnw',
  'gradlew',
  '.git',
})

local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':t')
local workspace = vim.fn.stdpath('data') .. '/jdtls-workspaces/' .. project_name

local config = {
  cmd = { 'jdtls', '-data', workspace },
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_dir = vim.fs.root(0, {
    'pom.xml',
    'build.gradle',
    'build.gradle.kts',
    'settings.gradle',
    'settings.gradle.kts',
    'mvnw',
    'gradlew',
    '.git',
  }),
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true, updateSnapshots = true },
      hover = { enabled = true },
      implementationCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      semanticHighlighting = { enabled = true },
      tokenTypes = {
        'namespace',
        'type',
        'class',
        'enum',
        'interface',
        'struct',
        'typeParameter',
        'parameter',
        'variable',
        'property',
        'enumMember',
        'function',
        'method',
        'macro',
        'keyword',
        'modifier',
        'comment',
        'string',
        'number',
        'regexp',
        'operator',
        'decorator',
        'annotation',
      },
      tokenModifiers = {
        'declaration',
        'definition',
        'readonly',
        'static',
        'deprecated',
        'abstract',
        'async',
        'modification',
        'documentation',
        'defaultLibrary',
        'public',
        'private',
        'protected',
        'native',
        'synchronized',
        'volatile',
        'transient',
        'constructor',
        'instance',
        'local',
      },
      references = { includeDecompiledSources = true },
      format = { enabled = true },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          'org.junit.jupiter.api.Assertions.*',
          'org.junit.Assert.*',
          'org.mockito.Mockito.*',
          'org.mockito.ArgumentMatchers.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.lwjgl.glfw.GLFW.*',
          'org.lwjgl.opengl.GL11.*',
          'org.lwjgl.opengl.GL20.*',
          'org.lwjgl.opengl.GL30.*',
          'org.lwjgl.opengl.GL33.*',
          'org.lwjgl.opengl.GL45.*',
          'org.lwjgl.vulkan.VK10.*',
          'org.lwjgl.system.MemoryUtil.*',
          'org.lwjgl.system.MemoryStack.*',
          'imgui.ImGui.*',
          'imgui.flag.ImGuiWindowFlags.*',
          'imgui.flag.ImGuiCol.*',
          'imgui.type.ImBoolean.*',
          'imgui.type.ImInt.*',
          'imgui.type.ImFloat.*',
        },
        filteredTypes = {
          'com.sun.*',
          'io.micrometer.shaded.*',
          'java.awt.*',
          'sun.*',
          'jdk.*',
        },
        importOrder = { 'java', 'javax', 'org.lwjgl', 'imgui', 'org', 'com' },
      },
      sources = {
        organizeImports = { starThreshold = 2, staticStarThreshold = 2 },
      },
      codeGeneration = {
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = '/usr/lib/jvm/java-21-openjdk',
          },
        },
      },
    },
  },
  init_options = { bundles = bundles },
  on_attach = function(client, bufnr)
    -- jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls.setup.add_commands()

    local map = function(lhs, rhs, desc)
      vim.keymap.set(
        'n',
        lhs,
        rhs,
        { buffer = bufnr, silent = true, desc = desc }
      )
    end
    local vmap = function(lhs, rhs, desc)
      vim.keymap.set(
        'v',
        lhs,
        rhs,
        { buffer = bufnr, silent = true, desc = desc }
      )
    end

    map('<leader>ji', jdtls.organize_imports, 'Java: Organize imports')
    map('<leader>jv', jdtls.extract_variable, 'Java: Extract variable')
    map('<leader>jc', jdtls.extract_constant, 'Java: Extract constant')
    map('<leader>jt', jdtls.test_nearest_method, 'Java: Test nearest method')
    map('<leader>jT', jdtls.test_class, 'Java: Test class')
    map('<leader>ju', '<cmd>JdtUpdateConfig<cr>', 'Java: Update config')
    vmap('<leader>jv', function()
      jdtls.extract_variable(true)
    end, 'Java: Extract variable (visual)')
    vmap('<leader>jm', function()
      jdtls.extract_method(true)
    end, 'Java: Extract method (visual)')
  end,
}

jdtls.start_or_attach(config)
