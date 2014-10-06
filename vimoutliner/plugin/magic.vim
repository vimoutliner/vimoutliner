"######################################################################
"# VimOutliner Magic
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

"NOTES:
" 1. This plugin is in TEST SCRIPT mode and has not been integrated into
" VO yet. It will be once testing is done. This script should be sourced
" ':so magic.vim' until the integration has been completed.
" 2. For other plugins to be able to use magic, this plugin must be
" loaded first. <-- ignore note #2. It is a placeholder for integration.

" Magic is a way to used simple keystrokes to perform dynamically 
" reconfigurable behaviors. For example:
" 	Key		Entity		Behavior	Description
" 	<S-Space>	[_]		,,cx		toggle checkbox
" 	<S-Space>	[X]		,,cx		toggle checkbox
" 	<S-Space>	n%		,,c+		increment by 10%
" 	<C-Space>	n%		,,c-		decrement by 10%
"	<S-Space>	[tag]		,,ct		set next tag in tag list
"	<C-Space>	[tag]		,,cT		set next tag list
"	<S-Space>	{math}		,,mm		compute math parents
"	<C-Space>	{math}		,,mt		compute math tree
"	<S-Space>	varname=	,,mm		compute math parents
"	<C-Space>	varname=	,,mt		compute math tree

" Key coding for magic
" 	When mapping for <S-Space>, use modifier of 0
" 	When mapping for <C-Space>, use modifier of 1
" 	Note the '0' and '1' could be any number, they just need to be 
" 	unique.

let g:voMagic = []

" Initial configuration for testing
" In the future, each plugin will have the option of adding it's own magic
" with: let g:voMagic += [['regex',modifier,'commands']]

if exists("*SwitchBox")
	" checboxes
	let g:voMagic += [['[_]',        0,  ': call SwitchBox()|call CalculateMyBranch(line("."))']]
	let g:voMagic += [['[X]',        0,  ': call SwitchBox()|call CalculateMyBranch(line("."))']]
	" checkbox percentages
	let g:voMagic += [['\d\+%\d*',   0,  ': call IncPercent(".")|call CalculateMyBranch(line("."))']]
	let g:voMagic += [['\d\+%\d*',   1,  ': call DecPercent(".")|call CalculateMyBranch(line("."))']]
	" tags
	let g:voMagic += [['[.\+\]',     0,  ': call SetNextTag()']]
	let g:voMagic += [['[.\+\]',     1,  ': call SetNextList()']]
endif
if exists("*ComputeUp")
	" math on formulae
	let g:voMagic += [['{.\+}',      0,  ': call ComputeUp(line("."))']]
	let g:voMagic += [['{.\+}',      1,  ': call ComputeTree(line("."))']]
	" math on results
	let g:voMagic += [['.\+=\d',     0,  ': call ComputeUp(line("."))']]
	let g:voMagic += [['.\+=\d',     1,  ': call ComputeTree(line("."))']]
endif

function! VOMagic(mod)
	let word = expand("<cWORD>")
	for action in g:voMagic
		if action[1] == a:mod && match(word,action[0]) != -1
			exec action[2]
			break
		endif
	endfor
endfunction

map <silent><buffer> <S-Space> :call VOMagic(0)<cr>
map <silent><buffer> <C-Space> :call VOMagic(1)<cr>

