#!/usr/bin/env python2
import argparse
import locale
import logging
import os
import re
import sys
import textwrap
import time

logging.basicConfig(format='%(levelname)s:%(funcName)s:%(message)s',
                    stream=sys.stdout, level=logging.INFO)
log = logging.getLogger('otl2html')

outline = []
flatoutline = []

def print_syntax():
    print(textwrap.dedent(
        '''Syntax
        Syntax is Vim Outliner's normal syntax. The following are supported:

            Text
        :    Body text marker. This text will wrap in the output.
        ;    Preformmated text. This text will will not wrap.

            Tables
        ||    Table header line.
        |    Table and table columns. Example:
                || Name | Age | Animal |
                | Kirby | 9 | Dog |
                | Sparky | 1 | Bird |
                | Sophia | 8 | Cat |
                This will cause an item to be left-justified.
                    | whatever  |
                This will cause an item to be right-justified.
                    |  whatever |
                This will cause an item to be centered.
                    |  whatever  |
                This will cause an item to be default aligned.
                    | whatever |

            Character Styles
        **    Bold. Example: **Bold Text**
        //    Italic. Example: //Italic Text//
        +++    Highlight. Example: +++Highlight Text+++
        ---    Strikeout. Example: ---Strikeout Text---
        Insane    ---+++//**Wow! This is insane!**//+++---
            Just remember to keep it all on one line.
            Horizontal Rule
        ----------------------------------------  (40 dashes).
            Copyright
        (c) or (C)    Converts to a standard copyright symbol.

            Including Images (for web pages)
        [imagename]    Examples:
                [logo.gif] [photo.jpg] [car.png]
                [http://i.a.cnn.net/cnn/.element/img/1.1/logo/logl.gif]
                or from a database:
                [http://www.lab.com/php/image.php?id=4]

            Including links (for web pages)
        [link text-or-image]    Examples:
                [about.html About] [http://www.cnn.com CNN]
                or with an image:
                [http://www.ted.com [http://www.ted.com/logo.png]]
                Links starting with a '+' will be opened in a new
                window. Eg. [+about.html About]

            Including external files
        !filename!    Examples:
                !file.txt!

            Including external outlines (first line is parent)
        !!filename!!    Examples:
                !!menu.otl!!

            Including output from executing external programs
        !!!program args!!!    Examples:
                !!!date +%Y%m%d!!!

            Note:
        When using -D, the top-level headings become divisions (<div>)
        and will be created using a class of the heading name. Spaces
        are not allowed. If a top-level heading begins with '_', it
        will not be shown but the division name will be the same as
        without the '_'. Example: _Menu will have a division name of
        Menu and will not be shown.
        ''')
         )


def getArgs():
    parser = argparse.ArgumentParser(
        description=textwrap.dedent(
            '''Convert a tab-formatted outline from VIM to HTML

            Copyright 2001 Noel Henson All rights reserved

            This program accepts text outline files and converts them
            to HTML.  The outline levels are indicated by tabs. A line with no
            tabs is assumed to be part of the highest outline level.

            10 outline levels are supported.  These loosely correspond to the
            HTML H1 through H9 tags.  Alphabetic, numeric and bullet formats
            are also supported.
            '''
        )
    )
    parser.add_argument('inputFile', nargs=argparse.REMAINDER,
                        help='Input OTL outline filename.')
    parser.add_argument('-d', '--debug', action='store_true',
                        help='Show debugging report.')
    parser.add_argument('-p', '--slides', action='store_true',
                        help='Presentation: ' +
                        'slide show output for use with HtmlSlides.')
    parser.add_argument('-D', '--silentDiv', action='store_true',
                        help='First-level is divisions (<div> </div>)' +
                        'for making pretty web pages')
    parser.add_argument('-T', '--showTitle', action='store_false',
                        help='The first line is not the title. ' +
                        'Treat it as outline data')
    parser.add_argument('-c', '--hideComments', action='store_true',
                        help='comments (line with [ as the first ' +
                        'non-whitespace character. Ending with ] is optional.')
    parser.add_argument('-C', '--copyright', action='store',
                        help='Override the internal copyright notice with ' +
                        'the one supplied in the quoted string following ' +
                        'this flag. Single or double quotes can be used.')
    parser.add_argument('-s', '--inlineStyle', action='store',
                        default='indent',
                        help='Use the specified style sheet with a link. ' +
                        'This is the default.')
    parser.add_argument('-S', '--styleSheet', action='store',
                        help='Include the specified style sheet in-line ' +
                        ' the output. For encapsulated style.')
    parser.add_argument('-l', '--level', action='store', default=0,
                        help='level')
    parser.add_argument('-B', '--inBody',
                        choices=['no', 'text', 'preformatted', 'table'],
                        default='no',
                        help='Divisions.')
    parser.add_argument('-H', '--syntax', action='store_true', help='Syntax')

    args = parser.parse_args()
    log.debug('args = %s', args)

    if args.syntax:
        print_syntax()
        sys.exit(0)
    elif len(args.inputFile) == 0:
        raise argparse.ArgumentTypeError('too few arguments')
    else:
        args.inputFile = args.inputFile[0]

    if args.styleSheet or args.inlineStyle:
        args.formatMode = 'indent'

    args.inBodyText = {
        'no': 0, 'text': 1, 'preformatted': 2, 'table': 3}[args.inBody]
    return args

