-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Only added this due to a bug where nvim spawns a child terminal in the parent terminal due to the root directory and first terminal directory mismatch
vim.keymap.set("t", "<C-/>", "<cmd>hide<cr>", { desc = "Hide terminal", silent = true })
