local M = {}

--- A dropin replacement of telescope that uses the builtin |vim.ui.select| and
--- |vim.ui.input| functions. Just starting work on this. Will break out into
--- separate project soon.

--- Based on telescope.builtin.spell_suggest: https://github.com/nvim-telescope/telescope.nvim/blob/2f3857c25bbd00ed7ac593c9d4071906369e4d20/lua/telescope/builtin/__internal.lua#L1340
M.spell_suggest = function(opts)
  local word_under_cursor = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word_under_cursor)

  opts = opts or { prompt = "Spelling suggestions:" }

  vim.ui.select(suggestions, opts, function(item)
    if item then
      vim.cmd("normal! ciw" .. item)
      vim.cmd("stopinsert")
    end
  end)
end

M.slightly_nicer_select = function (items, opts, on_choice)
  if not on_choice then
    error('Must supply a method for `on_choice`')
  end
end

M.setup = function ()
  vim.keymap.set('n', 'z=', function() require('periscope').spell_suggest() end,
    { desc = 'Show spelling suggestions' })
end

return M
