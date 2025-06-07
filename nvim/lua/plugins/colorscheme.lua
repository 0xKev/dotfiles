return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha", -- latte, frappe, macchioto, mocha
            transparent_background = true,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
    -- {
    --     "folke/tokyonight.nvim",
    --     opts = {
    --         transparent = true,
    --         styles = {
    --             sidebars = "transparent",
    --             floats = "transparent",
    --         },
    --     },
    -- },
}
