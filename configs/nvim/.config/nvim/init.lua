require("configs.vim-options")
require("configs.lazy")
require("lsp")

vim.api.nvim_create_user_command("ViewPath", function()
  print(vim.fn.expand("%:p"))
end, {})
