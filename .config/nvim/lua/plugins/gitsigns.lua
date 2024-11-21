return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Jump to next git [c]hange' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Jump to previous git [c]hange' })

      -- Actions
      -- visual mode
      map('v', '<leader>hs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'Git: [S]tage hunk' })
      map('v', '<leader>hr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'Git: [R]eset hunk' })
      -- normal mode
      map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git: [S]tage hunk' })
      map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git: [R]eset hunk' })
      map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git: [S]tage buffer' })
      map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Git: [U]ndo stage hunk' })
      map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git: [R]eset buffer' })
      map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git: [P]review hunk' })
      map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git: [B]lame line' })
      map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git: [D]iff against index' })
      map('n', '<leader>hD', function()
        gitsigns.diffthis '@'
      end, { desc = 'Git: [D]iff against last commit' })
      -- toggles
      map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Git: [T]oggle show [b]lame' })
      map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = 'Git: [T]oggle show [D]eleted' })
    end,
  },
}
