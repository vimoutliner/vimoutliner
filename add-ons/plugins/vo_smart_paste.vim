" Here is a small script that remaps the p and P normal commands such that VO
" will do what one would expect when pasting cut/copied nodes into another
" section of an outline. It will adjust the indents and not paste into the
" middle of a branch.
" Added 2011-03-01(JB): This script will now also copy an outline correctly by
" using yy, and cut an outline by using \\d
" http://www.lists.vimoutliner.org/pipermail/vimoutliner/2008-October/002366.html

map <buffer>p :call VOput()<cr>
map <buffer>yy :call VOcop()<cr>
map <buffer>\\d :call VOcut()<cr>
map <buffer>P ]P

if exists('s:loaded')
	finish
endif
let s:loaded = 1

function! IsParent(line)
	if a:line == line("$")
		return 0
	elseif Ind(a:line) < Ind(a:line+1)
		return 1
	else
		return 0
	endif
endfunction


function! VOcop()
	let thisLine = line(".")
	if (foldclosed(thisLine) == -1) && IsParent(thisLine)
		normal! zc
		let fold_cursor = getpos(".")
		normal! yy
		let get_cursor = getpos(".")
	    call setpos('.',fold_cursor)
	    normal! zo
	    call setpos('.',get_cursor)
	else
		normal! yy
	endif
endfunction

function! VOcut()
	let thisLine = line(".")
	if (foldclosed(thisLine) == -1) && IsParent(thisLine)
		normal! zc
		let fold_cursor = getpos(".")
		normal! dd
		let get_cursor = getpos(".")
	    call setpos('.',fold_cursor)
	    normal! zo
	    call setpos('.',get_cursor)
	else
		normal! dd
	endif
endfunction

function! VOput()
	let thisLine = line(".")
	if (foldclosed(thisLine) == -1) && IsParent(thisLine)
		normal! zc
		let fold_cursor = getpos(".")
		normal! ]p
		let put_cursor = getpos(".")
		call setpos('.',fold_cursor)
		normal! zo
		call setpos('.',put_cursor)
	else
		normal! ]p
	endif
endfunction

