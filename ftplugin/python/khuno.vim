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

" au commands

au BufLeave <buffer> call s:ClearFlakes()

au BufEnter <buffer> call s:Flake()
au BufWritePost <buffer> call s:Flake()

au CursorHold <buffer> call s:GetFlakesMessage()
au CursorMoved <buffer> call s:GetFlakesMessage()

function! s:Echo(msg, ...)
    redraw
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
    call s:ParseReport(out)

endfunction


function! s:ParseReport(output)
    " typical line expected from a report:
    " some_file.py:107:80: E501 line too long (86 > 79 characters)
    let current_file = expand("%:t")
    let file_regex =  '\v(^' . current_file . '|/' . current_file . ')'

    let errors = {}
    for line in split(a:output, '\n')
        if line =~ file_regex
            let current_error = {}
            let error_line = matchlist(line, '\v:(\d+):')[1]
            let has_error_column = matchlist(line, '\v:(\d+):(\d+):')
            if (has_error_column != [])
                let current_error.error_column = has_error_column[2]
            else
                let current_error.error_column = 0
            endif
            let current_error.error_text = matchlist(line, '\v(\d+):\s+(.*)')[2]

            " Lets see if we need to append to an existing line or not
            if has_key(errors, error_line)
                call add(errors[error_line], current_error)
            else
                let errors[error_line] = [current_error]
            endif
        endif
    endfor
    let b:flake_errors = errors
    call s:ShowErrors()
endfunction

function! s:ShowErrors()
    highlight link Flakes SpellBad
    for line in keys(b:flake_errors)
        "for error in line
        call matchadd('Flakes', '\%' . line . 'l\n\@!')
    endfor
endfunction


function s:ClearFlakes()
    let s:matches = getmatches()
    for s:matchId in s:matches
        if s:matchId['group'] == 'Flakes'
            call matchdelete(s:matchId['id'])
        endif
    endfor
    let b:flakes_errors = {}
endfunction


function s:GetFlakesMessage()
        if (b:flake_errors == {})
            return
        endif

        let s:cursorPos = getpos(".")

        " if there's a message for the line the cursor is currently on, echo
        " it to the console
        if has_key(b:flake_errors, s:cursorPos[1])
            call s:Echo(b:flake_errors[s:cursorPos[1]][0]['error_text'])
            return
        else
            echo
        endif

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
    elseif (a:action == "run")
        call s:Flake()
    else
        call s:Echo("Khuno: not a valid file or option ==> " . a:action)
    endif
endfunction


command! -nargs=+ -complete=file Khuno call s:Proxy(<f-args>)