# getLineLevel
# get the level of the current line (count the number of tabs)
# input: linein - a single line that may or may not have tabs at the beginning
# output: returns a number 1 is the lowest
def getLineLevel(linein):
    strstart = linein.lstrip()      # find the start of text in line
    x = linein.find(strstart)       # find the text index in the line
    n = linein.count("\t", 0, x)    # count the tabs
    return n + 1                    # return the count + 1 (for level)


# getLineTextLevel
# get the level of the current line (count the number of tabs)
# input: linein - a single line that may or may not have tabs at the
#        beginning
# output: returns a number 1 is the lowest
def getLineTextLevel(linein):
    strstart = linein.lstrip()         # find the start of text in line
    x = linein.find(strstart)        # find the text index in the line
    n = linein.count("\t", 0, x)     # count the tabs
    n = n + linein.count(" ", 0, x)  # count the spaces
    return n + 1                     # return the count + 1 (for level)


# colonStrip(line)
# stip a leading ':', if it exists
# input: line
# output: returns a string with a stipped ':'
def colonStrip(line):
    if line[0] == ":":
        return line[1:].lstrip()
    else:
        return line


# semicolonStrip(line)
# stip a leading ';', if it exists
# input: line
# output: returns a string with a stipped ';'
def semicolonStrip(line):
    if line[0] == ";":
        return line[1:]
    else:
        return line


# dashStrip(line)
# stip a leading '-', if it exists
# input: line
# output: returns a string with a stipped '-'
def dashStrip(line):
    if line[0] == "-":
        return line[1:]
    else:
        return line


# pipeStrip(line)
# stip a leading '|', if it exists
# input: line
# output: returns a string with a stipped '|'
def pipeStrip(line):
    if line[0] == "|":
        return line[1:]
    else:
        return line


# plusStrip(line)
# stip a leading '+', if it exists
# input: line
# output: returns a string with a stipped '+'
def plusStrip(line):
    if line[0] == "+":
        return line[1:]
    else:
        return line


# handleBodyText
# print body text lines with a class indicating level, if style sheets
# are being used. otherwise print just <p>
# input: linein - a single line that may or may not have tabs at the beginning
# output: through standard out
def handleBodyText(linein, lineLevel, conf):
    if conf.inBodyText == 2:
        print "</pre>"
    if conf.inBodyText == 3:
        print "</table>"
    print "<p",
    if conf.styleSheet != "":
        print " class=\"P" + str(lineLevel) + "\"",
        conf.inBodyText = 1
    print ">" + colonStrip(linein.strip()),


# handlePreformattedText
# print preformatted text lines with a class indicating level, if style sheets
# are being used. otherwise print just <pre>
# input: linein - a single line that may or may not have tabs at the beginning
# output: through standard out
def handlePreformattedText(linein, lineLevel, config):
    if config.inBodyText == 1:
        print "</p>"
    if config.inBodyText == 3:
        print "</table>"
    print "<pre",
    if config.styleSheet != "":
        print " class=\"PRE" + str(lineLevel) + "\"",
        config.inBodyText = 2
    print ">" + semicolonStrip(linein.strip()),


