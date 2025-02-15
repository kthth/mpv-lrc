set scrolloff=99

function! ReplaceTime(matched, line, time)
  let timePattern = '\[\d\{2}:\d\{2}.\d\{2,3}\]'
  if a:matched == 0 
    call setline('.', substitute(a:line, timePattern, a:time, ""))
  else
    call setline('.', substitute(a:line, '^', a:time, ''))
  endif
endfunction

function! FormatCurrentTime()
  let systemcall = system('echo ''{ "command": ["get_property", "time-pos"] }'' | socat - /tmp/mpv-socket')
  let time_pos = json_decode(systemcall).data - 0.3
  let m = floor(time_pos / 60)
  let s = time_pos - (m * 60)
  let currentTimeFormatted = printf('[%02.0f:%05.2f]', m, s)
  return currentTimeFormatted
endfunction

nnoremap <buffer> <F7> <Cmd>let currentTimeFormatted = FormatCurrentTime()
  \ \| let currentLine = getline('.')
  \ \| let timePattern = '\[\d\{2}:\d\{2}.\d\{2,3}\]'
  \ \| let matchPattern = match(currentLine, timePattern)
  \ \| call ReplaceTime(matchPattern, currentLine, currentTimeFormatted)<CR>
  \ <CR>jk0
nnoremap <buffer> <F4> <Cmd>let currentTimeFormatted = FormatCurrentTime()
  \ \| let currentLine = line('.')
  \ \| call append(currentLine, currentTimeFormatted)
  \ \| call cursor(currentLine+2,0)<CR>
nnoremap <buffer> <F8> <Cmd>silent call system('echo seek -2 \| socat - /tmp/mpv-socket')
  \ \| echom FormatCurrentTime()<CR>
nnoremap <buffer> <silent> <F9> <Cmd>silent call system('echo ''{ "command": ["cycle", "pause"] }'' \| socat - /tmp/mpv-socket')<CR>
" add a function that gets subtitle delay and writes that into the header as offset
" https://stackoverflow.com/posts/55447571/edit
nnoremap <buffer> <F10> <Cmd>let sub_delay = json_decode(system('echo ''{ "command": ["get_property", "sub-delay"] }'' \| socat - /tmp/mpv-socket')).data
  \ \| let lengthLine = search('[length:', 'b')
  \ \| call append(lengthLine, printf('[offset:%s]', sub_delay))
  \ <CR>
nnoremap <buffer> <F6> <Cmd>let sub_start = json_decode(system('echo ''{ "command": ["get_property", "sub-start"] }'' \| socat - /tmp/mpv-socket')).data
  \ \| let m = floor(sub_start / 60)
  \ \| let s = sub_start - (m * 60)
  \ \| call search(printf('[%02.0f:%05.2f', m, s))
  \ \| <CR>
nnoremap <buffer> <F5> -y%k"_Dpb<C-x>2j0
imap <buffer> <F7> <C-g>u<Esc><F7>
imap <buffer> <F8> <Esc><F8>
