return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
        if not lang then return end
        if pcall(vim.treesitter.language.add, lang) then
          vim.treesitter.query.get:clear(lang, 'highlights')
          pcall(vim.treesitter.start, ev.buf)
        else
          require('nvim-treesitter').install({ lang }):await(function(err)
            if not err and vim.api.nvim_buf_is_valid(ev.buf) then
              vim.schedule(function()
                vim.treesitter.query.get:clear(lang, 'highlights')
                pcall(vim.treesitter.start, ev.buf)
              end)
            end
          end)
        end
      end,
    })
  end,
}
