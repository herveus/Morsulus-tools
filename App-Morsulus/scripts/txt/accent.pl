#!/usr/local/bin/perl

#%  Translate from daud-codes to other character encodings.

$\ = "\n";
$[ = 1;
$, = ';';

$to = 'old';

while ($_ = $ARGV[1], /^-./) {
  shift;
  last if (/^--$/);
  if (/^-o/) { $to = 'old'; next; }
  if (/^-h/) { $to = 'html'; next; }
  if (/^-p/) { $to = 'postscript'; next; }
  if (/^-r/) { $to = 'roman-1'; next; }
  if (/^-u/) { $to = 'unicode'; next; }
  die "Bad option: $_\n";
}

#  Read unicode.tab
open (TAB, '/Users/herveus/aux/coa.tab')
	or die "Can't open coa.tab: $!";
while (<TAB>) {
  next if (/^\#/);
  chop;       # strip record separator

  #  Split the line into fields.
  ($daud, $old, $unicode, $html, $name) = split (/\;/);
  $map{$daud} = $old if ($to eq 'old');
  $map{$daud} = "$html;" if ($to eq 'html' && $html ne '');
  $map{$daud} = "#$unicode;" if ($to eq 'unicode');
  if ($to eq 'roman-1' || $to eq 'postscript') {
    $unicode = hex ($unicode);
    if ($unicode < 256) {
      $map{$daud} = pack ('C', $unicode);
    } else {
      $map{$daud} = $old;
      if ($to eq 'postscript') {
        $map{$daud} = "\201" if ($daud eq 'cv');
        $map{$daud} = "\202" if ($daud eq 'OE');
        $map{$daud} = "\203" if ($daud eq 'oe');
        $map{$daud} = "\204" if ($daud eq 'Sv');
        $map{$daud} = "\205" if ($daud eq 'sv');
      }
    }
  } 
}
close TAB;

while (<>) {
  chop;
  $i = 0;
  while (/\{(..)\}/) {
    $daud = $1;
    $old = $map{$daud};
    last if ($old eq '' || $i++ > 100);
    s/\{..\}/$old/ if ($old ne '');
  }
  print $_;
}
