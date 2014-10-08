"######################################################################
"# VimOutliner Outline Math
"# Copyright (C) 2014 by Noel Henson noelwhenson@gmail.com
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

" Naming Conventions ################################################## {{{1
" lnum:		line number
" line:		string from a line
" vars:		dictionary of variables, key:value pairs
"
" Common Functions #################################################### {{{1
" These functions have broader application scope than those specific to 
" performing math on outline trees. Perhaps even adding math to VO tables.
"

" MyLineage(lnum) {{{2
" return a list of ancestors in order of youngest-first
" eg:
" 9     A
" 10        B
" 11            C
" 12                D
" MyLineage(12)
" 	[11,10,9]
function! MyLineage(lnum)
	let lineage = []
	let lnum = a:lnum
	let indent = Ind(lnum)
	if indent == 0
		return lineage
	endif
	let parentIndent = indent - 1
	while (parentIndent >= 0) && (lnum >= 0)
		while (indent > parentIndent) && (lnum >= 0)
			let lnum -= 1
			let indent = Ind(lnum)
		endwhile
		let lineage += [lnum]
		let parentIndent -= 1
	endwhile
	return lineage
endfunction

" MyChildren(lnum) {{{2
" return a list of immediate children from the specificed line
function! MyChildren(lnum)
	let children = []
	let parentInd = Ind(a:lnum)
	let childInd = parentInd + 1
	let last = line("$")
	let lnum = a:lnum + 1
	let lnumInd = Ind(lnum)
	while (lnum <= last) && (parentInd < lnumInd)
		if lnumInd == childInd
			let children += [lnum]
		endif
		let lnum += 1
		let lnumInd = Ind(lnum)
	endwhile
	return children
endfunction

" RootParents() {{{2
" return a list of all root nodes (indent level 0)
function! RootParents()
	let parents = []
	let lnum = 1
	let lines = line("$")
	while lnum <= lines
		let ind = Ind(lnum)
		if ind == 0
			let parents += [lnum]
		endif
		let lnum += 1
	endwhile
	return parents
endfunction

" FindMath(string) {{{2
" location of first character of match, -1 if not
" notation: ...{...}...=number...
" function! FindMath(string)
"	return match(a:string,'{.*}.*=-\?[0-9]\+\(.[0-9]\+\)\+\([eE][-+]\?[0-9]\+\)\?')
" endfunction
" the below is faster!
" function! FindMath(string)
" 	return match(a:string,'{.*}.*=-\?[0-9]')
" endfunction
" the below is even faster 
" and allows for formulae to be placed at the end of a heading
function! FindMath(string)
	if match(a:string,'=') != -1
		return match(a:string,'{.*}')
	else
		return -1
	endif
endfunction

" GetMathFromString(string) {{{2
" returns a list of formulae in a string, in the order they were listed
" returns an empty list if none
" notation: {formula} or {formula1;formula2;...;formulan}
function! GetMathFromString(string)
	let mstart = FindMath(a:string)
	if mstart == -1
		return []
	endif
	let mstart += 1
	let mend = match(a:string,'}',mstart)
	if mend == -1
		return []
	endif
	let mend -= 1
	return split(a:string[mstart : mend],';')
endfunction

" MarkValues(string) {{{2
" mark Values in a string for replacement by formula results
" turns each number into '= voMathResult'
function! MarkValues(string)
	return substitute(a:string,'=-\?[0-9]\+\(.[0-9]\+\)\?\([eE][-+]\?[0-9]\+\)\?','=voMathResult','g')
endfunction

" GetVarsFromString(string,vars) {{{2
" add key:value pairs from a string to the passed dictionary
" 	create new entries if key does not exist
" 	add values to existing entries
" vars is a dictionary of key:value pairs
" notation: name=number
function! GetVarsFromString(string,vars)
	" quick return if no potential variables
	if match(a:string,'=') == -1
		return
	endif
	let tokens = split(a:string)
	for token in tokens
		if match(token,'=') == -1
			continue
		endif
		let [key,value] = split(token,"=")
		" read values are cast to floats to prevent
		" auto-casting to integers in the first case
		" and strings in the second
		if has_key(a:vars,key)
			let a:vars[key] += str2float(value)
		else
			let a:vars[key] = str2float(value)
		endif
	endfor
