return {
    "nmac427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        override_editorconfig = false, -- explicit, even though it's the default
        filetype_exclude = { "netrw", "tutor", "help", "lazy" },
    },
}
