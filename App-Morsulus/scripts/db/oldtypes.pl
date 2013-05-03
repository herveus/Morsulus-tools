#!/usr/bin/perl

#%  Convert new types to NC.

$\ = "\n";
$, = '|';
$[ = 1;

#  Process each input file.
while (<>) {
  chop;           # Strip the newline.

  #  Split the line into fields.
  ($name, $date, $type, $text, $notes, @rest) = split (/\|/);

  $notes =~ s/\(\-/(/g;
  if ($type eq 'vc') {
    $notes .= '(name variant correction)';
    $type = 'NC';
    $text = "See $text";
  } elsif ($type eq 'Nc') {
    $notes .= '(name correction)';
    $type = 'NC';
    $text = "See $text";
  } elsif ($type eq 'u') {
    $notes .= '(branch designator update)';
    $type = 'NC';
    $text = "See $text";
  } elsif ($type eq 'ANC') {
    $notes .= '(alternate name change)';
    $type = 'NC';
    $text = "See $text";
  } elsif ($type eq 'HNC') {
    $notes .= '(household name change)';
    $type = 'NC';
    $text = "See $text";
  } elsif ($type eq 'OC') {
    $notes .= '(order name change)';
    $type = 'NC';
    $text = "See $text";
  }

  print $name, $date, $type, $text, $notes, @rest;
}
