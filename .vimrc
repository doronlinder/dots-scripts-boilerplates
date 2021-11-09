set nocompatible
set nowrap nu smartindent
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

set path+=public/**
set path+=src/**
set path+=js/**
set path+=scripts/**
set path+=styles/**
set wildmenu
set suffixesadd=.js
set suffixesadd+=.json
filetype plugin indent on

set backup
set backupdir=/tmp//
set dir=/tmp//

" set termguicolors
set t_ut=

let g:netrw_banner=0
let g:netrw_liststyle=3
" let g:netrw_list_hide= netrw_gitignore#Hide() . '*.sw?'

call plug#begin('~/.vim/plugged')
Plug 'prettier/vim-prettier', { 'do': 'npm install' }                                                                                             
Plug 'rafi/awesome-vim-colorschemes'                                                                                                              
Plug 'leafgarland/typescript-vim'                                                                                                                 
Plug 'pangloss/vim-javascript'                                                                                                                    
Plug 'MaxMEllon/vim-jsx-pretty'                                                                                                                   
Plug 'peitalin/vim-jsx-typescript'                                                                                                                
Plug 'jparise/vim-graphql'
call plug#end()

nnoremap Q <nop>
nmap <Leader>p <Plug>(Prettier)
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier

" inoremap \des describe('', () => {<CR>});<ESC>kci'
" inoremap \be beforeEach(() => {<CR>});<ESC>O
" inoremap \ae afterEach(() => {<CR>});<ESC>O
" inoremap \it it('', () => {<CR>});<ESC>kci'
" inoremap \() () => {<CR>}));<ESC>kf)i

" autocmd BufWritePre *.js %s/\s\+$//e

colorscheme orbital
