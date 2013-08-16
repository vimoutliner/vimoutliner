#!/usr/bin/python
# otl2table.py
# convert a tab-formatted outline from VIM to tab-delimited table
#
# Copyright (c) 2004 Noel Henson All rights reserved
#
# ALPHA VERSION!!!
# $Revision: 1.2 $
# $Date: 2005/09/25 14:24:28 $
# $Author: noel $
# $Source: /home/noel/active/otl2table/RCS/otl2table.py,v $
# $Locker:  $

###########################################################################
# Basic function
#
#	This program accepts text outline files and converts them
#	the tab-delimited text tables.
#	This:
#		Test
#			Dog
#				Barks
#				Howls
#			Cat
#				Meows
#				Yowls
#	Becomes this:
#		Test	Dog	Barks
#		Test	Dog	Howls
#		Test	Cat	Meows
#		Test	Cat	Yowls
#
#	This will make searching for groups of data and report generation easier.
#


###########################################################################
# include whatever mdules we need

import sys
from string import *
#from time import *

###########################################################################
# global variables

level = 0
inputFile = ""
formatMode = "tab"
noTrailing = 0
columns = []

###########################################################################
# function definitions

# usage
# print the simplest form of help
# input: none
# output: simple command usage is printed on the console
 
def showUsage():
   print
   print "Usage:"
   print "otl2table.py [options] inputfile > outputfile"
   print "Options"
   print "    -n              Don't include trailing columns."
   print "    -t type        Specify field separator type."
   print "                   Types:"
   print "                      tab - separate fields with tabs (default)"
   print "                      csv - separate fields with ,"
   print "                      qcsv - separate fields with \",\""
   print "                      bullets - uses HTML tags <ul> and <li>"
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
   print " $Revision: 1.2 $"
   print " $Date: 2005/09/25 14:24:28 $"
   print " $Author: noel $"
   print " $Source: /home/noel/active/otl2table/RCS/otl2table.py,v $"
   print

# getArgs
# Check for input arguments and set the necessary switches
# input: none
# output: possible console output for help, switch variables may be set

def getArgs():
  global inputfile, debug, noTrailing, formatMode
  if (len(sys.argv) == 1): 
    showUsage()
    sys.exit()()
  else:
    for i in range(len(sys.argv)):
      if (i != 0):
        if   (sys.argv[i] == "-d"): debug = 1		# test for debug flag
        if   (sys.argv[i] == "-n"): noTrailing = 1	# test for noTrailing flag
        elif (sys.argv[i] == "-?"):			# test for help flag
	  showUsage()					# show the help
	  sys.exit()					# exit
        elif (sys.argv[i] == "--help"):
	  showUsage()
	  sys.exit()
        elif (sys.argv[i] == "-h"):
	  showUsage()
	  sys.exit()
        elif (sys.argv[i] == "-v"):
	  showVersion()
	  sys.exit()
        elif (sys.argv[i] == "-t"):		# test for the type flag
	  formatMode = sys.argv[i+1]		# get the type
	  i = i + 1				# increment the pointer
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
    
# closeLevels
# print the assembled line
# input: columns - an array of 10 lines (for 10 levels)
#        level - an integer between 1 and 9 that show the current level
# 	          (not to be confused with the level of the current line)
# 	 noTrailing - don't print trailing, empty columns
# output: through standard out

def closeLevels():
  global level,columns,noTrailing,formatMode
  if noTrailing == 1 :
	  colcount = level
  else:
	   colcount = 10
  if formatMode == "tab":
	  for i in range(1,colcount+1):
		  print columns[i] + "\t",
	  print
  elif formatMode == "csv":
	  output = ""
	  for i in range(1,colcount):
		  output = output + columns[i] + ","
	  output = output + columns[colcount]
	  print output
  elif formatMode == "qcsv":
	  output = "\""
	  for i in range(1,colcount):
		  output = output + columns[i] + "\",\""
	  output = output + columns[colcount] + "\""
	  print output
  for i in range(level+1,10):
	  columns[i] = ""


# processLine
# process a single line
# input: linein - a single line that may or may not have tabs at the beginning
#        format - a string indicating the mode to use for formatting
#        level - an integer between 1 and 9 that show the current level
# 	          (not to be confused with the level of the current line)
# output: through standard out

def processLine(linein):
  global level, noTrailing, columns
  if (lstrip(linein) == ""): return
  lineLevel = getLineLevel(linein)
  if (lineLevel > level):
	  columns[lineLevel] = lstrip(rstrip(linein))
	  level = lineLevel
  elif (lineLevel == level):
	  closeLevels()
	  columns[lineLevel] = lstrip(rstrip(linein))
  else:
	  closeLevels()
	  level = lineLevel
	  columns[lineLevel] = lstrip(rstrip(linein))
	  
      
def main():
  global columns
  getArgs()
  file = open(inputfile,"r")
  for i in range(11):
	  columns.append("")
  linein = lstrip(rstrip(file.readline()))
  while linein != "":
    processLine(linein)
    linein = file.readline()
  closeLevels()
  file.close()

main()
    
