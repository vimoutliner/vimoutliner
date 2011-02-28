" File:        plugin/delimitMate.vim
" Version:     1.0
" Modified:    2011-02-28
" Description: This plugin provides inter-outline links for vimoutliner.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      The following mappings are added:
"      					- <C-K> : Follow a link.
"      					- <C-N> : Jump back in the link-history.
"      					- <localleader>l : Create a link.
" ============================================================================

if v:version < 700
	echom 'VimOutliner: vo_links.vim requires Vim 7.0 or later.'
	finish
endif

" Only load for VO files.
if &filetype !=? 'vo_base'
	finish
endif

" Create outlines' jump-list.
if !exists('w:vo_jump_list')
	let w:vo_jump_list = []
endif

" Mappings {{{1

" Follow inter-outline link.
noremap <buffer> <Plug>VO_FollowLink :call <SID>follow_link()<CR>
if !hasmapto('<Plug>VO_FollowLink')
	"map <unique> <buffer> <C-K> <Plug>VO_FollowLink
	map <silent> <buffer> <C-K> <Plug>VO_FollowLink
endif

" Go back to previous outline.
noremap <buffer> <Plug>VO_JumpBack :call <SID>jump_back()<CR>
if !hasmapto('<Plug>VO_JumpBack')
	"map <unique> <buffer> <C-N> <Plug>VO_JumpBack
	map <silent> <buffer> <C-N> <Plug>VO_JumpBack
endif

" Create a link from a word in normal mode.
noremap <buffer> <Plug>VO_CreateLink :call <SID>create_link()<CR>
if !hasmapto('<Plug>VO_CreateLink')
	map <silent> <unique> <buffer> <localleader>l <Plug>VO_CreateLink
endif

" Create a link from a word in insert mode.
inoremap <buffer> <Plug>VO_CreateLinkI <C-O>:call <SID>create_link()<CR>
if !hasmapto('<Plug>VO_CreateLinkI')
	imap <silent> <unique> <buffer> <localleader>l <Plug>VO_CreateLinkI
endif

" Functions {{{1

" Don't re-load functions.
if exists('s:loaded')
	finish
endif
let s:loaded = 1

" s:follow_link() {{{2
" Follow an interoutline link.
function s:follow_link()
	" Check if it's a valid link.
	let line = getline('.')
	if line !~? '^\t*_tag_\w\+\s*$'
		echom 'Vimoutliner: "'.line.'" doesn''t not look like an interoutline link.'
		return
	endif
	" Split line.
	let line2 = getline(line('.') + 1)
	" The following pattern is very magic.
	let [_,file,row,col,_,_,_,_,_,_] = matchlist(line2, '\v^\s*([^:]+)%(:(\d+))?%(:(\d+))?$')
	"let line2 = substitute(line2, '^\s*\(\S.*\)\s*$','\1','')
	"let file = substitute(line2, '^\(.\{-}\)\(:\d\+\)\{0,2}$','\1','')
	" Expand '%'.
	let inner = 0
	if file == '%'
		let file = expand('%:p')
		let inner = 1
	endif
	"let row = substitute(line2, '^.\{-}\(:\d\+\)\?\(:\d\+\)\?$','\1','')
	"let row = substitute(row, ':','','')
	let row = row == '' ? 0 : row * 1
	"let col = substitute(line2, '^.\{-}:\d\+\(:\d\+\)\?$','\1','')
	"let col = substitute(col, ':','','')
	let col = col == '' ? 0 : col * 1

	" Check if file path exists.
	let file = s:get_absolute_path(expand('%:h'), file)
	let file = fnamemodify(file,':p')
	let baseDir = fnamemodify(file,':h')
	let dirconfirm = 0
	" Check if directories exists. {{{3
	if glob(baseDir) == ''
		if exists('*confirm')
			let dirconfirm = confirm('The linked file "'.file.'" and one or more directories do not exist, do you want to create them now?', "&Yes\n&No", '2', 'Question')
		else
			" Can't ask, asume a yes for answer.
			let dirconfirm = 1
		endif
		if dirconfirm == 1
			" Create dir(s):
			if exists('*mkdir')
				call mkdir(baseDir,'p')
			elseif executable('mkdir')
				call system('`which mkdir` -p '.shellescape(baseDir))
			else
				echom 'Vimoutliner: Vim can not create the required directories, please create them yourself.'
				return
			endif
		else
			return
		endif
	endif
	" Check if file exists. {{{3
	if glob(file) == ''
		if exists('*confirm') && dirconfirm == 0
			let confirm = confirm('The linked file "'.file.'" does not exist, do you want to create it now?', "&Yes\n&No", '2', 'Question')
		else
			" Can't ask, asume a yes for answer.
			let confirm = 1
		endif
		if confirm == 1
			call writefile([], file)
		else
			return
		endif
	endif
	" }}}3
	" Now let's jump to that outline.
	try
		call s:update_jump_list()
		if inner == 0
			exec "buffer ".bufnr(substitute(file, '^'.getcwd().'/','',''), 1)
		endif
		if row > 0
			call setpos('.',[0,row,col,0])
		endif
		setlocal buflisted
	catch
		" Prevent reporting that the error ocurred inside this function.
		echoh ErrorMsg
		echom substitute(v:exception,'^Vim(.\{-}):','','')
		echoh None
	endtry
	return ''
