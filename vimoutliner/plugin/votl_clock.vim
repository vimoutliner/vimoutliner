"######################################################################
"# VimOutliner Clock
"# Copyright (C) 2011 by Daniel Carl
"# The file is currently an experimental part of Vim Outliner.
"#
"# This program is free software; you can redistribute it and/or modify
"# it under the terms of the GNU General Public License as published by
"# the Free Software Foundation; either version 2 of the License, or
"# (at your option) any later version.
"#
"# This program is distributed in the hope that it will be useful,
"# but WITHOUT ANY WARRANTY; without even the implied warranty of
"# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"# GNU General Public License for more details.
"######################################################################
" Shortlog{{{1
"
" This plugin of vimoutliner allow the simple tracking of times and the
" calculation of them in seconds, minutes, hours or days
" Exmaple :
" May -> 64.75 h
"     Working time week 51 -> 46.00 h
"     Working time week 52 -> 18.75 h
"         2010-05-03 [08:00:00 -- 17:45:00] -> 9.75 h
"         2010-05-04 [09:00:00 -- 18:00:00] -> 9.00 h
"
" TODO: Use better date calculation to track also time around 00:00
"       [23:00:00 -- 03:00:00] that will at the time lead to negative
"       hours.
" TODO: change the clocking format so that times over several days could
"       be calculated -  [2010-05-03 08:00:00 -- 2010-05-23 26:30:45] or 
"       a shorter dateformat - this seems to need a more complex
"       datehandling
" TODO: write a helppage for the vimoutliner that describes the votd_clock
" TODO: allow the user to select his own dateformat
"}}}1
" ClockStart(space) {{{1
" Insert a space, then the datetime.
function! ClockStart(space)
    let @x = ""
    if a:space == 1
        let @x = " "
    endif
	let @x = @x . strftime("%Y-%m-%d [%T -- %T] ->")
	normal! "xp
endfunction
"}}}1
" ClockStop() {{{1
" Insert a space, then the datetime.
function! ClockStop()
    if match(getline("."), "\\[.* -- .*\\]\\s*-\>") != -1
        call setline(".",substitute(getline(".")," -- .*]\\s*-\>"," -- ".strftime("%T] ->"),""))
    endif
endfunction
"}}}1
" CalculateSeconds(str) {{{1
" Calculates the seconds between the start and the end time.
function! CalculateSeconds(str)
    let l:parts = split(a:str,"\ --\ ")
    let l:startparts = split(l:parts[0],":")
    let l:endparts = split(l:parts[1],":")

    let l:seconds = (str2nr(l:endparts[2]) - str2nr(l:startparts[2]))
    let l:seconds = (str2nr(l:endparts[1]) - str2nr(l:startparts[1])) * 60 + l:seconds
    let l:seconds = (str2nr(l:endparts[0]) - str2nr(l:startparts[0])) * 3600 + l:seconds
    return l:seconds
endfunction
" }}}1
" CalculateDuration() {{{1
" insert date time
function! CalculateDuration(line)
    let l:seconds=0
    let l:count=0
	let l:i = 1
	while Ind(a:line) < Ind(a:line+l:i)
		if (Ind(a:line)+1) == (Ind(a:line+l:i))
			let l:childseconds = CalculateDuration(a:line+l:i)
			if l:childseconds >= 0
				let l:seconds = l:seconds + l:childseconds
                let l:count = l:count+1
			endif
		endif
		let l:i = l:i+1
    endwhile

    " if no childs found calculate the seconds for the line
    let l:lineString = getline(a:line)
    if match(l:lineString,"\\s*-\>") != -1
        let l:times = matchstr(l:lineString,"\\[.* -- .*\\]\\s*-\>")
        if l:times != ""
            " calculate the real time difference
            let l:seconds = CalculateSeconds(substitute(l:times,"\\[\\(.*\\)\\]","\\1",""))
        endif
        " don't add summarized time to text lines
        if match(l:lineString,"^\t*[;:<>]") == -1
            if match(l:lineString," -\> [0-9 .]*s") != -1
                call setline(a:line,substitute(l:lineString," -\>.*s"," -> ".l:seconds." s",""))
            elseif match(getline(a:line)," -\> [0-9 .]*m") != -1
                call setline(a:line,substitute(l:lineString," -\>.*m"," -> ".printf("%.2f",l:seconds/60.0)." m",""))
            elseif match(getline(a:line)," -\> [0-9 .]*d") != -1
                call setline(a:line,substitute(l:lineString," -\>.*"," -> ".printf("%.2f",(l:seconds/86400.0))." d",""))
            else
                call setline(a:line,substitute(l:lineString," -\>.*"," -> ".printf("%.2f",(l:seconds/3600.0))." h",""))
            endif
        endif
    " else
    "     return -1
    endif
    return l:seconds
endf
"}}}1
" FindRootParent(line) {{{1
" returns the line number of the root parent for any child
function! FindRootParent(line)
	if Ind(a:line) == 0
		return (a:line)
	endif
	let l:i = a:line
	while l:i > 1 && Ind(l:i) > 0
		let l:i = l:i - 1
	endwhile
	return l:i
endf
"}}}1
" UpdateTimes() {{{1
" initiates the update of all times in the tree where the cursur is located
function! UpdateTimes()
    call CalculateDuration(FindRootParent(line(".")))
endf
"}}}1
" Mappings {{{1
nmap <silent> <buffer> <localleader>cs $:call ClockStart(1)<cr>
imap <silent> <buffer> <localleader>cs ~<esc>x:call ClockStart(0)<cr>a
nmap <silent> <buffer> <localleader>cS $:call ClockStop()<cr>:call UpdateTimes()<cr>
imap <silent> <buffer> <localleader>cS ~<esc>x:call ClockStop()<cr>:call UpdateTimes()<cr>i
nmap <silent> <buffer> <localleader>cu $:call UpdateTimes()<cr>
"}}}1
" The End
" vim600: set foldmethod=marker foldlevel=0:
