local jdtls = require('jdtls')
local ext_caps = jdtls.extendedClientCapabilities
ext_caps.resolveAdditionalTextEditsSupport = true

-- Debug/test bundles handed to jdtls so it can act as a DAP server
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = vim.fn.glob(
  mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)

-- Optional: `:MasonInstall java-test` enables JUnit run/debug.
-- The runner and jacoco jars must NOT be passed to jdtls.
for _, jar in ipairs(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", true, true)) do
  local name = vim.fn.fnamemodify(jar, ":t")
  if not name:match("^com%.microsoft%.java%.test%.runner%-jar%-with%-dependencies%.jar$")
    and not name:match("^jacocoagent%.jar$") then
    table.insert(bundles, jar)
  end
end

-- Real build files win; `src` makes each unmanaged sub-folder its own project;
-- `.git` is the last resort so a repo of loose folders doesn't collapse into one project.
local root_dir = vim.fs.root(0, {
  "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts",
  "mvnw", "gradlew",
  "src",
  ".git",
}) or vim.fn.getcwd()

-- One workspace per project. Sharing a single -data dir across projects
-- corrupts the classpath as soon as you open a second one.
local workspace = vim.fn.stdpath("cache") .. "/jdtls/"
  .. vim.fn.fnamemodify(root_dir, ":t") .. "_" .. vim.fn.sha256(root_dir):sub(1, 8)

local java_settings = {
  eclipse = { downloadSources = true },
  maven = { downloadSources = true },
  references = { includeDecompiledSources = true },
  contentProvider = { preferred = "fernflower" },
  configuration = {
    updateBuildConfiguration = "interactive",
  },
  implementationsCodeLens = { enabled = false },
  referencesCodeLens = { enabled = false },
  signatureHelp = { enabled = true },
  inlayHints = {
    parameterNames = { enabled = "all" },
  },
}

-- For projects with no build file jdtls creates an "unmanaged" project and only
-- looks in <root>/src. Point it at the layout actually in use, otherwise nothing
-- lands on the classpath and no main classes are ever resolved.
local has_build_file = vim.fn.glob(root_dir .. "/pom.xml") ~= ""
  or vim.fn.glob(root_dir .. "/build.gradle*") ~= ""
if not has_build_file then
  local src
  if vim.fn.isdirectory(root_dir .. "/src/main/java") == 1 then
    src = "src/main/java"
  elseif vim.fn.isdirectory(root_dir .. "/src") == 1 then
    src = "src"
  end
  if src then
    java_settings.project = {
      sourcePaths = { src },
      outputPath = "bin",
      referencedLibraries = { "lib/**/*.jar" },
    }
  end
end

local config = {
  cmd = {
    "jdtls",
    "--java-executable=/usr/lib/jvm/temurin-21-jdk-amd64/bin/java",
    "--jvm-arg=-Xmx4g",
    "-data", workspace,
  },
  root_dir = root_dir,
  settings = { java = java_settings },
  init_options = {
    extendedClientCapabilities = ext_caps,
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, silent = true }
    local function visual(fn)
      return function() fn({ visual = true }) end
    end

    vim.keymap.set('n', '<leader>ji', jdtls.organize_imports, opts)

    -- Normal mode relies on inferSelectionSupport: jdtls infers the expression
    -- or block under the cursor and prompts when the choice is ambiguous.
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, opts)
    vim.keymap.set('v', '<leader>jv', visual(jdtls.extract_variable), opts)
    vim.keymap.set('n', '<leader>jV', jdtls.extract_variable_all, opts)
    vim.keymap.set('v', '<leader>jV', visual(jdtls.extract_variable_all), opts)
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, opts)
    vim.keymap.set('v', '<leader>jc', visual(jdtls.extract_constant), opts)
    vim.keymap.set('n', '<leader>jm', jdtls.extract_method, opts)
    vim.keymap.set('v', '<leader>jm', visual(jdtls.extract_method), opts)

    -- Symbols of this class including inherited ones
    vim.keymap.set('n', '<leader>js', jdtls.extended_symbols, opts)
    -- Jump to the super implementation of the method under the cursor
    vim.keymap.set('n', '<leader>ju', jdtls.super_implementation, opts)

    -- Registers the java DAP adapter. Leaving dap.providers.configs["jdtls"]
    -- in place means dap.continue() resolves main classes on demand, so a
    -- config exists even when the project finishes importing after attach.
    jdtls.setup_dap({ hotcodereplace = "auto", config_overrides = {} })

    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, opts)
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, opts)
  end,
}

jdtls.start_or_attach(config)

vim.api.nvim_buf_create_user_command(0, "JdtlsRefreshDap", function()
  require("jdtls.dap").setup_dap_main_class_configs({ verbose = true })
end, { desc = "Re-resolve Java main classes for nvim-dap" })

vim.api.nvim_buf_create_user_command(0, "JdtlsInfo", function()
  vim.notify(("jdtls root: %s\nworkspace: %s\nbundles: %d")
    :format(root_dir, workspace, #bundles))
end, { desc = "Show jdtls root, workspace and bundle count" })
