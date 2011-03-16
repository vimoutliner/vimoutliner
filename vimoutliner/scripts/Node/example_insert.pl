#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors

use Node;	# Use Node.pm tool

#####################################################################
# WARNING: This is a difficult exercise. Do not attempt this exercise
# until you have completed the prerequisites listed in the README.otl
# file.
#
# I suggest you approach this example starting with the main routine
# at the bottom of the file, and then drilling down into subroutines
# and callbacks. Understand the big picture before drilling down.
#
# This exercise demonstrates insertion of nodes, and much, much more.
# Insertion is accomplished by the insertFirstChild(), 
# insertSiblingBeforeYou(), insertSiblingAfterYou(), and
# insertLastChild() methods. The insertLastChild() method is not
# demonstrated.
#
# This exercise is VERY contrived. It is contrived to show techniques
# of building a node tree using insertions, and also how to switch
# two nodes. The switching of the two nodes is especially contrived,
# but I could think of no better way of demonstrating node moving.
#
# This exercise builds a tree that represents a date book type calendar.
# Level 0 is Calender, level 1 are the years, of which there is only 2004,
# Level 2 are the months, level 3 the days, and level 4 the hour long
# timeslots. There is no provision for weekends, nor after hours
# appointments. It is a demonstration only.
#
# Using an array of month names and an array of days per month, you build
# the month and day levels using a nested loop. The hour level is built
# using a Walker. Node names are things like "January" or 31 or
# "11:00-12:00". Node types are things like "Year", "Month", "Day" or
# "Hour". Node values are undefined unless an appointment is made, in 
# which case the value is the node text.
#
# A special Walker is used to mark any day, month or year entities
# if they contain appointments. Specifically, all appointments in that
# day, month or year are counted, and that number of stars are placed
# beside the day, month or year. This is implemented by using an
# return callback so that by the time the callback is called, all children
# have been calculated.
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

#=================================================================
# The cbMakeMarks() callback is called on return to a node from
# its children (return callback). It executes only on year, month 
# and day nodes. It iterates through all its immediate children,
# totalling up the "appointments" attribute and setting its
# own attribute to that total. Remember, because this is a
# callback triggered on return from children, it is guaranteed
# that all children have been counted, and that all those children
# have totalled their children, etc.
#
# In the case of a day node, instead of totalling the "appointments"
# attribute, it counts the number of hour nodes with defined values.
# A defined value on an hour node is an appointment.
#
# Last but not least, on non-zero counts, this callback sets the
# day, month or year node's value to a number of asterisks equal
# to the number of appointments in its subtree.
#
# Read this code carefully. Once you understand it, you'll have
# many insights to Node.pm.
#=================================================================
sub cbMakeMarks()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	#### PROCESS ONLY DAY, MONTH OR YEAR NODES
	unless		(
			$checker->getType() eq "Day" ||
			$checker->getType() eq "Month" ||
			$checker->getType() eq "Year"
			)
		{
		return;
		}

	my $count = 0;
	my $childNode = $checker->getFirstChild();
	while(defined($childNode))
		{
		if($checker->getType() eq "Day")
			{
			if(defined($childNode->getValue()))
				{
				$count++;
				}
			}
		else
			{
			if($childNode->hasAttribute("appointments"))
				{
				$count += $childNode->getAttribute("appointments");
				}
			}
		$childNode = $childNode->getNextSibling();
		}
	$checker->setAttribute("appointments", $count);
	if($count > 0)
		{
		my $string;
		for(my $n=0; $n < $count; $n++){$string .= '*';}
		$checker->setValue($string);
		}
	}

#=================================================================
# The cbInsertHours() callback operates ONLY on day nodes. When
# called from a day node, it inserts hourlong appointment slots
# starting at 8am and ending at 5pm. The code is pretty 
# straightforward.
#=================================================================
sub cbInsertHours()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node


	return unless $checker->getType() eq "Day"; # Insert hours under days only

	my $checker2;
	for(my $n=8; $n <= 16; $n++)
		{
		my $startHour = "$n:00";
		my $n2 = $n + 1;
		my $endHour = "$n2:00";
		my $node = Node->new("$startHour" . "-" . "$endHour", "Hour", undef);
		if($checker->hasFirstChild())
			{
			$checker2 = $checker2->insertSiblingAfterYou($node);
			}
		else
			{
			$checker2 = $checker->insertFirstChild($node);
			}
		}
	}

