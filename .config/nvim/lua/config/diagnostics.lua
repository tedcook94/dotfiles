-- [[ Setting diagnostic options ]]
-- See `:help vim.diagnostic`

-- Alias vim.diagnostic
local diag = vim.diagnostic

-- Enable diagnostics
diag.enable = true

-- Turn on virtual text
diag.config {
  virtual_text = {
    virt_text_hide = false,
    virt_text_pos = 'eol',
  },
}
