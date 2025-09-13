" Cross-platform GUI font chooser for Vim/gVim/MacVim/Neovim-GUI
" Usage: call gui_font#Apply()
if exists('*gui_font#Apply') == 0
  function! gui_font#Apply() abort
    " Only when GUI is available
    if !exists('+guifont')
      return
    endif

    " OS detection
    if has('win32') || has('win64')
      let s:candidates = [
            \ 'JetBrainsMono Nerd Font:h12',
            \ 'JetBrains Mono:h12',
            \ 'FiraCode Nerd Font Mono:h12',
            \ 'Fira Code:h12',
            \ 'Cascadia Code PL:h12',
            \ 'Cascadia Mono PL:h12',
            \ 'Consolas:h12'
            \ ]
      " Wide font for CJK on Windows (preinstalled)
      let s:wide = 'Yu Gothic UI:h12'
    elseif has('mac')
      let s:candidates = [
            \ 'JetBrainsMono Nerd Font:h13',
            \ 'JetBrains Mono:h13',
            \ 'FiraCode Nerd Font Mono:h13',
            \ 'Fira Code:h13',
            \ 'Menlo:h13'
            \ ]
      let s:wide = 'Hiragino Sans:h13'
    else
      " Linux/*BSD
      let s:candidates = [
            \ 'JetBrainsMono Nerd Font:h12',
            \ 'JetBrains Mono:h12',
            \ 'FiraCode Nerd Font Mono:h12',
            \ 'Fira Code:h12',
            \ 'DejaVuSansMono:h12',
            \ 'UbuntuMono:h12'
            \ ]
      let s:wide = 'NotoSansCJKJP-Regular:h12'
    endif

    " Try candidates in order; stop at first success
    for font in s:candidates
      try
        execute 'set guifont=' . font
        " If set succeeded, optionally set wide font (ignore errors)
        " Only set guifontwide on systems that support it (Linux/Unix, not Windows or macOS)
        if !has('mac') && !has('win32') && !has('win64')
          if exists('+guifontwide') && has('gui_running')
            try | execute 'set guifontwide=' . s:wide | catch | endtry
          endif
        endif
        break
      catch
        " try next candidate
      endtry
    endfor
  endfunction
endif
