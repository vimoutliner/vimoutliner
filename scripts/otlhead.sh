#!/bin/bash
if [ "$#" -lt 1 ] ; then
	echo " Usage: otlhead level < file"
	echo "        Keep the number of levels specified, remove the rest."
	echo "        Great for generating summaries."
	echo "        level   - the number of levels to include"
	echo "        file    - an otl file"
	echo "        input   - standard in"
	echo "        output  - standard out"
	exit 0
fi
sed "/^\(\t\)\{$1\}.*$/ { D }" 