# isAlignRight
# return flag
# input: coldata, a string
def isAlignRight(coldata):
    l = len(coldata)
    if coldata[0:2] == "  " and coldata[l - 2:l] != "  ":
        return 1
    else:
        return 0


# isAlignLeft
# return flag
# input: coldata, a string
def isAlignLeft(coldata):
    l = len(coldata)
    if coldata[0:2] != "  " and coldata[l - 2:l] == "  ":
        return 1
    else:
        return 0


# isAlignCenter
# return flag
# input: coldata, a string
def isAlignCenter(coldata):
    l = len(coldata)
    if coldata[0:2] == "  " and coldata[l - 2:l] == "  ":
        return 1
    else:
        return 0


# getColumnAlignment(string)
# return string
# input: coldata
# output:
#   <td align="left"> or <td align="right"> or <td align="center"> or <td>
def getColumnAlignment(coldata):
    if isAlignCenter(coldata):
        return '<td align="center">'
    if isAlignRight(coldata):
        return '<td align="right">'
    if isAlignLeft(coldata):
        return '<td align="left">'
    return '<td>'


# handleTableColumns
# return the souce for a row's columns
# input: linein - a single line that may or may not have tabs at the beginning
# output: string with the columns' source
def handleTableColumns(linein):
    out = ""
    coldata = linein.strip()
    coldata = coldata.split("|")
    for i in range(1, len(coldata) - 1):
        out += getColumnAlignment(coldata[i])
        out += coldata[i].strip() + '</td>'
    return out


# handleTableHeaders
# return the souce for a row's headers
# input: linein - a single line that may or may not have tabs at the beginning
# output: string with the columns' source
def handleTableHeaders(linein):
    out = ""
    coldata = linein.strip()
    coldata = coldata.split("|")
    for i in range(2, len(coldata) - 1):
        out += getColumnAlignment(coldata[i])
        out += coldata[i].strip() + '</td>'
    out = out.replace('<td', '<th')
    out = out.replace('</td', '</th')
    return out


# handleTableRow
# print a table row
# input: linein - a single line that may or may not have tabs at the beginning
# output: out
def handleTableRow(linein, lineLevel):
    out = "<tr>"
    if lineLevel == (linein.find("|| ") + 1):
        out += handleTableHeaders(linein)
    else:
        out += handleTableColumns(linein)
    out += "</tr>"
    return out


# handleTable
# print a table, starting with a <TABLE> tag if necessary
# input: linein - a single line that may or may not have tabs at the beginning
# output: through standard out
def handleTable(linein, lineLevel, config):
    if config.inBodyText == 1:
        print "</p>"
    if config.inBodyText == 2:
        print "</pre>"
    if config.inBodyText != 3:
        print "<table class=\"TAB" + str(lineLevel) + "\">"
        config.inBodyText = 3
    print handleTableRow(linein, lineLevel),


# linkOrImage
# if there is a link to an image or another page, process it
# input: line
# output: modified line
def linkOrImage(line):
    line = re.sub(r'\[(\S+?)\]', r'<img src="\1" alt="\1">', line)
    line = re.sub(r'\[(\S+)\s(.*?)\]', r'<a href="\1">\2</a>', line)
    line = re.sub(r'(<a href=")\+(.*)">', r'\1\2" target=_new>', line)
    line = line.replace('<img src="X" alt="X">', '[X]')
    line = line.replace('<img src="_" alt="_">', '[_]')
    return line


# tabs
# return a string with 'count' tabs
# input: count
# output: string of tabs
def tabs(count):
    out = ""
    if count == 0:
        return ""
    out += "\t" * (count - 1)
    return out


# includeFile
# include the specified file, if it exists
# input: line and lineLevel
# output: line is replaced by the contents of the file
def includeFile(line, lineLevel, config):
    filename = re.sub(r'!(\S+?)!', r'\1', line.strip())
    incfile = open(filename, "r")
    linein = incfile.readline()
    while linein != "":
        linein = re.sub('^', tabs(lineLevel), linein)
        processLine(linein, config)
        linein = incfile.readline()
    incfile.close()
    return


