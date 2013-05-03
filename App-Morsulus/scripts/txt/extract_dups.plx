#!/usr/bin/perl
use strict;
use warnings;
use English;
use Perl6::Slurp;
#use Regexp::Autoflags;

my $database_file = '/Users/herveus/aux/oanda.db';

my @database = slurp $database_file;

while (my $potential_dup = <>) 
{
	chomp $potential_dup;
	my ($name1, $name2)
		= $potential_dup =~ m{\A[`]([^']+)'[ ]vs[ ][`]([^']+)'\z};
	next if !defined $name1;
	next if !defined $name2;
	print "$potential_dup\n",
		"$name1:\n",
		grep { /$name1/ } @database;
	print "-"x40, "\n",
		"$name2:\n",
		grep { /$name2/ } @database;
	print "=" x 80, "\n";
}