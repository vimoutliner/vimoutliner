usage="""
otl2latex.py

Translate a Vim Outliner file to a LaTeX document.


Usage:
    otl2latex.py -[abp] file.otl [file.tex]

    -a: Output to article class
    -b: Output to book class 
    -p: Output to Beamer (presentation) class (default)


Author: Serge Rey <sjsrey@gmail.com>
Version 0.1 (2007-01-21)
"""

import os,sys

class Line:
    """Class for markup lines"""
    def __init__(self, content):
        ntabs=content.count("\t")
        content=content.lstrip("\t")
        level = ntabs - content.count("\t")
        self.level=level
        self.content = content
        self.markup=0
        if content[0]=="|":
            self.markup=1

#3 lines added here
        self.bullet=0
        if len(content) > 2 and (content[2]=='*' or content[1]=='*'):
            self.bullet=1
        #print "%d: %s"%(self.bullet,content)

class Manager:
    """Abstract class for LaTeX document classes"""
    def __init__(self, content, fileOut):
        self.content=content
        self.fileOut=open(fileOut,'w')
        self.parse()
        self.fileOut.write(self.markup)
        self.fileOut.close()
    def parse(self):
        self.lines=[ Line(line) for line in self.content]
        preambleStart=0
        nl=len(self.lines)
        id=zip(range(nl),self.lines)
        level1=[i for i,line in id if line.level==0]
        preambleEnd=level1[1]
        preamble=self.lines[0:preambleEnd]
        self.level1=level1
        preambleMarkup=[]
        for line in preamble:
            if line.content.count("@"):
                tmp=line.content.split("@")[1]
                tmp=tmp.split()
                env=tmp[0]
                content=" ".join(tmp[1:])
                mu="\\%s{%s}"%(env,content)
                preambleMarkup.append(mu)
        self.preamble=preambleMarkup
        self.preambleLines=preamble
        self.documentLines=self.lines[preambleEnd:]





