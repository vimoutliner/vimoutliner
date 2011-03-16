#!/usr/bin/perl -w

#######################################################################
# Copyright (C) 2003 by Steve Litt, all rights reserved.
# Licensed under version 1 of the 
#    Litt Perl Development Tools License
# See COPYING file
# Or COPYING.LPDTL.1.0
# Or see http://www.troubleshooters.com/licenses/LPDTL/COPYING.LPDTL.1.0
#
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK!
#
# Version 0.2.0 released 5/13/2004

use strict;

package Node;
sub new($$$$)
	{
	my($typeOfClass) = $_[0];
	my($self) = {};
	bless($self, $typeOfClass);

	$self->{'name'}=$_[1];
	$self->{'type'}=$_[2];
	$self->{'value'}=$_[3];


	$self->{'nextsibling'}=undef;
	$self->{'prevsibling'}=undef;
	$self->{'parent'}=undef;
	$self->{'firstchild'}=undef;
	$self->{'lastchild'}=undef;

	$self->{'attributes'}={};

	return($self);
	}


#### For single attribute
sub setAttribute()
	{
	$_[0]->{'attributes'}->{$_[1]} = $_[2];
	}

sub removeAttribute()
	{
	delete $_[0]->{'attributes'}->{$_[1]};
	}

sub getAttribute()
	{
	if($_[0]->hasAttributes())
		{
		return $_[0]->{'attributes'}->{$_[1]};
		}
	else
		{
		return(undef);
		}
	}

sub hasAttribute()
	{
	if($_[0]->hasAttributes())
		{
		return defined($_[0]->getAttribute($_[1]));
		}
	else
		{
		return(undef);
		}
	}

#### For attribute array
sub hasAttributes()
	{
	return defined($_[0]->getAttributes());
	}
sub getAttributes()
	{
	return %{$_[0]->{'attributes'}};
	}

sub setAttributes()
	{
	$_[0]->{'attributes'} = $_[1];
	}




#### For traversing
sub getFirstChild()             {return($_[0]->{'firstchild'});}
sub getNextSibling()            {return($_[0]->{'nextsibling'});}
sub getParent()                 {return($_[0]->{'parent'});}        

sub hasFirstChild()             {return(defined($_[0]->{'firstchild'}));}
sub hasNextSibling()            {return(defined($_[0]->{'nextsibling'}));}
sub hasParent()                 {return(defined($_[0]->{'parent'}));}        

#### For reverse traversing
sub getLastChild()              {return($_[0]->{'lastchild'});}
sub getPrevSibling()            {return($_[0]->{'prevsibling'});}

sub hasLastChild()              {return(defined($_[0]->{'lastchild'}));}
sub hasPrevSibling()            {return(defined($_[0]->{'prevsibling'}));}

#### For content
sub getName()                   {return($_[0]->{'name'});}
sub getType()                   {return($_[0]->{'type'});}
sub getValue()                  {return($_[0]->{'value'});}       
sub setName()                   {$_[0]->{'name'} = $_[1];}
sub setType()                   {$_[0]->{'type'} = $_[1];}
sub setValue()                  {$_[0]->{'value'} = $_[1];}

sub hasName()                   {return(defined($_[0]->{'name'}));}
sub hasType()                   {return(defined($_[0]->{'type'}));}
sub hasValue()                  {return(defined($_[0]->{'value'}));}       

#### For setting pointers, should probably be private or protected
sub setFirstChild()             {$_[0]->{'firstchild'} = $_[1];}
sub setNextSibling()            {$_[0]->{'nextsibling'} = $_[1];}
sub setParent()                 {$_[0]->{'parent'} = $_[1];}        
sub setLastChild()              {$_[0]->{'lastchild'} = $_[1];}
sub setPrevSibling()            {$_[0]->{'prevsibling'} = $_[1];}

#### For creation
sub insertSiblingBeforeYou()
	{
	my($self) = $_[0];
	my($oldPrevSibling) = $self->getPrevSibling();
	$self->setPrevSibling($_[1]);
	$self->getPrevSibling()->setParent($self->getParent());
	$self->getPrevSibling()->setNextSibling($self);
	if(!defined($oldPrevSibling))
		{
		$self->getParent()->setFirstChild($self->getPrevSibling());
		$self->getPrevSibling()->setPrevSibling(undef);
		}
	else
		{
		$self->getPrevSibling()->setPrevSibling($oldPrevSibling);
		$oldPrevSibling->setNextSibling($self->getPrevSibling());
		}
	return($self->getPrevSibling());
	}

