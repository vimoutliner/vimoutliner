" File:        plugin/votl_tags.vim
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
	echom 'VimOutliner: votl_tags.vim requires Vim 7.0 or later.'
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
	silent! map <silent> <unique> <buffer> <localleader>l <Plug>VO_CreateLink
endif

" Create a link from a word in insert mode.
inoremap <buffer> <Plug>VO_CreateLinkI <C-O>:call <SID>create_link()<CR>
if !hasmapto('<Plug>VO_CreateLinkI')
	silent! imap <silent> <unique> <buffer> <localleader>l <Plug>VO_CreateLinkI
endif

" Functions {{{1

let s:checkboxpat = '\%(\[[^[\]]\+\]\s\+\%(\d*%\d*\s\+\)\?\)\?'

" Don't re-load functions.
if exists('s:loaded')
	finish
endif
let s:loaded = 1

" s:get_link() {{{2
" Get link data.
function! s:get_link(linenr)
	" Check if it's a valid link.
	let line = getline(a:linenr)
	if line =~? '\m^\t*'.s:checkboxpat.'_tag_\w\+\s*$'
		" Don't remember where this bit came from, please let me know if you do.
		let [_,file,row,col;m0] = matchlist(getline(a:linenr + 1), '\m^\t*'.s:checkboxpat.'\([^:]\+\)\%(:\(\d\+\)\)\?\%(:\(\d\+\)\)\?$')
	elseif line =~? '\m^\t*'.s:checkboxpat.'_ilink_\(.\{-}:\s\)\?\s*\S.*$'
		let pat = '\m^\t*'.s:checkboxpat.'_ilink_\%([^:\\/]\{-}:\s\)\?\s*\(.\+\)\%(:\(\d\+\)\)\?\%(:\(\d\+\)\)\?$'
		let [_,file,row,col;m0] = matchlist(line, pat)
	else
		return ['',0,0,0]
	endif
	let is_inner_link = 0
	if file == '%'
		let file = expand('%:p')
		let is_inner_link = 1
	endif
	let row = (row == '' ? 0 : row * 1)
	let col = (col == '' ? 0 : col * 1)

	return [file, row, col, is_inner_link]
endfunction

" s:follow_link() {{{2
" Follow an interoutline link.
function! s:follow_link()
	" Get link data.
	let [file, row, col, is_inner_link] = s:get_link(line('.'))
	if file == ''
		echom 'Vimoutliner: "'.substitute(getline('.'), '\m^\t*'.s:checkboxpat, '', '').'" doesn''t not look like an inter-outline link.'
		return
	endif

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
		if !is_inner_link
			exec "buffer ".bufnr(substitute(file, '\m^'.getcwd().'/','',''), 1)
		endif
		if row > 0
			call setpos('.',[0,row,col,0])
		endif
		setlocal buflisted
	catch
		" Prevent reporting that the error ocurred inside this function.
		echoh ErrorMsg
		echom substitute(v:exception,'\m^Vim(.\{-}):','','')
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

	let absFileName = substitute(absFileName, '\m/\./', '/', 'g')
	while absFileName =~ '/\.\./'
		absFileName = substitute(absFileName, '\m/[^/]*\.\./', '', '')
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
function! s:create_link()
	let line = getline('.')
	" Create link on a header only
	if line =~ '\m^\t\+[^ :;<>|]'
		echom 'Vimoutliner: Links have to be on a header.'
		return
	endif
	" Check if the there's is some content in the current line and a current
	" link doesn't exists.
	if line =~# '\m^\t*'.s:checkboxpat.'_ilink_\%([^:]\{-}:\s\)\?\s*\S\+.*$'
		echom 'Vimoutliner: Looks like "'.substitute(line,'^\t*'.s:checkboxpat.'\(\S.*$\)','\1','').'" is already a link.'
		return
	endif
	call inputsave()
	let path = input('Linked outline''s path: ', '', 'file')
	call inputrestore()
	if path == ''
		" User canceled.
		return ''
	endif
	let path = matchstr(path, '\m^\t*'.s:checkboxpat.'\zs\S.\{-}\ze\s*$')
	"if path !~ '\.otl$'
		"" Add extension.
		"let path = path.'.otl'
	"endif
	let tag = '_ilink_'
	let [_,indent,checkbox,label;m0] = matchlist(line, '\m^\(\t*\)\('.s:checkboxpat.'\)\%(_ilink_\)\?\s*\(\S\%(.\{-1,}\S\)\?\)\?\s*\%(:\s\)\?\s*$')
	"echom indent.'-'.checkbox.'-'.label
	if indent == ''
		let indent = matchstr(getline(line('.')-1), '\m^\(\t*\)')
	endif
	if label !~ ':\s*$'
		let label = substitute(label, '\m\s*$', ': ', '')
	else
		let label = substitute(label, '\m:\s*$', ': ', '')
	endif

	call setline(line('.'), indent.checkbox.tag.' '.label.path)
	echo ''
endfunction
" Autocommands {{{1
augroup vo_links
	au!
	au BufWinEnter * if !exists('w:vo_jump_list') | let w:vo_jump_list = [] | endif
augroup END
"{{{1 vim:foldmethod=marker
