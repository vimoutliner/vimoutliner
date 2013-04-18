"######################################################################
"# VimOutliner GTD
"# Copyright (C) 2003 by Noel Henson noel@noels-lab.com
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

" InsertElem() {{{1
" Insert a elem without disturbing the current folding.
function! InsertElem(elem)
	let @x = a:elem
	normal! ^"xP
endfunction
"}}}1

" DeleteCheckbox() {{{1
" Delete a checkbox with all its marks (team/completion)
" if one exists
function! DeleteCheckbox()
	:-1/\[[X_?-]\%(,[<>=] [^]]*\)\?\] \%(\d*%\)\?/s///
endfunction
"}}}1

let g:reOutline = "^\t\+\[<>:;|\]"
let g:reBox     = "[\[X_?-\]"
let g:reTeam    = ",\[<>=\] \[^]\]*"
let g:rePercent = "\\d*% "

" Safe Insert *Box() {{{1
" Insert a element at the beginning of a header without disturbing the
" current folding only if there is no element already.
function! InsertSwitch(elem)
	if match(getline("."),g:reOutline) != -1
		return
	endif
"	if match(getline("."),"[".a:elem."\\%(".g:reTeam."\\)\\?"."] ") != -1
"		return
"	endif
	if match(getline("."),g:reBox."\\%(".g:reTeam."\\)\\?"."] ") != -1
		substitute/\[./\="[".a:elem/
	else
		call InsertElem("[".a:elem."] ")
	endif
endfunction
"}}}1

" Safe Add Team Indicator() {{{1
" Insert a work with("="), for (">"), waiting for ("<") 
" in a checkbox (created if needed) at the beginning of a header
" without disturbing the current folding.
function! SafeAddTeam(elem)
	if match(getline("."),g:reOutline) != -1
		return
	endif
	if match(getline("."),g:reBox.g:reTeam."] ") != -1
		return
	endif
	if match(getline("."),g:reBox."] ") != -1
		substitute/\[[X_?-]/\=submatch(0).",".a:elem." "/
	else
		call InsertElem("[_".",".a:elem." "."] ")
	endif
endfunction
"}}}1

" Safe InsertCheckBoxPercent() {{{1
" Insert a checkbox and % sign at the beginning of a header without disturbing 
" the current folding
function! SafeAddPercent()
"	if Ind(line(".")+1) <= Ind(line("."))
"		return
"	endif
	if match(getline("."),g:reOutline) != -1
		return
	endif
	if match(getline("."),g:reBox."\\%(".g:reTeam."\\)\\?"."] ".g:rePercent) != -1
		return
	endif
	if match(getline("."),g:reBox."\\%(".g:reTeam."\\)\\?"."] ") != -1
		substitute/\[[^]]\+\] /&% /
	else
		call InsertElem("[_] % ")
	endif
endfunction
"}}}1

" Ind(line) {{{1
" Return the index of the line.
" Remove it when using the new version of VO
function! Ind(line)
	return indent(a:line) / &tabstop
endf
"}}}1

" FindRootParent(line) {{{1
" returns the line number of the root parent for any child
function! FindRootParent(line)
	let l:i = a:line
	while l:i > 1 && Ind(l:i) > 0
		let l:i -= 1
	endwhile
	return l:i
endf
"}}}1

" NewHMD(line) {{{1
" (How Many Done) 
" Calculates proportion of already done work in the subtree
function! NewHMD(line)
	let l:done       = 0 " checkboxes
	let l:count      = 0 " number of elems : for %
	let l:i          = 1 " line counting
	let l:proportion = 0 " % : for checkboxes (<100 or 100 ?) and %
	let l:lineindent = Ind(a:line)

	" look recursively

	while Ind(a:line+l:i) > l:lineindent
		if Ind(a:line+l:i) == l:lineindent + 1 
			let l:childdoneness = NewHMD(a:line+l:i)
			if l:childdoneness >= 0
				let l:done  += l:childdoneness
				let l:count += 1
			endif
" echomsg "->".a:line."/".(a:line+l:i)."/ [".l:childdoneness."]-[".l:count."]"
		else
" echomsg "(skip) ->".a:line."/".(a:line+l:i)
		endif
		let l:i += 1
	endwhile

	" update %

	if l:count > 0
" echomsg "->".a:line." proportion ".l:proportion
		let l:proportion = ((l:done * 100)/l:count)/100
	endif
	call setline(a:line,substitute(getline(a:line)," [0-9]*%"," ".l:proportion."%",""))

	"
	" update checkboxes
	"

	" everything under is done, toggle
	if l:proportion == 100
" echomsg "->".a:line." proportion 100."
		call setline(a:line,substitute(getline(a:line),"[.","[X",""))
		return 100
	endif 
	
	if l:proportion == 0 && l:count == 0
		" done or skipped
		if match(getline(a:line),"\[[X-][\],]") != -1
" echomsg "->".a:line." proportion is X or -."
			return 100
		endif

		" not done or questionnable
		if match(getline(a:line),"\[[_\?][\],]") != -1
" echomsg "->".a:line." proportion is _ or ?."
			return 0
		endif

		" unknown status for line
" echomsg "->".a:line." proportion is unknown."
		return -1
	endif

	" we have not done tasks, undo 'mark as done'
	if match(getline(a:line),"\[[X][\],]") != -1
		call setline(a:line,substitute(getline(a:line),"[.","[_",""))
	endif
" echomsg "->".a:line." proportion is revert?. [".l:proportion."] / [".l:count."]"
	return l:proportion
endf
"}}}1

" mappings {{{1
" gtd addings
	" work alone
noremap <buffer> <localleader>cb :call InsertSwitch("_")<cr>
noremap <buffer> <localleader>cq :call InsertSwitch("?")<cr>
noremap <buffer> <localleader>cD :call InsertSwitch("-")<cr>
noremap <buffer> <localleader>cx :call InsertSwitch("X")<cr>:call NewHMD(FindRootParent(line(".")))<cr>
" noremap <buffer> <localleader>cx :call InsertSwitch("X")<cr>
	" team work
noremap <buffer> <localleader>cw :call SafeAddTeam("<")<cr>
noremap <buffer> <localleader>cf :call SafeAddTeam(">")<cr>
noremap <buffer> <localleader>c= :call SafeAddTeam("=")<cr>
" completion
noremap <buffer> <localleader>c% :call SafeAddPercent()<cr>

" forced mapping
noremap <buffer> <localleader>gb :call InsertElem("[_] ")<cr>
noremap <buffer> <localleader>gq :call InsertElem("[?] ")<cr>
noremap <buffer> <localleader>gD :call InsertElem("[-] ")<cr>
noremap <buffer> <localleader>gx :call InsertElem("[X] ")<cr>
noremap <buffer> <localleader>gw :call InsertElem("[_,< ] ")<cr>
noremap <buffer> <localleader>gf :call InsertElem("[_,> ] ")<cr>
noremap <buffer> <localleader>g= :call InsertElem("[_,= ] ")<cr>
noremap <buffer> <localleader>g% :call InsertElem("[_] % ")<cr>

" delete a chechbox
noremap <buffer> <localleader>cd :call DeleteCheckbox()<cr>

" calculate the proportion of work done on the subtree
noremap <buffer> <localleader>cz :call NewHMD(FindRootParent(line(".")))<cr>
"}}}1

" vim600: set foldlevel=0 foldmethod=marker:
