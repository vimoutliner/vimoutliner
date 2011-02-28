if &filetype != 'vo_base'
	finish
endif
function! IsParent(line)
	if a:line == line("$")
		return 0
	elseif Ind(a:line) < Ind(a:line+1)
		return 1
	else
		return 0
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

map <buffer>p :call VOput()<cr>
map <buffer>P ]P

