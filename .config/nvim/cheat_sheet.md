(Neo)Vim cheatsheet
===================

I'm realizing I never pushed my vim knowledge to the next level. I always used
basic motion keys and never learned the more advanced motions of even the basic
vi key set. So, here is a reminder to myself of keys beyond the basics that I
am still learning.

## Window Motions
* Supported in basic `vi`
    - `<ctrl> + d` - move cursor and screen view 1/2 page down (think `d` for down)
    - `<ctrl> + u` - move cursor and screen view 1/2 page up (think `u` for up)
    - `<ctrl> + f` - move cursor and screen view 1 full page down (think `f` for forward)
    - `<ctrl> + b` - move cursor and screen view 1 full page up (think `b` for backward)

## Cursor Motions
* Supported in basic `vi`
    - `H` - move cursor to top (home) row on screen
    - `M` - move cursor to middle row on screen
    - `L` - move cursor to last row on screen
    - `^` - move cursor to first non-blank character of line
    - `0` - move cursor to start of line
    - `$` - move cursor to end of line

## Advanced VIM features
* Folding
    - See `:help folding`
    - Does nvim LSP or treesitter support folding on methods/classes, or is
      must all folding be done manually via the oldschool VIM motions?
