return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Replacements for removed plugins
    picker = {
      sources = {
        explorer = { hidden = true },
        files = { hidden = true },
        grep = { hidden = true },
        grep_word = { hidden = true },
      },
    },
    explorer = {},
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', cwd = true, limit = 8, padding = 1 },
        { section = 'projects', limit = 8, padding = 1 },
        { section = 'startup' },
      },
    },
    indent = { enabled = true },
    notifier = { enabled = true },
    input = { enabled = true },

    -- Image display (Kitty graphics protocol)
    image = {},

    -- New features
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    scope = { enabled = true },
    toggle = { enabled = true },
    terminal = { enabled = true },
    lazygit = { enabled = true },
    gitbrowse = { enabled = true },
    bufdelete = { enabled = true },
    rename = { enabled = true },
    scroll = { enabled = true },
    zen = { enabled = true },
    dim = { enabled = true },
  },
  keys = {
    -- Picker (migrated from telescope.nvim)
    { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
    { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[S]earch [S]nacks pickers' },
    { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord', mode = { 'n', 'x' } },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
    { '<leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
    { '<leader><leader>', function() Snacks.picker.buffers() end, desc = '[ ] Find existing buffers' },
    { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
    { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
    { '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = '[S]earch [N]eovim files' },

    -- Explorer (migrated from neo-tree.nvim)
    { '\\', function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'snacks_picker_list' then
          if vim.api.nvim_get_current_win() == win then
            Snacks.explorer()
          else
            vim.api.nvim_set_current_win(win)
          end
          return
        end
      end
      Snacks.explorer()
    end, desc = 'Explorer' },

    -- Lazygit
    { '<leader>gg', function() Snacks.lazygit() end, desc = '[G]it lazy[g]it' },

    -- Git browse
    { '<leader>gB', function() Snacks.gitbrowse() end, desc = '[G]it [B]rowse', mode = { 'n', 'x' } },

    -- Buffer delete
    { '<leader>bd', function() Snacks.bufdelete() end, desc = '[B]uffer [D]elete' },

    -- Terminal
    { '<c-/>', function() Snacks.terminal() end, desc = 'Toggle terminal' },

    -- Words (LSP reference jumping)
    { ']]', function() Snacks.words.jump(vim.v.count1) end, desc = 'Next LSP reference', mode = { 'n', 't' } },
    { '[[', function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev LSP reference', mode = { 'n', 't' } },

    -- Notifications
    { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss notifications' },

    -- Zen
    { '<leader>z', function() Snacks.zen() end, desc = '[Z]en mode' },
  },
}
