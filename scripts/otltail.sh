#!/bin/bash
if [ "$#" -lt 1 ] ; then
	echo " Usage: otltail level < file"
	echo "	      Remove the specified number of parent headings."
	echo "	      This is a way to promote children. It is"
	echo "	      useful for converting a single outline into a"
	echo "	      number of pages for a web site or chapters for"
	echo "	      a book."
	echo "	      level   - the number of levels to include"
	echo "	      file    - an otl file"
	echo "	      input   - standard in"
	echo "	      output  - standard out"
	exit 0
fi
sed "/^\(\t\)\{$1\}.*$/! { D }" | sed "s/^\(\t\)\{$1\}//" 