endfunction
" s:get_absolute_path(baseDir, fileName) {{{2
" Guess an absolute path
function! s:get_absolute_path(baseDir, fileName)
	let baseDir = a:baseDir
	if baseDir !~ '/$'
		let baseDir = baseDir . '/'
	endif
	if a:fileName =~ '^/'
		let absFileName = a:fileName
	else
		let absFileName = baseDir . a:fileName
	endif

	let absFileName = substitute(absFileName, '/\./', '/', 'g')
	while absFileName =~ '/\.\./'
		absFileName = substitute(absFileName, '/[^/]*\.\./', '', '')
	endwhile
	return absFileName
endfunction
" s:update_jump_list() {{{2
" Add current outline to list.
function! s:update_jump_list()
	call add(w:vo_jump_list, [bufnr('%')] + getpos('.'))
endfunction
" s:remove_buf(buf) {{{2
" Remove outline from list.
function! s:remove_buf()
	if !exists('w:vo_jump_list') || len(w:vo_jump_list) == 0
		return
	endif
	" Remove last outline.
	call remove(w:vo_jump_list, -1)
endfunction
" s:jump_back() {{{2
" Jump back to the previous outline.
function! s:jump_back()
	if len(w:vo_jump_list) == 0
		echom 'This is the first outline.'
		return
	endif
	exec "buffer ".w:vo_jump_list[-1][0]
	call setpos('.', w:vo_jump_list[-1][1 : ])
	call s:remove_buf()
endfunction
" s:create_link() {{{2
" Create an interoutline link with the current keyword under the cursor.
function s:create_link()
	let line = getline('.')
	" Check if the there's is a single word in the current line and a current
	" link doesn't exists.
	if line =~# '^\s*\w\+$' &&
				\ ( line('.') == line('$') ||
				\ indent('.') >= indent(line('.') + 1 ) ||
				\ match(getline(line('.') + 1), '^\s*\S.\s*$') == -1)
		call setline(line('.'), substitute(line, '^\(\s*\)\%(_tag_\)\?\(\w\+\)$','\1_tag_\3', ''))
		call inputsave()
		let input = input('Linked outline''s path: ', '', 'file')
		call inputrestore()
		if input == ''
			" User canceled.
			return ''
		endif
		let path = substitute(input, '^\s*\(\S.\{-}\)\s*$', '\1', '')
		"if path !~ '\.otl$'
			"" Add extension.
			"let path = path.'.otl'
		"endif
		call append(line('.'), path)
		let linenr = line('.')
		let indent = indent(linenr)
		" Adjust indentation.
		normal! j
		while indent >= indent(linenr + 1)
			normal! >>
		endwhile
		normal! k$
	else
		echom 'Vimoutliner: "'.substitute(line,'^\s*\(\S.*$\)','\1','').'" does not seem to be a proper tag name.'
		return ''
	endif
endfunction
" Autocommands {{{1
augroup vo_links
	au!
	au BufWinEnter * if !exists('w:vo_jump_list') | let w:vo_jump_list = [] | endif
augroup END
"{{{1 vim:foldmethod=marker
