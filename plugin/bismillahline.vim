if exists('g:loaded_bismillahline') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

lua require('bismillahline').init()

command! BismillahQuote lua require('bismillahline').display_quote()

let g:loaded_bismillahline = 1

let &cpo = s:save_cpo
unlet s:save_cpo
