# Some integer IDs
# headings are 1, 2, 3, ....
bodynowrap = -1 # ;
bodywrap = 0 # :

def level(line):
    '''return the heading level 1 for top level and down and 0 for body text'''
    if line.lstrip().find(':')==0: return bodywrap
    if line.lstrip().find(';')==0: return bodynowrap 
    strstart = line.lstrip() # find the start of text in lin
    x = line.find(strstart)  # find the text index in the line
    n = line.count("\t",0,x) # count the tabs
    return(n+1)              # return the count + 1 (for level)

def is_bodywrap(line):
    return level(line) == bodywrap

def is_bodynowrap(line):
    return level(line) == bodynowrap

def is_heading(line):
    return level(line) > 0

def is_body(line):
    return not is_heading(line)

