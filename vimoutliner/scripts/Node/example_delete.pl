#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors

use Node;	# Use Node.pm tool

#####################################################################
# This exercise demonstrates the deletion of nodes.
#
# Because Perl is a garbage collection language, node deletion
# DOES NOT deallocate memory and the like. However, in the absense
# of a copy of the node, it will be garbage collected and unavailable.
# Also, the deletion process specificly undef's the deleted node's
# first and last children.
#
# You noticed I mentioned keeping a copy. The algorithm of a Walker
# object moves a node around the tree like a checker. Calling
# $checker->deleteSelf() does not render $checker undefined. In fact,
# it still has its parent, nextSibling and previousSibling pointers
# intact. What this means is that the Walker's next iteration goes
# to exactly the same node as it would have if the deletion had not
# taken place. In other words, you do not need to "move the checker
# back one" after a deletion.
#
# This makes deletion algorithms very simple.
#
# There may come a time when you want to delete a node but keep its
# children. In that case, you must first attach its children to nodes
# that will not be deleted. 
#
#####################################################################

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

sub cbDelete()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	#### DELETE THIS NODE IF ITS VALUE CONTAINS deleteme
	my $text = "init";
	$text = $checker->getValue() if $checker->hasValue();
	if($text =~ m/deleteme/)
		{
		$checker->deleteSelf();
		}
	}

sub cbPrintNode()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;}

	for(my $n=0; $n < $level; $n++) {print "\t";}
	print $checker->getValue(), "\n";
	}

package Main;

sub main()
	{
	#### PARSE FROM FILE README.otl
	my $parser = OutlineParser->new();
	$parser->setCommentChar("#");
	$parser->fromFile();
	my $topNode=$parser->parse("deletetest.otl");

	#### INSTANTIATE THE Callbacks OBJECT
	my $callbacks = Callbacks->new();

	#### WALK THE NODE TREE,
	#### DELETING NODES WITH "deleteme" IN THEM
	my $walker = Walker->new
		(
		$topNode,
		[\&Callbacks::cbDelete, $callbacks]
		);
	$walker->walk();

	#### WALK THE NODE TREE,
	#### OUTPUTTING LEVEL AND TEXT
	$walker = Walker->new
		(
		$topNode,
		[\&Callbacks::cbPrintNode, $callbacks]
		);
	$walker->walk();
	}

main();
