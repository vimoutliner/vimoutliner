#!/bin/bash
# otl2ooimpress.sh
# needs otl2ooimpress.py to work at all
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

# Path to otl2ooimpress.py
MYPATH=$HOME/bin
# Path to rm
RMPATH=/bin
# Path to zip
ZIPPATH=/usr/bin

$MYPATH/otl2ooimpress.py $1 > content.xml
$ZIPPATH/zip $1.sxi content.xml
$RMPATH/rm content.xml
