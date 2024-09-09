" TODO: Change this to use the `--diff` output of black to only change the requested lines
" and to place the cursor exactly where it should be.
"
" As it is written now, black sometimes formats more lines than requested.
"
" Black command string should look similar to this command:
" let l:black_cmd = 'black --quiet --fast --no-color --diff --stdin-filename=' . expand('%') . '--line-ranges=' . l:ranges . ' - 2>/dev/null'
if executable('black')
    " See `black --help` for allowed values
    if !exists('g:black_flags')
        let g:black_flags = '--safe --quiet'
    endif

    function s:black_formatexpr() abort
        let l:old_buf_len = line('$')
        let l:ranges = strtrans(v:lnum) . '-' . strtrans(v:lnum + v:count)
        let l:black_cmd = 'black ' . g:black_flags . ' --stdin-filename=' . expand('%') . ' --line-ranges=' . l:ranges . ' - 2>/dev/null'

        let l:black_output = system(l:black_cmd, bufnr('%'))
        if v:shell_error
            echoerr 'Failed to run black'
            return 1
        endif

        execute 'normal ggdG'
        execute '1put! =l:black_output'
        execute 'normal Gdd'

        " Do a best effort to place cursor where it is supposed to be according to `gq` and `formatexpr` docs.
        " This is imprecise because black sometimes reformats lines that it shouldn't.
        let l:new_buf_len = line('$')
        let l:rear_index = l:old_buf_len - (v:lnum + v:count)
        let l:new_cursor_line = l:new_buf_len - l:rear_index - 1
        execute 'normal ' . strtrans(l:new_cursor_line) . 'gg^'

        return 0
    endfunction

    setlocal formatexpr=s:black_formatexpr()

    " For a whitespace sensitive language like Python,
    " reformatting the entire buffer is the safest option to ensure correctness.
    function BlackFormatOnSave() abort
        if exists('b:black_fmt_on_save')
            if b:black_fmt_on_save ==? 1
                silent :execute '!black ' . g:black_flags . ' %'
            endif
        elseif exists('g:black_fmt_on_save')
            if g:black_fmt_on_save ==? 1
                silent :execute '!black ' . g:black_flags . ' %'
            endif
        endif
    endfunction

    augroup BlackAutoFmt
        autocmd!

        autocmd BufWritePost *.py call BlackFormatOnSave()
    augroup END

endif

" if executable('python3')
"   compiler pyunit
" endif

" Assumes common package format where `tests` is next to `src`
" and assumes that this is run in the parent directory.
setlocal makeprg=python3\ -m\ unittest\ discover\ -s\ tests

" Traceback style error finding.
" setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" Doctest style error finding.
setlocal errorformat=File\ \"%f\"\\,\ line\ %l\\,%o%.%#
