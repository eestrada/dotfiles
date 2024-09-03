set tabstop=2
set conceallevel=2

" Can be installed via :Mason
"
" See links for details:
" * https://github.com/executablebooks/mdformat
" * https://mdformat.readthedocs.io/en/stable/users/style.html#paragraph-word-wrapping
if executable('mdformat')
    " See `mdformat --help` for allowed values
    if !exists('g:mdformat_flags')
        let g:mdformat_flags = '--number --wrap=keep'
    endif

    let &l:formatprg='mdformat ' . g:mdformat_flags . ' -'

    function MdFormatOnSave() abort
        if exists('b:mdformat_fmt_on_save') && b:mdformat_fmt_on_save ==? 1 || exists('g:mdformat_fmt_on_save') && g:mdformat_fmt_on_save ==? 1
            silent :execute '!mdformat ' . g:mdformat_flags . ' %'
        endif
    endfunction

    augroup MdFormatAutoFmt
        autocmd!

        autocmd BufWritePost *.md call MdFormatOnSave()
    augroup END
endif
