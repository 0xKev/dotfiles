-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("t", "<C-/>", "<cmd>hide<cr>", { desc = "Hide terminal", silent = true })
vim.keymap.set("t", "<C-_>", "<cmd>hide<cr>", { desc = "Hide terminal", silent = true })
