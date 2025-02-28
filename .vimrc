set nocompatible
set nowrap nu smartindent
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

set encoding=utf-8
set nobackup
set nowritebackup
set noswapfile
set dir=/tmp//

set path+=public/**
set path+=src/**
set path+=js/**
set path+=scripts/**
set path+=styles/**
set wildmenu
set suffixesadd=.js,.jsx,.ts,.tsx,.json
filetype plugin indent on

" set termguicolors
set t_ut=

" for quick vim-gitgutter updates
set updatetime=100

let g:netrw_banner=0
let g:netrw_liststyle=3
" let g:netrw_list_hide= netrw_gitignore#Hide() . '*.sw?'

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive',
Plug 'airblade/vim-gitgutter',
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'rafi/awesome-vim-colorschemes'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"let g:coc_global_extensions = [
"  \ 'coc-tsserver'
"  \ ]
call plug#end()

nnoremap Q <nop>
nmap <Leader>p <Plug>(Prettier)
nnoremap <C-p> :GitFiles<CR>
nnoremap <Leader>f :Rg<CR>
noremap <Leader>F :execute "Rg " . expand("<cword>")<cr>
noremap <Leader>E :execute "Rg \\b" . expand("<cword>") . "\\b"<cr>
noremap <Leader>C :execute ":e ~/.vimrc"<cr>

let g:prettier#autoformat = 0
let g:prettier#config#tab_width = 'auto'
let g:prettier#config#arrow_parens = 'always'
let g:prettier#config#trailing_comma = 'none'
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier

" source ~/.vimrc-coc

" nnoremap > :call CocAction('diagnosticNext')<CR>
" nnoremap < :call CocAction('diagnosticPrevious')<CR>

" Note coc#float#scroll works on neovim >= 0.4.3 or vim >= 8.2.0750
" nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
" nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
" inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" colorscheme orbital
set background=dark
colorscheme PaperColor
