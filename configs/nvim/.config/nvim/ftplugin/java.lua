local jdtls = require('jdtls')
local ext_caps = jdtls.extendedClientCapabilities
ext_caps.resolveAdditionalTextEditsSupport = true

local config = {
  cmd = {
    "jdtls",
    "--java-executable=/usr/lib/jvm/temurin-21-jdk-amd64/bin/java",
    "--jvm-arg=-Xmx4g",
    "-data", vim.fn.stdpath("cache") .. "/jdtls/ws",
  },
  root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" }),
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      references = { includeDecompiledSources = true },
      contentProvider = { preferred = "fernflower" },
      configuration = {
        updateBuildConfiguration = "interactive",
      },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      signatureHelp = { enabled = true },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
    },
  },
  init_options = {
    extendedClientCapabilities = ext_caps,
    bundles = {},
  },
  on_attach = function(client, bufnr)
    vim.lsp.codelens.enable(true, { bufnr = bufnr })

    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', '<leader>ji', jdtls.organize_imports, opts)
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, opts)
    vim.keymap.set('v', '<leader>jv', function() jdtls.extract_variable(true) end, opts)
    vim.keymap.set('n', '<leader>jV', jdtls.extract_variable_all, opts)
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, opts)
    vim.keymap.set('v', '<leader>jm', function() jdtls.extract_method(true) end, opts)
  end,
}

jdtls.start_or_attach(config)
