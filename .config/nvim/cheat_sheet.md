(Neo)Vim cheatsheet
===================

I'm realizing I never pushed my vim knowledge to the next level. I always used
basic motion keys and never learned the more advanced motions of even the basic
vi key set. So, here is a reminder to myself of keys beyond the basics that I
am still learning.

## vi features (i.e. "basic" features)
### Window Motions
  * `<ctrl> + d` - move cursor and screen view 1/2 page down (think `d` for down)
  * `<ctrl> + u` - move cursor and screen view 1/2 page up (think `u` for up)
  * `<ctrl> + f` - move cursor and screen view 1 full page down (think `f` for forward)
  * `<ctrl> + b` - move cursor and screen view 1 full page up (think `b` for backward)
### Cursor Motions
  * `H` - move cursor to top (home) row on screen
  * `M` - move cursor to middle row on screen
  * `L` - move cursor to last row on screen
  * `^` - move cursor to first non-blank character of line
  * `0` - move cursor to start of line
  * `$` - move cursor to end of line
### Marks?
  * I think buffer local marks (lowercase a-z) are a vi feature
  * Disappear at end of session, by default. Not sure if this can be changed.

## VIM features (beyond what vi offers)
### Marks?
  * I think global marks (uppercase A-Z) are a Vim feature
  * Global marks persist across sessions, by default
### Folding
  * See `:help folding`
  * Does nvim LSP or treesitter support folding on methods/classes, or must
      all folding be done manually via the oldschool VIM motions?
### Quickfix (Global to Vim session)
  * `:copen` - Open the quickfix list window.
  * `:ccl` or :cclose - Close the quickfix list window.
  * `:cnext` or :cn - Go to the next item on the list.
  * `:cprev` or :cp - Go to the previous item on the list.
  * `:cfirst` - Go to the first item on the list.
  * `:clast` - Go to the last item on the list.
  * `:cc <n>` - Go to the nth item.
### Location list (Local to current window)
  * `:lopen` - Open the location list window.
  * `:lcl` or `:lclose` - Close the location list window.
  * `:lnext` - Go to the next item on the list.
  * `:lprev` - Go to the previous item on the list.
  * `:lfirst` - Go to the first item on the list.
  * `:llast` - Go to the last item on the list.
  * `:ll <n>` - Go to the nth item.
