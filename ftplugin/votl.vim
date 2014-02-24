"#########################################################################
"# ftplugin/vo_base.vim: VimOutliner functions, commands and settings
"# version 0.3.7
"#   Copyright (C) 2001,2003 by Steve Litt (slitt@troubleshooters.com)
"#   Copyright (C) 2004 by Noel Henson (noel@noels-lab.com)
"#
"#   This program is free software; you can redistribute it and/or modify
"#   it under the terms of the GNU General Public License as published by
"#   the Free Software Foundation; either version 2 of the License, or
"#   (at your option) any later version.
"#
"#   This program is distributed in the hope that it will be useful,
"#   but WITHOUT ANY WARRANTY; without even the implied warranty of
"#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"#   GNU General Public License for more details.
"#
"#   You should have received a copy of the GNU General Public License
"#   along with this program; if not, write to the Free Software
"#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
"#
"# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
"#########################################################################

" Load the plugin {{{1
" Prevent the plugin from being loaded twice
"if exists("b:did_ftplugin")
"  finish
"endif
"let b:did_ftplugin = 1
let b:current_syntax = "outliner"

" User Preferences {{{1

"let maplocalleader = ",,"		" this is prepended to VO key mappings

"setlocal ignorecase			" searches ignore case
"setlocal smartcase			" searches use smart case

let use_space_colon=0

" End User Preferences

" VimOutliner Standard Settings {{{1
setlocal autoindent	
"setlocal backspace=2
setlocal wrapmargin=5
setlocal wrap
setlocal tw=78
setlocal noexpandtab
setlocal tabstop=4			" tabstop and shiftwidth must match
setlocal shiftwidth=4		" values from 2 to 8 work well
"setlocal nosmarttab
"setlocal softtabstop=0 
setlocal foldlevel=20
setlocal foldcolumn=1		" turns on "+" at the beginning of close folds
setlocal foldmethod=expr
setlocal foldexpr=MyFoldLevel(v:lnum)
setlocal indentexpr=
setlocal nocindent
setlocal iskeyword=@,39,45,48-57,_,129-255

" Vim Outliner Functions {{{1

if !exists("loaded_vimoutliner_functions")
let loaded_vimoutliner_functions=1

" Sorting {{{2 
" IsParent(line) {{{3
" Return 1 if this line is a parent
function! IsParent(line)
	return (Ind(a:line)+1) == Ind(a:line+1)
endfunction
"}}}3
" FindParent(line) {{{3
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
"}}}3
" FindLastChild(line) {{{3
" Return the line number of the last decendent of parent line
function! FindLastChild(line)
	let l:parentindent = Ind(a:line)
	let l:searchline = a:line+1
	while Ind(l:searchline) > l:parentindent
		let l:searchline = l:searchline+1
	endwhile
	return l:searchline-1
endfunction
"}}}3
" MoveDown() {{{3
" Move a heading down by one
" Used for sorts and reordering of headings
function! MoveDown()
	call cursor(line("."),0)
	del x
	put x
endfunction
"}}}3
" DelHead() {{{3
" Delete a heading
" Used for sorts and reordering of headings
function! DelHead(line)
	let l:fstart = foldclosed(a:line)
	if l:fstart == -1
		let l:execstr = a:line . "del x"
	else
		let l:fend = foldclosedend(a:line)
		let l:execstr = l:fstart . "," . l:fend . "del x"
	endif
	exec l:execstr
endfunction
" PutHead() {{{3
" Put a heading
" Used for sorts and reordering of headings
function! PutHead(line)
	let l:fstart = foldclosed(a:line)
	if l:fstart == -1
		let l:execstr = a:line . "put x"
		exec l:execstr
	else
		let l:fend = foldclosedend(a:line)
		let l:execstr = l:fend . "put x"
		exec l:execstr
	endif
endfunction
"}}}3
" NextHead(line) {{{3
" Return line of next heading
" Used for sorts and reordering of headings
function! NextHead(line)
	let l:fend = foldclosedend(a:line)
	if l:fend == -1
		return a:line+1
	else
		return l:fend+1
	endif
endfunction
"}}}3
" CompHead(line) {{{3
" Compare this heading and the next
" Return 1: next is greater, 0 next is same, -1 next is less
function! CompHead(line)
	let nexthead = NextHead(a:line)
	let l:thisline=getline(a:line)
	let l:nextline=getline(nexthead)
	if indent(a:line) != indent(nexthead)
		return 0
	elseif l:thisline <# l:nextline
		return 1
	elseif l:thisline ># l:nextline
		return -1
	else
		return 0
	endif
