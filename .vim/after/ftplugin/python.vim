if executable('black')
    setlocal formatprg=black\ --quiet\ --fast\ --stdin-filename\ %\ -\ 2>/dev/null
endif

" Assumes common package format where `tests` is next to `src` and this is run
" in the parent directory.
setlocal makeprg=python3\ -m\ unittest\ discover\ -s\ tests

" Traceback style error finding.
" setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" Doctest style error finding.
setlocal errorformat=File\ \"%f\"\\,\ line\ %l\\,%o%.%#
