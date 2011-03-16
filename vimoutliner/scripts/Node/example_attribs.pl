#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

#####################################################################
# This exercise demonstrates the use of attributes for each node.
# Attributes are facts about an entity, rather than an entity itself.
# In real practice, many times attributes can be substituted for nodes
# and vice versa. However, an attribute CANNOT have children.
#
# This is the first exercise using multiple Walker objects. The first
# Walker object counts each node's children, and if the node has
# children, it creates an attribute named "children" for that node.
# The value of the attribute is the number of direct children for
# that node.
#
# Nodes are accessed two ways in the cbPrintNode() callback. The entire
# attribute hash is accessed with hasAttributes and getAttributes(), 
# while single named attributes are accessed with hasAttributes and
# getAttributes(). 
# 
# One more action that's demonstrated is the use of secondary navigation
# within a callback routine. For each node, the callback routine
# navigates to the first child and then each successive sibling of that
# child in order to count the direct children. This is a common
# algorithm with Node.pm. It might look inefficient, and you might be
# tempted to perform the count during the callback that prints the
# information. Don't do it. Multiple walkers help keep Node.pm 
# enabled programs easy to understand and modify. Because the 
# entire node tree is in memory, the double navigation isn't
# particularly slow.
#
# Real world programs make heavy use of multiple walkers. For instance,
# the EMDL to UMENU program (not packaged here) has over 10 walkers.
#
#####################################################################

use strict;	# prevent hard to find errors

use Node;	# Use Note.pm tool

package Callbacks;
sub new()
	{
	my($type) = $_[0];
	my($self) = {};
	bless($self, $type);
	$self->{'errors'} = 0;
	$self->{'warnings'} = 0;
	return($self);
	}

sub getErrors(){return $_[0]->{'errors'};}
sub getWarnings(){return $_[0]->{'warnings'};}

sub cbCountChildren()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;}
	
	my $childCount=0;
	if($checker->hasFirstChild())
		{
		$childCount++;
		my $checker2 = $checker->getFirstChild();
		while($checker2->hasNextSibling())
			{
			$childCount++;
			$checker2 = $checker2->getNextSibling();
			}
		$checker->setAttribute("children", $childCount);
		}
	}

sub cbPrintNode()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	for(my $n=0; $n < $level; $n++) {print "\t";}
	print "* ";
	print $checker->getValue();		# print the text of the node
	print "\n";

	for(my $n=0; $n <= $level; $n++) {print "\t";}
	print "(";

	my %attribs = {};
	%attribs = $checker->getAttributes() if $checker->hasAttributes();

	my @keys = keys(%attribs);
	foreach my $key (sort @keys)
		{
		print $key, "=", $attribs{$key}, "; ";
		}

	print ")\n";

	if($checker->hasAttribute("children"))
		{
		for(my $n=0; $n <= $level; $n++) {print "\t";}
		print "This node has ";
		print $checker->getAttribute("children");
		print " children.\n";
		}
	}

package Main;

sub main()
	{
	#### PARSE FROM FILE README.otl
	my $parser = OutlineParser->new();		# instantiate parser
	$parser->setCommentChar("#");			# ignore lines starting with #
	$parser->fromFile();				# get input from file
	my $topNode=$parser->parse("README.otl");

	#====================================================================
	# The preceding statement parses file README.otl into a node hierarchy
	# and assigns the top level node of that hierarchy to $topNode. When
	# you run the program you'll notice that the text in $topNode does
	# not appear in README.otl, but instead has value
	# "Inserted by OutlineParser".
	#
	# This is a feature, not a bug. In order to accommodate the typical
	# case of an outline having several top level items, and yet still
	# be able to represent the whole hierarchy as a single top node,
	# the OutlineParser object creates a new node with value
	# " Inserted by OutlineParser"
	# and places all the outline's top level items under that newly
	# created node.
	#
	# If the outline you're working on is guaranteed to have only
	# a single top level item, and if you want that to be the top
	# level node, you can simply do the following:
	#
	# $topNode=$topNode->getFirstChild();
	#====================================================================

	#### INSTANTIATE THE Callbacks OBJECT
	my $callbacks = Callbacks->new();

	#### WALK THE NODE TREE,
	#### OUTPUTTING LEVEL AND TEXT
	my $walker = Walker->new
		(
		$topNode,				
		[\&Callbacks::cbCountChildren, $callbacks]
		);
	$walker->walk();
	my $walker = Walker->new
		(
		$topNode,				
		[\&Callbacks::cbPrintNode, $callbacks]
		);
	$walker->walk();
	}

main();
