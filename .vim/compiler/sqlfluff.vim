" Vim compiler file
" Compiler: sqlfluff for SQL
" Maintainer: Ethan Estrada <ethan@misterfidget.com>
" Last Change: 2024 Sep 11

if exists('current_compiler')
  finish
endif
let current_compiler = 'sqlfluff'

let s:save_cpo = &cpo
set cpo-=C

" A dialect must be passed as part of the `:make` invocation
" or this `makeprg` will fail.
CompilerSet makeprg=sqlfluff\ lint\ --disable-progress-bar\ --format\ github-annotation-native\ %:S\ --dialect
CompilerSet errorformat=\ %#::%t%.%#\\,file=%f\\,line=%l\\,col=%c\\,endLine=%e\\,endColumn=%k::%m

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: sw=2 sts=2 et
