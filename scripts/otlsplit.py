#!/usr/bin/python
# otlslit.py
# split an outline into several files.
#
# Copyright 2005 Noel Henson All rights reserved
#
# $Revision: 1.9 $
# $Date: 2006/02/19 14:39:06 $
# $Author: noel $
# $Source: /home/noel/active/otlsplit/RCS/otlsplit.py,v $
# $Locker:  $

###########################################################################
# Basic function
#
#	This program accepts text outline files and splits them into
#	several smaller files. The output file names are produced from the
#	heading names of the parents.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

###########################################################################
# include whatever mdules we need

import sys
from string import *
from re import *

###########################################################################
# global variables

debug = 0
subdir = ""
level = 1
title = 0
inputfile = ""

###########################################################################
# function definitions# usage
#
# print debug statements
# input: string
# output: string printed to standard out

def dprint(*vals):
	global debug
	if debug != 0: print vals

# usage
# print the simplest form of help
# input: none
# output: simple command usage is printed on the console
 
def showUsage():
   print
   print "Usage:"
   print "otlsplit.py [options] inputfile"
   print "Options"
   print "    -l level  The number of levels to split down to. The default is 1"
   print "    -D dir    Specifiy a target directory for the output files"
   print "    -t        Include a title line (the parerent heading) in split files"
   print "    -v        Print version (RCS) information."
   print "    -h        Show help."
   print "output is on STDOUT"
   print

# version
# print the RCS version information
# input: none
# output: RSC version information is printed on the console
 
def showVersion():
   print
   print "RCS"
   print " $Revision: 1.9 $"
   print " $Date: 2006/02/19 14:39:06 $"
   print " $Author: noel $"
   print

# getArgs
# Check for input arguments and set the necessary switches
# input: none
# output: possible console output for help, switch variables may be set

def getArgs():
  global debug, level, inputfile, title, subdir
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
        elif (sys.argv[i] == "-l"):		# test for the level flag
	  level = int(sys.argv[i+1])		# get the level
	  i = i + 1				# increment the pointer
        elif (sys.argv[i] == "-D"):		# test for the subdir flag
	  subdir = sys.argv[i+1]		# get the subdir
	  i = i + 1				# increment the pointer
  	elif   (sys.argv[i] == "-t"): title = 1	# test for title flag
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
  return(n)					# return the count + 1 (for level)

# convertSensitiveChars
# get the level of the current line (count the number of tabs)
# input: line - a single line that may or may not have tabs at the beginning
# output: returns a string

def convertSensitiveChars(line):
  line = lstrip(rstrip(line))
  line = sub('\W','_',line)
  return(line)			

# makeFileName
# make a file name from the string array provided
# input: line - a single line that may or may not have tabs at the beginning
# output: returns a string

def makeFileName(nameParts):

  global debug, level, subdir

  filename = ""
  for i in range(level):
	  filename = filename + lstrip(rstrip(convertSensitiveChars(nameParts[i]))) + "-"
  filename = filename[:-1]+ ".otl"
  if subdir != "": filename = subdir + "/" + filename
  return(lower(filename))			

# processFile
# split an outline file
# input: file - the filehandle of the file we are splitting
# output: output files

def processFile(file):

  global debug, level, title

  nameparts = []
  for i in range(10):
	  nameparts.append("")

  outOpen = 0

  line = file.readline()			# read the outline title
  						# and discard it
  line = file.readline()			# read the first parent heading
  dprint(level)
  while (line !=""):
	  linelevel = getLineLevel(line)
	  if (linelevel < level):
		if outOpen == 1: 
			ofile.close()
			outOpen = 0
	  	nameparts[linelevel] = line
		dprint(level,linelevel,line)
	  else:
		  if outOpen == 0: 
			  ofile = open(makeFileName(nameparts),"w")
			  outOpen = 1
			  if title == 1:
				  dprint("title:",title)
				  ofile.write(nameparts[level-1])
		  ofile.write(line[level:])
	  line = file.readline()
	
# main
# split an outline
# input: args and input file
# output: output files

def main():
  global inputfile, debug
  getArgs()
  file = open(inputfile,"r")
  processFile(file)  
  file.close()

main()
