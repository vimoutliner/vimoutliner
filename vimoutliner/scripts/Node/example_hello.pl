#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors
use Node;	

my $topNode = Node->new("myname", "mytype", "myvalue");
print "\n::: ";
print $topNode->getName(), " ::: ";
print $topNode->getType(), " ::: ";
print $topNode->getValue(), " :::\n";
