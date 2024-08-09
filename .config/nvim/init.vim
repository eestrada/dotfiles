" All Vim compatible config lives in `~/.vimrc` and nvim just adds Vim runtime
" paths as appropriate. Nvim specific config mostly lives elsewhere.
" Pulled from: https://neovim.io/doc/user/nvim.html#nvim-from-vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
