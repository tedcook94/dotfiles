# herdr

Terminal workspace manager, used here in place of tmux. The tmux config
(`.tmux.conf`, `.config/zsh/tmux-functions.zsh`) is still present and working;
the two run side by side.

`config.toml` is the only herdr state file tracked in this repo. Everything else
in `~/.config/herdr/` is runtime state -- sockets, logs, session snapshots, and
herdr's own managed plugin checkouts -- and is gitignored.

## Fresh machine setup

Stow puts `config.toml` and the local plugin source in place, but plugin
*registration* lives in `~/.config/herdr/plugins.json`, which is runtime state
and therefore not tracked. So the install steps below have to be run once per
machine.

```sh
stow .

# Vim-aware pane navigation. Provides the plugin actions that config.toml
# binds to ctrl+h/j/k/l -- without it those four keys do nothing.
herdr plugin install paulbkim-dev/vim-herdr-navigation

# Local plugin, source lives in this repo. Numbers the tab bar.
herdr plugin link ~/.config/herdr-plugins/tab-numbers

# Lets opencode report agent state (working / needs input / done) to herdr,
# which drives the sidebar indicators and notifications.
herdr integration install opencode

herdr plugin list   # all three should show enabled=true
```

The Neovim half of pane navigation (`aimdevlee/herdr-nvim-nav`, specced in
`.config/nvim/lua/plugins/herdr-nvim-nav.lua`) is handled by lazy.nvim and needs
no manual step.

## Plugins

### vim-herdr-navigation

Makes `ctrl+h/j/k/l` move between panes, but forward the keypress to the
application instead when the focused pane is running vim or nvim -- so window
splits inside the editor and herdr panes outside it share one set of keys. This
is the herdr-side equivalent of `christoomey/vim-tmux-navigator`, which is
retained for tmux.

Detection is stateless: it asks herdr for the pane's foreground process on every
keypress, so it keeps working after a pane is moved between tabs. Requires `jq`
-- without it, detection is skipped silently and the keys only ever move pane
focus.

### tab-numbers (local, `.config/herdr-plugins/tab-numbers/`)

herdr has no setting to display tab numbers; the tab bar renders the label and
nothing else. This plugin writes the number into the label, so tabs read
`[1] code`, `[2] shell` and line up with the `prefix+1..9` shortcuts.

It hooks `tab.created`, `tab.closed`, `tab.moved`, and `tab.renamed`, and on each
event renumbers every tab in every workspace.

Two design notes worth knowing before editing `renumber.sh`:

- **Numbers come from array position in `tab list`, not the `.number` field.**
  `.number` looks positional and is even called `public_tab_numbers` internally,
  but it is a stable handle that is never recycled: close tab 2 and the
  remaining tabs keep 1 and 3, while `prefix+2` still selects the *second* tab.
  Numbering from it would make the labels contradict the shortcuts.
- **Renaming is conditional on the label actually differing.** This is what stops
  the `tab.renamed` hook from recursing -- the follow-up event finds nothing to
  change and the cascade dies after one round.

Run it by hand if labels ever drift:

```sh
herdr plugin action invoke local.tab-numbers.renumber
```

Local plugin source is deliberately kept in `.config/herdr-plugins/` rather than
`.config/herdr/plugins/`, because the latter is herdr's own managed store and
gets rewritten by `plugin install` and `plugin uninstall`.

## Shell functions

`.config/zsh/herdr-functions.zsh` defines `h`, the herdr port of tmux's `tp`. It
resolves a directory through zoxide, starts the server if it is not running,
then creates or focuses a workspace with two tabs: `code` (nvim and opencode
split 50/50) and `shell`. It attaches afterwards unless already inside herdr.

Unlike tmux, the herdr CLI does not start a server on demand, so `h` polls for
one and launches it if needed.
