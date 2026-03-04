return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- The "*" acts as a wildcard, applying this to all active servers
                ["*"] = {
                    capabilities = {
                        general = {
                            positionEncodings = { "utf-8", "utf-16" },
                        },
                    },
                },
            },
        },
    },
}
