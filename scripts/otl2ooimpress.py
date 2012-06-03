#!/usr/bin/python
# otl2ooimpress.py
# needs otl2ooimpress.sh to work in an automated way
#############################################################################
#
#  Tool for Vim Outliner files to Open Office Impress files.
#  Copyright (C) 2003 by Noel Henson, all rights reserved.
#
#       This tool is free software; you can redistribute it and/or
#       modify it under the terms of the GNU Library General Public
#       License as published by the Free Software Foundation; either
#       version 2 of the License, or (at your option) any later version.
#
#       This library is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#       Lesser General Public License for more details.
#
#       You should have received a copy of the GNU Library General Public
#       License along with this library; if not, write to:
#
#       Free Software Foundation, Inc.
#       59 Temple Place, Suite 330
#       Boston, MA 02111-1307  USA
#
#############################################################################
# ALPHA VERSION!!!
# $Revision: 1.3 $
# $Date: 2003/12/01 20:22:18 $
# $Author: noel $
# $Source: /home/noel/apps/otl2ooimpress/RCS/otl2ooimpress.py,v $
# $Locker:  $

###########################################################################
# Basic function
#
#	This program accepts VO outline files and converts them
#	to the zipped XML files required by Open Office Impress.
#
#	10 outline levels are supported.  These loosely correspond to the
#	HTML H1 through H9 tags.
#


###########################################################################
# include whatever mdules we need

import sys
from string import *
from time import *

###########################################################################
# global variables

level = 0
inputFile = ""
outline = []
flatoutline = []
pageNumber = 0
inPage = 0
debug = 0

###########################################################################
# function definitions

# usage
# print the simplest form of help
# input: none
# output: simple command usage is printed on the console
 
def showUsage():
   print
   print "Usage:"
   print "otl2ooimpress.py [options] inputfile > outputfile"
   print "Options"
   print "    -v              Print version (RCS) information."
   print "output is on STDOUT"
   print

# version
# print the RCS version information
# input: none
# output: RSC version information is printed on the console
 
def showVersion():
   print
   print "RCS"
   print " $Revision: 1.3 $"
   print " $Date: 2003/12/01 20:22:18 $"
   print " $Author: noel $"
   print " $Source: /home/noel/apps/otl2ooimpress/RCS/otl2ooimpress.py,v $"
   print

# getArgs
# Check for input arguments and set the necessary switches
# input: none
# output: possible console output for help, switch variables may be set

def getArgs():
  global inputfile, debug
  if (len(sys.argv) == 1): 
    showUsage()
    sys.exit()()
  else:
    for i in range(len(sys.argv)):
      if (i != 0):
        if   (sys.argv[i] == "-d"): debug = 1	# test for debug flag
        elif (sys.argv[i] == "-?"):		# test for help flag
	  showUsage()				# show the help
	  sys.exit()				# exit
        elif (sys.argv[i] == "--help"):
	  showUsage()
	  sys.exit()
        elif (sys.argv[i] == "-h"):
	  showUsage()
	  sys.exit()
        elif (sys.argv[i] == "-v"):
	  showVersion()
	  sys.exit()
	elif (sys.argv[i][0] == "-"):
	  print "Error!  Unknown option.  Aborting"
	  sys.exit()
	else: 					# get the input file name
          inputfile = sys.argv[i]

# getLineLevel
# get the level of the current line (count the number of tabs)
# input: linein - a single line that may or may not have tabs at the beginning
# output: returns a number 1 is the lowest

def getLineLevel(linein):
  strstart = lstrip(linein)			# find the start of text in line
  x = find(linein,strstart)			# find the text index in the line
  n = count(linein,"\t",0,x)			# count the tabs
  return(n+1)					# return the count + 1 (for level)

# getLineTextLevel
# get the level of the current line (count the number of tabs)
# input: linein - a single line that may or may not have tabs at the beginning
# output: returns a number 1 is the lowest

def getLineTextLevel(linein):
  strstart = lstrip(linein)			# find the start of text in line
  x = find(linein,strstart)			# find the text index in the line
  n = count(linein,"\t",0,x)			# count the tabs
  n = n + count(linein," ",0,x)			# count the spaces
  return(n+1)					# return the count + 1 (for level)
    
