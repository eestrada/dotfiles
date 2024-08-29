set tabstop=4
set conceallevel=2

if executable('mdformat')
    " Can be installed via :Mason
    "
    " See links for details:
    " * https://github.com/executablebooks/mdformat
    " * https://mdformat.readthedocs.io/en/stable/users/style.html#paragraph-word-wrapping
    setlocal formatprg=mdformat\ -
endif
