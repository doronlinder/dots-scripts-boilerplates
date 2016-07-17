set nowrap nu smartindent
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab
colorscheme murphy

nnoremap Q <nop>

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-dispatch'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/syntastic'
Plug 'mtscout6/syntastic-local-eslint.vim'
call plug#end()

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