sub insertSiblingAfterYou()
	{
	my($self) = $_[0];
	my($oldNextSibling) = $self->getNextSibling();
	$self->setNextSibling($_[1]);
	$self->getNextSibling()->setParent($self->getParent());
	$self->getNextSibling()->setPrevSibling($self);
	if(!defined($oldNextSibling))
		{
		if(defined($self->getParent()))
			{
			$self->getParent()->setLastChild($self->getNextSibling());
			}
		$self->getNextSibling()->setNextSibling(undef);
		}
	else
		{
		$self->getNextSibling()->setNextSibling($oldNextSibling);
		$oldNextSibling->setPrevSibling($self->getNextSibling());
		}
	return($self->getNextSibling());
	}

sub insertFirstChild()
	{
	my($self) = $_[0];
	my($oldFirstChild) = $self->getFirstChild();
	if(defined($oldFirstChild))
		{
		$oldFirstChild->insertSiblingBeforeYou($_[1]);
		}
	else
		{
		$self->setFirstChild($_[1]);
		$self->setLastChild($_[1]);
		$self->getFirstChild()->setParent($self);
		}
	return($self->getFirstChild());
	}

sub insertLastChild()
	{
	my($self) = $_[0];
	my($oldLastChild) = $self->getLastChild();
	if(defined($oldLastChild))
		{
		$oldLastChild->insertSiblingAfterYou($_[1]);
		}
	else
		{
		$self->setFirstChild($_[1]);
		$self->setLastChild($_[1]);
		$self->getFirstChild()->setParent($self);
		}
	return($self->getLastChild());
	}

#### For cloning
sub clone()
	{
	my($self) = $_[0];
	my($clone) = Node->new();
	$clone->setName($self->getName());
	$clone->setType($self->getType());
	$clone->setValue($self->getValue());

	$clone->setParent($self->getParent());
	$clone->setFirstChild($self->getFirstChild());
	$clone->setLastChild($self->getLastChild());
	$clone->setPrevSibling($self->getPrevSibling());
	$clone->setNextSibling($self->getNextSibling());
	return($clone);
	}

#### For deletion
sub deleteSelf()
	{
	my($self) = $_[0];
	my($prev) = $self->getPrevSibling();
	my($next) = $self->getNextSibling();
	my($parent) = $self->getParent();
	if((defined($self->getPrevSibling()))&&(defined($self->getNextSibling())))
		{
		$self->getNextSibling()->setPrevSibling($self->getPrevSibling());
		$self->getPrevSibling()->setNextSibling($self->getNextSibling());
		}
	elsif((!defined($self->getPrevSibling()))&&(!defined($self->getNextSibling())))
		{
		$self->getParent()->setFirstChild(undef);
		$self->getParent()->setLastChild(undef);
		}
	elsif(!defined($self->getPrevSibling()))
		{
		$self->getParent()->setFirstChild($self->getNextSibling());
		$self->getNextSibling()->setPrevSibling(undef);
		}
	elsif(!defined($self->getNextSibling()))
		{
		$self->getParent()->setLastChild($self->getPrevSibling());
		$self->getPrevSibling()->setNextSibling(undef);
		}
	$self->setFirstChild(undef);
	$self->setLastChild(undef);
	}

sub deleteTree()
	{
	my($self) = $_[0];

#	#### Code to delete children and decendents here
	$self->deleteSelf();
	}

package OutlineParser;
sub new()
	{
	my($typeOfClass) = $_[0];
	my($self) = {};
	bless($self, $typeOfClass);
	$self->{'head'} = Node->new("Header Node", "Head", "Inserted by OutlineParser");
	$self->{'fromstdin'} = 1;
	$self->{'zapblanks'} = 1;
	return($self);
	}

sub setCommentChar($$)
	{
	$_[0]->{'commentchar'} = $_[1];
	}

sub getCommentChar($)
	{
	return($_[0]->{'commentchar'});
	}

sub hasCommentChar($)
	{
	return(defined($_[0]->{'commentchar'}));
	}

sub getFirstNonBlankChar($$)
	{
	my $self = shift;
	my $line = shift;
	chomp $line;
	my @parts = split(/\s+/,$line, 2);
	$line = join('', @parts);
	my $firstchar = substr($line, 0, 1);
	return $firstchar;
	}


