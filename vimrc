" .vimrc

syntax on
set bs=2
set <BS>=
set tabstop=2
set shiftwidth=2
set expandtab
set ruler
autocmd BufWritePre *.pp :%s/\s\+$//e
"set list listchars=tab:��,trail:�
"set spell

au BufNewFile,BufRead *.postgresql setfiletype sql
color desert

command! -range=% -nargs=0 Tab2Space execute "<line1>,<line2>s/^\\t\\+/\\=substitute(submatch(0), '\\t', repeat(' ', ".&ts."), 'g')"
command! -range=% -nargs=0 Space2Tab execute "<line1>,<line2>s/^\\( \\{".&ts."\\}\\)\\+/\\=substitute(submatch(0), ' \\{".&ts."\\}', '\\t', 'g')"

" Show tabs and trailing whitespace visually
"set list listchars=tab:>-,trail:.,extends:>
if (&termencoding == "utf-8") || has("gui_running")
    if v:version >= 700 
        set list listchars=tab:»·,trail:·,extends:?,nbsp:?
    else
        set list listchars=tab:»·,trail:·,extends:?
    endif
else
    if v:version >= 700 
        set list listchars=tab:>-,trail:.,extends:>,nbsp:_
    else
        set list listchars=tab:>-,trail:.,extends:>
    endif
endif