endfunction

"}}}3
" Sort1Line(line) {{{3
" Compare this heading and the next and swap if out of order
" Dir is 0 for forward, 1 for reverse
" Return a 1 if a change was made 
function! Sort1Line(line,dir)
	if (CompHead(a:line) == -1) && (a:dir == 0)
		call DelHead(a:line)
		call PutHead(a:line)
		return 1
	elseif (CompHead(a:line) == 1) && (a:dir == 1)
		call DelHead(a:line)
		call PutHead(a:line)
		return 1
	else
		return 0
	endif
endfunction
"}}}3
" Sort1Pass(start,end,dir) {{{3
" Compare this heading and the next and swap if out of order
" Dir is 0 for forward, 1 for reverse
" Return a 0 if no change was made, other wise return the change count
function! Sort1Pass(fstart,fend,dir)
	let l:i = a:fstart
	let l:changed = 0
	while l:i < a:fend
		let l:changed = l:changed + Sort1Line(l:i,a:dir)
		let l:i = NextHead(l:i)
	endwhile
	return l:changed
endfunction
"}}}3
" Sort(start,end,dir) {{{3
" Sort this range of headings
" dir: 0 = ascending, 1 = decending 
function! SortRange(fstart,fend,dir)
	let l:changed = 1
	while l:changed != 0
		let l:changed = Sort1Pass(a:fstart,a:fend,a:dir)
	endwhile
endfunction
"}}}3
" SortChildren(dir) {{{3
" Sort the children of a parent 
" dir: 0 = ascending, 1 = descending 
function! SortChildren(dir)
	let l:oldcursor = line(".")
	let l:fstart = FindParent(line("."))
	let l:fend = FindLastChild(l:fstart)
	let l:fstart = l:fstart
	if l:fend <= l:fstart + 1
		return
	endif
	call append(line("$"),"Temporary last line for sorting")
	mkview
	let l:execstr = "set foldlevel=" . foldlevel(l:fstart)
	exec l:execstr
	call SortRange(l:fstart + 1,l:fend,a:dir)
	call cursor(line("$"),0)
	del x
	loadview
	call cursor(l:oldcursor,0)
endfunction
"}}}3
"}}}2
" MakeChars() {{{2
" Make a string of characters
" Used for strings of repeated characters
function MakeChars(count,char)
	let i = 0
	let l:chars=""
	while i < a:count
		let l:chars = l:chars . a:char
		let i = i + 1
	endwhile
	return l:chars
endfunction
"}}}2
" MakeSpaces() {{{2
" Make a string of spaces
function MakeSpaces(count)
	return MakeChars(a:count," ")
endfunction
"}}}2
" MakeDashes() {{{2
" Make a string of dashes
function MakeDashes(count)
	return MakeChars(a:count,"-")
endfunction
"}}}2
" MyFoldText() {{{2
" Create string used for folded text blocks
function MyFoldText()
    if exists('g:vo_fold_length') && g:vo_fold_length == "max"
        let l:foldlength = winwidth(0) - 1 - &numberwidth - &foldcolumn
    elseif exists('g:vo_fold_length')
        let l:foldlength = g:vo_fold_length
    else
        let l:foldlength = 58
    endif
    " I have this as an option, if the user wants to set "…" as the padding
    " string, or some other string, like "(more)"
    if exists('g:vo_trim_string')
        let l:trimstr = g:vo_trim_string
    else
        let l:trimstr = "..."
    endif
	let l:MySpaces = MakeSpaces(&sw)
	let l:line = getline(v:foldstart)
	let l:bodyTextFlag=0
	if l:line =~ "^\t* \\S" || l:line =~ "^\t*\:"
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
    let l:sublen = strdisplaywidth(l:sub)
	let l:end = " (" . ((v:foldend + l:bodyTextFlag)- v:foldstart)
	if ((v:foldend + l:bodyTextFlag)- v:foldstart) == 1
		let l:end = l:end . " line)" 
	else
		let l:end = l:end . " lines)" 
	endif
    let l:endlen = strdisplaywidth(l:end)

    " Multiple cases:
    " (1) Full padding with ellipse (...) or user defined string,
    " (2) No point in padding, pad would just obscure the end of text,
    " (3) Don't pad and use dashes to fill up the space.
    if l:endlen + l:sublen > l:foldlength
        let l:sub = strpart(l:sub, 0, l:foldlength - l:endlen - strdisplaywidth(l:trimstr))
        let l:sub = l:sub . l:trimstr
        let l:sublen = strdisplaywidth(l:sub)
        let l:sub = l:sub . l:end
    elseif l:endlen + l:sublen == l:foldlength
        let l:sub = l:sub . l:end
    else
        let l:sub = l:sub . " " . MakeDashes(l:foldlength - l:endlen - l:sublen - 1) . l:end
    endif
	return l:sub.repeat(' ', winwidth(0)-strdisplaywidth(l:sub))
