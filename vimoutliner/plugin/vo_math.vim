" Require +float and +eval
if !has('float') || !has('eval')
	finish
endif

" global line pointer
let b:lnum = 0

map <buffer> <localleader>= :call ComputeDoc()<cr>

if exists('s:loaded')
	finish
endif
let s:loaded = 1

" return a value from a line, if it exists, return 0 if not
function! GetValue(line)
	let mstart = match(a:line,'= -\?[0-9]\+$')
	if mstart != -1
		return str2nr(a:line[mstart+2:])
	endif
	let mstart = match(a:line,'= -\?[0-9]\+.[0-9]\+$')
	if mstart != -1
		return str2float(a:line[mstart+2:])
	endif
endfunction

" return a variable name from a line, if it exists, return 0 if not
" a variable name is a word with an = sign, eg. variable=
" the = sign is not returned
function! GetVariable(line)
	let mstart = match(a:line,'\w\+=\s\{-\}')
	if mstart != -1
		let mend = matchend(a:line,'\w\+=\s\{-\}')
		return a:line[mstart : mend-2]
	endif
endfunction

" return a flag indicating if a formula exists
function! HasFormula(line)
	return match(a:line,'{.*}')
endfunction

" return a formula from a line, if it exists, return 0 if not
" a formula is entered withing {}
" the {} are not returned
function! GetFormula(line)
	let mstart = match(a:line,'{.*}')
	if mstart != -1
		let mend = matchend(a:line,'{.*}')
		return a:line[mstart+1 : mend-2]
	endif
endfunction

" return a formula:variablename:value tuple from a line
" 0 is returned for each field where no value exists
function! GetTuple(line)
	return [GetFormula(a:line),GetVariable(a:line),GetValue(a:line)]
endfunction

" return a variablename:value tuple from a line
" 0 is returned for each field where no value exists
function! GetVarVal(line)
	return [GetVariable(a:line),GetValue(a:line)]
endfunction

" return a line with the numeric value replaced with a:num
function! ReplaceValue(line,num)
	let mstart = match(a:line,'= -\?[0-9]\+$')
	if mstart != -1
		return substitute(a:line,'= -\?[0-9]\+$','= '.string(a:num),'')
	endif
	let mstart = match(a:line,'= -\?[0-9]\+.[0-9]\+$')
	if mstart != -1
		return substitute(a:line,'= -\?[0-9]\+.[0-9]\+$','= '.string(a:num),'')
	endif
	return a:line
endfunction

" execute a formula in a string and return the result
function! EvalFormula(line)
	return eval(a:line)
endfunction

" execute a formula and, if sucessful, return a line containing the
" computed result
function! HandleFormula(line)
	return ReplaceValue(a:line,EvalFormula(GetFormula(a:line)))
endfunction

" replace variables with their values from the supplied dictionary
function! ReplaceVars(formula,dict)
	let formula = a:formula
	for [var,val] in items(a:dict)
		let formula = substitute(formula,var,string(val),"g")
	endfor
	return formula
endfunction

" execute a formula and, if sucessful, replace the line with a line
" containing the computed result
function! HandleLineFormula(lnum)
	let line = getline(a:lnum)
	let newline = HandleFormula(line)
	if type(newline) == type("")
		call setline(a:lnum,newline)
	endif
endfunction

" compute a formula from a string, return the modified string
function! ComputeString(line,dict)
	let line = a:line
	if HasFormula(line) != -1
		let line = ReplaceVars(line,a:dict)
		let line = HandleFormula(line)
	endif
	return GetVarVal(line)
endfunction

" compute a formula, if it exists and return a variable:value tuple
" If neither the variable or value exists, return 0 for the missing item
function! ComputeLine(lnum,dict)
	let line = getline(a:lnum)
	return ComputeString(line,dict)
endfunction

" this is the main function that computes branches and leaves
" it will return a key:value pair of its result to its own parent
function! Compute(lnum)
	let myDict = {}
	let b:lnum = a:lnum
	let myLine = b:lnum
	let myIndent = indent(myLine)
	let b:lnum += 1
	while (b:lnum <= line("$")) && (myIndent < indent(b:lnum))
		let child = Compute(b:lnum)
		if child[0] == ""
			let child[0] = "SUM"
		endif
		" this sums up the variables of the children
		if has_key(myDict,child[0])
			let myDict[child[0]] = myDict[child[0]] + child[1]
		else
			let myDict[child[0]] = child[1]
		endif
	endwhile
	let result = ComputeString(getline(myLine),myDict)
	call setline(myLine,ReplaceValue(getline(myLine),result[1]))
	return result
endfunction

" this will compute the current leaf/branch
function! ComputeThis()
	call Compute(line("."))
endfunction

" this will compute an entire document
function! ComputeDoc()
	let linenum = 1
	while linenum <= line("$")
		if indent(linenum) == 0
			call Compute(linenum)
		endif
		let linenum += 1
	endwhile
endfunction
