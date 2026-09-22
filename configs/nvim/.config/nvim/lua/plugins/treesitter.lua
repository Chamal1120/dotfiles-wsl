return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {},
    config = function(_, opts)
        require('nvim-treesitter').setup({opts})
        require('nvim-treesitter').install({ 'java', 'html', 'json', 'c' })
    end,
}
