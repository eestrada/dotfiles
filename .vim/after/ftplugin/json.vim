setlocal tabstop=2

if executable('jq')
    let s:shiftwidth=&l:shiftwidth
    if &l:expandtab
        let s:shiftwidth=&l:tabstop
        let &l:formatprg= 'jq . --indent ' .. s:shiftwidth
    else
        setlocal formatprg=jq\ .\ --tab
    endif

    command! -buffer -range=% JSONFormat <line1>,<line2>!jq .

    command! -buffer -range=% JSONCompact <line1>,<line2>!jq --compact-output .
endif
