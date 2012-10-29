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


if !exists('g:khuno_flake_cmd')
  let g:khuno_flake_cmd = 'flake8'
endif


" au commands
augroup khuno_automagic
    au BufEnter <buffer> call s:Flake()
    au BufWritePost <buffer> call s:Flake()
augroup END

au CursorMoved <buffer> call s:GetFlakesMessage()
au BufLeave <buffer> call s:ClearFlakes()

function! s:KhunoAutomagic(enabled)
    if a:enabled
        augroup khuno_automagic
    else
        au! khuno_automagic
    endif
endfunction


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


if exists('g:khuno_automagic')
    if (g:khuno_automagic > 0)
        call s:KhunoAutomagic(1)
    else
        call s:KhunoAutomagic(0)
    endif
else
    call s:KhunoAutomagic(1)
endif


function! s:CurrentPath()
    let cwd = expand("%:p")
    return cwd
endfunction


function! s:Flake()
    if exists("g:khuno_builtins")
        let s:khuno_builtins_opt=" --builtins=".g:khuno_builtins
    else
        let s:khuno_builtins_opt=""
    endif

    if exists("g:khuno_ignore")
        let s:khuno_ignores=" --ignore=".g:khuno_ignore
    else
        let s:khuno_ignores=""
    endif

    if exists("g:khuno_max_line_length")
        let s:khuno_max_line_length=" --max-line-length=".g:khuno_max_line_length
    else
        let s:khuno_max_line_length=""
    endif

    let cmd=g:khuno_flake_cmd . s:khuno_builtins_opt . s:khuno_ignores . s:khuno_max_line_length

    let abspath = s:CurrentPath()
    let cmd = cmd . " ". abspath
    let out = system(cmd)
    call s:ParseReport(out)
endfunction


function! s:ParseReport(output)
    " typical line expected from a report:
    " some_file.py:107:80: E501 line too long (86 > 79 characters)
    let current_file = expand("%:t")
    let line_regex = '\v^(.*.py):(\d+):'

    let errors = {}
    for line in split(a:output, '\n')
        if line =~ line_regex
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
            let errors.last_error_line = error_line
        endif
    endfor
    let b:flake_errors = errors
    if len(errors)
        call s:ShowErrors()
    endif
endfunction


function! s:ShowErrors()
    highlight link Flakes SpellBad
    for line in keys(b:flake_errors)
        if line != "last_error_line"
            let err = line[0]
            if (err['error_column'] > 0)
                let match ='^\%'. line . 'l\_.\{-}\zs\k\+\k\@!\%>' . err['error_column'] . 'c'
                 call matchadd('Flakes', match)
            else
                call matchadd('Flakes', '\%' . line . 'l\n\@!')
            endif
        endif
    endfor
endfunction


function! s:ClearFlakes() abort
    let s:matches = getmatches()
    for s:matchId in s:matches
        if s:matchId['group'] == 'Flakes'
            call matchdelete(s:matchId['id'])
        endif
    endfor
    let b:flake_errors = {}
endfunction


function! s:GetFlakesMessage() abort
        if !(exists('b:flake_errors'))
            return
        endif
        let s:cursorPos = getpos(".")
        let line_no = s:cursorPos[1]
        " if there's a message for the line the cursor is currently on, echo
        " it to the console
        if has_key(b:flake_errors, line_no)
            call s:Echo(b:flake_errors[line_no][0]['error_text'])
        else
            echo
        endif
endfunction


function! s:Completion(ArgLead, CmdLine, CursorPos)
    let _version    = "version\n"
    let actionables = "run\n"
    return _version . actionables
endfunction


function! s:Version()
    call s:Echo("khuno.vim version 0.0.1dev", 1)
endfunction


function! s:Proxy(action)
    if (executable(g:khuno_flake_cmd) == 0)
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
