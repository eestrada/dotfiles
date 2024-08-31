" TODO: change this to a `formatexpr` that calls `black` using the `--line-ranges` so that it can properly format ranges.
" Right now, it just freaks out with snippets passed on stdin
" and completely breaks when it is in the middle of some sort syntactical construct.
"
" Also, it should do *nothing* if black changes anything other than the lines
" requested.
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