sub parse()
	{
	my($self) = $_[0];
	my($fname) = $_[1];

	my(@levelStack);
	push(@levelStack, ($self->{'head'}));
	my($checker) = $self->{'head'};
	my($lineno) = 0;
	my($prevLevel) = -1;

	my($inf);
	if($self->{'fromstdin'} == 0)
		{
		defined($fname) or die "OutlineParser::parse() requires a filename argument, terminating.\n";
		open(INF, "<" . $fname) or die "OutlineParser::parse() could not open $fname for input, terminating.\n";
		$inf = q(INF);
		}
	else
		{
		$inf = qw(STDIN);
		}
	while(<$inf>)
		{
		my($line) = $_;
		chomp($line);
		$lineno++;
		my $zapFlag = 0;
		my $firstNonBlankChar = $self->getFirstNonBlankChar($line);
		if(($self->{'zapblanks'} != 0) && ($firstNonBlankChar eq ''))
			{
			$zapFlag = 1;
			}
		if($self->hasCommentChar() && ($self->getCommentChar() eq $firstNonBlankChar))
			{
			$zapFlag = 1;
			}
		
		unless($zapFlag)
			{
			my($level) = 0;

			$line =~ m/^(	*)(.*)/;
			if(defined($1))
				{
				$level = length($1);
				$line = $2;
				}
			else
				{
				$line = $2;
				}

			my $node = Node->new("", "Node", $line);
			$node->setAttribute('_lineno', $lineno);

			if($level == $prevLevel)
				{
				$levelStack[$prevLevel]->insertSiblingAfterYou($node);
				$levelStack[$level] = $node;
				}
			elsif($level == $prevLevel + 1)
				{
				$levelStack[$prevLevel]->insertFirstChild($node);
				$levelStack[$level] = $node;
				}
			elsif($level > $prevLevel + 1)
				{
				die "Multiple indent at line $lineno, \"$line\", terminating.\n";
				}
			elsif($level < $prevLevel)
				{
				my($dedent) = $prevLevel - $level;
				while($level < $prevLevel)
					{
					pop(@levelStack);
					$prevLevel--;
					}
				$levelStack[$prevLevel]->insertSiblingAfterYou($node);
				$levelStack[$level] = $node;
				}
			$prevLevel = $level;
			}
		}
	if($self->{'fromstdin'} == 0) {close(INF);}
	return($self->getHead());
	}

sub fromStdin() {$_[0]->{'fromstdin'} = 1;}
sub fromFile() {$_[0]->{'fromstdin'} = 0;}
sub zapBlanks() {$_[0]->{'zapblanks'} = 1;}
sub dontZapBlanks() {$_[0]->{'zapblanks'} = 0;}
sub getHead() {return($_[0]->{'head'});}


package Walker;
sub new()
	{
	my $typeOfClass = $_[0];
	my $self = {};
	bless($self, $typeOfClass);
	$self->{'top'} = $_[1];
	$self->{'entrycallback'} = $_[2];
	$self->{'exitcallback'} = $_[3];
	return($self);
	}

sub walk()
	{
	my($self) = $_[0];
	my($ascending) = 0;
	my($checker)=$self->{'top'}; # like a checker you move around a board
	my($level)=0;
	my($continue) = 1;
	my $counter = 0;
	while($continue)
		{
		if($ascending == 0)
			{
			if(defined($self->{'entrycallback'}))
				{
				my @args = @{$self->{'entrycallback'}};
				my $sub = shift(@args);
				push(@args, ($checker, $level));
				&{$sub}(@args);
				}
			if($level < 0) {$continue=0;} ## Callback sets negative to terminate
			}
		else
			{
			if(defined($self->{'exitcallback'}))
				{
				my @args = @{$self->{'exitcallback'}};
				my $sub = shift(@args);
				push(@args, ($checker, $level));
				&{$sub}(@args);
				}
			if($level < 0) {$continue=0;} ## Callback sets negative to terminate
			if($checker == $self->{'top'}) {$continue=0;}
			}

		if($continue == 0)
			{
			#skip this if/elsif/else entirely
			}
		elsif(($ascending == 0) && (defined($checker->getFirstChild())))
			{
			$ascending = 0;
			$checker = $checker->getFirstChild();
			$level++;
			}
		elsif((defined($checker->getNextSibling())) && ($checker != $self->{'top'}))
			{
			$ascending = 0;
			$checker = $checker->getNextSibling();
			}
		elsif(defined($checker->getParent()))
			{
			$ascending = 1;
			$checker = $checker->getParent();
			$level--;
#			if($level < 1) {$continue = 0;}
			}
		else
			{
			$continue = 0;
			}
		$counter++;
		}
	}


1;

