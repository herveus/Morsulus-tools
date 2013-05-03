#!/usr/bin/perl

#% Thin a database, keeping only the indexed armory.

while (<>) {
  print $_ if split(/\|/) > 5;
}