# includeOutline
# include the specified file, if it exists
# input: line and lineLevel
# output: line is replaced by the contents of the file
def includeOutline(line, lineLevel, config):
    filename = re.sub(r'!!(\S+?)!!', r'\1', line.strip())
    incfile = open(filename, "r")
    linein = incfile.readline()
    linein = re.sub('^', tabs(lineLevel), linein)
    processLine(linein, config)
    linein = incfile.readline()
    while linein != "":
        linein = re.sub('^', tabs(lineLevel + 1), linein)
        processLine(linein, config)
        linein = incfile.readline()
    incfile.close()
    return


# execProgram
# execute the specified program
# input: line
# output: program specified is replaced by program output
def execProgram(line, config):
    program = re.sub('.*!!!(.*)!!!.*', r'\1', line.strip())
    child = os.popen(program)
    out = child.read()
    err = child.close()
    out = re.sub('!!!(.*)!!!', out, line)
    processLine(out, config)
    if err:
        raise RuntimeError('%s failed w/ exit code %d' % (program, err))
    return


# divName
# create a name for a division
# input: line
# output: division name
def divName(line, conf):
    line = line.strip()
    if line[0] == '_':
        conf.silentDiv = 1
        line = line[1:]
    line = line.replace(' ', '_')
    return'<div class="' + line + '">'


# getTitleText(line)
# extract some meaningful text to make the document title from the line
# input: line
# output: modified line
def getTitleText(line):
    out = re.sub(r'.*#(.*)#.*', r'\1', line)
    out = re.sub(r'<.*>', '', out)
#  if (out != ""): out = re.sub('\"(.*?)\"', '\\1', line)
    return out


# stripTitleText(line)
# strip the title text if it is enclosed in double-quotes
# input: line
# output: modified line
def stripTitleText(line):
    return re.sub(r'#\W*.*#', '', line)


# beautifyLine(line)
# do some optional, simple beautification of the text in a line
# input: line
# output: modified line
def beautifyLine(line):
    if line.strip() == ("-" * 40):
        return "<br><hr><br>"

    out = line
    line = ""

    while line != out:
        line = out
        # out = replace(out, '---', '<strike>', 1)
        if line[0].lstrip() != ";":
            out = re.sub(r'---(.*?)---', r'<strike>\1</strike>', out)
        out = linkOrImage(out)
        # out = replace(out, '**', '<strong>', 1)
        out = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', out)
        # out = replace(out, '//', '<i>', 1)
        out = re.sub(r'//(.*?)//', r'<i>\1</i>', out)
        # out = replace(out, '+++', '<code>', 1)
        out = re.sub(r'\+\+\+(.*?)\+\+\+', r'<code>\1</code>', out)
        out = re.sub(r'\(c\)', '&copy;', out, flags=re.IGNORECASE)
    return out


# closeLevels
# generate the number of </ul> or </ol> tags necessary to proplerly finish
# input: format - a string indicating the mode to use for formatting
#        level - an integer between 1 and 9 that show the current level
#               (not to be confused with the level of the current line)
# output: through standard out
def closeLevels(config):
    while config.level > 0:
        if config.formatMode == "bullets":
            print "</ul>"
        if config.formatMode in ["alpha", "numeric", "roman", "indent"]:
            print "</ol>"

        config.level -= 1


