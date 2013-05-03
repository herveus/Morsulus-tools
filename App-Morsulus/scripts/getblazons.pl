#!/usr/local/bin/perl

use strict;
use warnings;

while (<>)
{
	chomp;
	my ($name, $source, $type, $text, undef) = split(/\|/);
	next if $source =~ /-/;
	next if $type =~ /^[AHB]N$/;
	next if $type =~ /^[NOtRWju]$/;
	next if $type =~ /^B?vc?$/;
	next if $type =~ /C$/i;
	print $text, "\n";
}

