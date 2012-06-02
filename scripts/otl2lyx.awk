#!/usr/bin/gawk -f

# Copyright (C) 2007 by Steve Litt, all rights reserved.
# Licensed under the GNU General Public License, version 2.
# otl2lyx.awk version 0.1.1 pre-alpha
# 4/23/2007
# Fixed insertion of other environments at bodytext to bodytext
#  borders.
#
# USAGE: ./otl2lyx  level-environment-table-file  outline-file
#
# level-table-structure:
# 1: Top-level-environment-name
# 2: 2nd-level-environment-name
# 3: 3rd-level-environment-name
# 4: 4th-level-environment-name
# 5: 5th-level-environment-name
# 6: 6th-level-environment-name
# bodytext: environment-name-for-normal-text
#
# Example for a book:
# 1: Chapter       
# 2: Section        
# 3: Subsection    
# 4: Subsubsection 
# 5: Paragraph     
# 6: Subparagraph  
# 7: Garbage7       
# bodytext: Standard


BEGIN{
	FS=":[ \t]*"
	OFS="\x09"
	lastinbodytext=0
}

### BLOW OFF BLANKS OUTSIDE OF BODY TEXT
$0~/^[ \t]*$/ && inbodytext==0{
	next
}

### FILL THE ENVIRONMENTS ARRAY ###
ARGIND==1{
	FS=":[ \t]*";
	sub(/[ \t]*$/,"",$2);
	environments[$1] = $2;
	next;
}

FNR==101{
	for(i in environments) print "level=" i ", string=" environments[i];
}

### FIELD SEPARATOR IS TAB ON THE OUTLINE FILE ###
{FS="\x09"; }

### INCREMENT OUTLINE ID NUMBER
{ol_id++}

### CALCULATE LEVEL ###
{
	for(i=1;i<=NF;i++)
		if($i == ""){
		 } else {
			break
		}
	this["level"] = i
	if(ol_id == ol_id_first)
		this["level"]--
}

### FIGURE TEXT ###
{
	this["text"] = ""
	for(i=1;i<=NF;i++){
		if($i != ""){
			if(this["text"] == ""){
				this["text"] = this["text"] $i
			} else {
				this["text"] = this["text"] " " $i
			}
		}
	}
	sub(/^[ \t]+/, "", this["text"]);
	sub(/[ \t]+$/, "", this["text"]);
}

### SET BODYTEXT FLAGS ###
{ inbodytext = 0; newbodytext = 0; endbodytext = 0; btblankline=0; }


this["text"] ~ /^:[ \t]+[^ \t]/{
	inbodytext = 1;
	sub(/^:[ \t]*/, "", this["text"]);
	this["text"] = this["text"] " ";
}

this["text"] == "" || this["text"] == ":"{
	this["text"] = "";
	inbodytext = lastinbodytext;
	if(inbodytext == 1){
		endbodytext = 1;
		newbodytext = 1;
		btblankline = 1;
	}
}

lastinbodytext == 1 && inbodytext == 0{
	endbodytext = 1;
}

lastinbodytext == 0 && inbodytext == 1{
	newbodytext = 1;
}

{ lastinbodytext = inbodytext; }



### QUOTE SINGLE BACKSLASHES FOR LATEX ###
{gsub(/\\/,"\r\\backslash\r", this["text"]);}

### PRINT LYX CONTENT ###

endbodytext == 1{
	print "\\end_layout"
	print ""
}
newbodytext == 1{
	print "\\begin_layout " environments["bodytext"]
}
inbodytext == 1{
	if(btblankline == 0) print this["text"]
}

inbodytext == 0{
	print "\\begin_layout " environments[this["level"]]
	print this["text"]
	print "\\end_layout"
	print ""
}

END{
	if(inbodytext == 1){
	print "\\end_layout"
	print ""
	}
}
