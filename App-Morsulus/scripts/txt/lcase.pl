#!/usr/local/bin/perl

#% Convert a text file to lower-case.

$\ = '';

while (<>) {
  tr/[A-Z]/[a-z]/;
  print $_;
}
