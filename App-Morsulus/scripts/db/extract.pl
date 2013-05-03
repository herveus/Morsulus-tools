#!/usr/bin/perl

#% Extract an armorial database from an ordinary database.

$, = '|';		# set output field separator
$\ = "\n";		# set output record separator

while (<>) {
    chop;
    @fields = split (/\|/, $_, 99);
    $#fields = 4;
    print @fields;
}
