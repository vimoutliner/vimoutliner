#!/usr/bin/env perl
# #######################################################################
# votl_maketags.pl: Vim outline tagging system, main program, version 0.3.5
#   Copyright (C) 2001-2003, 2011 by Steve Litt (slitt@troubleshooters.com)
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, see <http://www.gnu.org/licenses/>.
#
# Steve Litt, slitt@troubleshooters.com, http://www.troubleshooters.com
# #######################################################################

# #######################################################################
# #######################################################################
# #######################################################################
# HISTORY
# V0.1.0 Pre-alpha
#     Starting at a "top level" indent-defined Vim outline, this
#     program finds all "tags" defined as headlines starting with
#     _tag_, and containing a subheadline containing the file
#     to which the tag should jump. This program creates a tags
#     file.
#Steve Litt, 5/28/2001
#End of version 0.1.0
#
# V0.1.1 Pre-alpha
#     Bug fixes, including ../ resolution
#
#Steve Litt, 5/28/2001
#End of version 0.1.1
#
#
# V0.1.2 Pre-alpha
#	More bug fixes, and facility to create a new outline
#	file from a tag whose corresponding file doesn't yet
#	exist.  
#Steve Litt, 5/30/2001
#End of version 0.1.2
#
# V0.1.3 Pre-alpha
#	More bug fixes. This was the first version released
#	file from a tag whose corresponding file doesn't yet
#	exist.  
#Steve Litt, 6/01/2001
#End of version 0.1.3
#
# V0.2.0 Pre-alpha
#Steve Litt, 12/03/2002
#	This file unchanged. The overall Vimoutliner version
#	0.2.0 has extensive improvements, including intuitive
#	collapse/expand.
#End of version 0.2.0
#END OF HISTORY
#
#
# V0.1.2 Pre-alpha
#	More bug fixes, and facility to create a new outline
#	file from a tag whose corresponding file doesn't yet
#	exist.  
#Steve Litt, 5/30/2001
#End of version 0.1.2
# V0.3.5 release 20110303
#       Changed vo_tags.tag directory from
#       $HOME/.vimoutliner/
#       to
#       $HOME/.vim/vimoutliner/
#Steve Litt, 3/3/2011
#End of version 0.3.5 release 20110303
#END OF HISTORY
#
# #######################################################################

use strict;
use warnings;
use Path::Tiny;
use autodie qw(:all);
use List::AllUtils qw(uniq);

my $TAGFILENAME = path("$ENV{HOME}/.vim/vimoutliner/vo_tags.tag");
my $TAGFILENAME_fh;

# HashRef containing a map from a filename to its tag names
# { filename => { tagname => filename } }
my $files_to_tags;
# Array of all the files left to process
my @process_queue;

main();

sub main {
	return usage() unless @ARGV;

	push @process_queue, @ARGV; # add all arguments to the process queue

	$TAGFILENAME_fh = $TAGFILENAME->opena();
	# no process each one
	while( @process_queue ) {
		create_and_process( shift @process_queue );
	}
	$TAGFILENAME_fh->close;

	sort_and_dedupe_tagfile();
}

sub usage {
	print "\nUsage is:\n";
	print "otltags topLevelOutlineFileName\n\n";
}

sub expand_filename {
	my ($filename, $base_dir) = @_;
	$filename =~ s|^\$HOME/|~/|; # special case the $HOME environment variable
	$filename = path( $filename ); # path expansion
	$filename = $filename->absolute( $base_dir ) if( $base_dir );
	$filename;
}

sub process_file {
	my ($filename) = @_;
	my $f = path( $filename );
	my $f_contents = $f->slurp;
	my %f_tags = $f_contents =~ /
		^\s*(?<tagname>_tag_\S+).*
		\n # and on the next line
		^\s*(?<filename>.*)
		/mgx;
	\%f_tags;
}

sub create_and_process {
	my ($filename) = @_;
	# we want an absolute path
	$filename = expand_filename( $filename, Path::Tiny->cwd );

	# it has already been processed
	return if exists $files_to_tags->{$filename};

	if( ! -f $filename ) {
		# does not exist: create it
		$filename->parent->mkpath( { verbose => 1 } ); # make path and be verbose about it
		$filename->touch;
		$files_to_tags->{$filename} = {}; # new file -> already processed
	} else {
		my $results = process_file( $filename );
		my $basedir = $filename->parent;
		for my $tag (keys $results) {
			# expand the files for each of the tags
			$results->{$tag} = expand_filename($results->{$tag}, $basedir);
		}

		# and add the files for each of the tags to the @process_queue
		push @process_queue, values %$results;

		append_tags_to_tagfile($results);

		$files_to_tags->{$filename} = $results; # let's store all the tags (useful for debugging)
	}
}

sub sort_and_dedupe_tagfile {
	my @contents = $TAGFILENAME->lines;
	my @uniq_tags = uniq sort { $a cmp $b } @contents;
	$TAGFILENAME->spew( \@uniq_tags );
}

sub append_tags_to_tagfile {
	my ($tags) = @_;
	for my $tag (keys $tags) {
		print $TAGFILENAME_fh "$tag\t$tags->{$tag}\t:1\n"
	}
}
