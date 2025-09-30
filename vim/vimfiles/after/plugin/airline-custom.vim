" キャッシュ無効化（Airline 読み込み前でもOK）
let g:airline_highlighting_cache = 0
" airline向けテーマ設定を最後に上書きでStatusLineのカラーをコントロール (Solarizedによる設定を上書き)
" :echo globpath(&rtp, 'autoload/airline/themes/*.vim') から選択
let g:airline_theme = 'badwolf'
" let g:airline_theme = 'ayu_mirage'
" let g:airline_theme = 'jet'
" let g:airline_theme = 'atomic'
" let g:airline_theme = 'minimalist'
" let g:airline_theme = 'cyberpunk'
" タブラインを表示
let g:airline#extensions#tabline#enabled = 1
" Powerline Fontsを利用
let g:airline_powerline_fonts = 1
