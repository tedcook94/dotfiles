-- multicursor
-- https://github.com/mg979/vim-visual-multi

return {
  'mg979/vim-visual-multi',
  event = { 'CursorMoved', 'CursorHold' },
  init = function()
    vim.g.VM_maps = {
      ['Add Cursor Down'] = '<C-Down>',
      ['Add Cursor Up'] = '<C-Up>',
    }
  end,
}
