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

" Common Functions #################################################### {{{1
" These functions have broader application scope than those specific to 
" performing math on outline trees. Perhaps even adding math to VO tables.

" FindMath(string) {{{2
" location of first character of match, -1 if not
" notation: ...{...}...=number...
" function! FindMath(string)
"	return match(a:string,'{.*}.*=-\?[0-9]\+\(.[0-9]\+\)\+\([eE][-+]\?[0-9]\+\)\?')
" endfunction
" faster!
function! FindMath(string)
	return match(a:string,'{.*}.*=-\?[0-9]')
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

" ComputeString(string) {{{2
" compute a string using its math and a dictionary of variables
" return the computed, modified string
" string is a string containing math and result variable names
" vars is a dictionary of key:value pairs used in the computation
function! ComputeString(string,vars)
	let string = MarkValues(a:string)
	let maths = GetMathFromString(a:string)
	for math in maths
		let math = ReplaceVars(math,a:vars)
		let result = string(eval(math))
		let string = substitute(string,'voMathResult',result,"")
	endfor
	return string
endfunction

" Math Functions on Outlines ########################################## {{{1


