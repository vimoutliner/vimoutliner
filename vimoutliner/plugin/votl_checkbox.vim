"######################################################################
"# VimOutliner Checkboxes
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

" mappings {{{1
" insert a chechbox
noremap <silent><buffer> <localleader>cb :call SafelyInsertCheckBox()<cr>
noremap <silent><buffer> <localleader>c% :call SafelyInsertCheckBoxPercent()<cr>
noremap <silent><buffer> <localleader>cp :call SafelyInsertCheckBoxPercentAlways()<cr>
noremap <silent><buffer> <localleader>cB :call InsertCheckBox()<cr>

" delete a chechbox
noremap <silent><buffer> <localleader>cd :call DeleteCheckbox()<cr>

" switch the status of the box and adjust percentages
if !exists('g:vo_checkbox_fast_calc') || g:vo_checkbox_fast_calc == 1
	" Use new and faster method
	noremap <silent><buffer> <localleader>cx :call SwitchBox()       <bar>call CalculateMyBranch(line("."))<cr>
	noremap <silent><buffer> <localleader>c+ :call IncPercent(".")   <bar>call CalculateMyBranch(line("."))<cr>
	noremap <silent><buffer> <localleader>c- :call DecPercent(".")   <bar>call CalculateMyBranch(line("."))<cr>
	noremap <silent><buffer> <localleader>c1 :call SetPercent(".",10)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c2 :call SetPercent(".",20)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c3 :call SetPercent(".",30)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c4 :call SetPercent(".",40)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c5 :call SetPercent(".",50)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c6 :call SetPercent(".",60)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c7 :call SetPercent(".",70)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c8 :call SetPercent(".",80)<bar>call CalculateMyBranch(line('.'))<cr>
	noremap <silent><buffer> <localleader>c9 :call SetPercent(".",90)<bar>call CalculateMyBranch(line('.'))<cr>
else
	" Use the old method
	noremap <silent><buffer> <localleader>cx :call SwitchBox()       <bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c+ :call IncPercent(".")   <bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c- :call DecPercent(".")   <bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c1 :call SetPercent(".",10)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c2 :call SetPercent(".",20)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c3 :call SetPercent(".",30)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c4 :call SetPercent(".",40)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c5 :call SetPercent(".",50)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c6 :call SetPercent(".",60)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c7 :call SetPercent(".",70)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c8 :call SetPercent(".",80)<bar>call NewHMD(FindRootParent(line(".")))<cr>
	noremap <silent><buffer> <localleader>c9 :call SetPercent(".",90)<bar>call NewHMD(FindRootParent(line(".")))<cr>
endif

" calculate the proportion of work done on the subtree
noremap <silent><buffer> <localleader>cz :call NewHMD(FindRootParent(line(".")))<cr>

" tag list key mappings
if exists("g:cbTags")
	noremap <silent><buffer> <localleader>ct :call SetNextTag()<cr>
	noremap <silent><buffer> <localleader>cT :call SetNextList()<cr>
endif

"}}}1
" Load guard for functions {{{1
if exists('s:loaded')
	finish
endif
let s:loaded = 1

" InsertCheckBox() {{{1
" Insert a checkbox at the beginning of a header without disturbing the
" current folding.
function! InsertCheckBox()
	let @x = "[_] "
	normal! ^"xP
endfunction
"}}}1
" Safely InsertCheckBox() {{{1
" Insert a checkbox at the beginning of a header without disturbing the
" current folding only if there is no checkbox already.
function! SafelyInsertCheckBox()
	if match(getline("."),"^\t\t*\[<>:;|\]") != -1
		return
	endif
	if match(getline("."),"[\[X_\]]") == -1
		let @x = "[_] "
		normal! ^"xP
	endif
