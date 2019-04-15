if exists('g:autoloaded_tmux_focus_events') && g:autoloaded_tmux_focus_events
  finish
endif
let g:autoloaded_tmux_focus_events = 1

let s:has_getcmdwintype = v:version > 704 || v:version == 704 && has("392")

function! s:cursor_in_cmd_line()
  echomsg 'cursor_in_cmd_line called at: '.strftime('%c')
  let in_cmd_line = !empty(getcmdtype())
  let in_cmd_window = s:has_getcmdwintype && !empty(getcmdwintype())
  echomsg 'in_cmd_line: '.in_cmd_line
  echomsg 'in_cmd_window: '.in_cmd_window
  echomsg 'returning: '.(in_cmd_line || in_cmd_window)
  return in_cmd_line || in_cmd_window
endfunction

function! s:delayed_checktime()
  echomsg 'delayed_checktime called at: '.strftime('%c')
  if <SID>cursor_in_cmd_line()
    echomsg 'delayed_checktime: cursor_in_cmd_line returned true'
    return 'in command line, exiting'
  endif
  echomsg 'delayed_checktime: cursor_in_cmd_line returned false'
  " clearing out 'emergency' events
  augroup focus_gained_checktime
    au!
  augroup END
  silent checktime
  return 'delayed_checktime exited at: '.strftime('%c')
endfunction

function! tmux_focus_events#focus_gained()
  if !&autoread
    return
  endif
  if <SID>cursor_in_cmd_line()
    augroup focus_gained_checktime
      au!
      " perform checktime ASAP when outside cmd line
      au * * echomsg <SID>delayed_checktime()
    augroup END
  else
    silent checktime
  endif
endfunction