class Beamer(Manager):
    """Manager for Beamer document class"""
    def __init__(self, content,fileOut):
        self.top1="""
\documentclass[nototal,handout]{beamer}
\mode<presentation>
{
  \usetheme{Madrid}
  \setbeamercovered{transparent}
}

\usepackage{verbatim}
\usepackage{fancyvrb}
\usepackage[english]{babel}
\usepackage[latin1]{inputenc}
\usepackage{times}
\usepackage{tikz}
\usepackage[T1]{fontenc}
\usepackage{graphicx} %sjr added
\graphicspath{{figures/}}
\usepackage{hyperref}"""
        self.top2="""
% Delete this, if you do not want the table of contents to pop up at
% the beginning of each subsection:
\AtBeginSubsection[]
{
  \\begin{frame}<beamer>
    \\frametitle{Outline}
    \\tableofcontents[currentsection,currentsubsection]
  \end{frame}
}


% If you wish to uncover everything in a step-wise fashion, uncomment
% the following command:
\\beamerdefaultoverlayspecification{<+->}
\\begin{document}
\\begin{frame}
  \\titlepage
\end{frame}
\\begin{frame}
  \\frametitle{Outline}
  \\tableofcontents[pausesections]
  % You might wish to add the option [pausesections]
\end{frame}
"""
        self.bulletLevel = 0
        Manager.__init__(self, content, fileOut)

    def itemize(self,line):
        nstars=line.content.count("*")
        content=line.content.lstrip("|").lstrip().lstrip("*")
        self.currentBLevel = nstars - content.count("*")
        stuff=[]
        if self.currentBLevel == self.bulletLevel and line.bullet:
            mu='\\item '+line.content.lstrip("|").lstrip().lstrip("*")
        elif line.bullet and self.currentBLevel > self.bulletLevel:
            self.bulletLevel += 1
            stuff.append("\\begin{itemize}\n")
            mu='\\item '+line.content.lstrip("|").lstrip().lstrip("*")
        elif self.currentBLevel < self.bulletLevel and line.bullet:
            self.bulletLevel -= 1
            stuff.append("\\end{itemize}\n")
            mu='\\item '+line.content.lstrip("|").lstrip().lstrip("*")
        elif self.currentBLevel < self.bulletLevel:
            self.bulletLevel -= 1
            stuff.append("\\end{itemize}\n")
            mu=line.content.lstrip("|")
        else:
            panic()
        return stuff,mu

    def parse(self):
        Manager.parse(self)
        #print self.content
        #print self.lines
        #print self.level1
        #for info in self.preamble:
        #    print info

        # do my own preamble
        field=("author ","instituteShort ","dateShort ","date ","subtitle ",
            "title ", "institute ", "titleShort ")
        pattern=["@"+token for token in field]
        f=zip(field,pattern)
        d={}
        for field,pattern in f:
            t=[line.content for line in self.preambleLines if line.content.count(pattern)]
            if t:
                d[field]= t[0].split(pattern)[1].strip()
            else:
                d[field]=""
        preamble="\n\n\\author{%s}\n"%d['author ']
        preamble+="\\institute[%s]{%s}\n"%(d['instituteShort '],d['institute '])
        preamble+="\\title[%s]{%s}\n"%(d['titleShort '],d['title '])
        preamble+="\\subtitle{%s}\n"%(d['subtitle '])
        preamble+="\\date[%s]{%s}\n"%(d['dateShort '],d['date '])

        print self.preamble
        self.preamble=preamble


        body=[]
        prev=0
        frameOpen=0
        blockOpen=0
        frameCount=0
        blockCount=0

        for line in self.documentLines:
            if line.level==0:
                for i in range(0,self.bulletLevel):
                    self.bulletLevel -= 1
                    body.append("\\end{itemize}\n")
                if blockOpen:
                    body.append("\\end{block}")
                    blockOpen=0
                if frameOpen:
                    body.append("\\end{frame}")
                    frameOpen=0
                mu="\n\n\n\\section{%s}"%line.content.strip()
            elif line.level==1:
                for i in range(0,self.bulletLevel):
                    self.bulletLevel -= 1
                    body.append("\\end{itemize}\n")
                if blockOpen:
                    body.append("\\end{block}")
                    blockOpen=0
                if frameOpen:
                    body.append("\\end{frame}")
                    frameOpen=0
                mu="\n\n\\subsection{%s}"%line.content.strip()
            elif line.level==2:
                # check if this frame has blocks or is nonblocked
                if line.markup:
                    if line.bullet or self.bulletLevel:
                        stuff,mu=self.itemize(line)
                        if len(stuff) > 0:
                            for i in stuff:
                                body.append(i)
                    else:
                        mu=line.content.lstrip("|")
                else:
                    for i in range(0,self.bulletLevel):
                        self.bulletLevel -= 1
                        body.append("\\end{itemize}\n")
                    if blockOpen:
                        body.append("\\end{block}")
                        blockOpen=0
                    if frameOpen:
                        body.append("\\end{frame}")
                    else:
                        frameOpen=1
                    # check for verbatim here
                    tmp=line.content.strip()
                    if tmp.count("@vb"):
                        tmp=tmp.split("@")[0]
                        mu="\n\n\\begin{frame}[containsverbatim]\n\t\\frametitle{%s}\n"%tmp
                    else:
                        mu="\n\n\\begin{frame}\n\t\\frametitle{%s}\n"%tmp
                    frameCount+=1
            elif line.level==3:
                # check if it is a block or body content
                if line.markup:
                    if line.bullet or self.bulletLevel:
                        stuff,mu=self.itemize(line)
                        if len(stuff) > 0:
                            for i in stuff:
                                body.append(i)
                    else:
                        mu=line.content.lstrip("\t")
                        mu=mu.lstrip("|")
                else:
                    for i in range(0,self.bulletLevel):
                        self.bulletLevel -= 1
                        body.append("\\end{itemize}\n")
                    #block title
                    if blockOpen:
                        body.append("\\end{block}")
                    else:
                        blockOpen=1
                    mu="\n\\begin{block}{%s}\n"%line.content.strip()
                    blockCount+=1
            else:
                mu=""
            body.append(mu)
        for i in range(0,self.bulletLevel):
            self.bulletLevel -= 1
            body.append("\\end{itemize}\n")
        if blockOpen:
            body.append("\\end{block}")
        if frameOpen:
            body.append("\\end{frame}")

        self.body=" ".join(body)
        self.markup=self.top1+self.preamble+self.top2
        self.markup+=self.body
        self.markup+="\n\\end{document}\n"
        print self.markup

# Process command line arguments
args = sys.argv
nargs=len(args)
dispatch={}
dispatch['beamer']=Beamer
inputFileName=None
outputFileName=None

def printUsage():
    print usage
    sys.exit()

if nargs==1:
    printUsage()
else:
    docType='beamer'
    options=args[1]
    if options.count("-"):
        if options.count("a"):
            docType='article'
        elif options.count("b"):
            docType='book'
        if nargs==2:
            printUsage()
        elif nargs==3:
            inputFileName=args[2]
        elif nargs==4:
            inputFileName=args[2]
            outputFileName=args[3]
        else:
            printUsage()
    elif nargs==2:
        inputFileName=args[1]
    elif nargs==3:
        inputFileName=args[1]
        outputFileName=args[3]
    else:
        printUsage()
    # Dispatch to correct document class manager
    fin=open(inputFileName,'r')
    content=fin.readlines()
    fin.close()
    dispatch[docType](content,outputFileName)
