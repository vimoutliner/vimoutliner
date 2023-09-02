#!/usr/bin/perl
#license
    #Copyright (C) 2003 by Gabriel Horner
    #You can find me through my website at http://www.chwhat.com
    #GNU GPL LICENSE, FREE SOFTWARE BUT NO WARRANTIES
    #see http://www.gnu.org/copyleft/gpl.html for details
#declarations
    package Mypalm;
    use Getopt::Long;
    Getopt::Long::Configure("bundling");
    use Palm::Address;
    use strict;
    use Data::Dumper;

    our (%o,$file,@array);
    GetOptions(\%o,qw/v h w:s/);
    my $pdb = new Palm::Address;
#functions
    sub usage {
        my $var;
        ($var = << '') =~ s/(^|\n)\t\t/\1/g;
        Usage: {OPTIONS} {contact file}     #note: []-required,{}-optional
            -w [file] file to write
            -h brings up help
            -v verbose

        print $var;
    }
    sub file2array {
        open(FILE,'<',$_[0]);
        chomp(my @lines = <FILE>);
        close FILE;
        return @lines;
    }
    sub indent {
        #u: $var or $line,$file
        #d:counts tabs of line
        my $count=0; my @array;my $line;my $x;
        if (@_ ==1) { $x =$_[0]}
        elsif (@_ ==2) { ($line,$file)=@_;
            tie @array,'Tie::File',$file or die;
            $x=$array[$line-1];}
        else { die "? arguments of &indent buster\n";}
        while ($x =~ /\t/g) {$count++}
        if (@_ ==2) {untie @array;}
        return $count;
    }
    sub indents {
        #u: (\@ ||$file) or lines,$file
        #d:makes array of lines' indent levels
        my (@tabs,@array);
        if (@_==1) {
            my $a=0; my @array;
            if (ref($_[0]) eq "ARRAY") { @array = @{$_[0]}}
            else { tie @array,'Tie::File',$_[0] or die; }
            while($array[$a]) {$tabs[$a] = indent($array[$a]);$a++}
            untie @array if (ref($_[0]) ne "ARRAY");
        }
        else {
            my ($a,$b,$file)= @_;
            tie @array,'Tie::File',$file or die;
            for (my $j=$a;$j<=$b;$j++) { $tabs[$j]= indent($array[$j]); }
            untie @array;
        }
        return @tabs;
    }
#main
    if ($o{h}) {&usage;exit}
    my @temp = file2array(shift || "/home/bozo/bin/dat/contacts");

    #ignore empty or '#' commented lines
    my @lines = grep(!/^\s*#|^\s*$/,@temp);

    #obtain indent level of lines
    my @tabs = indents(\@lines);

    #get rid of surrounding white space
    my @lines = map {$_ =~ s/^\s*|\s*$//;$_} @lines;

    my $categorylevel = $tabs[0];
    my ($category,%rec,$reclevel,$prec,%cat);
    # %rec is only for error checking
    my $a = 0;
    for (@lines) {
        #read in a category
        if ($tabs[$a] == $categorylevel) {
            $rec{category} = $category = $_;
            $reclevel = $tabs[$a+1];
            print "c:$tabs[$a]\n" if ($o{v});
        }
        #read in person's name and initialize a new record
        elsif ($tabs[$a] == $reclevel) {
            %rec=();
            $prec = $pdb->append_Record;
            $pdb->addCategory($category) unless exists $cat{$category};
            $cat{$category}++;
            $prec->{category} = $category;
            #print Dumper $prec;
            $prec->{phoneLabel}{phone3} = 7;
            $rec{category}=$category;
            #$prec->{fields}{name} = $_;
            $rec{name} = $_;
            $prec->{fields}{name} = $_;
            print "n:$tabs[$a]\n" if ($o{v});
        }
        #fills in all the record's fields
        else {
            print "details:$tabs[$a],$_\n" if ($o{v});
            for ($_) {
                /^a.*:\s*(.*)/i  && do {$rec{addr} = $1; $prec->{fields}{address} = $1; last};
                /^c.*:\s*(.*)/i  && do {$rec{cell} = $1; $prec->{fields}{phone3} = $1;last};
                /^e.*:\s*(.*)/i  && do {$rec{email} = $1; $prec->{fields}{phone5} = $1;last};
                /^h.*:\s*(.*)/i  && do {$rec{home} = $1; $prec->{fields}{phone2} = $1;last};
                /^n.*:\s*(.*)/i  && do {$rec{notes} = $1; $prec->{fields}{note} = $1;last};
                /^o.*:\s*(.*)/i  && do {$rec{other} = $1; $prec->{fields}{phone4} = $1;last};
                /^web.*:\s*(.*)/i  && do {$rec{web} = $1; $prec->{fields}{custom1} = $1;last};
                /^w.*:\s*(.*)/i  && do {$rec{work} = $1; $prec->{fields}{phone1} = $1;last};
                #print "shouldn't be here\n";
            }
        }
        if ((($tabs[$a+1] <= $reclevel) and $tabs[$a] != $categorylevel) or ($a == @lines -1))
            { #write record
                print "record $a finished\n";
                print Dumper(\%rec) if ($o{v});
                #push (@recs,\%rec);
            }
        $a++;
    }
    $pdb->Write($o{w}||"/home/bozo/bin/dat/AddressDB.pdb");

__END__

=head1 NAME

otl2pdb.pl - A script that takes an outline of contact information and creates an AddressDB.pdb file
for a Palm.

=head1 DESCRIPTION

For now this script can only create a .pdb file. You then have to use a syncing tool
to load it into your Palm. I recommend the pilot-link package for linux.

The format of the contact outline is the following:

    $category
        $record_name
            c:$cell
            a:$address
            ....

You can have as many categories and records(entries) as you want.
The following are valid fields for a record with the necessary text
to indicate them in quotes:

    'a:'-address
    'c:'-cell
    'e:'-email
    'h:'-home phone
    'n:'-note
    'web:'-website
    'w:'-work phone

Also, each record's category is left as 'Unfiled' as I can't get the record's
category to write correctly.

=head1 TIPS

If using the pilot-link package:

    -load the pdb with 'pilot-xfer -i AddressDB.pdb'
    -specify the serial port if other than /dev/pilot (which will usually be the case
    unless you link to it) with -p in the above command; usually this is /dev/ttyS0 in linux

=head1 AUTHOR

Me. Gabriel that is. If you want to bug me with a bug: cldwalker@chwhat.com
If you like using perl,linux,vim and databases to make your life easier (not lazier ;) check out my website
at www.chwhat.com.

=head1 LINKS

http://www.pilot-link.org
http://www.coldsync.org
