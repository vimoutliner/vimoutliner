#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors

use Node;	# Use Node.pm tool

#####################################################################
# The Walker object walks the node hierarchy recursively. That is,
# it goes deep before going laterally. That's just what's needed for
# many applications. However, sometimes it's necessary to look at 
# one level at a time.
#
# There are many ways to accomplish this. Some involve sorting and
# merging. Many involve arrays of nodes on a given level, and
# plunging one deep into each one.
#
# In this example we'll start with a walker that assigns the full
# path to each node as an attribute of that node. We'll then loop
# through all levels starting with 0, and for each one we'll print all
# children of nodes at that level. Every time there's a parent change,
# we'll print a header for that parent.
#
# This example also illustrates the use of variables within the 
# Callback object. You might have wondered why callbacks must be
# part of an object rather than free floating functions. The answer
# is that the use of callbacks as object methods means that we can
# keep totals and break logic variables within the callback object,
# thereby eliminating the (nasty) necessity of global variables.
#
# We cannot simply pass variables into and out of callback
# routines because, by the very nature of a callback routine,
# its arguments and return type are strictly predefined. In the
# case of Node.pm the arguments are always $self, $checker and 
# $level. To get any other information into or out of the callback
# routine, we must use a non-callback method of the same object.
#
# It should be noted that there's nothing wrong with having
# multiple callback objects. If there are numerous callback 
# routines it might make sense to group them by functionality,
# or by totals and persistent variables they must keep track of.
# 
# As you run, study and understand this code, be aware that converting
# a hierarchy to a list by levels is a very difficult and complex task.
# Imagine keeping a list of children, and for each level using those
# children to find the next generation, and rewriting the array. Or
# prepending a level number followed by a child index on each line, 
# and then sorting the whole array by the level number and child
# index, and finally running a routine to output the formatted 
# output, complete with break logic and headers.
#
# Now consider how easy Node.pm made this job. First, a trivial
# Walker to calculate full paths, then a level loop calling a
# Walker to print only children of nodes at the desired level. The
# code is short, and it's very readable and understandable. The 
# callback routines are short enough that you can safely use non-
# structured techniques such as returning from the middle instead
# of using nested if statements. The result is even more readability.
#
# One could make the (very valid) point that nodes are visited many
# times to process each once, and that this is not efficient in
# terms of runtime performance. Absolutely true!
#
# However, the programming simplicity prevents truly collosal
# efficency problems, such as cascading intermediate files, sorts,
# and the various other CPU cycle grabbers that seem to crop up
# in complex algorithms. And remember, the entire tree is in memory,
# with navigation via simple pointers, so the environment of Node.pm
# favors runtime speed.
#
# Case in point. My original EMDL to UMENU converter was such an
# epic production that I needed to study it for 4 hours every time
# I made a minor improvement. I had developed it using informal OOP
# and structured techniques, and had paid close attention to
# efficiency. The resulting program took 15 seconds to convert a
# 2300 line EMDL file.
#
# I rewrote the converter using Node.pm. This was a complete
# rewrite -- all new code -- no salvage. It was so much simpler
# that I wrote it in 12 hours. But I was very concerned with
# runtime. If the 15 seconds doubled, this would be a hassle,
# and if it quadrupled it would be totally impractical. When 
# I ran it, the program did everything the original did, but
# did it in 2 seconds. Node.pm had given me a 7 fold speed 
# increase.
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
	$self->{'childrenatlevel'} = 0;
	$self->{'currentlevel'} = 0;
	$self->{'previousparentfullpath'} = "initialize";
	return($self);
	}

sub getErrors(){return $_[0]->{'errors'};}
sub getWarnings(){return $_[0]->{'warnings'};}

sub getChildrenAtLevel(){return $_[0]->{'childrenatlevel'};}
sub setChildrenAtLevel(){$_[0]->{'childrenatlevel'} = $_[1];}
sub incChildrenAtLevel(){$_[0]->{'childrenatlevel'}++;}

sub getCurrentLevel(){return $_[0]->{'currentlevel'};}
sub setCurrentLevel(){$_[0]->{'currentlevel'} = $_[1];}

sub cbCalculateFullPath()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	if($checker->hasParent)
		{
		my $fullpath = $checker->getParent()->getAttribute("fullpath");
		$fullpath .= "/";
		$fullpath .= $checker->getValue();
		$checker->setAttribute("fullpath", $fullpath);
		}
	else
		{
		$checker->setAttribute("fullpath", $checker->getValue());
		}
	}

sub cbPrintNode()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	#### DO NOTHING UNLESS THIS NODE IS AT THE CURRENTLY SOUGHT LEVEL
	return unless $level == $self->getCurrentLevel();

	#### DO NOTHING UNLESS THIS NODE HAS CHILDREN
	return unless $checker->hasFirstChild();

	#### PRINT HEADER
	print "\n", $checker->getAttribute("fullpath"), "\n";
	
	#### PRINT CHILDREN AND COUNT CHILDREN AT LEVEL
	my $checker2 = $checker->getFirstChild(); # We returned if there wasn't one
	print "\t", $checker2->getValue(), "\n";
	$self->incChildrenAtLevel();

	while($checker2->hasNextSibling())
		{
		$checker2 = $checker2->getNextSibling();
		print "\t", $checker2->getValue(), "\n";
		$self->incChildrenAtLevel();
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


	#### INSTANTIATE THE Callbacks OBJECT
	my $callbacks = Callbacks->new();

	#### WALK THE NODE TREE,
	#### CALCULATING FULL PATHS AND PUTTING THEM IN AN ATTRIBUTE
	my $walker = Walker->new
		(
		$topNode,				# start with this node
		[\&Callbacks::cbCalculateFullPath, $callbacks]	# do this on entry to each node
		);
	$walker->walk();

	#### PRINT LEVEL 0
	print "\n\n********** BEGIN LEVEL ", "0", "\n";
	print "\t", $topNode->getValue(), "\n";

	#### SET STARTING PARENT LEVEL,
	#### AND SET $childCount SO THE LOOP WILL FIRE THE FIRST TIME
	my $level=0;
	my $childCount=9999;

	#==================================================================
	# The main loop follows, level by level. At each level, nodes are
	# queried for their children, which are then printed below the
	# node's full path. The result is a list of nodes sorted by
	# level.
	#
	# We add 1 to the level in the level header because we're referring
	# to the level of the children, not of the current node. We keep 
	# looping to deeper levels until a level counts no children.
	#
	# This logic result in an empty level header at the bottom. If this
	# were a big concern, we could print the level headers in the
	# Callbacks::cbPrintNode() callback, with slightly altered logic.
	# However, it's a minor point, so for simplicity we print the
	# level header at the top of this loop in the main routine.
	#==================================================================
	while($childCount > 0)
		{
		print "\n\n********** BEGIN LEVEL ", $level + 1, "\n";
		$callbacks->setChildrenAtLevel(0);
		$callbacks->setCurrentLevel($level);
		my $walker = Walker->new
			(
			$topNode,
			[\&Callbacks::cbPrintNode, $callbacks]
			);
		$walker->walk();
		$childCount = $callbacks->getChildrenAtLevel();
		$level++;
		}
	}

main();
