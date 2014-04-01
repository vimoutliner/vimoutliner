"######################################################################
"# VimOutliner Format plugin
"# Copyright (C) 2011 by Jostein Berntsen 
"# The file is currently an experimental part of Vim Outliner.
"#
"# This program is free software; you can redistribute it and/or modify
"# it under the terms of the GNU General Public License as published by
"# the Free Software Foundation; either version 2 of the License, or
"# (at your option) any later version.
"#
"# This program is distributed in the hope that it will be useful,
"# but WITHOUT ANY WARRANTY; without even the implied warranty of
"# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
"# GNU General Public License for more details.
"######################################################################
" Documentation{{{1
"
" This script inserts bullets, dashes, and arrows in front of lines, including
" VO body text. To insert markers for several lines, select the lines with V
" and execute the mapping. Indents will be kept as they are.
" You can also use the MakeText function to make body text from headers or
" lists.
" 
" There are also functions for 
" 1) Aligning text in a paragraph to a level 1 header
" 2) Insert checkboxes for all headings in a paragraph
" 3) Indent text in a paragraph/branch to the right
" 4) Indent text in a paragraph/branch to the left
"
"}}}1
" Load guard for functions {{{1
if exists("g:loaded_votl_format") || &cp
  finish
endif
let g:loaded_votl_format= 1
let s:keepcpo           = &cpo
set cpo&vim

" Mappings {{{1

""" Command mappings
"
" Insert bullets on selected text
map <buffer><localleader><F1> :call InsertBullet()<cr> 
" Insert dashes on selected text
map <buffer><localleader><F2> :call InsertDash()<cr>
" Insert arrows on selected text
map <buffer><localleader><F3> :call InsertArrow()<cr>
" Insert colons before selected text
map <buffer><localleader><F4> :call MakeText()<cr>
" Align text in a paragraph and indent 1 level
map <buffer><localleader><F5> V}k:le<cr>V}>
" Insert checkboxes for text lines in a paragraph
map <buffer><localleader><F6> V}k,,cb
" Indent text in a paragraph 1 level to the right and keep indentation
map <buffer><localleader><F7> :call VOindentright()<cr>
" Indent text in a paragraph 1 level to the level and keep indentation
map <buffer><localleader><F8> :call VOindentleft()<cr>

"}}}1
" InsertBullet() {{{1
" Insert bullets on selected text.

function! InsertBullet()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": * "
        normal! ^"xPex
    else 
        let @x = "* "
        normal! ^"xP
    endif	
endfunction

"}}}1  
" InsertDash() {{{1
" Insert dashes on selected text.

function! InsertDash()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": - "
        normal! ^"xPex
    else 
        let @x = "- "
        normal! ^"xP
    endif	
endfunction

"}}}1  
" InsertArrow() {{{1
" Insert arrows on selected text.

function! InsertArrow()
        if match(getline("."),"^[\t]*:") != -1
       let @x = ": --> "
        normal! ^"xPex
    else 
        let @x = "--> "
        normal! ^"xP
    endif	
endfunction

"}}}1  
" MakeText() {{{1
" Make selected lines body text.

function! MakeText()
        let @x = ":"
		normal! ^"xP
endfunction

"}}}1  
" VOindentright() {{{1
" Indent branch 1 level to the right.

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


"}}}1   
" VOindentleft() {{{1
" Indent branch 1 level to the left.

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

"}}}1  
" The End
" vim600: set foldmethod=marker foldlevel=0:



