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
