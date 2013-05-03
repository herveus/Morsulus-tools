#!/usr/bin/perl

#  perl script to extract all names and armory from a particular period

$, = '|';
$\ = "\n";
$[ = 1;

if ($ARGV[1] eq '-i') {
  $include_released_items = 1;
  shift;
}

$end_date = shift;   # (YYYYMM, inclusive)
#die if ($end_date !~ /^\d\d[01]\d$/);
$end_date += 10000 if ($end_date < 6600);

# extract all name-changes whose last date is in the interval
#  -- name changes with no last date are included
# extract all other items whose first date is in the interval
#  -- other items with no first date are included
#  -- other items with a last date <= $end_date are ignored

while (<>) {
  chop;	                	   # strip record separator
  @fields = split (/[|]/, $_, 99); # split into fields
  $date = $fields[2];
  $type = $fields[3];

  if ($type =~ /^(ANC|BNC|BNc|Bvc|HNC|NC|Nc|OC|u|vc)$/) {
    if ($date =~ /[-]/) {
      #  dual-date format
      ($d1, $d2) = split (/[-]/, $date, 2); # get both dates
      $lastdate = substr ($d2, 1, 6);
    } else {
      $lastdate = substr ($date, 1, 6);
    }
    if ($lastdate eq '' || $lastdate <= $end_date) {
      print @fields;
    }
  } else {
    if ($date =~ /[-]/) {
      #  dual-date format
      ($d1, $d2) = split (/[-]/, $date, 2); # get both dates
      $date = substr ($d1, 1, 6);
      $lastdate = substr ($d2, 1, 6);
    } else {
      $date = substr ($date, 1, 6);
      $lastdate = '';
    }
    $lastdate += 10000 if ($lastdate ne '' && $lastdate < 6600);
    $date += 10000 if ($date ne '' && $date < 6600);
    if ($include_released_items || $lastdate eq '' || $lastdate > $end_date) {
      # not released (yet)
      if ($date eq '' || $date <= $end_date) {
        print @fields;
      }
    }
  }
} # end while
