"winpos 500 0
nmap * *N
nmap <ESC><ESC> :<C-u>nohlsearch<cr><Esc>
"nmap <C-c><C-c> :<C-u>nohlsearch<cr><Esc>
"nmap <C-c><C-c> :%s@^\t@//\t@g
set fileformat=dos
set fileformats=dos,unix
set fileencoding=utf-8
set fileencodings=utf-8,cp932
set autoindent
"set smartindent
"set cindent
"set indentexpr
set ts=4
set sw=4
set sts=0
set noexpandtab
retab 4
set autoindent
set nolist
"set list
set listchars=tab:^\ ,trail:~
set listchars=tab:^\ ,trail:~,eol:$
"swap output directory
set directory=$HOME\vimfiles\tmp
set backupdir=$HOME\vimfiles\tmp

""""""""""""""""""""""""""""""
"SpXy[Xð\¦
""""""""""""""""""""""""""""""
"RgÈOÅSpXy[XðwèµÄ¢éÌÅ scriptencodingÆA
"±Ìt@CÌGR[hªêv·éæ¤ÓI
"SpXy[Xª­²\¦³êÈ¢êA±±Åscriptencodingðwè·éÆÇ¢B
"scriptencoding cp932

"ftHgÌZenkakuSpaceðè`
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpaceðJ[t@CÅÝè·éÈçÌsÍí
    autocmd ColorScheme       * call ZenkakuSpace()
    " SpXy[XÌnCCgwè
    autocmd VimEnter,WinEnter * match ZenkakuSpace /@/
  augroup END
  call ZenkakuSpace()
endif
