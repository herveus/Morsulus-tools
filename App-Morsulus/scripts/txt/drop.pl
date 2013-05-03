#!/usr/local/bin/perl

#% Delete all a's and e's from a text file.
#  useful for discovering name typoes

# getnames.pl oanda.db | sort -u | drop.pl | sort | uniq -c

while (<>) {
  tr/A-Za-z/A-Za-z/s;
  tr/ AEae//d;
  tr/IYiy//d;
  #tr/Kk/Cc/;
  tr/Kk/Cc/s;

#  tr/OoUu//d;
  print;
}