# processLine
# process a single line
# input: linein - a single line that may or may not have tabs at the beginning
#        format - a string indicating the mode to use for formatting
#        level - an integer between 1 and 9 that show the current level
#               (not to be confused with the level of the current line)
# output: through standard out
def processLine(linein, conf):
    if linein.lstrip() == "":
        return
    linein = beautifyLine(linein)
    lineLevel = getLineLevel(linein)
    if not conf.hideComments or lineLevel != (linein.find("[") + 1):

        if lineLevel > conf.level:  # increasing depth
            while lineLevel > conf.level:
                if conf.formatMode in ["indent", "simple"]:
                    if conf.inBodyText == 1:
                        print"</p>"
                        conf.inBodyText = 0
                    elif conf.inBodyText == 2:
                        print"</pre>"
                        conf.inBodyText = 0
                    elif conf.inBodyText == 3:
                        print"</table>"
                        conf.inBodyText = 0
                    if not (conf.silentDiv and lineLevel == 1):
                        print "<ol>"
                else:
                    sys.exit("Error! Unknown formatMode type")
                conf.level += 1

        elif lineLevel < conf.level:  # decreasing depth
            while lineLevel < conf.level:
                if conf.inBodyText == 1:
                    print"</p>"
                    conf.inBodyText = 0
                elif conf.inBodyText == 2:
                    print"</pre>"
                    conf.inBodyText = 0
                elif conf.inBodyText == 3:
                    print"</table>"
                    conf.inBodyText = 0
                print "</ol>"
                conf.level = conf.level - 1
                if conf.silentDiv and conf.level == 1:
                    if not conf.silentDiv:
                        print'</ol>'
                    else:
                        conf.silentDiv = False
                    print'</div>'

        else:
            print  # same depth
        if conf.silentDiv and lineLevel == 1:
            if lineLevel != (linein.find("!") + 1):
                print divName(linein, conf)
                if conf.silentDiv == 0:
                    print "<ol>"

        if conf.slides == 0:
            if (lineLevel == linein.find(" ") + 1) or \
                    (lineLevel == linein.find(":") + 1):
                if conf.inBodyText != 1:
                    handleBodyText(linein, lineLevel, conf)
                elif colonStrip(linein.strip()) == "":
                    print "</p>"
                    handleBodyText(linein, lineLevel, conf)
                else:
                    print colonStrip(linein.strip()),
            elif lineLevel == (linein.find(";") + 1):
                if conf.inBodyText != 2:
                    handlePreformattedText(linein, lineLevel, conf)
                elif semicolonStrip(linein.strip()) == "":
                    print "</pre>"
                    handlePreformattedText(linein, lineLevel, conf)
                else:
                    print semicolonStrip(linein.strip()),
            elif lineLevel == (linein.find("|") + 1):
                if conf.inBodyText != 3:
                    handleTable(linein, lineLevel, conf)
                elif pipeStrip(linein.strip()) == "":
                    print "</table>"
                    handleTable(linein, lineLevel, conf)
                else:
                    print handleTableRow(linein, lineLevel),
            elif lineLevel == (linein.find("!!!") + 1):
                execProgram(linein, conf)
            elif lineLevel == (linein.find("!!") + 1):
                includeOutline(linein, lineLevel, conf)
            elif lineLevel == (linein.find("!") + 1):
                includeFile(linein, lineLevel, conf)
            else:
                if conf.inBodyText == 1:
                    print"</p>"
                    conf.inBodyText = 0
                elif conf.inBodyText == 2:
                    print"</pre>"
                    conf.inBodyText = 0
                elif conf.inBodyText == 3:
                    print"</table>"
                    conf.inBodyText = 0
                if conf.silentDiv == 0:
                    print "<li",
                    if conf.styleSheet != "":
                        if lineLevel == (linein.find("- ") + 1):
                            print " class=\"LB" + str(lineLevel) + "\"",
                            print ">" + \
                                  dashStrip(linein.strip()),
                        elif lineLevel == (linein.find("+ ") + 1):
                            print " class=\"LN" + str(lineLevel) + "\"",
                            print ">" + plusStrip(linein.strip()),
                        else:
                            print ' class="L' + str(lineLevel) + '"',
                            print ">" + linein.strip(),
                else:
                    conf.silentDiv = 0
        else:
            if lineLevel == 1:
                if linein[0] == " ":
                    if conf.inBodyText == 0:
                        handleBodyText(linein, lineLevel, conf)
                    else:
                        print linein.strip(),
                else:
                    print "<address>"
                    print linein.strip(),
                    print "</address>\n"
            else:
                if (lineLevel == linein.find(" ") + 1) or \
                        (lineLevel == linein.find(":") + 1):
                    if conf.inBodyText == 0:
                        handleBodyText(linein, lineLevel, conf)
                    else:
                        print linein.strip(),
                else:
                    if conf.inBodyText == 1:
                        print"</p>"
                        conf.inBodyText = 0
                    print "<li",
                    if conf.styleSheet != "":
                        print " class=\"LI.L" + str(lineLevel) + "\"",
                    print ">" + linein.strip(),


