return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1001, -- Explicitly higher
        opts = {
            flavour = "mocha",
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
}
