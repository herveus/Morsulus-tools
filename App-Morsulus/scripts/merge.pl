#!/usr/bin/perl

#  Merge re-indexed blazons into the main database.

$, = "|";
$\ = "\n";
$[ = 1;

$map_file = shift;
if ($map_file eq '') {
  print STDERR "Usage: $0 ( <mapfile> | <mapdb>.db ) [ <db> ... ]";
  exit;
}

#  The progam recognizes database files (by the .db extension)
#    and adjusts accordingly
#  Otherwise, the first input is assumed to be a 'map file'
#    containing only blazon and categories.
if ($map_file =~ /\.db$/) {
  $bfield = 4;
  $start = 6;
} else {
  $bfield = 1;
  $start = 2;
}

open  (FILE, $map_file) || die "cannot open mapfile $map_file";
while (<FILE>) {
  chop;                               # Strip off the record separator.
  @fields = split (/\|/, $_, 99);     # Split the record into fields.

  $blazon = $fields[$bfield];
  $map{$blazon} = $fields[$start];
  for ($i = $start+1; $i <= $#fields; $i++) {
    $map{$blazon} .= '|' . $fields[$i];
  }
}

while (<>) {
  chop;                               # Strip off the record separator.
  # Split the record into fields.
  ($n, $source, $type, $blazon, @rest) = split (/\|/, $_, 99);

  $change = $map{$blazon};
  if (($type =~ /^[ABDSabdgs]?$/ || $type eq 'D?' || $type eq 'BD')
   && $source !~ /\-/ && $change ne '') {
    $#rest = 1;
    $rest[2] = $change;
  }
  print $n, $source, $type, $blazon, @rest;
}
