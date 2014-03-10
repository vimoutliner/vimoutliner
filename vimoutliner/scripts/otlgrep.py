#!/usr/bin/python2
# otlgrep.py
# grep an outline for a regex and return the branch with all the leaves.
#
# Copyright 2005 Noel Henson All rights reserved

###########################################################################
# Basic function
#
#    This program searches an outline file for a branch that contains
#    a line matching the regex argument. The parent headings (branches)
#    and the children (sub-branches and leaves) of the matching headings
#    are returned.
#
#    Examples
#
#    Using this outline:
#
#    Pets
#    Indoor
#        Cats
#            Sophia
#            Hillary
#        Rats
#            Finley
#            Oliver
#        Dogs
#            Kirby
#    Outdoor
#        Dogs
#            Kirby
#            Hoover
#        Goats
#            Primrose
#            Joey
#
#    a grep for Sophia returns:
#
#    Indoor
#        Cats
#            Sophia
#
#    a grep for Dogs returns:
#
#    Indoor
#        Dogs
#            Kirby
#            Hoover
#    Outdoor
#        Dogs
#            Kirby
#            Hoover
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
import re

###########################################################################
# global variables

debug = 0
ignorecase = 0
pattern = ""
inputfiles = []

###########################################################################
# function definitions# usage
#
# print debug statements
# input: string
# output: string printed to standard out


def dprint(*vals):
    global debug
    if debug != 0:
        print vals


# usage
# print the simplest form of help
# input: none
# output: simple command usage is printed on the console
def showUsage():
    print """
    Usage:
    otlgrep.py [options] pattern [file...]
    Options
        -i            Ignore case
        --help        Show help.
    [file...] is zero or more files to search. Wildcards are supported.
            if no file is specified, input is expected on stdin.
    output is on STDOUT
    """


# getArgs
# Check for input arguments and set the necessary switches
# input: none
# output: possible console output for help, switch variables may be set

def getArgs():
    global debug, pattern, inputfiles, ignorecase
    if (len(sys.argv) == 1):
        showUsage()
        sys.exit()()
    else:
        for i in range(len(sys.argv)):
            if (i != 0):
                if (sys.argv[i] == "-d"):
                    debug = 1  # test for debug flag
                elif (sys.argv[i] == "-i"):
                    ignorecase = 1    # test for debug flag
                elif (sys.argv[i] == "-?"):        # test for help flag
                    showUsage()                           # show the help
                    sys.exit()                            # exit
                elif (sys.argv[i] == "--help"):
                    showUsage()
                    sys.exit()
                elif (sys.argv[i][0] == "-"):
                    print "Error!  Unknown option.  Aborting"
                    sys.exit()
                else:       # get the input file name
                    if (pattern == ""):
                        pattern = sys.argv[i]
                    else:
                        inputfiles.append(sys.argv[i])


# getLineLevel
# get the level of the current line (count the number of tabs)
# input: linein - a single line that may or may not have tabs at the beginning
# output: returns a number 1 is the lowest
def getLineLevel(linein):
    strstart = linein.lstrip()           # find the start of text in line
    x = linein.find(strstart)            # find the text index in the line
    n = linein.count("\t", 0, x)         # count the tabs
    return(n)                    # return the count + 1 (for level)


# processFile
# split an outline file
# input: file - the filehandle of the file we are splitting
# output: output files
def processFile(file):
    global debug, pattern, ignorecase

    parents = []
    parentprinted = []
    for i in range(10):
        parents.append("")
        parentprinted.append(0)

    matchlevel = 0
    line = file.readline()      # read the outline title
                                # and discard it
    line = file.readline()      # read the first parent heading
    while (line != ""):
        level = getLineLevel(line)
        parents[level] = line
        parentprinted[level] = 0
        if (ignorecase == 1):
            linesearch = re.search(pattern, line.strip(), re.I)
        else:
            linesearch = re.search(pattern, line.strip())
        if (linesearch is not None):
            matchlevel = level
            for i in range(level):  # print my ancestors
                if (parentprinted[i] == 0):
                    print parents[i][:-1]
                    parentprinted[i] = 1
            print parents[level][:-1]  # print myself
            line = file.readline()
            while (line != "") and (getLineLevel(line) > matchlevel):
                print line[:-1]
                line = file.readline()
        else:
            line = file.readline()


# main
# split an outline
# input: args and input file
# output: output files

def main():
    global inputfiles, debug
    getArgs()
    if (len(inputfiles) == 0):
        processFile(sys.stdin)
    else:
        for i in range(len(inputfiles)):
            file = open(inputfiles[i], "r")
            processFile(file)
        file.close()

main()
