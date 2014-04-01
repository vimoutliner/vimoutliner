#!/usr/bin/python2

'''
usage:
    freemind.py -o [fmt] <files>, where ofmt selects output format: {otl,mm}

freemind.py -o otl <files>:
    Read in an freemind XML .mm file and generate a outline file
    compatable with vim-outliner.
freemind.py -o mm <files>:
    Read in an otl file and generate an XML mind map viewable in freemind

NOTE:
    Make sure that you check that round trip on your file works.

Author: Julian Ryde
'''
import sys
import getopt
import codecs

import otl
import xml.etree.ElementTree as et
from xml.etree.ElementTree import XMLParser

debug = False


class Outline:                     # The target object of the parser
    depth = -1
    indent = '\t'
    current_tag = None

    def start(self, tag, attrib):  # Called for each opening tag.
        self.depth += 1
        self.current_tag = tag
        # print the indented heading
        if tag == 'node' and self.depth > 1:
            #if 'tab' in attrib['TEXT']:
                #import pdb; pdb.set_trace()
            print (self.depth - 2) * self.indent + attrib['TEXT']

    def end(self, tag):            # Called for each closing tag.
        self.depth -= 1
        self.current_tag = None

    def data(self, data):
        if self.current_tag == 'p':
            bodyline = data.rstrip('\r\n')
            bodyindent = (self.depth - 5) * self.indent + ": "
            #textlines = textwrap.wrap(bodytext, width=77-len(bodyindent),
            #   break_on_hyphens=False)
            #for line in textlines:
            print bodyindent + bodyline

    def close(self):    # Called when all data has been parsed.
        pass


def mm2otl(*arg, **kwarg):
    fname = arg[0][0]
    file = codecs.open(fname, 'r', encoding='utf-8')

    filelines = file.readlines()
    outline = Outline()
    parser = XMLParser(target=outline, encoding='utf-8')
    parser.feed(filelines[0].encode('utf-8'))
    parser.close()


# TODO body text with manual breaks
# TODO commandline arguments for depth, maxlength etc.
# TODO do not read whole file into memory?
# TODO handle decreasing indent by more than one tab
# TODO handle body text lines sometimes not ending with space

depth = 99


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
    bodynode = et.SubElement(htmlnode, 'body')
    for line in textlines:
        pnode = et.SubElement(bodynode, 'p')
        pnode.text = line


def otl2mm(*arg, **kwarg):
    fname = arg[0][0]

    # node ID should be based on the line number of line in the
    # otl file for easier debugging
    #for lineno, line in enumerate(open(fname)):
    # enumerate starts at 0 I want to start at 1
    # FIXME freemind.py|107| W806 local variable 'lineno' is assigned to but never used
    lineno = 0

    mapnode = et.Element('map')
    mapnode.set('version', '0.9.0')

    topnode = et.SubElement(mapnode, 'node')
    topnode.set('TEXT', fname)

    parents = [mapnode, topnode]

    #left_side = True # POSITION="right"

    # read otl file into memory
    filelines = codecs.open(fname, 'r', encoding='utf-8')

    # first handle the body texts turn it into a list of headings
    # with associated body text for each one this is because the
    # body text especially multi-line is what makes it awkward.
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
        if debug:
            print heading, bodytext

        level = otl.level(heading)
        oldlevel = otl.level(oldheading)

        if level == oldlevel:
            pass
        elif level > oldlevel:
            # about to go down in the hierarchy so add this line
            # as a parent to the stack
            # FIXME freemind.py|149| W802 undefined name 'node'
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


def usage():
    print "usage: %s -[mo] <files>" % (sys.argv[0])


def main():
    args = sys.argv
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'moh', [""])
    except getopt.GetoptError, err:
        usage()
        print str(err)
        sys.exit(2)

    for o, a in opts:
        if o == "-m":
            otl2mm(args)
        elif o == "-o":
            mm2otl(args)
        elif o == "-h":
            usage()
            sys.exit(0)
        else:
            usage()
            assert False, "unhandled option: %s" % o
    return args

if __name__ == "__main__":
    main()

# vim: set noet :
