" Licence: GPL 3, Copyright (C) 2013 by Hagen Fuchs

" Preample {{{1
" TODO This is commented out in vimoutliner
if exists("b:loaded_wretch")
    finish
endif
" }}}1

" Parameters, Globals and Redefinitions. {{{1
let maplocalleader = ",,"

"setlocal backspace=2
"setlocal wrapmargin=5
"setlocal wrap!
setlocal noexpandtab
setlocal nosmarttab
setlocal softtabstop=0
setlocal tabstop=4
setlocal shiftwidth=4   " I wish sth. like `set sw=&ts` would work.
setlocal foldlevel=0
"setlocal foldcolumn=1
setlocal foldmethod=expr
setlocal foldexpr=MyFoldLevel(v:lnum)
" TODO vimoutlinersens claim that setlocal wouldn't work with this line
set foldtext=MyFoldText()
" Suppress that neverending string of dashes after the fold texts.
setlocal fillchars="fold: "
"setlocal indentexpr=
"setlocal nocindent
setlocal autoindent
setlocal comments+=:.	" don't delete this comment - it protects the TAB!
"setlocal iskeyword=@,39,45,48-57,_,129-255
" }}}1

" Mappings.
" Fold Mappings {{{1
" TODO l: prefix?
map <silent><buffer>   <localleader>0    :set foldlevel=99999<CR>
map <silent><buffer>   <localleader>9    :set foldlevel=8<CR>
map <silent><buffer>   <localleader>8    :set foldlevel=7<CR>
map <silent><buffer>   <localleader>7    :set foldlevel=6<CR>
map <silent><buffer>   <localleader>6    :set foldlevel=5<CR>
map <silent><buffer>   <localleader>5    :set foldlevel=4<CR>
map <silent><buffer>   <localleader>4    :set foldlevel=3<CR>
map <silent><buffer>   <localleader>3    :set foldlevel=2<CR>
map <silent><buffer>   <localleader>2    :set foldlevel=1<CR>
map <silent><buffer>   <localleader>1    :set foldlevel=0<CR>
" }}}1
" Checkbox Mappings {{{1
map <silent><buffer>   <localleader>cb    :call InsertCheckbox('')<CR>
map <silent><buffer>   <localleader>c%    :call InsertCheckbox('0% ')<CR>
map <silent><buffer>   <localleader>cd    :call DeleteCheckbox()<CR>
map <silent><buffer>   <localleader>cx    :call ToggleCheckbox(line('.'),'')<CR>
map <silent><buffer>   <localleader>c-    :call ToggleCheckbox(line('.'),'-')<CR>
" }}}1
" Convenience Mappings {{{1
" TODO ,,T: Insert heading below current body?
inoremap <silent><buffer>  <localleader>h    <C-o>:call InsertHeading()<CR>
nnoremap <silent><buffer>  <localleader>h    :call InsertHeading()<CR>
inoremap <silent><buffer>  <localleader>b    <C-o>:call InsertBody()<CR>
nnoremap <silent><buffer>  <localleader>b    :call InsertBody()<CR>
inoremap <silent><buffer>  <localleader>-    <C-o>:call InsertDivider()<CR><Down><End><CR>
nnoremap <silent><buffer>  <localleader>-    :call InsertDivider()<CR>
noremap  <silent><buffer>  <localleader><    :call ShiftHeading('<')<CR>
noremap  <silent><buffer>  <localleader>>    :call ShiftHeading('>')<CR>
" }}}1
" Interlinking Mappings {{{1
nnoremap <buffer> <localleader>j :call JumpToTargetID()<CR>
" This time we really want to escape to normal mode first.
inoremap <buffer> <localleader>j :call <ESC>JumpToTargetID()<CR>
" }}}1

" Functions.
" Basic Functions {{{1
" These functions should not depend on any of the other function groups.
" Foundational stuff indeed.
" Ind(line) {{{2
" Determine the indentation level of a heading.
" Returns 0 for the first valid indentation level ('^.\t').
function! Ind(line)
    return matchend( getline(a:line), '^\.\t*' ) - 2
endfunction
"}}}2
" IsHeading {{{2
function! IsHeading(line)
    return ( match( getline(a:line), '^\.\t\+' ) != -1 )
endfunction
" }}}2
" FindParent(line) {{{2
function! FindParent(line)
    for i in range(a:line,1,-1)
        if ( Ind(i) == -3 )
            continue
        elseif ( ( Ind(i) < Ind(a:line) ) && IsHeading(i) )
            return i
        endif
    endfor
endfunction
"}}}2
" FindNextHeading(line) {{{2
function! FindNextHeading(line)
    for i in range(a:line+1,line('$'))
        if ( IsHeading(i) )
            return i
        endif
    endfor
    return line('$')
endfunction
"}}}2
" FindPreviousHeading(line) {{{2
function! FindPreviousHeading(line)
    for i in range(a:line,1,-1)
        if ( IsHeading(i) )
            return i
        endif
    endfor
    return -1
endfunction
"}}}2
" MyFoldLevel {{{2
" I start from the current line and go backwards till I find
" a line of heading type.  It's indentation level +1 is this line's fold
" level.  This is the most surprising and pleasing part: the runtime
" behaviour is orders of magnitude better than Vimoutliner's (because of
" the simplified design).
function! MyFoldLevel(line)
    if ( IsHeading(a:line) )
        return '>'.(Ind(a:line)+1)
    else
        if ( IsHeading(a:line-1) )
            if ( getline(a:line) == "" )   " IsEmptyLine()
                return 0
            else
                return '>' . (Ind(a:line-1)+2)
            endif
        else
            return '='
        endif
    endif
endfunction
" }}}2
" MyFoldText {{{2
" By default, Vim will replace \t with just a single space when folding.
" For beautiful alignment of folds, we replace \t by an equivalent
" amount of spaces here.  Also note the absence of width-filling dashes
" in wretch's folds; that's done by setting 'fillchars' (see above).
function! MyFoldText()
    let l:lines  = v:foldend - v:foldstart
    let l:lines  = ( l:lines > 1 ) ? " (".l:lines.")" : ""
    let l:spaces = repeat(' ', &ts)

    if ( IsHeading(v:foldstart) )
        " In order for everything to nicely line up at &ts columns,
        " I need to replace the first <TAB> with &ts-1 spaces.  Hence
        " two steps here.
        let l:sub = substitute( getline(v:foldstart), "\t", repeat(' ', &ts - 1), "" )
        let l:sub = substitute( l:sub               , "\t", l:spaces            , "g" )
    else
        " TODO '(text)'?  Perhaps '(rst text; 2013-05-01)'?
        let l:sub = repeat( l:spaces , len(v:folddashes) - 1 ) . l:spaces . '(text)'
    endif
    " Multibyte string length counting proudly presented by :h strlen().
    let l:len = strlen( substitute(l:sub, ".", "x", "g") )
    return l:sub . ' ' . repeat( '-', &tw - l:len - len(l:lines) - 1 ) . l:lines
endfunction
"}}}2
" Checkbox Functions {{{1
" Everything checkbox.
" HasCheckbox {{{2
function! HasCheckbox(line)
    return ( match( getline(a:line), '^\.\t\+\[[xX_-]\]') != -1 )
endfunction
" }}}2
" InsertCheckbox {{{2
" TODO Add optional percentage counter.
function! InsertCheckbox(postfix)
    if ( IsHeading(line('.')) )
        if ( HasCheckbox(line('.')) )
            return -1
        else
            call setline(line('.'), substitute(getline('.'), '^\(\.\t*\)', '\1[_] '.a:postfix, ''))
        endif
    endif
endfunction
" }}}2
" DeleteCheckbox {{{2
function! DeleteCheckbox()
    if ( IsHeading(line('.')) )
        call setline(line('.'), substitute(getline('.'), '^\(\.\t*\)\[[_-xX]\]\( \d\{1,3}%\)\?\s*', '\1', ''))
    endif
endfunction
" }}}2
" SetChecked {{{2
function! SetChecked(lineno)
    if ( HasCheckbox(a:lineno) )
        let l:line = getline(a:lineno)
        call setline(a:lineno, substitute(l:line, '^\(\.\t*\)\[[-_]\]\s*', '\1[x] ', ''))
    endif
endfunction
" }}}2
" SetUnChecked {{{2
function! SetUnChecked(lineno)
    if ( HasCheckbox(a:lineno) )
        let l:line = getline(a:lineno)
        call setline(a:lineno, substitute(l:line, '^\(\.\t*\)\[[xX]\]\s*', '\1[_] ', ''))
    endif