endfunction
"}}}1
" Safely InsertCheckBoxPercent() {{{1
" Insert a checkbox and % sign at the beginning of a header without disturbing 
" the current folding only if there is no checkbox already.
function! SafelyInsertCheckBoxPercent()
	if match(getline("."),"^\t\t*\[<>:;|\]") != -1
		return
	endif
        if match(getline("."), "[\[X_\]]") == -1
		if Ind(line(".")+1) > Ind(line("."))
			let @x = "[_] % "
		else
			let @x = "[_] "
		endif
           normal! ^"xP
        endif
endfunction
"}}}1
" Safely InsertCheckBoxPercentAlways() {{{1
" Insert a checkbox and % sign at the beginning of a header without disturbing 
" the current folding only if there is no checkbox already. Include the 
" checkbox even on childless headings.
function! SafelyInsertCheckBoxPercentAlways()
	if match(getline("."),"^\t\t*\[<>:;|\]") != -1
		return
	endif
        if match(getline("."), "[\[X_\]]") == -1
		let @x = "[_] % "
           normal! ^"xP
        endif
endfunction
"}}}1
" SetBox(char) {{{1
" Switch the state of the checkbox on the current line.
function! SetBox(char)
   substitute/\[.\]/\="[".expand(a:char)."]"/
   if a:char == 'X'
      call SetPercent(".",100)
   elseif a:char == '_'
      call SetPercent(".",0)
   endif
endfunction

"}}}1
" SwitchBox() {{{1
" Switch the state of the checkbox on the current line.
function! SwitchBox()
   let l:line = getline(".")
   let questa = strridx(l:line,"[_]")
   let questb = strridx(l:line,"[X]")
   if (questa != -1) || (questb != -1)
	if (questa != -1) 
		call SetBox('X')
	else
		call SetBox('_')
	endif
   endif
endfunction
"}}}1
" DeleteCheckbox() {{{1
" Delete a checkbox if one exists
function! DeleteCheckbox()
   let questa = strridx(getline("."),"[_]")
   let questb = strridx(getline("."),"[X]")
   if (questa != -1) || (questb != -1)
	   if (questa != -1) 
	      substitute/\(^\s*\)\[_\] \(.*\)/\1\2/
	   else
	      substitute/\(^\s*\)\[X\] \(.*\)/\1\2/
	   endif
   endif
endfunction
"}}}1
" Ind(line) {{{1
" Return the index of the line.
" Remove it when using the new version of VO
function! Ind(line)
	return indent(a:line) / &tabstop
endf
" FindMyParent(line) {{{1
" returns the line number of the parent of the current node
function! FindMyParent(line)
	let l:mylevel = Ind(a:line)
	if l:mylevel == 0
		return (a:line)
	endif
	let l:i = a:line
	while Ind(l:i) >= l:mylevel
		let l:i -= 1
	endwhile
	return l:i
endf

" FindRootParent(line) {{{1
" returns the line number of the root parent for any child
function! FindRootParent(line)
	if Ind(a:line) == 0
		return (a:line)
	endif
	let l:i = a:line
	while l:i > 1 && Ind(l:i) > 0
		let l:i = l:i - 1
	endwhile
	return l:i
endf

" LimitPercent(percent) {{{1
" Limits percentage values to between 0 and 100
function! LimitPercent(val)
	if a:val > 100
		return 100
	elseif a:val < 0
		return 0
	else
		return a:val
	endif
endf

" GetPercent(line) {{{1
" Get the percent complete from a line
function! GetPercent(line)
   let l:proportion = 0
   let mbegin=match(getline(a:line), " [0-9]*%")
   if mbegin
           let mend=matchend(getline(a:line), " [0-9]*%")
           let l:proportion=getline(a:line)[mbegin+1 : mend-1]
           let l:proportion=str2nr(l:proportion)
   endif
   return l:proportion
endf

" SetPercent(line,proportion) {{{1
" Set the percent complete for a line
function! SetPercent(line,proportion)
   let mbegin=match(getline(a:line), " [0-9]*%")
   if mbegin
   	call setline(a:line,substitute(getline(a:line)," [0-9]*%"," ".a:proportion."%",""))
   endif
endf

