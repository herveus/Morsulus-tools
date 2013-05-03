#!/usr/bin/perl

#%  Delete brackets.

$\ = "\n";
$[ = 1;
$, = ';';

while (<>) {
  chop;
  s/[<>]//g;
  print $_;
}