endfunction
"}}}2
" InsertDate() {{{2
" Insert today's date.
function InsertDate(ba)
	let @x = strftime("%Y-%m-%d")
	if a:ba == "0"
		normal! "xp
	else
		normal! "xP
	endif
endfunction
"}}}2
" InsertSpaceDate() {{{2
" Insert a space, then today's date.
function InsertSpaceDate()
	let @x = " "
	let @x = @x . strftime("%Y-%m-%d")
	normal! "xp
endfunction
"}}}2
" InsertTime() {{{2
" Insert the time.
function InsertTime(ba)
    let @x = strftime("%H:%M:%S")
	if a:ba == "0"
		normal! "xp
	else
		normal! "xP
	endif
endfunction
"}}}2
" InsertSpaceTime() {{{2
" Insert a space, then the time.
function InsertSpaceTime()
	let @x = " "
    let @x = @x . strftime("%H:%M:%S")
	normal! "xp
endfunction
"}}}2
" Ind(line) {{{2
" Determine the indent level of a line.
" Courtesy of Gabriel Horner
function! Ind(line)
	return indent(a:line)/&tabstop
endfunction
"}}}2
" BodyText(line) {{{2
" Determine the indent level of a line.
function! BodyText(line)
	return (match(getline(a:line),"^\t*:") == 0)
endfunction
"}}}2
" PreformattedBodyText(line) {{{2
" Determine the indent level of a line.
function! PreformattedBodyText(line)
	return (match(getline(a:line),"^\t*;") == 0)
endfunction
"}}}2
" PreformattedUserText(line) {{{2
" Determine the indent level of a line.
function! PreformattedUserText(line)
	return (match(getline(a:line),"^\t*<") == 0)
endfunction
"}}}2
" PreformattedUserTextLabeled(line) {{{2
" Determine the indent level of a line.
function! PreformattedUserTextLabeled(line)
	return (match(getline(a:line),"^\t*<\S") == 0)
endfunction
"}}}2
" PreformattedUserTextSpace(line) {{{2
" Determine the indent level of a line.
function! PreformattedUserTextSpace(line)
	return (match(getline(a:line),"^\t*< ") == 0)
endfunction
"}}}2
" UserText(line) {{{2
" Determine the indent level of a line.
function! UserText(line)
	return (match(getline(a:line),"^\t*>") == 0)
endfunction
"}}}2
" UserTextSpace(line) {{{2
" Determine the indent level of a line.
function! UserTextSpace(line)
	return (match(getline(a:line),"^\t*> ") == 0)
endfunction
"}}}2
" UserTextLabeled(line) {{{2
" Determine the indent level of a line.
function! UserTextLabeled(line)
	return (match(getline(a:line),"^\t*>\S") == 0)
endfunction
"}}}2
" PreformattedTable(line) {{{2
" Determine the indent level of a line.
function! PreformattedTable(line)
	return (match(getline(a:line),"^\t*|") == 0)
endfunction
"}}}2
" MyFoldLevel(Line) {{{2
" Determine the fold level of a line.
function MyFoldLevel(line)
	let l:myindent = Ind(a:line)
	let l:nextindent = Ind(a:line+1)

	if BodyText(a:line)
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
			"return '<'.(l:nextindent+1)
			return (l:myindent)
			"return '<'.(l:nextindent-1)
		endif
		return l:myindent
	endif
endfunction
"}}}2
" Spawn(line) {{{2
" Execute an executable line
" Courtesy of Steve Litt
if !exists("loaded_steveoutliner_functions")
	let loaded_steveoutliner_functions=1
function Spawn()
		let theline=getline(line("."))
		let idx=matchend(theline, "_exe_\\s*")
		if idx == -1
			echo "Not an executable line"
		else
			let command=strpart(theline, idx)
			let command="!".command
			exec command
		endif
endfunction
endif
"}}}2
" This should be a setlocal but that doesn't work when switching to a new .otl file
" within the same buffer. Using :e has demonstrated this.
set foldtext=MyFoldText()

"setlocal fillchars=|, 

