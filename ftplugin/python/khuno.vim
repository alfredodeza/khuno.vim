" File:        khuno.vim
" Description: A Python Flakes plugin: analyze your code on the fly
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
" Notes:       The (current) alternatives forced you to call a function. We
"              can do better. This plugin is better.
"
"============================================================================


if exists("g:loaded_khuno") || &cp
  finish
endif

let g:loaded_khuno = 1

if !exists('g:flake_executable')
  let g:flake_executable = 'flake8'
endif


function! s:Echo(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        echohl WarningMsg | echo a:msg | echohl None
    endif

    let &ruler=x | let &showcmd=y
endfun

function! s:CurrentPath()
    let cwd = expand("%:p")
    return cwd
endfunction

function! s:Flake()
    let abspath = s:CurrentPath()
    let cmd = "flake8 " . abspath
    let out = system(cmd)
    echo out

endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
    let _version    = "version\n"
    return _version
endfunction


function! s:Version()
    call s:Echo("khuno.vim version 0.0.1dev", 1)
endfunction


function! s:Proxy(action)
    if (executable(g:flake_executable) == 0)
        call s:Echo("flake8 not found. This plugin needs flake8 installed and accessible")
        return
    endif
    if (a:action == "version")
        call s:Version()
    else
        call s:Flake()
        "call s:Echo("Khuno: not a valid file or option ==> " . a:action)
    endif
endfunction


command! -nargs=+ -complete=file Khuno call s:Proxy(<f-args>)
