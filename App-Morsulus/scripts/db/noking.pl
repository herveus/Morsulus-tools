#!/usr/bin/perl

#  perl script to delete kingdom information

$, = '|';
$\ = "\n";
$[ = 1;

while (<>) {
  chop;	                	   # strip record separator
  ($n, $date, @rest) = split (/[|]/, $_, 99); # split into fields

  if ($date =~ /^(\d{6})?[A-Za-z]?[-](\d{6})?[A-Za-z]?$/) {
    #  dual-date format
    $date = "$1-$2";
  } elsif ($date =~ /^(\d{6})?[A-Za-z]?$/) {
    $date = $1;
  } else {
    die "$date";
  }
  print $n, $date, @rest;
}
