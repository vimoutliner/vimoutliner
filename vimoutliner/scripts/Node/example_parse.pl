#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors

use Node;	# Use Node.pm tool

#####################################################################
# This exercise demonstrates the most elemental use of Node.pm.
# It does nothing more than read README.otl into a Node tree, and
# then print the tree.
#
# Here's the high level logic:
# 	Set up a Callback object to house the callback routines
# 	Instantiate and configure a Parser object to parse README.otl
# 	Instantiate a Walker object to walk the resulting node tree
# 	Link Callbacks::cbPrintNode() as the Walker's entry callback
#
#####################################################################

##############################################################
# You need an object to house callback routines. The object can
# be named anything, but it should have facilities to count up
# errors and warnings. Its new() method should always be something
# like what you see below, and there should have getErrors() and
# getWarnings() methods.
#
# The cbPrintNode() method is typical of a simple callback routine.
# All callback routines have exactly three arguments, $self, 
# $checker and $level. $self refers to the object containing
# the callback routine, $checker is the node that called this
# callback routine, and $level is the level of that node in the
# hierarchy. Armed with these pieces of information, you can 
# perform almost any operation on the current node ($checker).
#
# The callback routines are called by the Parser object during
# parsing. A callback routine can be called upon first entry 
# into a node, or it can be called upon reentry into that node
# after processing all that node's children. The latter is
# an excellent way of outputting end tags at the proper time.
##############################################################
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

sub cbPrintNode()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node
	print $level, " ::: ";			# print the level
	print $checker->getValue();		# print the text of the node
	print "\n";
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
		$topNode,				# start with this node
		[\&Callbacks::cbPrintNode, $callbacks]	# do this on entry to each node
		);
	$walker->walk();
	}

main();
