" This script inserts bullets, dash, and arrow in from of lines, including
" text lines. To insert markers for several lines, choose the linues with V
" and execute the mapping. Indents will be kept as they are.
" You can also use the colon function to make text lines from headers.
" 
" There are also mappings for 1) Aligning text in a paragraph to a 1 level header, 2)
" Insert checkboxes for all headings in a paragraph, 3) Indent text in a
" paragraph to the right, 4) Indent text in a paragraph to the left.
"


""" Command mappings
"
" Insert bullets on selected text
map <buffer><localleader><F1> :call InsertBullet()<cr> 
" Insert dashes on selected text
map <buffer><localleader><F2> :call InsertDash()<cr>
" Insert arrows on selected text
map <buffer><localleader><F3> :call InsertArrow()<cr>
" Insert colons before selected text
map <buffer><localleader><F4> :call InsertColon()<cr>
" Align text in a paragraph and indent 1 level
map <buffer><localleader><F5> V}k:le<cr>V}>
" Insert checkboxes for text lines in a paragraph
map <buffer><localleader><F6> V}k,,cb
" Indent text in a paragraph 1 level to the right and keep indentation
map <buffer><localleader><F7> :call VOindentright()<cr>
" Indent text in a paragraph 1 level to the level and keep indentation
map <buffer><localleader><F8> :call VOindentleft()<cr>


""" Functions

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



" InsertBullet() function
function! InsertBullet()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": * "
        normal! ^"xPex
    else 
        let @x = "* "
        normal! ^"xP
    endif	
endfunction


" InsertDash() function
function! InsertDash()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": - "
        normal! ^"xPex
    else 
        let @x = "- "
        normal! ^"xP
    endif	
endfunction


" InsertArrow() function
function! InsertArrow()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": --> "
        normal! ^"xPex
    else 
        let @x = "--> "
        normal! ^"xP
    endif	
endfunction


" InsertColon() function
function! InsertColon()
        let @x = ":"
		normal! ^"xP
endfunction

" VOindentright() function

function! VOindentright()
	let thisLine = line(".")
	if (foldclosed(thisLine) == -1) && IsParent(thisLine)
		normal! zc
		let fold_cursor = getpos(".")
		normal! >>
		let get_cursor = getpos(".")
	    call setpos('.',fold_cursor)
	    normal! zo
	    call setpos('.',get_cursor)
        set foldlevel=3
	else
		normal! >>
	endif
endfunction


" VOindentleft() function

function! VOindentleft()
	let thisLine = line(".")
	if (foldclosed(thisLine) == -1) && IsParent(thisLine)
		normal! zc
		let fold_cursor = getpos(".")
		normal! <<
		let get_cursor = getpos(".")
	    call setpos('.',fold_cursor)
	    normal! zo
	    call setpos('.',get_cursor)
        set foldlevel=3
	else
		normal! << 
	endif
endfunction



