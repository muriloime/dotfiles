
"execute pathogen#infect()
"
"
source ~/code/dotfiles/bundles.vim

set nocompatible
filetype off 

set rtp+=~/.vim/bundle/Vundle.vim

colorscheme railscasts
"Invisible character colors 
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59


" set up some custom colors
highlight clear SignColumn
highlight VertSplit    ctermbg=236
highlight ColorColumn  ctermbg=237
highlight LineNr       ctermbg=236 ctermfg=240
highlight CursorLineNr ctermbg=236 ctermfg=240
highlight CursorLine   ctermbg=236
highlight StatusLineNC ctermbg=238 ctermfg=0
highlight StatusLine   ctermbg=240 ctermfg=12
highlight IncSearch    ctermbg=3   ctermfg=1
highlight Search       ctermbg=1   ctermfg=3
highlight Visual       ctermbg=3   ctermfg=0
highlight Pmenu        ctermbg=240 ctermfg=12
highlight PmenuSel     ctermbg=3   ctermfg=1
highlight SpellBad     ctermbg=0   ctermfg=1


" map markdown preview
map <leader>m :!open -a "Atom" %<cr><cr>

" map git commands
map <leader>b :Gblame<cr>
map <leader>l :!clear && git log -p %<cr>
map <leader>d :!clear && git diff %<cr>

"###################
"# general 
"###################

let mapleader = "\<Space>"

"improve speed for ctrlp fuzzy finder 
let g:ctrlp_user_command = 'ag %s -l --hidden --nocolor -g ""'
let g:ctrlp_use_caching = 0


if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

" if executable('ag')
" 		" Note we extract the column as well as the file and line number
" 		set grepprg=ag\ --nogroup\ --nocolor\ --column
" 		set grepformat=%f:%l:%c%m
" endif


syntax on 
set shiftwidth=2
set tabstop=2
set expandtab
set lazyredraw            " don't update while executing macros
set history=1000 
set scrolloff=4

set backspace=indent,eol,start

se mouse+=a "allow to copy without line numbers

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

nmap <leader>vr :sp $MYVIMRC<cr>
nmap <leader>so :source $MYVIMRC<cr>

nmap k gk
nmap j gj

" Copy the entire buffer into the system register
nmap <leader>co ggVG*y

map <Leader>p :set paste<CR><esc>"*]p:set nopaste<cr>

map <Leader>i mmgg=G`m<cr>


map <Leader>cs :call SearchForCallSitesCursor()<CR>

"
" Use the same symbols as TextMate for tabstops and EOLs
"set listchars=tab:▸\ ,eol:¬
"set lcs=tab:>-,eol:<

" search with / faster 
set incsearch
set hlsearch
" Use Silver Searcher instead of grep
set grepprg=ag

set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter

set magic " Set magic on, for regex

set clipboard=unnamed "allow to copy to clipboard


set autoindent " automatically set indent of new line
set smartindent

set laststatus=2 " show the satus line all the time

" Numbers
set number
"set numberwidth=5
set relativenumber 

""" SYSTEM CLIPBOARD COPY & PASTE SUPPORT
set pastetoggle=<F2> "F2 before pasting to preserve indentation
"Copy paste to/from clipboard
vnoremap <C-c> "*y

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright
 
"more split configs 
set winwidth=84 
set winheight=5
set winminheight=5
set winheight=999

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" resize panes
nnoremap <silent> <Right> :vertical resize +5<cr>
nnoremap <silent> <Left> :vertical resize -5<cr>
nnoremap <silent> <Up> :resize +5<cr>
nnoremap <silent> <Down> :resize -5<cr>

autocmd Filetype help nmap <buffer> q :q<cr>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" set tags directory for goto definition
set tags=./.git/tags;

" add match to module, class, def, etc using % or ]]
runtime macros/matchit.vim
" fix error in NERDTree as per
" http://superuser.com/questions/387777/what-could-cause-strange-characters-in-vim
let g:NERDTreeDirArrows=0

"###################
"# Plugin setup 
"###################

"adding spec config to dispatch 
let g:rspec_command = "Dispatch rspec {spec}"

"NERDTree configurations 
"autocmd vimenter * NERDTree
map <C-n> :NERDTreeToggle<CR>

"mappings for rspec
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>


function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
	exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
	exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction
