return {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = function()
        local nvimbattery = {
            function()
                return require("battery").get_status_line()
            end,
        }

        return {
            theme = "vague",
            options = {
                component_separators = " ",
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        fmt = function(str)
                            -- Return only the first character of the mode string
                            return str:sub(1, 1)
                        end,
                    },
                },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype", nvimbattery },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        }
    end,
}
