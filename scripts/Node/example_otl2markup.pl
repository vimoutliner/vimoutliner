#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

#####################################################################
# This exercise demonstrates use of the return callback routine. The
# return callback routine occurs when node navigation returns to a 
# node from its children. Therefore, the return callback routine is
# never executed by nodes without children.
#
# An obvious use of the return callback routine is to print end tags
# for nested markup. A node's end tag must follow all markup for all
# the node's children, so the return callback is perfect for that
# purpose.
#
# Because childless nodes never execute the return callback routine, 
# in the case of childless nodes this program prints the end tags
# from the entry callback routine.
#
# This program prints the attributes of each Node object. You'll 
# immediately note that the "children" attributes you set are printed.
# But you'll also observe that a "_lineno" attribute has been set for
# all nodes except the top one. That attribute was set by the Parser
# object, and corresponds to the line in the parsed outline file. This
# attribute is extremely helpful in printing error messages.
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

##############################################################
# cbPrintTag is the entry callback, and is called on first
# entry to each node. It prints the start tag and text. If
# the node is a leaf level node, it also prints the end tag
# on the same line.
##############################################################
sub cbPrintTag()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;}
	
	#### PRINT START TAG AND CONTENT
	for(my $n = 0; $n < $level; $n++) {print "\t";}
	print "<node level=", $level, ">";
	print $checker->getValue() if $checker->hasValue();

	#### IF THIS IS A LEAF LEVEL ITEM, PRINT THE
	#### END TAG IMMEDIATELY. OTHERWISE, THE
	#### RETURN CALLBACK WILL TAKE CARE OF THE END TAG.
	unless($checker->hasFirstChild())
		{
		print "</node>";
		}

	#### PRINT NEWLINE
	print "\n";
	}

##############################################################
# cbPrintEndTag is the return callback, and is called on reentry
# to the node, after all its children have been processed.
# It is not called by leaf level (childless) nodes. The purpose
# of this routine is to print the end tag.
#
# For nodes with children, the end tag must be printed after
# all information for the node's children has been printed,
# in order to preserve proper nesting.
##############################################################
sub cbPrintEndTag()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;}
	
	#### PRINT END TAG FOR PARENT
	for(my $n = 0; $n < $level; $n++) {print "\t";}
	print "</node>";
	print "\n";
	}

package Main;

sub main()
	{
	#### PARSE FROM FILE README.otl
	my $parser = OutlineParser->new();
	$parser->setCommentChar("#");
	$parser->fromFile();	
	my $topNode=$parser->parse("README.otl");

	#### INSTANTIATE THE Callbacks OBJECT
	my $callbacks = Callbacks->new();

	#### WALK THE NODE TREE,
	#### OUTPUTTING LEVEL AND TEXT
	my $walker = Walker->new
		(
		$topNode,				# start with this node
		[\&Callbacks::cbPrintTag, $callbacks],	# do this on entry to each node
		[\&Callbacks::cbPrintEndTag, $callbacks]# do this on return from node's children
		);
	$walker->walk();
	}

main();
