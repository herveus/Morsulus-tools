#!/usr/bin/perl

#%  Delete bracketed text, both Linnean names and designators,
#%  when generating a printed O&A.

$\ = "\n";
$[ = 1;
$, = ';';

while (<>) {
  chop;
  s/<[^>]+>//g;
  s/\s+\[[^\]]+\]//g;
  print $_;
}
