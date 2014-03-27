" Licence: GPL 3, Copyright (C) 2013 by Hagen Fuchs

" TODO Ideally, I'd like to link to the user's own colorscheme, not
" enforce my own.
syntax clear
syntax case ignore

" LoadSyntaxes() {{{1
" Dynamically load syntax highlighting 'xyz' for text blocks that start
" with {syntax:xyz}.
"
" TODO Do it with
" redir => myvar
" global /^{syn/
" let mylist = split(myvar, "\n")
" ... list -> dictionary
let g:wretch_loaded_syntaxes = {}
function! LoadSyntaxes(toload)
    " Static version:
    "for i in ['sh', 'rst', 'perl', 'python', 'tex']
    "    unlet! b:current_syntax
    "    let syntaxfile="syntax/".i.".vim"
    "    exec "syntax include @". i . " " . syntaxfile
    "    exec 'syntax region noutBody'.i.' matchgroup=noutBodyLimits start=+{'.i.'}$+ end=+^\(.\t\|{.\)+me=s-2 keepend contains=@'.i
    "endfor
    "let b:current_syntax = "wretch"
    for i in range(1, line('$'))
        let l:line = getline(i)

        " TODO There must be some use for :global here...
        if ( match( l:line, '^{syn\(tax\)\?' ) == -1 )
            continue
        endif

        let l:synlang = substitute( l:line, '{syn\(tax\)\?:\(.*\)}', '\2', '' )
        " Reject synlang if it's empty, already loaded or not
        " alphanumerical (what?).  Otherwise put it on the stack of
        " already loaded syntax files.
        if ( ( l:synlang == "" ) ||
                    \ ( has_key(g:wretch_loaded_syntaxes, l:synlang) ) ||
                    \ ( match(l:synlang, '^[[:alnum:]]*$') == -1 ) )
            continue
        else
            let a:toload[l:synlang] = 1
        endif
    endfor

    for l:synlang in keys(a:toload)
        unlet! b:current_syntax
        let l:syntaxfile="syntax/" . l:synlang . ".vim"
        " TODO what if the file doesn't exist?
        exec "syntax include @" . l:synlang . " " . l:syntaxfile
        exec 'syntax region noutBody' . l:synlang .
                    \ ' matchgroup=noutBodyLimits start=+{syn\(tax\)\?:' .
                    \ l:synlang . '}$+ end=+^\(.\t\|{.\)+me=s-2 keepend contains=@' .
                    \ l:synlang
        let b:current_syntax = "wretch"
        let g:wretch_loaded_syntaxes[l:synlang] = 1
    endfor
endfunction
" }}}1

" Make sure that at least the 'rst' syntax file gets loaded because
" that's what InsertBody() uses by default.
call LoadSyntaxes({'rst':1})

"" TODO How do I deal with things like `setlocal foldmethod=syntax` in syntax/perl.vim?
setlocal foldmethod=expr

syntax match noutHeadingOdd   /^\.\t\(\t\t\)*[^\t]*$/
syntax match noutHeadingEven  /^\.\t\t\(\t\t\)*[^\t]*$/
syntax match noutBodyLimits   /^{-\{3,\}}$/

" Highlight Definitions {{{1
highlight Folded          ctermfg=cyan
highlight FoldColumn      ctermfg=cyan ctermbg=242
highlight noutHeadingOdd  ctermfg=LightGreen
highlight noutHeadingEven ctermfg=LightBlue
highlight noutMeta        ctermfg=DarkGrey
highlight noutBody        ctermbg=DarkBlue
highlight noutBodyLimits  ctermfg=DarkGrey
" }}}1

" 2014-03-27, Ha!  All this time I was using ccomment-style syntax
" syncing.  The constant-line/time approach satisfies me for now.
" This needs to come at the end of all that syntax-loading logic.
syntax sync clear
syntax sync minlines=100

" vim:foldmethod=marker
