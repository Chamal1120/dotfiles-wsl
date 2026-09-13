return {
  {
    "williamboman/mason.nvim",
    lazy = "Verylazy",
    config = function()
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
    config = function()
      require("mason-lspconfig").setup({
        -- jdtls is started per-buffer by ftplugin/java.lua. Letting
        -- mason-lspconfig enable it too starts a second, competing server.
        automatic_enable = { exclude = { "jdtls" } },
        ensure_installed = {
          "lua_ls",
          --"ts_ls",
          --"tailwindcss",
          --"rust_analyzer",
          --"clangd",
          --"pylsp",
          --"gopls",
        },
      })
    end,
  },
}