#=================================================================
# The cbPrintNode() callback prints the name of the node,
# and its value if a value is defined. It's very straighforward.
#=================================================================
sub cbPrintNode()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	#### DON'T PRINT LEVEL 0 (CALENDER)
	return if $level == 0;

	for(my $n=1; $n < $level; $n++) { print "\t";}

	print $checker->getName() if $checker->hasName();
	print ":   ";

	print $checker->getValue() if $checker->hasValue();
	print "\n";
	}


#=================================================================
# The cbPrintNodeDiagnosic() callback is not used, but provided
# for any necessary debugging.
#=================================================================
sub cbPrintNodeDiagnostic()
	{
	my($self, $checker, $level) = @_;
	unless (defined($checker)) {return -999;} # don't process undef node

	for(my $n=0; $n < $level; $n++) { print "\t";}

	print ">";
	print $checker->getName() if $checker->hasName();
	print " ::: ";

	print $checker->getType() if $checker->hasType();
	print " ::: ";

	print $checker->getValue() if $checker->hasValue();
	print "<\n";
	}

package Main;

###########################################################################
# The insertDays() subroutine handles insertion of days below all
# month nodes.
###########################################################################
sub makeAppointments($)
	{
	my $yearNode = shift;
	#### MARCH 22  AT 8AM
	my $monthNode = $yearNode->getFirstChild() ->		#January
			getNextSibling() ->			#February
			getNextSibling();			#March
	my $dayNode = $monthNode->getFirstChild();
	while($dayNode->getName() != 22)
		{
		$dayNode = $dayNode->getNextSibling();
		unless(defined($dayNode))
			{
			die "No March 22\n";
			}
		}
	my $hourNode = $dayNode->getFirstChild();
	$hourNode->setValue("Spring Cleaning");

	#### JUNE 22  AT 9AM
	#### WRONGLY LABELED AS FALL FESTIVAL
	#### INSTEAD OF SUMMER BREAK
	$monthNode = $monthNode->getNextSibling() ->		# April
			getNextSibling() ->			# May
			getNextSibling();			# June
	$dayNode = $monthNode->getFirstChild();
	while($dayNode->getName() != 22)
		{
		$dayNode = $dayNode->getNextSibling();
		unless(defined($dayNode))
			{
			die "No June 22\n";
			}
		}
	$hourNode = $dayNode->getFirstChild()->getNextSibling();
	$hourNode->setValue("Fall Festival");

	#### SEPTEMBER 22  AT 10AM
	#### WRONGLY LABELED AS FALL FESTIVAL
	#### INSTEAD OF SUMMER BREAK
	$monthNode = $monthNode->getNextSibling() ->		# July
			getNextSibling() ->			# August
			getNextSibling();			# September
	$dayNode = $monthNode->getFirstChild();
	while($dayNode->getName() != 22)
		{
		$dayNode = $dayNode->getNextSibling();
		unless(defined($dayNode))
			{
			die "No September 22\n";
			}
		}
	$hourNode = $dayNode -> getFirstChild() ->		#8-9
				getNextSibling() ->		# 9-10
				getNextSibling();		# 10-11
	$hourNode->setValue("Summer Break");

	#### DECEMBER 22 FROM 3PM TO 5PM (2 TIMESLOTS)
	#### HAPPY HOLIDAYS PARTY
	$monthNode = $monthNode->getNextSibling() ->		# October
			getNextSibling() ->			# November
			getNextSibling();			# December
	$dayNode = $monthNode->getFirstChild();
	while($dayNode->getName() != 22)
		{
		$dayNode = $dayNode->getNextSibling();
		unless(defined($dayNode))
			{
			die "No December 22\n";
			}
		}
	$hourNode = $dayNode->getFirstChild();
	while($hourNode->getName() ne "15:00-16:00")
		{
		$hourNode = $hourNode->getNextSibling();
		unless(defined($hourNode))
			{
			die "No 4pm slot\n";
			}
		}
	$hourNode->setValue("Happy Holidays Party");
	$hourNode = $hourNode->getNextSibling();
	$hourNode->setValue("Happy Holidays Party");

	#### DECEMBER 30 AT 9AM BUY PARTY SUPPLIES
	while($dayNode->getName() != 30)
		{
		$dayNode = $dayNode->getNextSibling();
		unless(defined($dayNode))
			{
			die "No December 30\n";
			}
		}
	$hourNode = $dayNode->getFirstChild()->getNextSibling();
	$hourNode->setValue("Buy Party Supplies");
	}

