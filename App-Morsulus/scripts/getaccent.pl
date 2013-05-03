#!/usr/bin/perl

#%  Tally daud-codes in tabular form.

$\ = "\n";
$[ = 1;

#  Read unicode.tab
open (TAB, '/Users/herveus/unicode/coa.tab');
while (<TAB>) {
  next if (/^\#/);
  chop;       # strip record separator

  #  Split the line into fields.
  ($daud, $old, $unicode, $html, $name) = split (/\;/);
  $unicode{$daud} = $unicode;
  $html{$daud} = $html;
  $name{$daud} = $name;
  $eq = $daud;
  $eq =~ tr/A-Za-z//cd;
  if ($eq =~ /^(.)[^EeHh]$/) {
    $eq = $1;
  }
  $eq{$daud} = $eq;
}
close TAB;

while (<>) {
  while (/\{(..)\}/) {
    $daud = $1;
    $count{$daud} ++;
    s/\{(..)\}//;
  }
}

foreach (sort { hex($unicode{$a}) <=> hex($unicode{$b}) } keys %count) {
#foreach (keys %count) {
  $code = hex ($unicode{$_});
  if ($code >= 256) {
    printf "%4u %-2s %s %s\n", $count{$_}, $eq{$_}, "{$_}", $name{$_};
	#print "{$_}\t$eq{$_}\t\t$unicode{$_}";
  } else {
	#print "{$_}\t$eq{$_}\t$html{$_};\t$unicode{$_}";
    #printf "%4u %3u %3o %2X %-8s %-2s %s %s\n",
    printf "%4u %3u %3o %2X %s %-2s %s %s\n",
      $count{$_}, $code, $code, $code, $html{$_}.';',
      $eq{$_}, "{$_}", $name{$_};
  }
}
