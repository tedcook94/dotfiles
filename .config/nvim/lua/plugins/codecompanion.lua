-- CodeCompanion is a productivity tool which streamlines how you develop with LLMs, in Neovim.
-- https://codecompanion.olimorris.dev/

return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },
  {
    'github/copilot.vim',
    init = function()
      vim.g.copilot_enabled = false
    end,
  },
}
