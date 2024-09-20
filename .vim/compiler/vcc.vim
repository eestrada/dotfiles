" Vim compiler file
" Compiler: vcc vex compiler for SideFX Houdini
" Maintainer: Ethan Estrada <ethan@misterfidget.com>
" Last Change: 2024 Sep 19

if exists('current_compiler')
  finish
endif
let current_compiler = 'vcc'

let s:save_cpo = &cpo
set cpo-=C

CompilerSet makeprg=vcc\ --Werror\ %:S
CompilerSet errorformat=%f:%l:%c%.%#:\ %t%.%#\ %n:\ %m

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: sw=2 sts=2 et
