" tmux-yank.vim - Synchronize Vim and Tmux clipboards
" Maintainer:   Jabir Ali Ouassou
" Version:      1.0

" Include guard.
if exists("g:loaded_tmux_yank")
    finish
endif
let g:loaded_tmux_yank = 1

" If tmux doesn't exist, exit early. Otherwise the subsequent `tmux display`
" command will cause an error.
let s:tmux_exists = system("tmux -V")
unlet s:tmux_exists
if v:shell_error != 0
    finish
endif

" If not inside a tmux session, exit early. Otherwise the subsequent `tmux
" display` cmmand will cause an error.
if empty($TMUX)
  finish
endif

" Function to yank to OSC-52.
function! TmuxYank()
    let base64_cmd="base64 -w0"
    if system("uname")->trim() ==# "Darwin"
        let base64_cmd="base64"
    endif
    let buffer=system(base64_cmd, @0)
    let buffer=substitute(buffer, "\n$", "", "")
    let buffer='\e]52;c;'.buffer.'\x07'
    silent exe "!echo -ne ".shellescape(buffer)." > ".system("tmux display -p '#{pane_tty}'")
endfunction

" Autoforward yank events.
set clipboard+=unnamedplus
augroup TmuxYankAuto
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call TmuxYank() | endif
augroup END
