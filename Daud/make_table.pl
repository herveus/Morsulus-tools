#!/usr/local/bin/perl
use strict;
use warnings;
use Daud;
use v5.16;
use utf8;
use warnings qw(FATAL utf8);
use open qw(:std :utf8);

print '<table width="80%" border="1" align="left">', "\n",
    '<tr align="left" valign="top">', "\n",
    '<th>Da\'ud code</th><th>ASCII encoding</th><th>Unicode code point</th>',
    '<th>Unicode character</th><th>HTML entity</th><th>Unicode name</th>', "\n",
    '</tr>', "\n";

for my $daud (Daud::_raw_data())
{
    next if $daud =~ /^#/;
    chomp $daud;
    my ($daud, $ascii, $unicode, $html, $name) = split(/;/, $daud);
    $html =~ s/&/&amp;/;
    print '<tr align="left" valign="top">', 
        "<td>$daud</td><td>$ascii</td><td>$unicode</td><td>", chr(hex($unicode)),
        "<td>$html</td><td>$name</td>", "\n",
        '</tr>', "\n";
}
