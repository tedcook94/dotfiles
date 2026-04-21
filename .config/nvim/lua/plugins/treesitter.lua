return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  -- NOTE: nvim-treesitter `main` branch is upstream-unstable. The autocmd below
  -- is tailored to the pinned commit in lazy-lock.json. After `:Lazy update`,
  -- if highlighting breaks, revisit the `install()`/`:await` API here.
  config = function()
    local nts = require('nvim-treesitter')
    nts.setup()

    local pending = {} ---@type table<string, integer[]>
    local failed = {} ---@type table<string, true>

    local QUERY_KINDS = { 'highlights', 'locals', 'folds', 'indents', 'injections' }

    local function clear_query_cache(lang)
      for _, kind in ipairs(QUERY_KINDS) do
        pcall(function() vim.treesitter.query.get:clear(lang, kind) end)
      end
    end

    local function is_installed(lang)
      for _, l in ipairs(nts.get_installed()) do
        if l == lang then return true end
      end
      return false
    end

    -- Used when parser+queries are already available at FileType time.
    local function start_buf(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      pcall(vim.treesitter.language.add, lang)
      -- Bust cached negative-lookups: if `query.get(lang, kind)` was ever
      -- called before the parser/queries existed (returning nil), that nil
      -- is cached and would leave the highlighter with no queries to run.
      clear_query_cache(lang)
      pcall(vim.treesitter.start, buf)
    end

    -- Used after a fresh install completes. `vim.treesitter.start` alone is
    -- insufficient on a buffer that loaded before parser/queries existed; the
    -- buffer's filetype-time treesitter attachment is sticky, and the surest
    -- way to re-attach is to reload the buffer, which re-fires our autocmd
    -- and lets the immediate branch run with parser+queries now present.
    local function reattach_buf(buf)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if vim.bo[buf].modified then return end
      vim.api.nvim_buf_call(buf, function() vim.cmd.edit() end)
    end

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(ev)
        if vim.bo[ev.buf].buftype ~= '' then return end
        local ft = vim.bo[ev.buf].filetype
        if ft == '' then return end
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if failed[lang] then return end

        -- Note: `vim.treesitter.language.add(lang)` returns true on `main`
        -- branch even when the parser isn't actually installed (setup()
        -- pre-registers all known languages from parser-info/). Use
        -- get_installed() as the authoritative check.
        if is_installed(lang) then
          start_buf(ev.buf, lang)
          return
        end

        if pending[lang] then
          table.insert(pending[lang], ev.buf)
          return
        end
        pending[lang] = { ev.buf }

        -- Defer to next main-loop tick out of caution; install machinery
        -- uses coroutines and may not enjoy being invoked inline from an
        -- autocmd callback.
        vim.schedule(function()
          nts.install({ lang }):await(function(err, success)
            vim.schedule(function()
              local bufs = pending[lang] or {}
              pending[lang] = nil
              if err or success == false then
                failed[lang] = true
                vim.notify(
                  ('nvim-treesitter: failed to install %q: %s'):format(lang, err or 'see :messages'),
                  vim.log.levels.WARN
                )
                return
              end
              -- Bust cached negative-lookups from the pre-install window
              -- before the re-fired FileType autocmd resolves queries.
              clear_query_cache(lang)
              local seen = {}
              for _, buf in ipairs(bufs) do
                reattach_buf(buf)
                seen[buf] = true
              end
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if not seen[buf]
                  and vim.api.nvim_buf_is_loaded(buf)
                  and vim.bo[buf].buftype == ''
                then
                  local bft = vim.bo[buf].filetype
                  if bft ~= '' and (vim.treesitter.language.get_lang(bft) or bft) == lang then
                    reattach_buf(buf)
                  end
                end
              end
            end)
          end)
        end)
      end,
    })
  end,
}