endfunction

" ReplaceVars(formula,vars) {{{2
" replace variables with their values from the supplied dictionary
" vars is a dictionary of key:value pairs
" key:value pairs are first sorted by key length, longest-first
" 	this prevents name collisions when similar key names are used like:
" 	Total and Totals -or- X1 and X12
function! ReplaceVars(formula,vars)
	let formula = a:formula
	let vars = []
	for [key,val] in items(a:vars)
		let vars += [[len(key),key,val]]
	endfor
	let vars = reverse(sort(vars))
	for [len,key,val] in vars
		let formula = substitute(formula,key,string(val),"g")
	endfor
	return formula
endfunction

" ComputeString(string,vars) {{{2
" compute a string using its math and a dictionary of variables
" return the computed, modified string
" string is a string containing math and result variable names
" vars is a dictionary of key:value pairs used in the computation
function! ComputeString(string,vars)
	let string = a:string
	let maths = GetMathFromString(string)
	if len(maths)
		let string = MarkValues(string)
		for math in maths
			let math = ReplaceVars(math,a:vars)
			let result = string(eval(math))
			let string = substitute(string,'voMathResult',result,"")
		endfor
	endif
	return string
endfunction

" Math Functions on Outlines ########################################## {{{1

" MyChildrensVars(lnum) {{{2
" return a dictionary of variable from immediate children
function! MyChildrensVars(lnum)
	let children = MyChildren(a:lnum)
	let vars = {}
	for child in children
		call GetVarsFromString(getline(child),vars)
	endfor
	return vars
endfunction

" ComputeLine(lnum) {{{2
" compute a line's maths using variables from it's children
" replace the line with the newly computed line
function! ComputeLine(lnum)
	let vars = MyChildrensVars(a:lnum)
	let line = ComputeString(getline(a:lnum),vars)
	call setline(a:lnum,line)
endfunction

" ComputeUp(lnum) {{{2
" compute 'up' a tree towards level 1
" the line (lnum) itself is computed first
" this is intended to be a fast compute method to update a branch of nodes
" it assumes that all other calculations in a tree are correct
function! ComputeUp(lnum)
	call ComputeLine(a:lnum)
	let lineage = MyLineage(a:lnum)
	if len(lineage)
		for lnum in lineage
			call ComputeLine(lnum)
		endfor
	endif
endfunction

" ComputeDown(lnum) {{{2
" compute 'down' a tree from the current node
" the line (lnum) itself is computed last
function! ComputeDown(lnum)
	let children = MyChildren(a:lnum)
	if len(children)
		for lnum in children
			call ComputeDown(lnum)
		endfor
	endif
	call ComputeLine(a:lnum)
endfunction

" ComputeTree(lnum) {{{2
" compute down an entire tree
function! ComputeTree(lnum)
	let parents = MyLineage(a:lnum)
	if len(parents)
		let topparent = parents[-1]
	else
		let topparent = a:lnum
	endif
		call ComputeDown(topparent)
endfunction

" ComputeDocument() {{{2
" compute down all trees

function! ComputeDocument(lnum)
	let parents = RootParents()
	for parent in parents
		call ComputeDown(parent)
	endfor
endfunction

" Concealings {{{1
" BadWord is a very old VO region that is no longer used.
" It can be used now for plugins :)
" This should probably be fixed at some point in the future
syntax match BadWord "{.\+}" conceal transparent cchar=µ
set conceallevel=1

" mappings {{{1

map <silent><buffer> <localleader>== :call ComputeUp(line("."))<cr>
map <silent><buffer> <localleader>=t :call ComputeTree(line("."))<cr>
map <silent><buffer> <localleader>=d :call ComputeDocument()<cr>
map <silent><buffer> <localleader>=h :set conceallevel=1<cr>
map <silent><buffer> <localleader>=H :set conceallevel=0<cr>
