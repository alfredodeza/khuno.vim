" File:        khuno.vim
" Description: A Python Flakes plugin: analyze your code on the fly
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"
"============================================================================


function! khuno#Status(...) abort
    if !exists('b:flake_errors')
        return ''
    endif
    if (a:0 > 0)
        let text = a:1
    else
        let text = "E"
    endif
    if len(b:flake_errors)
        return '['.text.']'
    else
        return ''
endfunction