" IncPercent(line) {{{1
" Increments the percent doneness by 10%
function! IncPercent(line)
   if match(getline(a:line), " [0-9]*%")
	   call SetPercent(a:line,LimitPercent(GetPercent(a:line)+10))
   endif
endf

" DecPercent(line) {{{1
" Decrements the percent doneness by 10%
function! DecPercent(line)
   if match(getline(a:line), " [0-9]*%")
	   let l:percent = GetPercent(a:line)
           call setline(a:line,substitute(getline(a:line),"\\[X\\]","[_]",""))
	   call SetPercent(a:line,LimitPercent(l:percent-10))
   endif
endf

" ComputePW(line,count,done) {{{1
" Computes proportion and weight of a node
" Returns (proportion,weight) proportion could be a flag of -1
function! ComputePW(line,count,done)
   let l:proportion=0
	 let l:haspercent = 0
   " get the percent
   let mbegin=match(getline(a:line), " [0-9]*%")
   if mbegin != -1
		 let l:haspercent = 1
           let mend=matchend(getline(a:line), " [0-9]*%")
           let l:proportion=str2nr(getline(a:line)[mbegin+1 : mend-1])
   endif
   " get the weight
   let l:weight=1
   let mbegin=match(getline(a:line), "%[0-9]\\+")
   if mbegin != -1
	   let mend=matchend(getline(a:line), "%[0-9]\\+\s")
	   let l:weight=str2nr(getline(a:line)[mbegin+1 : mend-1])
   endif
   " compute the proportion
   if a:count>0
     let l:proportion = ((a:done*100)/a:count)/100
   elseif match(getline(a:line),"\\[X\\]") != -1
	      let l:proportion = 100
   elseif match(getline(a:line),"\\[-\\]") != -1
	      let l:weight = 0
   endif
   " update non-ignored items
   let l:questa = strridx(getline(a:line),"[-]")
   if l:questa == -1
      call setline(a:line,substitute(getline(a:line)," [0-9]*%"," ".l:proportion."%",""))
   endif
	 " Limit proportion to 0 or 100 if there is not a percentage sign
	 if !haspercent && (!exists('g:vo_checkbox_fast_calc') || g:vo_checkbox_fast_calc == 1)
		 let l:proportion = l:proportion == 100 ? l:proportion : 0
	 endif
   " update the completion
   if l:questa != -1
      return [100,l:weight]
   elseif l:proportion == 100
      call setline(a:line,substitute(getline(a:line),"\\[_\\]","[X]",""))
      return [100,l:weight]
   elseif l:proportion == 0 && a:count == 0
      if match(getline(a:line),"\\[X\\]") != -1
	      return [100,l:weight]
      elseif match(getline(a:line),"\\[_\\]") != -1
	      return [0,l:weight]
      else
	      return [-1,l:weight]
      endif
   else
      call setline(a:line,substitute(getline(a:line),"\\[X\\]","[_]",""))
      return [l:proportion,l:weight]
   endif
endf

" CalculateMyChildren(line) {{{1
" Calculates percent completion only on the immediate children of the 
" parent specified by line.
function! CalculateMyChildren(line)
	let l:done = 0
	let l:count = 0
	let l:line = a:line + 1
	let l:mylevel = Ind(a:line)
	let l:childlevel = l:mylevel+1
	while l:mylevel < Ind(l:line)	" I have children
		if l:childlevel == Ind(l:line)
			let l:childstat = ComputePW(l:line,0,0)
			let l:childdoneness = l:childstat[0] * l:childstat[1]
			if l:childdoneness >= 0
				let l:done += l:childdoneness
				let l:count += l:childstat[1]
			endif
		endif
		let l:line += 1
	endwhile
	return ComputePW(a:line,l:count,l:done) " returns with (proportion,weight)
endf

" CalculateMyBranch(line) {{{1
" Calculate from the leaf, up unlke NewHMD
function! CalculateMyBranch(line)
	call NewHMD(a:line) " compute and adjust my children, if I have any
	let l:line = a:line
	while Ind(l:line) > 0
		let l:line = FindMyParent(l:line)
		call CalculateMyChildren(l:line)
	endwhile