endfunction
" }}}2
" SetFailed {{{2
function! SetFailed(lineno)
    if ( HasCheckbox(a:lineno) )
        let l:line = getline(a:lineno)
        call setline(a:lineno, substitute(l:line, '^\(\.\t*\)\[[_xX]\]\s*', '\1[-] ', ''))
    endif
endfunction
" }}}2
" SetRatioOrCheck {{{2
function! SetRatioOrCheck(lineno, ratio)
    if ( HasCheckbox(a:lineno) )
        let l:line = getline(a:lineno)
        call setline( a:lineno, substitute(l:line, '^\(\.\t*\)\[\([_xX-]\)\]\s\d\{1,3\}%', '\1[\2] '.a:ratio.'%', '') )
    endif
    if ( a:ratio == 100 )
        call SetChecked(a:lineno)
    else
        call SetUnChecked(a:lineno)
    endif
endfunction
" }}}2
" IsUnCheckedOrFailed {{{2
function! IsUnCheckedOrFailed(line)
    return ( match( getline(a:line), '^\.\t\+\[[_-]\]') != -1 )
endfunction
" }}}2
" IsUnChecked {{{2
function! IsUnChecked(line)
    return ( match( getline(a:line), '^\.\t\+\[[_]\]') != -1 )
endfunction
" }}}2
" ToggleCheckbox {{{2
" Design Decision™:  On toggling a checkbox' state, I won't change the
" status of the child headings only the once higher up in the hierarchy.
" This is in marked contrast to Vimoutliner.  Reason: Personal
" preference (for whatever reason, I often want to declare an
" incompletely completed list as completed) and performance (I only need
" to ascend in the tree; very important).
function! ToggleCheckbox(lineno, char)
    if ( ! HasCheckbox(a:lineno) )
        return
    endif

    if ( a:char == '-' )
        call SetFailed(a:lineno)
    elseif ( IsUnCheckedOrFailed(a:lineno) )
        call SetChecked(a:lineno)
    else
        call SetUnChecked(a:lineno)
    endif

    call UpdateBox( FindParent(a:lineno) )
endfunction
" }}}2
" UpdateBox {{{2
function! UpdateBox(lineno)
    let l:line     = getline(a:lineno)
    let l:childind = Ind(a:lineno) + 1    " Indentation level of children.

    if ( !HasCheckbox(a:lineno) )
        return
    endif

    let l:checked = 0
    let l:total   = 0

    for i in range( a:lineno+1, line('$') )
        " First, test whether the line's a text element (indentation: -3
        " [don't ask]), then skip if indentation is lower than my
        " children's (next heading, higher hierarchy) and then, and only
        " if the indentation level's the same, count the boxes.
        if ( Ind(i) == -3 )
            continue
        elseif ( Ind(i) < l:childind )
            break
        elseif ( ( Ind(i) == l:childind ) && HasCheckbox(i) )
            let l:total   += 1
            let l:checked += IsUnChecked(i) ? 0 : 1
        endif
    endfor

    call SetRatioOrCheck(a:lineno, l:checked * 100 / l:total)

    call UpdateBox( FindParent(a:lineno) )
endfunction
" }}}2
" }}}1
" Convenience Functions {{{1
" InsertHeading {{{2
" Insert new heading below this line OR body text block with the
" indentation of the last heading.
function! InsertHeading()
    let l:refline = FindPreviousHeading(line('.'))
    let l:target  = FindNextHeading(line('.'))

    if ( l:refline == -1 )
        call setline(l:target, '.	')
    else
        call append(l:target-1, substitute(getline(l:refline), '^\(\.\t*\).*$', '\1', ''))
        call cursor(l:target, 1)
    endif
    startinsert!
endfunction
" }}}2
" InsertDivider {{{2
function! InsertDivider()
    let l:div = repeat('-', 40)

    if IsHeading(line('.'))
        call append('.', substitute(getline('.'), '^\(\.\t*\).*$', '\1'.l:div, ''))
    else
        call append('.', l:div)
    endif
    " let l:refline = FindPreviousHeading(line('.'))
    " if ( l:refline == -1 )
    "     call setline('.', '.	'.repeat('-', &tw-&sw-1)
    " else
    "     let l:div = repeat('-', 40)
    "     call append('.', substitute(getline(l:refline), '^\(\.\t*\).*$', '\1'.l:div, ''))
    " endif
