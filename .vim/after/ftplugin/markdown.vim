set tabstop=2
set shiftwidth=0
set conceallevel=2

" Can be installed via :Mason
"
" Be sure to install GFM (Github Flavored Markdown) extensions for `mdformat` in the venv.
" This allows for autoformatting tables, and along with other common extensions.
"
" Instructions for this can be found in the Github repo links below.
"
" See links for details:
" * https://github.com/executablebooks/mdformat
" * https://github.com/hukkin/mdformat-gfm
" * https://mdformat.readthedocs.io/en/stable/users/style.html#paragraph-word-wrapping
if executable('mdformat')
    " See `mdformat --help` for allowed values
    if !exists('g:mdformat_flags')
        let g:mdformat_flags = '--number --wrap=keep'
    endif

    let &l:formatprg='mdformat ' . g:mdformat_flags . ' -'

    function MdFormatOnSave() abort
        if exists('b:mdformat_fmt_on_save')
            if b:mdformat_fmt_on_save ==? 1
                silent :execute '!mdformat ' . g:mdformat_flags . ' %'
            endif
        elseif exists('g:mdformat_fmt_on_save')
            if g:mdformat_fmt_on_save ==? 1
                silent :execute '!mdformat ' . g:mdformat_flags . ' %'
            endif
        endif
    endfunction

    augroup MdFormatAutoFmt
        autocmd!

        autocmd BufWritePost *.md call MdFormatOnSave()
    augroup END
endif

if executable('pandoc')
  compiler pandoc
endif
