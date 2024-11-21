-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Alias vim.keymap
local keymap = vim.keymap

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience
--  NOTE: This won't work in all terminal emulators/tmux/etc.
keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
keymap.set('n', '<left>', '<cmd>echo "Use h to move!"<CR>')
keymap.set('n', '<right>', '<cmd>echo "Use l to move!"<CR>')
keymap.set('n', '<up>', '<cmd>echo "Use k to move!"<CR>')
keymap.set('n', '<down>', '<cmd>echo "Use j to move!"<CR>')

-- Keybinds to make split navigation easier
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Add new line without entering insert mode
keymap.set('n', '<CR>', 'o<Esc>', { desc = 'Add new line without entering insert mode' })
keymap.set('n', '<S-CR>', 'O<Esc>', { desc = 'Add new line above without entering insert mode' })
