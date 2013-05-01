" Licence: GPL 3, Copyright (C) 2013 by Hagen Fuchs

syntax clear
syntax case ignore

"for i in range(1, line('$'))
"    let l:synlang = matchstr(i, '{syn(tax)?:\(.*\)}')
"    if ( l:synlang != "" )
"        echom l:synlang
"        unlet! b:current_syntax
"        let syntaxfile="syntax/".l:synlang.".vim"
"        exec "syntax include @". l:synlang . " " . syntaxfile
"        exec 'syntax region noutBody'.l:synlang.' matchgroup=noutBodyLimits start=+{syn(tax)?:'.l:synlang.'}$+ matchgroup=NONE end=+^\(.\t\|{\)+ keepend contains=@'.l:synlang
"        let b:current_syntax = "noutliner"
"    endif
"endfor
" TODO Not perfect (endgroup matching).
for i in ['sh', 'rst', 'perl', 'python', 'tex']
    unlet! b:current_syntax
    let syntaxfile="syntax/".i.".vim"
    exec "syntax include @". i . " " . syntaxfile
    "exec 'syntax region noutBody'.i.' matchgroup=noutBodyLimits start=+{'.i.'}$+ end=+^\(.\t\|{\)+ keepend contains=@'.i
    exec 'syntax region noutBody'.i.' matchgroup=noutBodyLimits start=+{'.i.'}$+ end=+^\(.\t\|{.\)+me=s-2 keepend contains=@'.i
endfor
let b:current_syntax = "noutliner"
"" TODO How do I deal with `setlocal foldmethod=syntax` in syntax/perl.vim
setlocal foldmethod=expr
" 11th.
syntax match noutHeadingOdd   /^\.\t\(\t\t\)*[^\t]*$/
"syntax region noutHeadingOdd  start=+^\.\t\(\t\t\)*+ end=+\n+
syntax match noutHeadingEven  /^\.\t\t\(\t\t\)*[^\t]*$/
"syntax region noutHeadingEven start=+^\.\t\t\(\t\t\)*+ end=+\n+
syntax match  noutBodyLimits   /^{-\{3,\}}$/


highlight Folded guifg=darkcyan guibg=bg   ctermfg=cyan
highlight FoldColumn guifg=darkcyan guibg=bg   ctermfg=cyan ctermbg=242
highlight noutHeadingOdd  ctermfg=LightGreen guifg=Green
highlight noutHeadingEven ctermfg=LightBlue guifg=Green
highlight noutMeta  ctermfg=DarkGrey guifg=Green
highlight noutBody ctermbg=DarkBlue
highlight noutBodyLimits  ctermfg=DarkGrey guifg=Green

