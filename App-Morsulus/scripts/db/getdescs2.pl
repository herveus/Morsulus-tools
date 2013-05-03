#!/usr/bin/perl

#%  Extract the descriptions from an ordinary database.

$\ = "\n";
$[ = 1;

$descfile = shift;
open (DESCFILE, $descfile) || die "cannot open $descfile";
while (<DESCFILE>) {
  chop;
  push(@de, $_);
}

while (<>) {
  chop;                               # Strip off the record separator.
  @fields = split (/\|/, $_, 99);     # Split the record into fields.
  for ($i = 6; $i <= $#fields; $i++) {
    $count{$fields[$i]} ++;
  }
}

foreach (sort @de) {
  printf "%7u %s\n", $count{$_}, $_;
  delete $count{$_};
}
foreach (sort keys %count) {
  printf "%7u %s???\n", $count{$_}, $_;
}
