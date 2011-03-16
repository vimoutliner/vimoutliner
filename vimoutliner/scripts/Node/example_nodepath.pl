#!/usr/bin/perl -w

# Copyright (C) 2004 by Steve Litt
# Licensed with the GNU General Public License, Version 2
# ABSOLUTELY NO WARRANTY, USE AT YOUR OWN RISK
# See http://www.gnu.org/licenses/gpl.txt

use strict;	# prevent hard to find errors

#####################################################################
# Node.pm is a tool you will probably use in many projects located
# in varying directories. How do you enable those projects to
# include Node.pm? Here are some ways:
#   1. Place Node.pm in the project's directory
#   2. Place Node.pm on Perl's module path
#   3. Run the project as perl -I/path/to/Node project.pl
#   4. Shebang line #!/usr/bin/perl -w -I/path/to/Node
#   
# Number 1 can become problematic as the number of apps using Node.pm
# increases. If you have 30 different copies in 30 different directories,
# how do you keep them all up to date.
#
# Number 2 is a much better option. It works. However, which @INC
# directory do you place it in? When you update Perl or your distribution,
# it goes away.
#
# Number 3 is great, except you need to create a shellscript to call
# Perl with your program as an argument. BE SURE not to leave a space
# between the -I and the directory, or that space actually becomes
# part of the directory.
#
# Number 4 is greater, because it doesn't require a shellscript. Once
# again, no space between -I and the directory. In all cases where 
# you know what directory will contain Node.pm, number 4 is a great
# alternative. 
#
# But what if you don't know in advance what directory
# will contain Node.pm? What if you're writing an application to be
# run at varying locations with varying setups? What if, in addition,
# you don't want the end user messing with the source code to change
# the shebang line? In that case, you can actually place the path
# to Node.pm in a configuration file. It takes several lines of code,
# but it's certainly nice to be able to accommodate the user's
# environment without requiring change to the source code.
#
# This exercise demonstrates how to set the Node.pm location from a
# configuration file. Once again, if you're the sole user it might be
# better to change the shebang line, but if you're distributing
# your program like the autumn leaves, a configuration file is the 
# way to go.
#
#####################################################################


#####################################################################
# The loadNodeModule() subroutine is a complete substitute for:
#    use Node
# 
# It includes:
#	require Node;
#	import Node;
# 
# The preceding two calls completely replace a use Node statement,
# and better still, unlike the use statement, they happen at 
# runtime instead of compile time. Therefore, this subroutine reads
# the directory from a config file, then executes that directory
# with the proper require and import statements. Obviously, the
# loadNodeModule() subroutine must be executed before any code depending
# on the Node.pm module is executed.
#####################################################################
sub loadNodeModule()
	{
	#### CHANGE THE FOLLOWING TO CHANGE THE DEFAULT APP FILENAME
	my $defaultConfFileName = "./myapp.cfg";

	#### CHANGE THE FOLLOWING TO CHANGE APP FILENAME ENVIRONMENT VAR
	my $envVarName = "MY_APP_CONFIG";

	my($conffile) = $ENV{$envVarName};
	print $conffile, "\n" if defined $conffile;
	$conffile = $defaultConfFileName unless defined($conffile);
	print "Using config file $conffile.\n";

	open CONF, '<' . $conffile or die "FATAL ERROR: Could not open config file $conffile.";
	my @lines = <CONF>;
	close CONF;

	my @nodedirs;
	foreach my $line (@lines)
		{
		chomp $line;
		if($line =~ m/^\s*nodedir\s*=\s*([^\s]*)/)
			{
			my $dir = $1;
			if($dir =~ m/(.*)\$HOME(.*)/)
				{
				$dir = $1 . $ENV{'HOME'} . $2;
				}
			push @nodedirs, ($dir);
			}
		}

	if(@nodedirs)
		{
		unshift @INC, @nodedirs;
		}

	require Node;
	import Node;
	}

#####################################################################
# The main() routine calls loadNodeModule to include Node.pm,
# and then runs a few lines of code to conclusively prove that
# Node.pm is loaded. It also prints out the @INC array to show that
# directory in which Node.pm resides is now in the @INC path.
#
# Note that in the absense of any change to the environment variable
# defined in loadNodeModule(), the configuration file will be ./myapp.cfg.
#####################################################################
sub main()
	{
	loadNodeModule();
	my $topNode = Node->new("myname", "mytype", "myvalue");
	print "\n::: ";
	print $topNode->getName(), " ::: ";
	print $topNode->getType(), " ::: ";
	print $topNode->getValue(), " :::\n";
	foreach my $line (@INC)
		{
		print $line, "\n";
		}
	}

main();