###########################################################################
# The insertMonthsAndDays() subroutine handles insertion of months
# below the year, and days below every month. It works by iterating through
# an array of months, and finding number of days in an array of month
# lengths. It does NOT use the Node.pm navigational system to find months.
# Use of the Node.pm navigational system for this purpose is demonstrated
# in the insertion of hours in all days.
#
# Note that we could have avoided using a nested loop by using a Walker
# and associated callback to install the days under every month. In such
# a case the array of month lengths would have been placed in the Callback
# object. However, for the sake of variety, we chose to use a nested loop
# to load the months and days.
###########################################################################
sub insertMonthsAndDays($)
	{
	my $yearNode = shift;
	my $checker = $yearNode;
	my $checker2;
	my @monthNames=("January", "February", "March", "April", "May",
		"June", "July", "August", "September", "October",
		"November", "December");
	my @monthLengths=(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	my $monthSS = 0;
	foreach my $monthName (@monthNames)
		{
		my $node = Node->new($monthName, "Month", undef);
		$node->setAttribute("days", $monthLengths[$monthSS]);
		if($yearNode->hasFirstChild())
			{
			$checker = $checker->insertSiblingAfterYou($node);
			}
		else
			{
			$checker = $yearNode->insertFirstChild($node);
			}
		for(my $n=1; $n <= $monthLengths[$monthSS]; $n++)
			{
			$node = Node->new($n, "Day", undef);
			if($checker->hasFirstChild())
				{
				$checker2 = $checker2->insertSiblingAfterYou($node);
				}
			else
				{
				$checker2 = $checker->insertFirstChild($node);
				}
			}
		$monthSS++;
		}
	}

###########################################################################
# This subroutine switches the June 22 9am appointment and the
# September 22 10am appointment. In each case, both the appointment
# text and the time needed switching.
#
# The sane way to accomplish this task would have been to modify
# the nodes in place. However, this subroutine was created solely to 
# demonstrate the movement of nodes, so that's what we did.
#
# Note that the fact that the two are at different times complicates the
# situation. It's not enough to just trade nodes -- the Sept 9am node
# must be placed after the existing June 10am node, which itself is after
# the erroneous June 9am node containing what should be September's 
# appointment. After such placement, the original June 9am node must
# have its name updated so that it is a 10am node. A similar process
# takes place for September. The original nodes are also deleted.
#
# Please follow the (convoluted and contrived) logic:
#   1. Store the June hour node in $juneNode
#   2. Store the September hour node in $septNode
#   3. After the existing June 10am, place a CLONE of the Sept appointment
#   4. Before the existing Sept 9am,  place a CLONE of the June appointment
#   5. Delete the original June appointment
#   6. Delete the original September appointment
#   7. On the original June 10am node, make it 9am
#   8. On the original September 9am node, make it 10am
###########################################################################
sub switchJuneAndSeptemberAppointments($)
	{
	my $yearNode = shift;

	#### FIND NODE FOR JUNE 22 9AM APPOINTMENT
	my $juneNode = $yearNode->getFirstChild();
	while(defined($juneNode))
		{
		last if $juneNode->getName() eq "June";
		$juneNode = $juneNode->getNextSibling();
		}
	die "Cannot find month of June\n" unless defined($juneNode);

	$juneNode = $juneNode->getFirstChild();
	while(defined($juneNode))
		{
		last if $juneNode->getName() eq "22";
		$juneNode = $juneNode->getNextSibling();
		}
	die "Cannot find June 22\n" unless defined($juneNode);

	$juneNode = $juneNode->getFirstChild();
	while(defined($juneNode))
		{
		last if $juneNode->getName() eq "9:00-10:00";
		$juneNode = $juneNode->getNextSibling();
		}
	die "Cannot find June 22 at 9am\n" unless defined($juneNode);

	#### FIND NODE FOR SEPTEMBER 22 10AM APPOINTMENT
	my $septNode = $yearNode->getFirstChild();
	while(defined($septNode))
		{
		last if $septNode->getName() eq "September";
		$septNode = $septNode->getNextSibling();
		}
	die "Cannot find month of September\n" unless defined($septNode);

	$septNode = $septNode->getFirstChild();
	while(defined($septNode))
		{
		last if $septNode->getName() eq "22";
		$septNode = $septNode->getNextSibling();
		}
	die "Cannot find September 22\n" unless defined($septNode);

	$septNode = $septNode->getFirstChild();
	while(defined($septNode))
		{
		last if $septNode->getName() eq "10:00-11:00";
		$septNode = $septNode->getNextSibling();
		}
	die "Cannot find September 22 at 9am\n" unless defined($septNode);

	#### SWITCH THE NODES
	my $newJune = $juneNode->getNextSibling()->insertSiblingAfterYou($septNode->clone());
	my $newSept = $septNode->getPrevSibling()->insertSiblingBeforeYou($juneNode->clone());
	$juneNode->deleteSelf();
	$septNode->deleteSelf();

	#### FIX NAMES OF SURROUNDING CLONES
	$newJune->getPrevSibling()->setName("9:00-10:00");
	$newSept->getNextSibling()->setName("10:00-11:00");

	return;
	}


###########################################################################
# In the main routine, you carry out or delegate the following tasks
# in order to create an appointment calendar:
#   1. Insert single level 0 and 1 nodes
#   2. Instantiate the Callbacks object
#   3. Insert all month and day nodes
#   4. Insert all hour nodes
#   5. Make appointments
#         erroneously switching the june 22 & Sept 22 appointments
#   6. Mark days, months and years containing appointments
#   7. Output the calendar
#   8. Switch back June22 and Sept22
#   9. Re mark days, months and years
#   10. Output a separator between bad and good calendars
#   11. Re output the calendar
#
###########################################################################
sub main()
	{
	#### INSERT SINGLE LEVEL 0 AND 1 NODES
	my $topNode=Node->new("Calender", "Calender", "Calender");
	my $yearNode=$topNode->insertFirstChild(Node->new("2004", "Year", undef));

	#### INSTANTIATE THE Callbacks OBJECT
	my $callbacks = Callbacks->new();

	#### INSERT MONTH AND DAY NODES
	insertMonthsAndDays($yearNode);

	#### INSERT THE HOURS USING A Walker
	my $walker = Walker->new
		(
		$topNode,
		[\&Callbacks::cbInsertHours, $callbacks]
		);
	$walker->walk();


	#### MAKE A FEW APPOINTMENTS
	#### ACCIDENTALLY SWITCHING SUMMER AND FALL
	makeAppointments($yearNode);

	#### MARK DAYS, MONTHS AND YEAR THAT HAVE APPOINTMENTS
	#### USING A WALKER WITH ONLY A RETURN CALLBACK
	$walker = Walker->new
		(
		$topNode,
		undef,
		[\&Callbacks::cbMakeMarks, $callbacks]
		);
	$walker->walk();

	#### WALK THE NODE TREE,
	#### OUTPUTTING THE CALENDER
	$walker = Walker->new
		(
		$topNode,				# start with this node
		[\&Callbacks::cbPrintNode, $callbacks]	# do this on entry to each node
		);
	$walker->walk();

	#### CORRECT THE MISTAKE
	#### SWITCH JUNE 22 AND SEPT 22
	switchJuneAndSeptemberAppointments($yearNode);

	#### RE-MARK DAYS, MONTHS AND YEAR THAT HAVE APPOINTMENTS
	#### USING A WALKER WITH ONLY A RETURN CALLBACK
	$walker = Walker->new
		(
		$topNode,
		undef,
		[\&Callbacks::cbMakeMarks, $callbacks]
		);
	$walker->walk();

	#### OUTPUT A SEPARATOR BETWEEN ORIGINAL AND CORRECTED CALENDARS
	for (my $n=0; $n<5; $n++)
		{
		print "######################################################\n";
		}

	#### RE-WALK THE NODE TREE,
	#### RE-OUTPUTTING THE CALENDER
	$walker = Walker->new
		(
		$topNode,				# start with this node
		[\&Callbacks::cbPrintNode, $callbacks]	# do this on entry to each node
		);
	$walker->walk();
	}

main();