# flatten
# Flatten a subsection of an outline.  The index passed is the
# outline section title.  All sublevels that are only one level
# deeper are indcluded in the current subsection.  Then there is
# a recursion for those items listed in the subsection.  Exits
# when the next line to be processed is of the same or lower
# outline level.  (lower means shallower)
# input: idx - the index into the outline.  The indexed line is the title.
# output: adds reformatted lines to flatoutline[]
def flatten(idx):
    if outline[idx] == "":
        return
    if len(outline) <= idx:
        return
    titleline = outline[idx]
    titlelevel = getLineLevel(titleline)
    if getLineLevel(outline[idx + 1]) > titlelevel:
        if titleline[titlelevel - 1] != " ":
            flatoutline.append(titleline.lstrip())
        exitflag = 0
        while exitflag == 0:
            if idx < (len(outline) - 1):
                idx = idx + 1
                currlevel = getLineLevel(outline[idx])
                if currlevel == titlelevel + 1:
                    if currlevel == outline[idx].find(" ") + 1:
                        flatoutline.append("\t " + outline[idx].lstrip())
                    else:
                        flatoutline.append("\t" + outline[idx].lstrip())
                elif currlevel <= titlelevel:
                    exitflag = 1
            else:
                exitflag = 1
    return


def createCSS(config):
    output = """    /* copyright notice and filename */
    body {
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
    }
        /* title at the top of the page */
    H1 {
            font-family: helvetica, arial, sans-serif;
            font-size: 14pt;
            font-weight: bold;
            text-align: center;
            color: black;
        background-color: #ddddee;
        padding-top: 20px;
        padding-bottom: 20px;
    }
    H2 {
            font-family: helvetica, arial, sans-serif;
            font-size: 12pt;
            font-weight: bold;
            text-align: left;
            color: black;
    }
    H3 {
            font-family: helvetica, arial, sans-serif;
            font-size: 12pt;
            text-align: left;
            color: black;
    }
    H4 {
            font-family: helvetica, arial, sans-serif;
            font-size: 12pt;
            text-align: left;
            color: black;
    }
    H5 {
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
            text-align: left;
            color: black;
    }
        /* outline level spacing */
    OL {
            margin-left: 1.0em;
            padding-left: 0;
            padding-bottom: 8pt;
    }
        /* global heading settings */
    LI {
            font-family: helvetica, arial, sans-serif;
            color: black;
            font-weight: normal;
            list-style: lower-alpha;
        padding-top: 4px;
    }
        /* level 1 heading overrides */
    LI.L1 {
            font-size: 12pt;
            font-weight: bold;
            list-style: none;
    }
        /* level 2 heading overrides */
    LI.L2 {
            font-size: 10pt;
            font-weight: bold;
            list-style: none;
    }
        /* level 3 heading overrides */
    LI.L3 {
            font-size: 10pt;
            list-style: none;
    }
        /* level 4 heading overrides */
    LI.L4 {
            font-size: 10pt;
            list-style: none;
    }
        /* level 5 heading overrides */
    LI.L5 {
            font-size: 10pt;
            list-style: none;
    }
        /* level 6 heading overrides */
    LI.L6 {
            font-size: 10pt;
            list-style: none;
    }
        /* level 7 heading overrides */
    LI.L7 {
            font-size: 10pt;
            list-style: none;
    }
        /* level 1 bullet heading overrides */
    LI.LB1 {
            font-size: 12pt;
            font-weight: bold;
            list-style: disc;
    }
        /* level 2 bullet heading overrides */
    LI.LB2 {
            font-size: 10pt;
            font-weight: bold;
            list-style: disc;
    }
        /* level 3 bullet heading overrides */
    LI.LB3 {
            font-size: 10pt;
            list-style: disc;
    }
        /* level 4 bullet heading overrides */
    LI.LB4 {
            font-size: 10pt;
            list-style: disc;
    }
        /* level 5 bullet heading overrides */
    LI.LB5 {
            font-size: 10pt;
            list-style: disc;
    }
        /* level 6 bullet heading overrides */
    LI.LB6 {
            font-size: 10pt;
            list-style: disc;
    }
        /* level 7 bullet heading overrides */
    LI.LB7 {
            font-size: 10pt;
            list-style: disc;
    }
        /* level 1 numeric heading overrides */
    LI.LN1 {
            font-size: 12pt;
            font-weight: bold;
            list-style: decimal;
    }
        /* level 2 numeric heading overrides */
    LI.LN2 {
            font-size: 10pt;
            font-weight: bold;
            list-style: decimal;
    }
        /* level 3 numeric heading overrides */
    LI.LN3 {
            font-size: 10pt;
            list-style: decimal;
    }
        /* level 4 numeric heading overrides */
    LI.LN4 {
            font-size: 10pt;
            list-style: decimal;
    }
        /* level 5 numeric heading overrides */
    LI.LN5 {
            font-size: 10pt;
            list-style: decimal;
    }
        /* level 6 numeric heading overrides */
    LI.LN6 {
            font-size: 10pt;
            list-style: decimal;
    }
        /* level 7 numeric heading overrides */
    LI.LN7 {
            font-size: 10pt;
            list-style: decimal;
    }
               /* body text */
    P {
            font-family: helvetica, arial, sans-serif;
            font-size: 9pt;
            font-weight: normal;
            color: darkgreen;
    }
        /* preformatted text */
    PRE {
            font-family: fixed, monospace;
            font-size: 9pt;
            font-weight: normal;
            color: darkblue;
    }

    TABLE {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 12pt;
            font-weight: normal;
        border-collapse: collapse;
    }

    TH {
        border: 1px solid black;
        padding: 0.5em;
        background-color: #eeddee;
    }

    TD {
        border: 1px solid black;
        padding: 0.5em;
        background-color: #ddeeee;
    }

    CODE {
        background-color: yellow;
    }

    TABLE.TAB1 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 12pt;
            font-weight: normal;
        border-collapse: collapse;
    }
    TABLE.TAB2 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 11pt;
            font-weight: normal;
        border-collapse: collapse;
    }
    TABLE.TAB3 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
            font-weight: normal;
        border-collapse: collapse;
    }
    TABLE.TAB4 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
            font-weight: normal;
        border-collapse: collapse;
    }
    TABLE.TAB5 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
            font-weight: normal;
        border-collapse: collapse;
    }
    TABLE.TAB6 {
        margin-top: 1em;
            font-family: helvetica, arial, sans-serif;
            font-size: 10pt;
            font-weight: normal;
        border-collapse: collapse;
    """
    with open(config.styleSheet, "w") as css_file:
        css_file.write(output)


