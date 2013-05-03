#!/usr/bin/perl

#% Convert a cat file in to an exportable form.

$\ = "\n";

while (<>) {
  chop;
  if (/.+\|/ && / do not print/) {
    s/ do not print//;
    ($head, @rest) = split (/\|/);
    $heads{$head} = 1;
  }
  if (/(.+) - see /) {
    s/ - see / - see also / if ($heads{$1});
  }
  print $_;
}
