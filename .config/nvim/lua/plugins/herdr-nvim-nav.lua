return { -- Seamless <C-hjkl> navigation across herdr panes and neovim splits
  -- The herdr half is the `vim-herdr-navigation` herdr plugin (see
  -- ~/.config/herdr/config.toml); only this neovim module is used from here.
  --
  -- Under herdr: moves within neovim splits, falls through to herdr panes at the edge.
  -- Under tmux:  delegates to vim-tmux-navigator (auto-detected from $TMUX).
  'aimdevlee/herdr-nvim-nav',
  dependencies = { 'christoomey/vim-tmux-navigator' },
  config = function()
    require('herdr-nvim-nav').setup {
      with_tmux = nil, -- nil = auto-detect $TMUX
    }
  end,
}
