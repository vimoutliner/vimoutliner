# *Title: otl2aft 
# *Author: Todd Coram (http://maplefish.com/todd)
# *TOC
#
#		~Version 1.3~
#
# 		~This source is hereby placed into the Public Domain.~
#		~What you do with it is your own business.~
#		~Just please do no harm.~
#
#------------------------------------------------------------------------
#
# * Introduction
#
# Otl2aft converts VimOutliner files into 
# [AFT (http://www.maplefish.com/todd/aft.html)] documents. This file
# can be run with nawk, mawk or gawk.
#
# This tool was created upon the request/inspiration of David J Patrick 
#(of http://linuxcaffe.ca fame).
#
# You can downloaded the most up to date
# source [here (http://www.maplefish.com/todd/otl2aft.awk)]. 
# A PDF version of this file resides
# [here (http://www.maplefish.com/todd/otl2aft.pdf)].
#
# AEY: Changed all # symbols within regular expressions to \043
# to avoid problems with # being the comment character.
#
# * Code
#
# In the beginning we want to print out the AFT title and author.
# We expect the otl file to contain two top level headlines. The first
# will be used as the title and the second as the author.
#
# We also print out some control bits and a table of contents placeholder.
#
BEGIN { 
  VERSION="v1.3 9/04/2009";
  # AEY: Note first line is now for OTL use only; we ignore it here.
  getline;			# expect title
  print "#---SET-CONTROL tableparser=new"
  # AEY: Commented out following lines, since this info is now metadata.
  #print "*Title: " $0;
  #getline;			# expect author
  #print "*Author: " $0;
  #print "\n*TOC\n"
}

# AEY: > now starts an inline comment. We ignore these.
/^[\t]+>/ {
  next;
}

# AEY: < is now used for metadata. We only act on certain ones.
#/^[\t]+<[ \t]*title:[ \t]*/ {
/^[\t]+</ {
  # "Munch" off the first part, which we don't care about
  #sub(/^[\t]+<[ \t]*/,"");
  # If there's no colon, there won't be a tag, so we don't care.
  spec = rightpart($0,"<");
  if (match(spec,/:/)) {
    key = leftpart(spec,":");
    value = rightpart(spec,":");
        
    if (key == "title") {
      print "*Title: " value;
    } else if (key == "author") {
      print "*Author: " value;
    } else if (key == "aft") {
      print value;  # "aft:" is an all-purpose "aft"-code insertion tag
    }
  } else {
    if (spec == "toc") {
      print "*TOC";
    }
  }
  next;
  
}

# AEY: Any other metadata line starting with < is currently ignored.
#/^[\t]+</ {
#  next;
#}

# AEY: Stop processing after ---END--- line
#/^---END---/ {
/^\043--- END ---/ {
  exit;
}

# AEY: If we find a VIM Outliner checkbox, get rid of it
/\[[_X]\][ ]/ {
  gsub(/\[[_X]\][ ]/, "");
}

# Scan for  one or more tabs followed by a colon (:). This is the outliner's
# markup for ''body text (wrapping)''.
# If we are not nested inside a list (subheaders), then [reset] before doing
# any work. This makes sure we properly terminatel tables and other modes.
#
# Our work here involves simply killing tabs and removing the colon. 
# We then continue reading the rest of the file.
#
/^[\t]+:/ {
  if (!list_level) reset();
  gsub(/\t/,"");
  sub(/[ ]*:/, "");
  # AEY: Need to handle bulleted and numbered lists too,
  # but not here. From our point of view, ": * " is now verboten.
  #sub(/^[\t ]*\*/,"\t*");
  #sub(/^[\t ]*\043\./,"\t#.");
  # End changes
  print $0; next;
}

# AEY: Support for our own style of bulleted and numbered lists (experimental).
/^[\t]+(\*|\043[\.\)])/ {
  if (!list_level) reset();
  gsub(/\t/,"");
  if (list_level || $0 ~ /[ ]*(\*|\043[\.\)])/) {
    handlelist();
  }
  print $0; next;
}
# AEY: * now handled like heading, but must add extra space to avoid confusing Aft
#/^[\t]+\*/ {
#  gsub("*"," *");
#  # Continue on and handle as normal
#}

