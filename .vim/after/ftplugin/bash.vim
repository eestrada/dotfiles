" Originally sourced from here: https://github.com/z0mbix/vim-shfmt
if executable('shfmt')
    let s:shiftwidth=&l:shiftwidth
    if &l:expandtab
        let s:shiftwidth=&l:tabstop
    endif
    let &l:formatprg='shfmt -i ' . s:shiftwidth . ' -ln bash -sr -ci -s'
endif
