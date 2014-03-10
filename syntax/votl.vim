"#########################################################################
"# syntax/votl.vim: VimOutliner syntax highlighting
"# version 0.3.7
"#   Copyright (C) 2001,2003 by Steve Litt (slitt@troubleshooters.com)
"#
"#   This program is free software; you can redistribute it and/or modify
"#   it under the terms of the GNU General Public License as published by
"#   the Free Software Foundation; either version 2 of the License, or
"#   (at your option) any later version.
"#
"#   This program is distributed in the hope that it will be useful,
"#   but WITHOUT ANY WARRANTY; without even the implied warranty of
"#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"#   GNU General Public License for more details.
"#
"#   You should have received a copy of the GNU General Public License
"#   along with this program; if not, write to the Free Software
"#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
"#
"# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
"#########################################################################

" HISTORY {{{1
"#########################################################################
"#  V0.1.0 Pre-alpha
"#      Set of outliner friendly settings
"# Steve Litt, 5/28/2001
"# End of version 0.1.0
"# 
"#  V0.1.1 Pre-alpha
"#      No change
"# 
"# Steve Litt, 5/28/2001
"# End of version 0.1.1
"# 
"#  V0.1.2 Pre-alpha
"# 	No Change
"# Steve Litt, 5/30/2001
"# End of version 0.1.2
"#  V0.1.3 Pre-alpha
"# 	No Change
"# Steve Litt, 5/30/2001
"# End of version 0.1.3
"#  V0.2.0 
"# 	Noel Henson adds code for outliner-friendly expand and
"# 	collapse, comma comma commands, color coding, hooks for a
"# 	spellchecker, sorting, and date insertion.
"# Noel Henson, 11/24/2002
"# End of version 0.2.0
"# END OF HISTORY
"# 
"#########################################################################

" Colors linked {{{1
" Bill Powell, http://www.billpowellisalive.com
" Linked colors to normal groups. Different schemes will need tweaking.
" Occasionally certain groups will be rendered invisible. ;)
"
" Changelog {{{2
"2007 Jan 23, 21:23 Tue - 0.3.0, Modified version 0.1
    " Linked syntax groups to standard Vim color groups, intsead of to
    " particular colors. Now each colorscheme can work its own magic on
    " a VO file.
"2007 Apr 30,  9:36 Mon - 0.3.0, Modified version 0.2
    " Changed a few linked groups to reduce chances of groups being invisible.
    " No longer use Ignore group for anything.
    " Still a little redundancy; different groups might linked to same color group.
        " E.g., PT1 and UT1. But some color schemes (e.g. astronout) will differentiate between 
        " Special and Debug. Others will use the same colors for, say, Identifier and Debug. 
        " It just depends.
    " To tweak these groups, try :h syntax and go to group-name.
    " This shows the color groups, highlighted in your current colorscheme.
" }}}
hi link OL1 Statement 
hi link OL2 Identifier
hi link OL3 Constant
hi link OL4 PreProc   
hi link OL5 Statement 
hi link OL6 Identifier
hi link OL7 Constant
hi link OL8 PreProc   
hi link OL9 Statement

"colors for tags
"hi link outlTags Tag
hi link outlTags Todo

"color for body text
hi link BT1 Comment
hi link BT2 Comment
hi link BT3 Comment
hi link BT4 Comment
hi link BT5 Comment
hi link BT6 Comment
hi link BT7 Comment
hi link BT8 Comment
hi link BT9 Comment

"color for pre-formatted text
hi link PT1 Special
hi link PT2 Special
hi link PT3 Special
hi link PT4 Special
hi link PT5 Special
hi link PT6 Special
hi link PT7 Special
hi link PT8 Special
hi link PT9 Special

"color for tables 
hi link TA1 Type
hi link TA2 Type
hi link TA3 Type
hi link TA4 Type
hi link TA5 Type
hi link TA6 Type
hi link TA7 Type
hi link TA8 Type
hi link TA9 Type

"color for user text (wrapping)
hi link UT1 Debug
hi link UT2 Debug
hi link UT3 Debug
hi link UT4 Debug
hi link UT5 Debug
hi link UT6 Debug
hi link UT7 Debug
hi link UT8 Debug
hi link UT9 Debug

"color for user text (non-wrapping)
hi link UB1 Underlined
hi link UB2 Underlined
hi link UB3 Underlined
hi link UB4 Underlined
hi link UB5 Underlined
hi link UB6 Underlined
hi link UB7 Underlined
hi link UB8 Underlined
hi link UB9 Underlined

"colors for folded sections
"hi link Folded Special
"hi link FoldColumn Type

"colors for experimental spelling error highlighting
"this only works for spellfix.vim with will be cease to exist soon
hi link spellErr Error
hi link BadWord Todo

" Syntax {{{1
syn clear
syn sync fromstart

syn match outlTags '_tag_\w*' contained

" Noel's style of body text {{{2
syntax region BT1 start=+^ \S+ skip=+^ \S+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=e-2 contains=spellErr,SpellErrors,BadWord contained
syntax region BT2 start=+^\(\t\)\{1} \S+ skip=+^\(\t\)\{1} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT3 start=+^\(\t\)\{2} \S+ skip=+^\(\t\)\{2} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT4 start=+^\(\t\)\{3} \S+ skip=+^\(\t\)\{3} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT5 start=+^\(\t\)\{4} \S+ skip=+^\(\t\)\{4} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT6 start=+^\(\t\)\{5} \S+ skip=+^\(\t\)\{5} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT7 start=+^\(\t\)\{6} \S+ skip=+^\(\t\)\{6} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT8 start=+^\(\t\)\{7} \S+ skip=+^\(\t\)\{7} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT9 start=+^\(\t\)\{8} \S+ skip=+^\(\t\)\{8} \S+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"comment-style bodytext as per Steve Litt {{{2
syntax region BT1 start=+^:+ skip=+^:+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT2 start=+^\(\t\)\{1}:+ skip=+^\(\t\)\{1}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT3 start=+^\(\t\)\{2}:+ skip=+^\(\t\)\{2}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT4 start=+^\(\t\)\{3}:+ skip=+^\(\t\)\{3}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT5 start=+^\(\t\)\{4}:+ skip=+^\(\t\)\{4}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT6 start=+^\(\t\)\{5}:+ skip=+^\(\t\)\{5}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT7 start=+^\(\t\)\{6}:+ skip=+^\(\t\)\{6}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT8 start=+^\(\t\)\{7}:+ skip=+^\(\t\)\{7}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region BT9 start=+^\(\t\)\{8}:+ skip=+^\(\t\)\{8}:+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"Preformatted body text {{{2
syntax region PT1 start=+^;+ skip=+^;+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT2 start=+^\(\t\)\{1};+ skip=+^\(\t\)\{1};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT3 start=+^\(\t\)\{2};+ skip=+^\(\t\)\{2};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT4 start=+^\(\t\)\{3};+ skip=+^\(\t\)\{3};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT5 start=+^\(\t\)\{4};+ skip=+^\(\t\)\{4};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT6 start=+^\(\t\)\{5};+ skip=+^\(\t\)\{5};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT7 start=+^\(\t\)\{6};+ skip=+^\(\t\)\{6};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT8 start=+^\(\t\)\{7};+ skip=+^\(\t\)\{7};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region PT9 start=+^\(\t\)\{8};+ skip=+^\(\t\)\{8};+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"Preformatted tables {{{2
syntax region TA1 start=+^|+ skip=+^|+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA2 start=+^\(\t\)\{1}|+ skip=+^\(\t\)\{1}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA3 start=+^\(\t\)\{2}|+ skip=+^\(\t\)\{2}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA4 start=+^\(\t\)\{3}|+ skip=+^\(\t\)\{3}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA5 start=+^\(\t\)\{4}|+ skip=+^\(\t\)\{4}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA6 start=+^\(\t\)\{5}|+ skip=+^\(\t\)\{5}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA7 start=+^\(\t\)\{6}|+ skip=+^\(\t\)\{6}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA8 start=+^\(\t\)\{7}|+ skip=+^\(\t\)\{7}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region TA9 start=+^\(\t\)\{8}|+ skip=+^\(\t\)\{8}|+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"wrapping user text {{{2
syntax region UT1 start=+^>+ skip=+^>+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT2 start=+^\(\t\)\{1}>+ skip=+^\(\t\)\{1}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT3 start=+^\(\t\)\{2}>+ skip=+^\(\t\)\{2}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT4 start=+^\(\t\)\{3}>+ skip=+^\(\t\)\{3}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT5 start=+^\(\t\)\{4}>+ skip=+^\(\t\)\{4}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT6 start=+^\(\t\)\{5}>+ skip=+^\(\t\)\{5}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT7 start=+^\(\t\)\{6}>+ skip=+^\(\t\)\{6}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT8 start=+^\(\t\)\{7}>+ skip=+^\(\t\)\{7}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UT9 start=+^\(\t\)\{8}>+ skip=+^\(\t\)\{8}>+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"non-wrapping user text {{{2
syntax region UB1 start=+^<+ skip=+^<+ end=+^\S+me=e-1 end=+^\(\t\)\{1}\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB2 start=+^\(\t\)\{1}<+ skip=+^\(\t\)\{1}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB3 start=+^\(\t\)\{2}<+ skip=+^\(\t\)\{2}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB4 start=+^\(\t\)\{3}<+ skip=+^\(\t\)\{3}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB5 start=+^\(\t\)\{4}<+ skip=+^\(\t\)\{4}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB6 start=+^\(\t\)\{5}<+ skip=+^\(\t\)\{5}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB7 start=+^\(\t\)\{6}<+ skip=+^\(\t\)\{6}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB8 start=+^\(\t\)\{7}<+ skip=+^\(\t\)\{7}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained
syntax region UB9 start=+^\(\t\)\{8}<+ skip=+^\(\t\)\{8}<+ end=+^\(\t\)*\S+me=s-1 contains=spellErr,SpellErrors,BadWord contained

"comment-style bodytext formatting as per Steve Litt
syntax match Comment "^\s*:.*$"
setlocal fo-=t fo+=crqno
setlocal com=sO:\:\ -,mO:\:\ \ ,eO:\:\:,:\:,sO:\>\ -,mO:\>\ \ ,eO:\>\>,:\>

" Headings {{{2
syntax region OL1 start=+^[^:\t]+ end=+^[^:\t]+me=e-1 contains=outlTags,BT1,BT2,PT1,PT2,TA1,TA2,UT1,UT2,UB1,UB2,spellErr,SpellErrors,BadWord,OL2 keepend
syntax region OL2 start=+^\t[^:\t]+ end=+^\t[^:\t]+me=s-1 contains=outlTags,BT2,BT3,PT2,PT3,TA2,TA3,UT2,UT3,UB2,UB3,spellErr,SpellErrors,BadWord,OL3 keepend
syntax region OL3 start=+^\(\t\)\{2}[^:\t]+ end=+^\(\t\)\{2}[^:\t]+me=e-3 contains=outlTags,BT3,BT4,PT3,PT4,TA3,TA4,UT3,UT4,UB3,UB4,spellErr,SpellErrors,BadWord,OL4 keepend
syntax region OL4 start=+^\(\t\)\{3}[^:\t]+ end=+^\(\t\)\{3}[^:\t]+me=e-4 contains=outlTags,BT4,BT5,PT4,PT5,TA4,TA5,UT4,UT5,UB4,UB5,spellErr,SpellErrors,BadWord,OL5 keepend
syntax region OL5 start=+^\(\t\)\{4}[^:\t]+ end=+^\(\t\)\{4}[^:\t]+me=e-5 contains=outlTags,BT5,BT6,PT5,PT6,TA5,TA6,UT5,UT6,UB5,UB6,spellErr,SpellErrors,BadWord,OL6 keepend
syntax region OL6 start=+^\(\t\)\{5}[^:\t]+ end=+^\(\t\)\{5}[^:\t]+me=e-6 contains=outlTags,BT6,BT7,PT6,PT7,TA6,TA7,UT6,UT7,UB6,UB7,spellErr,SpellErrors,BadWord,OL7 keepend
syntax region OL7 start=+^\(\t\)\{6}[^:\t]+ end=+^\(\t\)\{6}[^:\t]+me=e-7 contains=outlTags,BT7,BT8,PT7,PT8,TA7,TA8,UT7,UT8,UB7,UB8,spellErr,SpellErrors,BadWord,OL8 keepend
syntax region OL8 start=+^\(\t\)\{7}[^:\t]+ end=+^\(\t\)\{7}[^:\t]+me=e-8 contains=outlTags,BT8,BT9,PT8,PT9,TA8,TA9,UT8,UT9,UB8,UB9,spellErr,SpellErrors,BadWord,OL9 keepend
syntax region OL9 start=+^\(\t\)\{8}[^:\t]+ end=+^\(\t\)\{8}[^:\t]+me=e-9 contains=outlTags,BT9,PT9,TA9,UT9,UB9,spellErr,SpellErrors,BadWord keepend

" Auto-commands {{{1
if !exists("autocommand_vo_loaded")
	let autocommand_vo_loaded = 1
	au BufNewFile,BufRead *.otl                     setf outliner
"	au CursorHold *.otl                             syn sync fromstart
"	set updatetime=500
endif

" The End
" vim600: set foldmethod=marker foldlevel=0:
