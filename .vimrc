set nocompatible
set nowrap nu smartindent
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

set path+=**
set wildmenu
filetype plugin indent on

colorscheme murphy

let g:netrw_banner=0
let g:netrw_liststyle=3
let g:netrw_list_hide= netrw_gitignore#Hide() . '*.sw?'

call plug#begin('~/.vim/plugged')
Plug 'vim-syntastic/syntastic'
Plug 'mtscout6/syntastic-local-eslint.vim'
call plug#end()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']

nnoremap Q <nop>

inoremap \des describe('', () => {<CR>});<ESC>kci'
inoremap \be beforeEach(() => {<CR>});<ESC>O
inoremap \ae afterEach(() => {<CR>});<ESC>O
inoremap \it it('', () => {<CR>});<ESC>kci'
inoremap \() () => {<CR>}));<ESC>kf)i