endf

" NewHMD(line) {{{1
" (New How Many Done) 
" Calculates proportion of already done work in the subtree
" Recursive, but slow because it computes an entire branch of an outline 
" from level 1.
" Returns (proportion,weight) proportion could be a flag of -1
function! NewHMD(line)
	let l:done = 0
	let l:count = 0
	let l:line = a:line+1
	let l:mylevel = Ind(a:line)
	let l:childlevel = l:mylevel+1
	while l:mylevel < Ind(l:line)	" I have children
		if l:childlevel == Ind(l:line)
			let l:childstat = NewHMD(l:line)
			let l:childdoneness = l:childstat[0] * l:childstat[1]
			if l:childdoneness >= 0
				let l:done += l:childdoneness
				let l:count += l:childstat[1]
			endif
		endif
		let l:line += 1
	endwhile
	return ComputePW(a:line,l:count,l:done) " returns with (proportion,weight)
endf

" Experimental Heading Tags {{{1

if !exists('g:cbTags')
	finish
endif

" GetTag() {{{2
" return the tag word under the cursor
function! GetTag()
	let word = expand("<cWORD>")
	if word[0] == '[' && word[-1:] == ']'
		return word[1:-2]
	endif
	return ""
endfunction

" WhereInLists(word) {{{2
" return a single-entry list with a pair of values [listIndex,tagIndex]
" return -1,-1 if tag word not found
function! WhereInLists(word)
	let lidx = 0
	for list in g:cbTags
		let tidx = index(list,a:word)
		if tidx >= 0
			return [lidx,tidx]
		endif
		let lidx += 1
	endfor
	return [-1,-1]
endfunction

" NextTagIdx(lidx,tidx) {{{2
" return the index of the next tag in the current list
function! NextTagIdx(lidx,tidx)
	if a:tidx >= 0
		let llen = len(g:cbTags[a:lidx])
		let tidx = (a:tidx + 1)%llen
	endif
	return tidx
endfunction

" GetNextTag(word) {{{2
" return the next tag word (from a:word) in the list
function! GetNextTag(word)
	if a:word == 'tag'
		return g:cbTags[0][0]
	endif
	let liti = WhereInLists(a:word)
	if liti[1] == -1
		return ""
	endif
	let liti[1] = NextTagIdx(liti[0],liti[1])
	let nextword = g:cbTags[liti[0]][liti[1]]
	return nextword
endfunction

" SetNextTag() {{{2
" set the current tag to the next tag in the same list
" this is circular, the last tag will roll to the first tag
function! SetNextTag()
	let oldtag = GetTag()
	let newtag = GetNextTag(oldtag)
	if newtag == ""
		return
	endif
	let sub = "normal!ci[".newtag
	exec sub
endfunction

" NextListIdx(lidx) {{{2
" return the index of the next list
function! NextListIdx(lidx)
	if a:lidx >= 0
		let llen = len(g:cbTags)
		let lidx = (a:lidx + 1)%llen
	endif
	return lidx
endfunction

" GetNextList(word) {{{2
" return the next tag word (from a:word) in the list
function! GetNextList(word)
	if a:word == 'tag'
		return g:cbTags[0][0]
	endif
	let liti = WhereInLists(a:word)
	if liti[1] == -1
		return ""
	endif
	let liti[0] = NextListIdx(liti[0])
	let nextword = g:cbTags[liti[0]][0]
	return nextword
endfunction

" SetNextList() {{{2
" set the current tag to the first tag in the next list
" this is circular, the last list will roll to the first list
function! SetNextList()
	let oldtag = GetTag()
	let newtag = GetNextList(oldtag)
	if newtag == ""
		return
	endif
	let sub = "normal!ci[".newtag
	exec sub
endfunction
" vim600: set foldlevel=0 foldmethod=marker:
