#!/usr/local/bin/perl

#%  List recent armory registrations that lack name registration data.

$\ = "\n";
$[ = 1;
$, = '|';

while (<>) {
  chop;  # Strip off the record separator.

  # Split the record into fields.
  ($name, $source, $type, $text, $notes, $other) = split (/\|/);
  ($reg, $rel) = split (/\-/, $source);
  $date = substr ($reg, 1, 6);
  if ($date ne '' && $notes !~ /non-SCA/) {
    if ($date < 6605) {
      $date += 200000
    } elsif ($date < 10000) {
      $date += 190000
    }
    if ($type =~ /^[NBD]$/ || $type eq 'BN' || $type eq 'BD') {
      $name_date{$name} = $date;

    } elsif ($type =~ /^[abdgjs]$/ || $type eq 'D?') {
      if ($armory_date{$name} eq '' || $date > $armory_date) {
        $armory_date{$name} = $date;
      }
    }
  }
}

while (($name, $date) = each (%name_date)) {
  delete $armory_date{$name};
}

while (($name, $date) = each (%armory_date)) {
  print $date, $name;
}
