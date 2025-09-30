" vim-plug Plugin Management Configuration
" This file manages vim plugins using vim-plug
" Source this file from your main vim configuration

"---------------------------------------------------------------------------
" vim-plug initialization
"
" Ensure vim-plug is installed
" Check multiple possible locations for vim-plug
let s:plug_locations = [
  \ expand('~/.vim/autoload/plug.vim'),
  \ expand('~/vimfiles/autoload/plug.vim'),
  \ expand('~/dotfiles/vim/vimfiles/autoload/plug.vim')
  \ ]

let s:plug_found = 0
for s:plug_path in s:plug_locations
  if filereadable(s:plug_path)
    execute 'source ' . s:plug_path
    let s:plug_found = 1
    " Debug: show which vim-plug file was loaded
    if get(g:, 'debug_plugins', 0)
      echo 'vim-plug loaded from: ' . s:plug_path
    endif
    break
  endif
endfor

" Debug: show all checked paths if vim-plug not found
if !s:plug_found && get(g:, 'debug_plugins', 0)
  echo 'vim-plug not found in any of these locations:'
  for s:plug_path in s:plug_locations
    echo '  ' . s:plug_path . ' (exists: ' . (filereadable(s:plug_path) ? 'yes' : 'no') . ')'
  endfor
endif

if !s:plug_found
  " Auto-install vim-plug if not found
  if has('win32') || has('win64')
    " Windows - try multiple methods
    let s:plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    let s:plug_dir = expand('~/vimfiles/autoload')
    let s:plug_file = s:plug_dir . '/plug.vim'
    
    " Create directory if it doesn't exist
    if !isdirectory(s:plug_dir)
      call mkdir(s:plug_dir, 'p')
    endif
    
    " Try to download vim-plug
    if executable('curl')
      silent execute '!curl -fLo ' . s:plug_file . ' ' . s:plug_url
    elseif executable('wget')
      silent execute '!wget -O ' . s:plug_file . ' ' . s:plug_url
    elseif executable('powershell')
      " Use PowerShell as fallback
      silent execute '!powershell -Command "Invoke-WebRequest -Uri ' . s:plug_url . ' -OutFile ' . s:plug_file . '"'
    else
      echoerr 'vim-plug installation failed: curl, wget, or PowerShell not available'
      echoerr 'Please manually install vim-plug from: https://github.com/junegunn/vim-plug'
    endif
    
    " Verify installation and reload if successful
    if filereadable(s:plug_file)
      source s:plug_file
      echo 'vim-plug installed successfully. Run :PlugInstall to install plugins.'
    endif
  else
    " Unix/macOS
    silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

" Determine plugin directory based on platform
if has('win32') || has('win64')
  let g:plug_home = expand('~/vimfiles/plugged')
else
  let g:plug_home = expand('~/.vim/plugged')
endif

"---------------------------------------------------------------------------
" Plugin definitions
"
call plug#begin(g:plug_home)

" Essential plugins
Plug 'tpope/vim-sensible'           " Sensible defaults
Plug 'tpope/vim-surround'           " Surround text objects
Plug 'tpope/vim-commentary'         " Comment/uncomment
Plug 'tpope/vim-repeat'             " Repeat plugin commands

" File and search enhancement
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'             " Fuzzy finder
Plug 'preservim/nerdtree'           " File tree explorer

" Git integration
Plug 'tpope/vim-fugitive'           " Git wrapper
Plug 'airblade/vim-gitgutter'       " Git diff in gutter

" Appearance and themes
Plug 'altercation/vim-colors-solarized'  " Solarized theme (already included)
Plug 'vim-airline/vim-airline'      " Status line enhancement
Plug 'vim-airline/vim-airline-themes'

" Language support (lightweight selection)
Plug 'sheerun/vim-polyglot'         " Language pack
Plug 'dense-analysis/ale'           " Async linting engine

" Productivity enhancements
Plug 'jiangmiao/auto-pairs'         " Auto-close brackets
Plug 'godlygeek/tabular'           " Text alignment
Plug 'easymotion/vim-easymotion'   " Quick cursor movement

call plug#end()

"---------------------------------------------------------------------------
" Plugin-specific configurations
"

" NERDTree configuration
let g:NERDTreeWinSize = 30
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\.pyc$', '\~$', '\.swp$', '\.git$']

" fzf configuration
let g:fzf_layout = { 'down': '~40%' }
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" vim-airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 0  " Disable powerline fonts for compatibility

" ALE linting configuration
let g:ale_enabled = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0

" GitGutter configuration
let g:gitgutter_enabled = 1
let g:gitgutter_map_keys = 0  " Disable default mappings

" EasyMotion configuration
let g:EasyMotion_do_mapping = 0  " Disable default mappings
let g:EasyMotion_smartcase = 1   " Turn on case-insensitive feature
let g:EasyMotion_startofline = 0 " Keep cursor column when JK motion
let g:EasyMotion_use_upper = 1   " Use uppercase letters for labels
let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ;'
let g:EasyMotion_use_smartsign_us = 1 " Smart sign matching

"---------------------------------------------------------------------------
" Plugin-related key mappings
"

" NERDTree toggle
nnoremap <silent> <F2> :NERDTreeToggle<CR>

" fzf mappings
" CTRL+P restored to default (command-line history) - use <leader>p for file finder
nnoremap <silent> <leader>p :Files<CR>
" CTRL+B restored to default (scroll up) - use <leader>b for buffer list
nnoremap <silent> <leader>b :Buffers<CR>
" CTRL+F restored to default (page down) - use <leader>f for ripgrep search
nnoremap <silent> <leader>f :Rg<CR>

" Git fugitive mappings
nnoremap <silent> <leader>gs :Git status<CR>
nnoremap <silent> <leader>gd :Git diff<CR>
nnoremap <silent> <leader>gc :Git commit<CR>

" ALE navigation
nnoremap <silent> <leader>an :ALENext<CR>
nnoremap <silent> <leader>ap :ALEPrevious<CR>

" EasyMotion mappings
" <Leader><Leader> prefix for all EasyMotion commands
" Jump to anywhere you want with minimal keystrokes
nmap <Leader><Leader>s <Plug>(easymotion-s2)
nmap <Leader><Leader>t <Plug>(easymotion-t2)

" Line motions
map <Leader><Leader>j <Plug>(easymotion-j)
map <Leader><Leader>k <Plug>(easymotion-k)
map <Leader><Leader>l <Plug>(easymotion-lineforward)
map <Leader><Leader>h <Plug>(easymotion-linebackward)

" Word motions
map <Leader><Leader>w <Plug>(easymotion-w)
map <Leader><Leader>b <Plug>(easymotion-b)
map <Leader><Leader>e <Plug>(easymotion-e)
map <Leader><Leader>ge <Plug>(easymotion-ge)

" Search motion (similar to / but with EasyMotion)
map <Leader><Leader>/ <Plug>(easymotion-sn)

" Repeat last motion
map <Leader><Leader>. <Plug>(easymotion-repeat)

"---------------------------------------------------------------------------
" Plugin management commands
"

" Command to install/update plugins
command! PluginUpdate PlugUpdate | PlugUpgrade
command! PluginClean PlugClean
command! PluginInstall PlugInstall

" Auto-install missing plugins on startup (optional)
if get(g:, 'auto_install_plugins', 0)
  autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif
endif
