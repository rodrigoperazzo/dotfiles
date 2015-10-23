" Make Vim more useful
set nocompatible
" Enable syntax highlighting
syntax enable
" Use the Delek theme
colorscheme delek
" Enable line numbers
set number
" Convert tabs as 4 spaces
set tabstop=4 shiftwidth=4 expandtab
" allow backspacing in insert mode
set backspace=indent,eol,start
" Show the cursor position
set ruler
" Show the filename in the window titlebar
set title
" Highlight current line
set cursorline
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" toggle auto indent on paste
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

"=========== Vundle ===========
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugins and its maps
Plugin 'victorrattis/tcomment_vim'
map <C-_> :TComment<CR>

Plugin 'rodrigoperazzo/whitespaces_vim'
map <C-t>w :ToggleWhitespaces<CR>

" Required, Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
"==============================

" Highlight long lines
fun! LongLineHighlight()
    " Only do it if b:noLLHi variable isn't set
    if exists('b:noLLHi')
        return
    endif
    match ErrorMsg '\%>99v.\+'
endfun
autocmd VimEnter * call LongLineHighlight()
autocmd FileType text let b:noLLHi=1

" Select all
map <C-a> <ESC>gg<CR>vG
" Write buffer
map <C-o> <ESC>:w<CR>
" Move text
nnoremap <C-j> :m .+1<CR>
nnoremap <C-k> :m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
