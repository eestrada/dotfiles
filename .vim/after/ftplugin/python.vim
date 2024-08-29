if executable('black')
    setlocal formatprg=black\ -q\ 2>/dev/null\ --stdin-filename\ %\ -
endif
