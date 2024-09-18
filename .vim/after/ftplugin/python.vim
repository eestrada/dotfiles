if executable('python3')
    " `compiler pyunit` does traceback style error finding, like comment below.
    " setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
    compiler pyunit

    " Add Doctest style error finding.
    setlocal errorformat+=,File\ \"%f\"\\,\ line\ %l\\,%o%.%#

    " Assumes common package format where `tests` is next to `src`
    " and assumes that this is run in the parent directory.
    setlocal makeprg=python3\ -m\ unittest\ discover\ -s\ tests
endif
