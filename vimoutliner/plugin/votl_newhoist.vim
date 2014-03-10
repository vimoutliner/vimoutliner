"######################################################################
"# VimOutliner Hoisting
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

" Load the plugin {{{1
if exists("g:did_vo_hoist")
	"finish
endif
if !exists("g:hoistParanoia")
	let g:hoistParanoia=0
endif
if !exists('hlevel')
	let hlevel = 20
endif
let g:did_vo_hoist = 1
" mappings {{{1
map <silent> <buffer> <localleader>hh :call Hoist(line("."))<cr>
map <silent> <buffer> <localleader>hd :call DeHoist()<cr>
map <silent> <buffer> <localleader>hD :call DeHoistAll()<cr>
"}}}1
" syntax {{{1
" Hoisted {{{2
"syntax match Invis +^\~\zs.*$+ containedin=ALL conceal cchar=~
""hi Invis guifg=bg ctermfg=bg
""hi Invis guifg=bg
"hi link Invis Conceal
"}}}2
"}}}1
" MyFoldText() {{{1
" Create string used for folded text blocks
function! MyFoldText()
	let l:MySpaces = MakeSpaces(&sw)
	let l:line = getline(v:foldstart)
	let l:bodyTextFlag=0
	if l:line =~'^\~'
		let l:line = '~'.repeat(' ', winwidth(0)-1)
	elseif l:line =~ "^\t* \\S" || l:line =~ "^\t*\:"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TEXT]"
	elseif l:line =~ "^\t*\;"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TEXT BLOCK]"
	elseif l:line =~ "^\t*\> "
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER]"
	elseif l:line =~ "^\t*\>"
		let l:ls = stridx(l:line,">")
		let l:le = stridx(l:line," ")
		if l:le == -1
			let l:l = strpart(l:line, l:ls+1)
		else
			let l:l = strpart(l:line, l:ls+1, l:le-l:ls-1)
		endif
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER ".l:l."]"
	elseif l:line =~ "^\t*\< "
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER BLOCK]"
	elseif l:line =~ "^\t*\<"
		let l:ls = stridx(l:line,"<")
		let l:le = stridx(l:line," ")
		if l:le == -1
			let l:l = strpart(l:line, l:ls+1)
		else
			let l:l = strpart(l:line, l:ls+1, l:le-l:ls-1)
		endif
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[USER BLOCK ".l:l."]"
	elseif l:line =~ "^\t*\|"
		let l:bodyTextFlag=1
		let l:MySpaces = MakeSpaces(&sw * (v:foldlevel-1))
		let l:line = l:MySpaces."[TABLE]"
	endif
	let l:sub = substitute(l:line,'\t',l:MySpaces,'g')
	let l:len = strlen(l:sub)
	let l:sub = l:sub . " " . MakeDashes(58 - l:len)
	let frange = (v:foldend + l:bodyTextFlag)- v:foldstart
	let l:sub = l:sub . " (" . frange
	if frange == 1
		let l:sub = l:sub . " line)"
	else
		let l:sub = l:sub . " lines)"
	endif
	return l:sub.repeat(' ', winwidth(0)-len(l:sub))
