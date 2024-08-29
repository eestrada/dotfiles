if executable('black')
    setlocal formatprg=black\ --quiet\ --fast\ --stdin-filename\ %\ -\ 2>/dev/null
endif
