" .vimrc

execute pathogen#infect()
syntax on

set t_Co=256

filetype plugin indent on
au BufRead,BufNewFile Vagrantfile setlocal ft=ruby

set tabstop=2
set shiftwidth=2
set expandtab
set <BS>=
set backspace=2
set list listchars=tab:\|·,trail:·
set smartindent
set smarttab
set autoindent
set ruler
set laststatus=2
set number

" let g:gitgutter_sign_column_always=1

color jellybeans
highlight clear LineNr
highlight link LineNr SignColumn
let g:airline_powerline_fonts=1
let g:puppet_align_hashes=1

command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"