# Scan for ''user defined text block (wrapping)''. If we get this, we
# kill the tabs, remove the |>| and if we discover a crosshatch |#|, we
# start a list. If we are already in a list, we continue the list. Both
# starting and continuing is handled by [handlelist].
#
# AEY: Removed this
#/^[\t]+>/ {
#  if (!list_level) reset();
#  gsub(/\t/,"");
#  sub(/>/, "");
#
#  if (list_level || $0 ~ /[ ]*[\043*]/) {
#    handlelist();
#  }
#  print $0; next;
#}

# Scan for |;| or |<| which indicate ''preformatted body text'' and 
# ''user-defined preformatted text block'' respectively. Both of these
# are non wrapping but we ignore that (for now). We handle lists just like
# the previous scan action.
#
# AEY: Removed < handling
/^[\t]+;/ {		# Handle ";" and "<" (preformated text)
  if (!list_level) reset();
  gsub(/\t/,"");
  sub(/;/, "");

  if (list_level || $0 ~ /[ ]*\043/) {   # Convert "< #" into numbered lists.
    handlelist();
  }
  print $0; next;
}

# Scan for a table.  This is tricky. We want to cast the Outliner table
# into the AFT ''new table'' format.  AFT tables (especially as rendered
# by LaTeX) really want to have captions/headers. We fake that for now
# by using a |-| place holder. This should be fixed!
#
/^[\t]+\|/ {
  if (!in_table) reset();
  in_table = 1
  gsub(/\t/,"");
  if ($1 ~ /\|\|/) {
    print "\t!   _      !";
    print "\t!----------!"
  } 
  gsub(/\|\|/,"!");
  gsub(/\|/,"!");
  print "\t"$0
  print "\t!----------!"
  next;
}

# The default scan matches anything not matching the above scan. We simply
# go through and set the known indent level based on the number of tabs
# seen.
#
{ match($0,/^[\t]+/); indent = RLENGTH; if (indent == -1) indent = 0; }

# Given the iden level set by the default scan (above), we now determine
# what type of AFT output to do. 
#
# Indent levels lower than 7 are represented directly
# using AFT sections.
#
# AEY: Added $0 = "*"$0; back in to ensure top-level headings remain headings!
# (This existed in earlier versions, but not in version 1.3.)
#indent < 7 { gsub(/\t/,"*"); print "";}
indent < 7 { gsub(/\t/,"*"); $0 = "*"$0; print "";}

# Indent levels greater than 6 are represented by AFT bullet lists.
# This is done by first killing some tabs (we don't want to start off
# nesting too deeply), and using the remaining tabs to adjust to the 
# appropriate list nesting level.
#
indent > 6 { 
  gsub(/\t\t\t/, ""); 
  match($0,/^[\t]+/);
  remtabs = substr($0,RSTART,RLENGTH);
  text = substr($0,RSTART+RLENGTH);
  $0 = remtabs"* "text;
  print "";
}

# After adjusting indentation, just print out the line.
#
{ print $0 }

# **handlelist
#  Look at the indentation and produce lists accordingly.
#
function handlelist() {
  if (!list_level) {
    list_indent = length(indent) + 1;
  }
  list_level = list_indent - length(indent);

  if ($0 ~ /[ ]*\043/) {    # Convert " #" into numbered lists.
    for (i=0; i < list_level; i++) 
      printf("\t");
    gsub(/[ ]*\\043/,"#.");
  } else if ($0 ~ /[ ]*\*/) { # Convert " *" into bullet lists.
    for (i=0; i < list_level; i++) 
      printf("\t");
    gsub(/[ ]*\*/,"*");
  } else if (list_level) {
    for (i=0; i < list_level; i++) 
      printf("\t");
  }
}

# **reset
# Reset various parameters to get us out of various modes.
#
function reset() {
  if (list_level) {
    print "  ";
    list_level = 0;
  }
  if (in_table) {
    print "\t!----------!\n"
    in_table = 0;
  }
}

# AEY: "Trim" function, added for sanity's sake.
function trim(str) {
  sub(/^[ \t]*/,"",str);
  sub(/[ \t]*$/,"",str);
  return str;
}

# AEY: Get everything to left of specified regex, and trim it too.
function leftpart(str,regex) {
  if (match(str,regex)) {
    return trim(substr(str,1,RSTART-1));
  } else {
    return "";
  }
}

# AEY: Get everything to right of specified regex, and trim it too.
function rightpart(str,regex) {
  if (match(str,regex)) {
    return trim(substr(str,RSTART+RLENGTH));
  } else {
    return "";
  }
}

# That's all folks!