# colonStrip(line)
# stip a leading ':', if it exists
# input: line
# output: returns a string with a stipped ':'

def colonStrip(line):
	if (line[0] == ":"): return lstrip(line[1:])
        else: return line

# processLine
# process a single line
# input: linein - a single line that may or may not have tabs at the beginning
#        level - an integer between 1 and 9 that show the current level
# 	          (not to be confused with the level of the current line)
# output: through standard out

def processLine(linein):
  global inPage, pageNumber
  if (lstrip(linein) == ""): 
	print 
  	return
  if (getLineLevel(linein) == 1):
	  if (inPage==1): 
		  print '</draw:text-box></draw:page>'
		  inPage = 0
	  pageNumber += 1
	  outstring = '<draw:page draw:name="'
	  outstring += 'page'
	  outstring += str(pageNumber)
	  outstring += '" draw:style-name="dp1" draw:id="1" draw:master-page-name="Default" presentation:presentation-page-layout-name="AL1T0">'
	  print outstring 
	  outstring  = '<draw:text-box presentation:style-name="pr1" draw:layer="layout" svg:width="23.911cm" svg:height="3.508cm" svg:x="2.057cm" svg:y="1.0cm" presentation:class="title">'
	  print outstring 
	  outstring = '<text:p text:style-name="P1">'
	  outstring += lstrip(linein)
	  outstring += "</text:p></draw:text-box>"
	  print outstring 
	  outstring = '<draw:text-box presentation:style-name="pr1" draw:layer="layout" svg:width="23.911cm" svg:height="3.508cm" svg:x="2.057cm" svg:y="5.38cm" presentation:class="subtitle">'
	  print outstring 
	  inPage = 1
  else:
	  outstring = '<text:p text:style-name="P1">'
	  outstring += lstrip(linein)
	  outstring += '</text:p>'
	  print outstring 
      
# flatten
# Flatten a subsection of an outline.  The index passed is the outline section
# title.  All sublevels that are only one level deeper are indcluded in the current
# subsection.  Then there is a recursion for those items listed in the subsection.
# Exits when the next line to be processed is of the same or lower outline level.
#  (lower means shallower)
# input: idx - the index into the outline.  The indexed line is the title.
# output: adds reformatted lines to flatoutline[]

def flatten(idx):
  if (outline[idx] == ""):
    return
  if (len(outline) <= idx):
    return
  titleline = outline[idx]
  titlelevel = getLineLevel(titleline)
  if (getLineLevel(outline[idx+1]) > titlelevel):
    if (titleline[titlelevel-1] != " "):
      flatoutline.append(lstrip(titleline))
    exitflag = 0
    while (exitflag == 0):
      if (idx < len(outline)-1):
        idx = idx + 1
        currlevel = getLineLevel(outline[idx])
        if (currlevel == titlelevel + 1):
          if (currlevel == find(outline[idx]," ") +1):
            flatoutline.append("\t " + lstrip(outline[idx]))
          else:
            flatoutline.append("\t" + lstrip(outline[idx]))
        elif (currlevel <= titlelevel):
          exitflag = 1
      else:
        exitflag = 1
  level =  titlelevel
  return

def printHeader(linein):
  print'<?xml version="1.0" encoding="UTF-8"?>'
  print'<!DOCTYPE office:document-content PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "office.dtd">'
  print'<office:document-content xmlns:office="http://openoffice.org/2000/office" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:presentation="http://openoffice.org/2000/presentation" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script" office:class="presentation" office:version="1.0">'
  print'<office:script/>'
  print'<office:body>'

def printFooter():
  print '</draw:text-box></draw:page>'
  print'</office:body>'

def main():
  getArgs()
  flatouline = []
  file = open(inputfile,"r")
  linein = lstrip(rstrip(file.readline()))
  outline.append(linein)
  linein = lstrip(rstrip(file.readline()))
  while linein != "":
    outline.append("\t" + linein)
    linein = rstrip(file.readline())
  for i in range (0,len(outline)-1):
    flatten(i)

  printHeader(flatoutline[0])
  for i in range (0,len(flatoutline)):
    processLine(flatoutline[i])
  printFooter()

  file.close()

main()
    