endfunction
"}}}1
" New Fold Function (will be put into vo_base later {{{1
function! MyHoistableFoldLevel(line)
	let l:myindent = Ind(a:line)
	let l:nextindent = Ind(a:line+1)

	if HoistFold(a:line)
	  " if (a:line == 1)
		"	return g:hlevel
		" elseif (HoistFold(a:line-1) == 0)
		"	return ">".0
		" else
		"	return g:hlevel
		" endif
		return g:hlevel

	elseif BodyText(a:line)
		if (BodyText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (BodyText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedBodyText(a:line)
		if (PreformattedBodyText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedBodyText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedTable(a:line)
		if (PreformattedTable(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedTable(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedUserText(a:line)
		if (PreformattedUserText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedUserTextSpace(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif PreformattedUserTextLabeled(a:line)
		if (PreformattedUserTextLabeled(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (PreformattedUserText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif UserText(a:line)
		if (UserText(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (UserTextSpace(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	elseif UserTextLabeled(a:line)
		if (UserTextLabeled(a:line-1) == 0)
			return '>'.(l:myindent+1)
		endif
		if (UserText(a:line+1) == 0)
			return '<'.(l:myindent+1)
		endif
		return (l:myindent+1)
	else
		if l:myindent < l:nextindent
			return '>'.(l:myindent+1)
		endif
		if l:myindent > l:nextindent
			return (l:myindent)
		endif
		return l:myindent
	endif
endfunction
set foldexpr=MyHoistableFoldLevel(v:lnum)
"}}}2
"}}}1
" Functions {{{1
" RemoveTabs(line,tabs) {{{2
" remove specified number of tabs from the begining of line
function! RemoveTabs(start,end,tabs)
	if a:tabs > 0
		let l:doit = "silent ".a:start.",".a:end."s/^\\(\\t\\)\\{".a:tabs."}/"
		exe l:doit
	endif
endfunction
"}}}2
" IsParent(line) {{{2
" Return 1 if this line is a parent
function! IsParent(line)
	return (Ind(a:line)+1) == Ind(a:line+1)
endfunction
"}}}2
" FindParent(line) {{{2
" Return line if parent, parent line if not
function! FindParent(line)
	if IsParent(a:line)
		return a:line
	else
		let l:parentindent = Ind(a:line)-1
		let l:searchline = a:line
		while (Ind(l:searchline) != l:parentindent) && (l:searchline > 0)
			let l:searchline = l:searchline-1
		endwhile
		return l:searchline
	endif
endfunction
"}}}2
" HoistFold() {{{2
" Return a flag indicating that there is a valid hoist
function! HoistFold(line)
	if getline(a:line) =~ '^\~'
		return 1
	else
		return 0
	endif
endfunction
"}}}2
" Hoisted() {{{2
" Return a flag indicating that there is a valid hoist
function! Hoisted()
	if getline(1) =~ '^\~'
		return 1
	else
		return 0
	endif
endfunction
"}}}2
" FindTopHoist(line) {{{2
" Return line number of the nearest (last line) top hoist tag
function! FindTopHoist(line)
	let l:line = a:line
	while (match(getline(l:line),"^\\~") == -1) && (l:line > 0)
		let l:line -= 1
	endwhile
	return l:line
endfunction
"}}}2
" FindBottomHoist(line) {{{2
" Return line number of the nearest (last line) top hoist tag
function! FindBottomHoist(line)
	let l:line = a:line
	let l:lastline = line('$')
	while getline(l:line) !~ "^\\~" && (l:line > 0) && l:line <= l:lastline
		let l:line += 1
	endwhile
	return l:line
endfunction
"}}}2
" FindLastChild(line) {{{2
" Return the line number of the last decendent of parent line
function! FindLastChild(line)
	let l:parentindent = Ind(a:line)
	let l:searchline = a:line+1
	while Ind(l:searchline) > l:parentindent
		let l:searchline = l:searchline+1
	endwhile
	return l:searchline-1
endfunction
"}}}2
" GetHoistedIndent(line) {{{2
" line is the line number containing the indent
" Returns the original indent of the hoisted region
function! GetHoistedIndent(line)
	return str2nr(strpart(getline(a:line),1,2))
endfunction
"}}}2
" HoistTagBefore(line,indent) {{{2
function! HoistTagBefore(line,indent)
	let l:doit = "silent 1,".(a:line-1)."s/^/\\~".a:indent." /"
	exe l:doit
	"call setline(1, map(getline(1,a:line-1), '"~".a:indent.v:val'))
endfunction
"}}}2
" HoistDeTagBefore(line) {{{2
function! HoistDeTagBefore(line)
	let l:doit = "silent 1,".a:line."s/^\\~\\d* //"
	exe l:doit
endfunction
"}}}2
" HoistTagAfter(line) {{{2
function! HoistTagAfter(line)
	if a:line > line('$')
		return
	endif
	let l:doit = "silent ".a:line.",$s/^/\\~/"
	exe l:doit
endfunction
"}}}2
" HoistDeTagAfter(line) {{{2
function! HoistDeTagAfter(line)
	if a:line > line('$')
		return
	endif
	let l:doit = "silent ".a:line.",$s/^\\~//"
	exe l:doit
endfunction
"}}}2
" HoistWrite(file) {{{2
" Write the clean file if hoisted
function! HoistWrite(file,...) range
	"let lines = getline(1,line('$'))
	let saved = 0
	mkview
	call DeHoistAll()
	if v:cmdbang
		let bang = '!'
	else
		let bang = ''
	endif
	try
		if a:0
			echom a:firstline.','.a:lastline."w".bang.fnameescape(v:cmdarg).' '.a:file
			exe a:firstline.','.a:lastline."w".bang.fnameescape(v:cmdarg).' '.a:file
		else
			exe "w".bang.fnameescape(v:cmdarg).' '.a:file
		endif
		let saved = 1
	catch
		echohl ErrorMsg
		echom substitute(v:exception,'^Vim(.\{-}):','','')
		echohl None
	endtry
	"call setline(1,lines)
	silent earlier
	silent loadview
	if saved
		silent setlocal nomodified
	endif
endfunction "HoistWrite
" Hoist(line) {{{2
" Write the offspring of a parent to a new file, open it and remove the
" leading tabs.
function! Hoist(line)
	let l:parent = FindParent(a:line)
	if l:parent == 0
		return
	endif
	"call cursor(l:parent,1)
	"let l:firstline = l:parent+1
	let l:firstline = l:parent
	let l:childindent = Ind(l:firstline)
	let l:lastline = FindLastChild(l:parent)
	setlocal foldlevel=20
	call HoistTagBefore(l:firstline,l:childindent)
	call HoistTagAfter(l:lastline+1)
"	call RemoveTabs(l:firstline,l:lastline,l:childindent)
	call cursor(l:firstline,1)
	setlocal foldlevel=19
	augroup VO_HOIST
		au!
		au CursorMoved,CursorMovedI <buffer>
					\ if getline('.') =~ '^\~\d* ' |
					\   call HoistKeepCursor(1)    |
					\ elseif getline('.') =~ '^\~' |
					\   call HoistKeepCursor(0)    |
					\ endif
		"au BufWriteCmd <buffer> call HoistWrite(fnameescape(expand("<amatch>")))
		"au FileWriteCmd <buffer> '[,']call HoistWrite(fnameescape(expand("<amatch>")), 1)
	augroup END
	if exists('+conceallevel')
		syntax match Invis +^\~.*$+ conceal cchar=~
		hi link Invis Conceal
		setlocal conceallevel=2
	else
		syntax match Invis +^\~.*$+ containedin=ALL
		let i = 1
		while synIDtrans(i) != 0
			if synIDattr(i, 'name') == 'Normal'
				if synIDattr(i, 'bg') >= 0
					" bg is set
					hi Invis guifg=bg ctermfg=bg
				else
					hi Invis guifg=NONE ctermfg=NONE
				endif
				break
			endif
			let i += 1
		endwhile
	endif
endfunction
" }}}2
" HoistKeepCursor(top) {{{2
" Keep cursor out of non-hoisted area.
function! HoistKeepCursor( top )
	if a:top
		while getline('.') =~ '^\~\d* '
			normal! j
		endwhile
	else
		while getline('.') =~ '^\~'
			normal! k
		endwhile
	endif
endfunction "HoistKeepCursor }}}2
" MakeTabs(n) {{{2
" return a string of n tabs
function! MakeTabs(n)
	let l:tabs = ""
	let l:n = a:n
	while l:n > 0
		let l:tabs = l:tabs."\t"
		let l:n -= 1
	endwhile
	return l:tabs
endfunction
"}}}2
"}}}2
" DeHoist() {{{2
" Write the offspring of a parent to a new file, open it and remove the
" leading tabs.
function! DeHoist()
	if !Hoisted()
		return
	endif
	let l:line = line(".")
	let l:top = FindTopHoist(l:line)
	let l:bottom = FindBottomHoist(l:line)
	echom 1
	let l:indent = GetHoistedIndent(l:top)
"	let l:tabs = MakeTabs(l:indent)
"	let l:doit = "silent ".(l:top+1).",".(l:bottom-1)."s/^/".l:tabs."/"
"	exe l:doit
	call HoistDeTagBefore(l:top)
	call HoistDeTagAfter(l:bottom)
	if !Hoisted()
		augroup VO_HOIST
			au!
			augroup! VO_HOIST
			augroup END
		endif
	call cursor(l:line,l:indent)
endfunction
"}}}2
" DeHoistAll() {{{2
" Write the offspring of a parent to a new file, open it and remove the
" leading tabs.
function! DeHoistAll()
	while Hoisted()
		call DeHoist()
	endwhile
endfunction
"}}}2
"}}}1
" vim600: set foldlevel=0 foldmethod=marker:
