#!/usr/bin/perl

#%  Put titles, order names, and household names
#%  both ways in the database.

$\ = "\n";
$, = '|';
$[ = 1;

#  Process each input file.
while (<>) {
  chop;           # Strip the newline.

  #  Split the line into fields.
  ($name, $date, $type, $text, $notes, @rest) = split (/\|/);

  $t = $text;
  $t =~ s/["]//g if ($type eq 'O' || $type eq 'HN');
  print $name, $date, $type, $t, $notes, @rest;

  if ($type eq 'O' || $type eq 'HN' || $type eq 'T' || $type eq 't') {
    if ($text =~ /^["](.*)["]$/) {
      $text = $1;
    }
    @T = split (/["] and ["]/, $text);
    foreach $t (@T) {
      print $t, $date, $type, $name, $notes, @rest;
    }
  }
}
