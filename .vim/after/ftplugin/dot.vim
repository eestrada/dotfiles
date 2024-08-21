set commentstring=\/\/%s

" Just always automatically compile `dot` files
" This will only work if the 'liuchengxu/graphviz.vim' plugin is installed and
" the Graphviz `dot` utility is installed.
augroup DotAutocompile
    autocmd!

    autocmd BufWritePost *.dot,*.gv :GraphvizCompile
    autocmd BufWritePost *.dot,*.gv :GraphvizCompile svg
augroup END
