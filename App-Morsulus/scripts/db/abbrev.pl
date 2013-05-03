#!/usr/bin/perl

#% abbreviate blazons

$\ = "\n";
$, = '|';

while (<>) {
  chop;                               # Strip off the record separator.

  # Split the record into fields.
  ($n, $date, $type, $text, @rest) = split (/\|/, $_, 99);

  if ($type =~ /^[ABDSabdsg]$/ || $type eq 'D?' ||$type eq 'BD') {
    $text =~ s/\bargent\b/Arg/ig;            # 54k
    $text =~ s/\band\b/\&/ig;                # 39k
    $text =~ s/\bsable\b/Sa/ig;              # 32k
    $text =~ s/\bazure\b/Az/ig;              # 25k
    $text =~ s/\bcounterchanged\b/ctrch/ig;  # 25k
    $text =~ s/\bgules\b/Gu/ig;              # 25k
    $text =~ s/\bsinister\b/sin/ig;          # 25k
    $text =~ s/\bthree\b/3/ig;               # 19k
    $text =~ s/\bbetween\b/betw/ig;          # 15k
    $text =~ s/\bvert\b/Vt/ig;               # 12k
    $text =~ s/\btwo\b/2/ig;                 # 12k
    $text =~ s/\binverted\b/inv/ig;          # 12k
    $text =~ s/\bchief\b/chf/ig;             # 10k
    $text =~ s/\bbordure\b/bord/ig;          # 10k
    $text =~ s/\bpurpure\b/Purp/ig;          #  7k
    $text =~ s/\bchevron\b/chev/ig;          #  7k
    $text =~ s/\bsaltire\b/salt/ig;          #  5k
    $text =~ s/\bembattled\b/embat/ig;       #  5k
    $text =~ s/\brampant\b/ramp/ig;          #  4k
    $text =~ s/\bdisplayed\b/disp/ig;        #  4k
    $text =~ s/\bfour\b/4/ig;                #  4k
  }
  print $n, $date, $type, $text, @rest;
}
