scriptencoding utf-8

if exists('g:loaded_artist_nvim') | finish | endif

let s:save_cpo = &cpoptions
set cpoptions&vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! ArtistFreehandToggle lua require'artist'.artist_freehand_toggle()

command! ArtistFreehandOn lua require'artist'.artist_freehand_on()

command! ArtistFreehandOff lua require'artist'.artist_freehand_off()


nnoremap <silent> <leader>aa :ArtistFreehandToggle<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""

let &cpoptions = s:save_cpo
unlet s:save_cpo

let g:loaded_artist_nvim = 1
