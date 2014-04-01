#!/usr/bin/python2
'''Read in an otl file and generate an xml mind map viewable in freemind

Make sure that you check that round trip on your file works.

Author: Julian Ryde
'''

import sys
import os
import xml.etree.ElementTree as et
import otl
import codecs

fname = sys.argv[1]
max_length = 40
depth = 99

debug = False

# TODO body text with manual breaks
# TODO commandline arguments for depth, maxlength etc.
# TODO do not read whole file into memory?
# TODO handle decreasing indent by more than one tab 
# TODO handle body text lines sometimes not ending with space

otlfile = open(fname)
indent = '  '

def attach_note(node, textlines):
    et.ElementTree
    # Format should look like
    #<richcontent TYPE="NOTE">
    #<html>
    #  <head> </head>
    #  <body>
    #  %s
    #  </body>
    #</html>
    #</richcontent>
    notenode = et.SubElement(node, 'richcontent')
    notenode.set('TYPE', 'NOTE')
    htmlnode = et.SubElement(notenode, 'html')
    headnode = et.SubElement(htmlnode, 'head')
    bodynode = et.SubElement(htmlnode, 'body')
    for line in textlines:
        pnode = et.SubElement(bodynode, 'p')
        pnode.text = line

# node ID should be based on the line number of line in the otl file for easier 
# debugging
#for lineno, line in enumerate(open(fname)): 
# enumerate starts at 0 I want to start at 1
lineno = 0

mapnode = et.Element('map')
mapnode.set('version', '0.9.0')

topnode = et.SubElement(mapnode, 'node')
topnode.set('TEXT', fname)

parents = [mapnode, topnode]

#left_side = True # POSITION="right"

# read otl file into memory
filelines = codecs.open(fname, 'r', encoding='utf-8')

# remove those that are too deep or body text and pesky end of line characters
#filelines = [line.rstrip('\r\n') for line in filelines if otl.level(line) <= depth]
#filelines = [line for line in filelines if otl.is_heading(line)]

# first handle the body texts turn it into a list of headings with associated 
# body text for each one this is because the body text especially multi-line is 
# what makes it awkward.
headings = []
bodytexts = []
for line in filelines:
    if otl.is_heading(line):
        headings.append(line)
        bodytexts.append([])
    else:
        # TODO this ': ' removal should go in otl.py?
        bodytexts[-1].append(line.lstrip()[2:] + '\n')

#import pdb; pdb.set_trace()
oldheading = ''
for heading, bodytext in zip(headings, bodytexts):
    if debug: print heading, bodytext

    level = otl.level(heading)
    oldlevel = otl.level(oldheading)

    if level == oldlevel:
        pass
    elif level > oldlevel:
        # about to go down in the hierarchy so add this line as a parent to the 
        # stack
        parents.append(node)
    elif level < oldlevel:
        # about to go up in the hierarchy so remove parents from the stack
        leveldiff = oldlevel - level
        parents = parents[:-leveldiff]

    node = et.SubElement(parents[-1], 'node')
    node.set('TEXT', heading.lstrip().rstrip('\r\n'))
    #if len(bodytext) > 0:
    attach_note(node, bodytext)

    oldheading = heading

xmltree = et.ElementTree(mapnode)
xmltree.write(sys.stdout, 'utf-8')
print
