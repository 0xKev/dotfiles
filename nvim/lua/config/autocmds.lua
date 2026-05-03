-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go", "make" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.expandtab = false -- use actual tab characters
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "yaml", "yml" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        local ft = vim.bo.filetype
        if ft ~= "go" and ft ~= "make" and ft ~= "yaml" and ft ~= "yml" then
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.expandtab = true -- use spaces elsewhere
        end
    end,
})

vim.api.nvim_create_autocmd("SwapExists", {
    callback = function()
        local swap_info = vim.fn.swapinfo(vim.v.swapname)
        local pid = swap_info.pid

        -- no pid info means we can't determine state, let Neovim prompt
        if not pid or pid == 0 then
            return
        end

        -- only auto-delete if the swap was created on this machine
        if swap_info.host ~= vim.fn.hostname() then
            return
        end

        -- if the process is dead, the swap is stale — safe to delete
        local process_alive = vim.uv.kill(pid, 0) == 0
        if not process_alive then
            vim.v.swapchoice = "d"
        end
    end,
})
