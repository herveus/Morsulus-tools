#!/usr/local/bin/perl

$[ = 1;

#% Tabulate the number of occurances of each line in a text file.

if ($ARGV[1] eq '-dup') {
  shift;
  $file = shift;
  open (FILE, $file) || die "cannot open `$file'";
  while (<FILE>) {
    chop;
    $line{$.} = $_;
  }
  
  while (<>) {
    chop;          # Strip off the record separator.
    if ($map{$_} ne '') {
      print "`$line{$map{$_}}' vs `$line{$.}'\n";
    }
    $map{$_}=$.;
  }

} elsif ($ARGV[1] eq '-bytes') {
  shift;
  while (<>) {
    chop;          # Strip off the record separator.
    $map{$_}++;
  }
  foreach (keys (%map)) {
    printf "%7u\t%s\n", $map{$_}*length, $_;
  }

} else {
  while (<>) {
    chop;          # Strip off the record separator.
    $map{$_}++;
  }
  foreach (keys (%map)) {
    printf "%7u\t%s\n", $map{$_}, $_;
  }
}
