#!/usr/bin/perl

use strict;
use XML::Writer;
use vars qw($writer $section_has_contents $VERSION);

use constant DEBUG => 0;

$VERSION = '2.0';

sub debug {
	if ( DEBUG )
	{
		print STDERR @_;
	}
}

sub start_docbook {
	$writer = XML::Writer->new(DATA_MODE => 1,
	                           DATA_INDENT => 1);

	debug('  'x$writer->getDataIndent(), "starting new docbook\n");

	$writer->xmlDecl();

#    my $system = '/usr/share/sgml/docbook/xml-dtd-4.1/docbookx.dtd';
	my $system = 'http://www.oasis-open.org/docbook/xml/4.0/docbookx.dtd';

	$writer->doctype('article',
	                 '-//OASIS//DTD DocBook XML V4.1//EN',
	                 $system);
}

sub start_article {
	my $id = shift;

	debug('  'x$writer->getDataIndent(), "starting new article\n");

	my @attributes = (
	                  'class' => 'whitepaper',
	);

	if ( $id )
	{
		push @attributes, ( 'id' => $id );
	}

	$writer->startTag('article', @attributes);
}

sub start_section {
	my $title = shift;

	debug('  'x$writer->getDataIndent(), "starting new section\n");

	$writer->startTag('section');

	$section_has_contents = 0;

	if ( $title )
	{
		$writer->dataElement('title', $title);
	}
}

sub start_list {
	debug('  'x$writer->getDataIndent(), "starting new list\n");

	$writer->startTag('itemizedlist');
}

sub append_list_item {
	my $text = shift;

	debug('  'x$writer->getDataIndent(), "starting new listitem\n");

	$writer->startTag('listitem');

	$writer->dataElement('para', $text);

	$writer->endTag('listitem');
}

sub end_list {
	$writer->endTag('itemizedlist');

	debug('  'x$writer->getDataIndent(), "ending list\n");
}

sub append_code {
	my $code = shift;

	debug('  'x$writer->getDataIndent(), "starting new programlisting\n");

	$section_has_contents = 1;

	$writer->dataElement('programlisting', $code, role=>'C');
}

sub append_para {
	my $text = shift;

	debug('  'x$writer->getDataIndent(), "starting new para\n");

	$section_has_contents = 1;

	$writer->dataElement('para', $text);
}

sub end_section {
	if ( ! $section_has_contents )
	{
		$writer->emptyTag('para');
		$section_has_contents = 1;
	}

	$writer->endTag('section');

	debug('  'x$writer->getDataIndent(), "ending section\n");
}

sub end_article {
	$writer->endTag('article');

	debug('  'x$writer->getDataIndent(), "ending article\n");
}

sub end_docbook {
	$writer->end();

	debug('  'x$writer->getDataIndent(), "ending docbook\n");
}

####################################################

start_docbook();
start_article();

my $section_level = 0;
my $line;
my $para = '';
my $list_mode = 0;
my $code_mode = 0;
my $first_line = 1;

sub list_done {
	if ( $list_mode ) {
		end_list();
		$list_mode = 0;
	}
}

sub para_done {
	if ( $para )
	{
		chomp $para;
		if ( $code_mode )
		{
			append_code($para);
			$code_mode = 0;
		}
		elsif ( $list_mode )
		{
			append_list_item($para);
		}
		else
		{
			append_para($para);
		}
	}
	$para = '';
}

while ( defined ($line = <>) )
{
	if ( $first_line and $line =~ /^-\*-/ )
	{
		next;
	}
	$first_line = 0;

	if ( $line =~ /^\t*\* (.*)/ )
	{
		para_done();

		$para = $1;
 
		if ( ! $list_mode )
		{
			start_list();
			$list_mode = 1;
		}
 
		next;
	}

	if ( $line =~ /^\t*[^\t: ]/ )
	{
		para_done();
		list_done();
	}

	if ( $line =~ /^(\t*)([^\t\n: ].*)/ )
	{
		my $title = $2;
		my $new_section_level = length($1) + 1;

		para_done();
		list_done();

		for ( my $i = 0 ; $section_level - $new_section_level >= $i ; $i++ )
		{
			end_section();
		}

		chomp $title;
		start_section($title);

		$section_level = $new_section_level;
		next;
	}

# Code mode not supported yet
#    if ( ! $list_mode and $line =~ /^\s+/ )
#    {
#        debug("enabling code mode\n");
#        $code_mode = 1;
#    }

	 $line =~ s/^\t*(\: ?| )//;
	 if ($line =~ /^$/) {
		 para_done();
		 list_done();
	 next;
	 }
	 $para .= $line;
}
para_done();

for ( my $i = 0 ; $section_level > $i ; $i++ )
{
	end_section();
}

end_article();
end_docbook();

__END__

=head1 NAME

outline2dockbook - Generate DocBook XML from VimOutliner outline

=head1 SYNOPSIS

outline2docbook < input > output

=head1 DESCRIPTION

B<outline2docbook> reads an VimOutliner outline-mode type text file on
standard input and outputs DocBook XML on standard output.

The original version was written by Thomas R. Fullhart to convert from Emacs
outline mode.  It is available at
http://genetikayos.com/code/repos/outline2docbook/distribution/.

This program uses the B<XML::Writer> perl module, which is available
on B<CPAN>.

=cut