endfunction
" }}}2
" InsertBody {{{2
function! InsertBody()
    " To be honest, I'm blowing up the size to avoid 1-line text bodies
    " because they won't be folded nicely.  Also: I like it that way.
    call append(line('.'), "{syntax:rst}")
    call append(line('.')+1, "")
    call append(line('.')+2, "{----------}")
    call cursor(line('.')+2, 1)
    normal! zv
    startinsert!
endfunction
" }}}2
" ShiftHeading {{{2
function! ShiftHeading(direction)
    if ( IsHeading(line('.')) )
        if ( a:direction == '<' )
            call setline( line('.'), substitute(getline('.'), '^\.\t\t', '.\t', '') )
        elseif ( a:direction == '>' )
            call setline( line('.'), substitute(getline('.'), '^\.\t', '.\t\t', '') )
        else
            echoe "ShiftHeading: wrong argument!"
        end
    endif
endfunction
" }}}2
" }}}1
" Interlinking {{{1
" JumpToTargetID {{{2
" Implements a interlinking feature for wretch.  To define a target,
" just place square brackets around it: '[target]'.  To link to it,
" simply write '[-> target]' or just '[> target]'.
" If you are on a line containing [> string], cursor positioned inside
" the brackets, then calling this function (usually by hitting
" '<localleader>j') will jump to the (nearest) occurence of [string].
" Really simple but rather effective.
function! JumpToTargetID()
    " General parameters (like shape of the regexp for interlinks).
    let l:pattern = '\m\[-\?>\s*\([^\[\]]\+\)\]'
    let l:links   = [[]]
    let l:timeout = 1000

    " For links that spread over two lines, we need to take the previous
    " and next line in consideration and join these with a special
    " separator (l:sep).
    let l:sep     = '!:-:!'
    let l:lines   = join( getline( line('.') - 1 , line('.') + 1 ), l:sep )

    " Ugly special test necessary with the multi-line approach: Don't
    " jump if there's no bracket character on /this/ line (would
    " otherwise jump also if only the adjacent lines had links).
    if ( match(getline('.'), '[\[\]]') == -1 )
        echom "No ID found on this line."
        return
    endif

    " Find all occurences of the link pattern in the combined lines and
    " note their position (begin and end).
    let l:i = 1
    while l:i
        let l:begin = match(l:lines, l:pattern, 0, l:i)
        if l:begin != -1
            " Determine the beginning of a pattern and immediately stop
            " collecting links if it's on the third line (the one below
            " the cursor): on the third line, we're only ever interested
            " in continuations of links from the current line.
            let l:begin -= len(l:sep)
            let l:maxbegin = strlen( getline( line('.') - 1 ) . getline( line('.') ) )
            if l:begin > l:maxbegin
                break
            endif
            " The two substitute()s simply normalize multi-line links
            " and create valid target IDs (even with \V, I seem to need
            " to quote heavily in search()es).
            let l:end    = matchend(l:lines, l:pattern, 0, l:i) - len(l:sep)
            let l:id     = matchstr(l:lines, l:pattern, 0, l:i)
            let l:target = substitute(l:id, l:sep.'\s*:\?\s*', ' ', '')
            let l:target = substitute(l:target, l:pattern, '\\\[\1\\\]', '')
            let l:links += [[ l:begin, l:end, l:target ]]
            let l:i += 1
            " For debugging only:
            "echo "Id: " l:id "Target: " l:target "Links: " l:links
        else
            break
        endif
    endwhile

    " If the list is still empty, quit now.
    if l:links == [[]]
        echom "Can't find link target.  Misspelled?"
        return
    else
        call remove(l:links, 0)
    endif

    " Check whether the cursor is placed inside of one of the links and
    " jump there if so (search()'s 's' parameter sets a jump mark to get
    " back with ^o).   Also, use the no-magic flag (\V) in all searches!
    let l:cursorpos = getpos(".")[2] + strlen( getline( line('.') - 1 ) )
    for l:link in l:links
        if index(range(l:link[0], l:link[1]), l:cursorpos) != -1
            if search('\V'.l:link[2], 'sw', 0, l:timeout) == 0
                echom "Target ID not found!"
            endif
            return
        endif
    endfor

    " If the cursor's not positioned smack in the middle of a link, use
    " the last (even partial) link *on* the line the cursor is on!
    if search('\V'.l:links[-1][2], 'sw', 0, l:timeout) == 0
        echom "Target ID not found!"
    endif
endfunction
" }}}2
" }}}1

let b:loaded_wretch = 1

" vim:set foldmethod=marker:foldlevel=0:tw=78