endif " if !exists("loaded_vimoutliner_functions")
" End Vim Outliner Functions

" Vim Outliner Key Mappings {{{1
" insert the date
nmap <silent><buffer> <localleader>d $:call InsertSpaceDate()<cr>
imap <silent><buffer> <localleader>d ~<esc>x:call InsertDate(0)<cr>a
nmap <silent><buffer> <localleader>D ^:call InsertDate(1)<cr>a <esc>


" insert the time
nmap <silent><buffer> <localleader>t $:call InsertSpaceTime()<cr>
imap <silent><buffer> <localleader>t ~<esc>x:call InsertTime(0)<cr>a
nmap <silent><buffer> <localleader>T ^:call InsertTime(1)<cr>a <esc>

" sort a list naturally
map <silent> <buffer> <localleader>s :silent call SortChildren(0)<cr>
" sort a list, but you supply the options
map <silent> <buffer> <localleader>S :silent call SortChildren(1)<cr>

" invoke the file explorer
map <silent><buffer> <localleader>f :e .<cr>
imap <silent><buffer> <localleader>f :e .<cr>

" Insert a fence for segmented lists.
" I also use this divider to create a <hr> when converting to html
map <silent><buffer> <localleader>- o----------------------------------------0
imap <silent><buffer> <localleader>- ----------------------------------------<cr>

" switch document between the two types of bodytext styles
if use_space_colon == 1
  "   First, convert document to the marker style
  map <silent><buffer><localleader>b :%s/\(^\t*\) :/\1/e<cr>:%s/\(^\t*\) /\1 : /e<cr>:let @/=""<cr>
  "   Now, convert document to the space style
  map <silent><buffer><localleader>B :%s/\(^\t*\) :/\1/e<cr>:let @/=""<cr>
else
  "   First, convert document to the marker style
  map <silent><buffer><localleader>b :%s/\(^\t*\):/\1/e<cr>:%s/\(^\t*\) /\1: /e<cr>:let @/=""<cr>
  "   Now, convert document to the space style
  map <silent><buffer><localleader>B :%s/\(^\t*\):/\1/e<cr>:let @/=""<cr>
endif

" Steve's additional mappings start here
map <silent><buffer>   <C-K>         <C-]>
map <silent><buffer>   <C-N>         <C-T>
map <silent><buffer>   <localleader>0           :set foldlevel=99999<CR>
map <silent><buffer>   <localleader>9           :set foldlevel=8<CR>
map <silent><buffer>   <localleader>8           :set foldlevel=7<CR>
map <silent><buffer>   <localleader>7           :set foldlevel=6<CR>
map <silent><buffer>   <localleader>6           :set foldlevel=5<CR>
map <silent><buffer>   <localleader>5           :set foldlevel=4<CR>
map <silent><buffer>   <localleader>4           :set foldlevel=3<CR>
map <silent><buffer>   <localleader>3           :set foldlevel=2<CR>
map <silent><buffer>   <localleader>2           :set foldlevel=1<CR>
map <silent><buffer>   <localleader>1           :set foldlevel=0<CR>
map <silent><buffer>   <localleader>,,          :runtime vimoutliner/vimoutlinerrc<CR>
map! <silent><buffer>  <localleader>w           <Esc>:w<CR>a
nmap <silent><buffer>  <localleader>e           :call Spawn()<cr>
" Steve's additional mappings end here

" Placeholders for already assigned but non-functional commands
map <silent><buffer> <localleader>h :echo "VimOutliner reserved command: ,,h"<cr>
imap <silent><buffer> <localleader>h :echo "VimOutliner reserved command: ,,h"<cr>
map <silent><buffer> <localleader>H :echo "VimOutliner reserved command: ,,H"<cr>
imap <silent><buffer> <localleader>H :echo "VimOutliner reserved command: ,,H"<cr>

