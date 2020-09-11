scriptencoding utf-8

if exists('g:loaded_artist_nvim') | finish | endif

let s:save_cpo = &cpoptions
set cpoptions&vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! ArtistToggle lua require'artist'.artist_toggle()

command! ArtistOn lua require'artist'.artist_on()

command! ArtistOff lua require'artist'.artist_off()

""""""""""""""""""""""""""""""""""""""""""""""""""""""

let &cpoptions = s:save_cpo
unlet s:save_cpo

let g:loaded_artist_nvim = 1
