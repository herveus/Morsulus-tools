#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

my $USAGE = <<USAGE;
tag-owners.pl -q -d input -o output -e errors
   -q        do not ask for user input
   -d input  source database - defaults to STDIN
   -o output edited database - defaults to source + ".tagged"
   -e errors records for which owner could not be 
             divined - defaults to source + ".err"
USAGE

my %opts;
die $USAGE unless getopts("qd:o:e:", \%opts);
if (exists $opts{d})
{
	$opts{o} = $opts{d} . ".tagged" unless exists $opts{o};
	$opts{e} = $opts{d} . ".err" unless exists $opts{e};
	push @ARGV, $opts{d};
}

open my $output, ">", $opts{o} or die "opening $opts{o}:$!";
open my $errors, ">", $opts{e} or die "opening $opts{e}:$!";

my %owners = 
(
	'Society for Creative Anachronism' => { xxxx => 1},
);
my %orders;
my @records = <>;
foreach (@records)
{
	chomp;
	my ($name, $source, $type, $text, $notes, @descs) = split(/\|/, $_);
	#my %notes = map {$_, 1} split_notes($notes);
	if ($type =~ /^(B?NC?|B|D|BD)$/)
	{
		$owners{$name}->{$source} = $_;
	}
	elsif ($type =~ /^(AN|HN|O)$/)
	{
		$orders{$name} = $text;
	}
}
foreach (@records)
{
	no warnings 'uninitialized';
	chomp;
	my ($name, $source, $type, $text, $notes, @descs) = split(/\|/, $_);
	if ($notes =~ /\(Owner: / or $type eq 'R')
	{
		print $output $_, "\n";
		next;
	}
	elsif ($notes =~ /\(Important non-SCA/)
	{
		$notes .= "(Owner: Laurel - admin)";
		my $new_rec = join('|', $name, $source, $type, $text, $notes,
			@descs). "\n";
		print $output $new_rec;
		next;
	}
	my %notes = map {$_, 1} split_notes($notes);
	if ($type =~ /^(B?vc?|.?Nc)$/) # correction -- "owned" by Morsulus
	{
		$notes{"Owner: Morsulus - admin"} = 1;
	}
	elsif ($type =~ /^(B?NC|u|t|HN|AN|O)$/)
	{
		(my $new_name = $text) =~ s/^See //;
		$new_name =~ s/^For //;
		if (exists $owners{$new_name})
		{
			my $owner = get_owner($_, $new_name, $owners{$new_name});
			$notes{"Owner: $owner"} = 1 if $owner;
		}
		else
		{
			$notes{"Owner: Laurel - admin"} = 1;
		}
	}
	elsif ($type =~ /^C$/)
	{
		if (exists $orders{$text})
		{
			my $owner = get_owner($_, $orders{$text}, $owners{$orders{$text}});
			$notes{"Owner: $owner"} = 1 if $owner;
		}
	}
	elsif (exists $owners{$name})
	{
		my $owner = get_owner($_, $name, $owners{$name});
		$notes{"Owner: $owner"} = 1 if $owner;
	}
	$notes = join_notes(keys %notes);
	my $new_rec = join('|', $name, $source, $type, $text, $notes,
		@descs). "\n";
	print $output $new_rec;
	print $errors $new_rec unless $notes =~ /\(Owner: /;	
}

sub get_owner
{
	my ($rec, $name, $dates) = @_;
	return join(":", $name, keys %$dates) if scalar keys %$dates == 1;
	return if $opts{"q"};
	
	print STDERR "$rec\nhas multiple possible owners:\n";
	my $i = 1;
	my @dates;
	foreach my $date (keys %$dates)
	{
		print STDERR "$i) $name($date) - $dates->{$date}\n";
		push @dates, $date;
		$i++;
	}
	my $input;
	while (1)
	{
		print STDERR "Which one? (0 to skip): ";
		$input = <STDIN>;
		chomp $input;
		return if $input == 0;
		return "$name - $dates[$input-1]" if $input > 0 && $input < $i;
	}
}


sub split_notes
{
	my $notes = shift or return;
	$notes =~ s/^\(//;
	$notes =~ s/\)$//;
	return split(/\)\(/, $notes);
}

sub join_notes
{
	return "" unless @_;
	return "(".join(")(", @_).")";
}
