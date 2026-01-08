return {
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        cond = vim.g.neovide == nil,
        opts = {
            -- existing
            hide_target_hack = true,
            cursor_color = "none",
        },
        specs = {
            {
                -- disable mini.animate cursor
                "nvim-mini/mini.animate",
                optional = true,
                opts = {
                    cursor = { enable = false },
                },
            },
        },
    },
}
