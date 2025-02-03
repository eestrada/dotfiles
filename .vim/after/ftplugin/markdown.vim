set expandtab
set tabstop=2
set shiftwidth=0
set conceallevel=2

if executable('pandoc')
  compiler pandoc
endif

" If you want to disable autoformatting for markdown by default.
" if executable('mdformat')
"   let b:conform_disable_autoformat = v:true
" endif
