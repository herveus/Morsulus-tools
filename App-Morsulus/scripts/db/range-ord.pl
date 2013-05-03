#!/usr/bin/perl

#  Extract all new armory from a particular period
#  for an Ordinary update.

$, = '|';
$\ = "\n";
$[ = 1;

$start_date = shift; # (YYMM, inclusive)
$end_date = shift;   # (YYMM, inclusive)

die if ($start_date eq '' || $end_date eq '');

$start_date += 10000 if ($start_date < 6600);
$end_date += 10000 if ($end_date < 6600);

# extract all armory items whose first date is in the interval
#  -- those with no first date are ignored
#  -- those with a last date are ignored

while (<>) {
  chop;	                	   # strip record separator
  @fields = split (/[|]/, $_, 99); # split into fields
  $sources = $fields[2];
  $type = $fields[3];

  if ($type =~ /^[AaBbgSsDd]$/ || $type eq 'D?' || $type eq 'BD') {
    ($d1, $d2) = split (/[-]/, $sources);

    $first = substr ($d1, 1, 4);
    $first += 10000 if ($first < 6600 && $first ne '');
    print @fields
      if ($first >= $start_date && $first <= $end_date && $last eq '');
  }
} # end while
