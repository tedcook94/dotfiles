-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, you can see `:help option-list`

-- Alias vim.opt
local opt = vim.opt

-- Enable line numbers
opt.number = true
-- Enable relative line numbers
opt.relativenumber = true

-- Enable mouse mode
opt.mouse = 'a'

-- Show the mode in the command line
opt.showmode = false

-- Sync clipboard between OS and Neovim
--  Schedule the setting after 'UiEnter' because it can increase startup time.
--  See `:help clipboard`
vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching unless \C or one+ capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how Neovim will display certain whitespace characters in the editor
--  See `:help list`
--  and `:help listchars`
opt.list = false
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live as you type
opt.inccommand = 'split'

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below cursor
opt.scrolloff = 10
