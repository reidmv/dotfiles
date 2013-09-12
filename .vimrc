" .vimrc

execute pathogen#infect()
syntax on

filetype plugin indent on
au BufRead,BufNewFile Vagrantfile setlocal ft=ruby

set tabstop=2
set shiftwidth=2
set expandtab
set <BS>=
set list listchars=tab:»·,trail:·
set smartindent
set autoindent
set ruler

highlight clear SignColumn

command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"