" End of Vim Outliner Key Mappings }}}1
" Menu Entries {{{1
" VO menu
amenu &VO.Expand\ Level\ &1 :set foldlevel=0<cr>
amenu &VO.Expand\ Level\ &2 :set foldlevel=1<cr>
amenu &VO.Expand\ Level\ &3 :set foldlevel=2<cr>
amenu &VO.Expand\ Level\ &4 :set foldlevel=3<cr>
amenu &VO.Expand\ Level\ &5 :set foldlevel=4<cr>
amenu &VO.Expand\ Level\ &6 :set foldlevel=5<cr>
amenu &VO.Expand\ Level\ &7 :set foldlevel=6<cr>
amenu &VO.Expand\ Level\ &8 :set foldlevel=7<cr>
amenu &VO.Expand\ Level\ &9 :set foldlevel=8<cr>
amenu &VO.Expand\ Level\ &All :set foldlevel=99999<cr>
amenu &VO.-Sep1- :
"Tools sub-menu
let s:path2scripts = expand('<sfile>:p:h:h').'/vimoutliner/scripts'
" otl2html
exec 'amenu &VO.&Tools.otl2&html\.py\	(otl2html\.py\ thisfile\ -S\ html2otl_nnnnnn\.css\ >\ thisfile\.html) :!'.s:path2scripts.'/otl2html.py -S html2otl_nnnnnn.css % > %.html<CR>'
" otl2docbook
exec 'amenu &VO.&Tools.otl2&docbook\.pl\	(otl2docbook\.pl\ thisfile\ >\ thisfile\.dbk) :!'.s:path2scripts.'/otl2docbook.pl % > %.dbk<CR>'
" otl2table
exec 'amenu &VO.&Tools.otl2&table\.py\	(otl2table\.py\ thisfile\ >\ thisfile\.txt) :!'.s:path2scripts.'/otl2table.py % > %.txt<CR>'
" otl2tags => FreeMind
exec 'amenu &VO.&Tools.otl2tags\.py\ =>\ &FreeMind\	(otl2tags\.py\ \-c\ otl2tags_freemind\.conf\ thisfile\ >\ thisfile\.mm) :!'.s:path2scripts.'/otl2tags.py -c '.s:path2scripts.'/otl2tags_freemind.conf % > %.mm<CR>'
" otl2tags => Graphviz
exec 'amenu &VO.&Tools.otl2tags\.py\ =>\ &Graphviz\	(otl2tags\.py\ \-c\ otl2tags_graphviz\.conf\ thisfile\ >\ thisfile\.gv) :!'.s:path2scripts.'/otl2tags.py -c '.s:path2scripts.'/otl2tags_graphviz.conf % > %.gv<CR>'
amenu &VO.&Tools.&myotl2thml\.sh\	(myotl2html\.sh\ thisfile) :!myotl2html.sh %<CR>
amenu &VO.-Sep2- :
amenu &VO.&Color\ Scheme :popup Edit.Color\ Scheme<cr>
amenu &VO.-Sep3- :
amenu &VO.&Help.&Index :he vo<cr>
amenu &VO.&Help.&,,\ Commands :he vo-command<cr>
amenu &VO.&Help.&Checkboxes :he vo-checkbox<cr>
amenu &VO.&Help.&Hoisting :he vo-hoisting<cr>
amenu &Help.-Sep1- :
" Help menu additions
amenu &Help.&Vim\ Outliner.&Index :he vo<cr>
amenu &Help.&Vim\ Outliner.&,,\ Commands :he vo-command<cr>
amenu &Help.&Vim\ Outliner.&Checkboxes :he vo-checkbox<cr>
amenu &Help.&Vim\ Outliner.&Hoisting :he vo-hoisting<cr>
"}}}1
" Auto-commands {{{1
if !exists("autocommand_vo_loaded")
	let autocommand_vo_loaded = 1
	au BufNewFile,BufRead *.otl                     setf votl
"	au CursorHold *.otl                             syn sync fromstart
	"set updatetime=500
endif
"}}}1

" this command needs to be run every time so Vim doesn't forget where to look
setlocal tags^=$HOME/.vim/vimoutliner/vo_tags.tag

" Added an indication of current syntax as per Dillon Jones' request
let b:current_syntax = "outliner"

" Directory where VO is located now
let vo_dir = expand("<sfile>:p:h:h")

" Load rc file, only the first found.
let rcs = split(globpath('$HOME,$HOME/.vimoutliner','.vimoutlinerrc'), "\n") +
    \ split(globpath('$HOME,$HOME/.vimoutliner,$HOME/.vim', 'vimoutlinerrc'), "\n") +
    \ split(globpath(vo_dir, 'vimoutlinerrc'), "\n")

if len(rcs) > 0
	exec 'source '.rcs[0]
else
	runtime vimoutliner/vimoutlinerrc
endif
" Load modules
if exists('g:vo_modules_load')
	for vo_module in split(g:vo_modules_load, '\s*:\s*')
		exec "runtime! vimoutliner/plugin/votl_" . vo_module . ".vim"
	endfor
unlet! vo_module
endif

" The End
" vim600: set foldmethod=marker foldlevel=0:
