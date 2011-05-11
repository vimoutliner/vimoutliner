" local .vimrc for working with otl2latex
"
" Used to write notes in vim outlier file (.otl) and have dynamically
" generated beamer-latex files produced.
"
" requires the script otl2latex.py is in the same directory as this script.
" also requires that your user ~/.vimrc file has "set exrc" specified
"
" This can be added to as more functionality is desired.
"
" Author: Serge Rey <sjsrey@gmail.com>
" Last Revision: 2007-01-21

version 6.0

"get rid of blank lines
map ,n :g/^$/d

"make the next paragraph a text block (in Vim Outliner terms)
map ,t ma}k^mb'a'bI|

"make an itemized list out of the following contiguous lines (each line is an
"item)
map ,i ^ma}k^mb'a'bI\item 'aObegin{itemize}'aki\'bo\end{itemize}

"make an itemized list out of the following contiguous lines (each line is an
"item) and then mark block as otl text
map ,I ^ma}k^mb'a'bI\item 'aObegin{itemize}'aki\'bo\end{itemize}'akma}k^mb'a'bI|

map ,f ^Obegin{center}jo\end{center}k^i\includegraphics[width=.8\linewidth]{A}k^i\^jjmbkk'bI|

"process the otl file to produce a pdf presentation
map ,b :!python otl2latex.py -p % %<.tex;pdflatex %<.tex

"pdflatex the current buffer
map ,p :!pdflatex %

"set up menus
amenu o&2l.&process<Tab>,b  ,b
amenu o&2l.&delete\ blank\ lines<Tab>,n  ,n
amenu o2l.-Sep-     :
amenu o&2l.&itemize<Tab>,i     ,i
amenu o&2l.&textualize<Tab>,t  ,t
amenu o&2l.&itemize_and_textualize<Tab>,t  ,I
