#!/usr/bin/perl

#%  Translate branch-name records into name records.

$\ = "\n";
$[ = 1;
$, = "\n";

while (<>) {
  chop;  # Strip off the record separator.

  # Split the record into fields.
  ($name, $s, $type, $text, $notes, $other) = split (/\|/, $_, 6);
  if ($type =~ /^B(NC|Nc|v|vc|N|B|D)$/) {
    $type = $1;
  }
  $other = "|$other" if ($other ne '');
  print "$name|$s|$type|$text|$notes$other";
}