def printHeader(linein, config):
    out_string = """<!DOCTYPE HTML>
        <html>
    <head>
        <meta charset="%s">
        <title>%s</title>
    """ % (
        locale.getpreferredencoding(),
        getTitleText(linein))
    try:
        css_file = open(config.styleSheet, "r")
    except IOError:
        createCSS(config)
        css_file = open(config.styleSheet, "r")
    if config.styleSheet != "" and not config.inlineStyle:
        out_string += '<link href="%s" rel="stylesheet" type="text/css">' \
            % (config.styleSheet)
    if config.styleSheet != "" and config.inlineStyle:
        out_string += '<style type="text/css">'
        out_string += css_file.read()
        out_string += "</style>\n</head>"
    print out_string + "\n<body>"
    css_file.close()


def printFirstLine(linein):
    print '''<div class="DocTitle">
    <h1>%s</h1>
    </div>
    <div class="MainPage">''' % stripTitleText(linein.strip())


def printFooter(config):
    print "</div>"
    if not config.slides and not config.silentDiv:
        print "<div class=\"Footer\">"
        print "<hr>"
        print config.copyright
        print "<br>"
        print config.inputFile + "&nbsp;&nbsp; " + \
            time.strftime("%Y/%m/%d %H:%M", time.localtime(time.time()))
        print "</div>"
    print "</body></html>"


def main():
    locale.setlocale(locale.LC_ALL, '')
    conf = getArgs()
    with open(conf.inputFile, "r") as in_file:
        if conf.slides:
            firstLine = beautifyLine(in_file.readline().strip())
            printHeader(firstLine, conf)
            if conf.showTitle:
                printFirstLine(firstLine)
                linein = beautifyLine(in_file.readline().strip())
            else:
                linein = firstLine
            while linein != "":
                processLine(linein, conf)
                linein = in_file.readline()
            closeLevels(conf)
        else:
            linein = beautifyLine(in_file.readline().strip())
            outline.append(linein)
            linein = in_file.readline().strip()
            while linein != "":
                outline.append("\t" + linein)
                linein = in_file.readline().rstrip()
            for i in range(0, len(outline) - 1):
                flatten(i)
            printHeader(flatoutline[0], conf)
            for i in range(0, len(flatoutline)):
                processLine(flatoutline[i], conf)

        printFooter(conf)


if __name__ == "__main__":
    main()
