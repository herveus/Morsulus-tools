#!/usr/bin/perl

#  Extract all names and armory from a particular period
#  for an Armorial update.

$, = '|';
$\ = "\n";
$[ = 1;

$start_date = shift; # (YYMM, inclusive)
$end_date = shift;   # (YYMM, inclusive)

die if ($start_date eq '' || $end_date eq '');

$start_date += 10000 if ($start_date < 6600);
$end_date += 10000 if ($end_date < 6600);

# extract all records one or more dates in the range

while (<>) {
  chop;	                	   # strip record separator
  @fields = split (/[|]/, $_, 99); # split into fields
  $sources = $fields[2];
  $notes = $fields[5];

  @d = split (/[-]/, $sources);
  push (@d, $1) if ($notes =~ /[(]re-registered (\d\d[01]\d\S?)[)]/);

  $print = 0;
  foreach (@d) {
    $_ = substr ($_, 1, 4);
    $_ += 10000 if ($_ < 6600 && $_ ne '');
    $print = 1 if ($_ >= $start_date && $_ <= $end_date);
  }
  if ($print) {
    $#fields = 5;
    print @fields;
  }
} # end while
