" Example local vim configuration file
" Copy this to ~/.vim/local.vim or ~/vimfiles/local.vim and customize as needed
"
" This file provides examples for user-specific vim overrides and customizations
" It will be sourced automatically if it exists

" =============================================================================
" Personal Editor Preferences
" =============================================================================

" Override common settings
" set number          " Show line numbers
" set relativenumber  " Show relative line numbers
" set wrap            " Enable line wrapping
" set cursorline      " Highlight current line
" set colorcolumn=80  " Show column guide at 80 characters

" Personal indentation preferences (override defaults)
" set tabstop=2       " Use 2-space tabs
" set shiftwidth=2
" set softtabstop=2

" =============================================================================
" Color Scheme Overrides
" =============================================================================

" Override default color scheme
" colorscheme desert
" colorscheme molokai

" Custom highlight overrides
" highlight Comment ctermfg=gray guifg=gray
" highlight LineNr ctermfg=darkgray guifg=darkgray

" =============================================================================
" Plugin Configuration Overrides
" =============================================================================

" NERDTree personal preferences
" let g:NERDTreeWinSize = 40
" let g:NERDTreeShowBookmarks = 1

" fzf personal preferences
" let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }

" ALE linter overrides
" let g:ale_linters = {
" \   'python': ['flake8', 'mypy'],
" \   'javascript': ['eslint'],
" \}
" let g:ale_fixers = {
" \   'python': ['black', 'isort'],
" \   'javascript': ['prettier'],
" \}

" =============================================================================
" Custom Key Mappings
" =============================================================================

" Personal leader key (override default)
" let mapleader = ','

" Custom navigation mappings
" nnoremap <leader>h <C-w>h
" nnoremap <leader>j <C-w>j
" nnoremap <leader>k <C-w>k
" nnoremap <leader>l <C-w>l

" Quick save and quit
" nnoremap <leader>w :w<CR>
" nnoremap <leader>q :q<CR>

" Buffer navigation
" nnoremap <C-n> :bnext<CR>
" nnoremap <C-p> :bprevious<CR>

" Custom text editing shortcuts
" inoremap jj <Esc>
" nnoremap <leader>/ :nohlsearch<CR>

" =============================================================================
" File Type Specific Settings
" =============================================================================

" Python files
" autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
" autocmd FileType python setlocal colorcolumn=88

" JavaScript/TypeScript files
" autocmd FileType javascript,typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2

" Markdown files
" autocmd FileType markdown setlocal wrap linebreak nolist
" autocmd FileType markdown setlocal spell spelllang=en_us

" =============================================================================
" Development Environment Specific
" =============================================================================

" Work-specific settings
" if hostname() =~# 'work'
"     set directory=/tmp/vim-swap
"     set backupdir=/tmp/vim-backup
" endif

" Language-specific development setups
" if isdirectory(expand('~/projects/python'))
"     set path+=~/projects/python/**
" endif

" =============================================================================
" Performance Tuning (Personal)
" =============================================================================

" Disable expensive features on slow machines
" if $SLOW_MACHINE == '1'
"     set norelativenumber
"     set nocursorline
"     set lazyredraw
"     let g:gitgutter_enabled = 0
" endif

" =============================================================================
" Custom Commands and Functions
" =============================================================================

" Custom command to edit this local config
" command! EditLocalVim :edit ~/.vim/local.vim

" Function to toggle between number modes
" function! ToggleNumber()
"     if &number
"         set nonumber
"         set norelativenumber
"     else
"         set number
"         set relativenumber
"     endif
" endfunction
" nnoremap <leader>n :call ToggleNumber()<CR>

" Function to clean trailing whitespace
" function! CleanTrailingWhitespace()
"     let save_cursor = getpos(".")
"     let old_query = getreg('/')
"     silent! %s/\s\+$//e
"     call setpos('.', save_cursor)
"     call setreg('/', old_query)
" endfunction
" nnoremap <leader>cw :call CleanTrailingWhitespace()<CR>

" =============================================================================
" Plugin Additions (Personal Plugins)
" =============================================================================

" Add personal plugins (if using plugins.vim)
" This section would extend the plugin list
" Uncomment and add to vim/plugins.vim instead:

" " Personal productivity plugins
" Plug 'vimwiki/vimwiki'
" Plug 'junegunn/goyo.vim'         " Distraction-free writing
" Plug 'junegunn/limelight.vim'    " Hyperfocus-writing

" " Personal language plugins
" Plug 'rust-lang/rust.vim'
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" =============================================================================
" GUI Vim Specific (gvim/MacVim)
" =============================================================================

if has('gui_running')
    " Personal GUI preferences
    " set guifont=Monaco:h14        " macOS
    " set guifont=Consolas:h12      " Windows
    " set guifont=DejaVu\ Sans\ Mono:h12  " Linux
    
    " Remove GUI elements you don't like
    " set guioptions-=T             " Remove toolbar
    " set guioptions-=m             " Remove menu bar
    " set guioptions-=r             " Remove right scrollbar
    " set guioptions-=L             " Remove left scrollbar
endif

" =============================================================================
" Terminal Vim Specific
" =============================================================================

if !has('gui_running')
    " Terminal-specific settings
    " set t_Co=256                  " Enable 256 colors
    
    " Better color support for terminal
    " if exists('+termguicolors')
    "     set termguicolors
    " endif
endif

" =============================================================================
" Experimental Features
" =============================================================================

" Test new features before adding to main config
" if $VIM_EXPERIMENTAL == '1'
"     " Experimental settings go here
"     set inccommand=nosplit        " Live substitution preview (Neovim)
" endif

" =============================================================================
" Project-Specific Settings
" =============================================================================

" Load project-specific vim configuration
" if filereadable('.vimrc.local')
"     source .vimrc.local
" endif

echo "Local vim configuration loaded successfully"