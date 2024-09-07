setlocal tabstop=2

" jq can be installed via :Mason or homebrew
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

    compiler jq
endif

" jsonlint can be installed via :Mason
if executable('jsonlint')
    compiler jsonlint
endif
