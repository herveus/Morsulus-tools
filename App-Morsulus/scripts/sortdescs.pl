#!/usr/bin/perl

#  Sort the keys of a database, desc, or map file into canonical order.

$\ = "\n";
#$[ = 1;
$, = '|';

$noncat_fields = 5;  # default is db file

while ($_ = $ARGV[1], /^-./) {
  shift;
  last if (/^--$/);
  if (/^-d$/) { $noncat_fields = 0; next; }  # desc file
  if (/^-m$/) { $noncat_fields = 1; next; }  # map file
  die "Bad option: $_\n";
}

while (<>) {
  chop;                               # Strip off the record separator.
  @fields = split (/\|/, $_, 99);     # Split the record into fields.
  @hout = ();
  while ($#fields > $noncat_fields) {
    ($head, @features) = split (/\:/, pop (@fields), 99);
    $prev = '';
    @fout = ();
    foreach $cur (sort (@features)) {
      push (@fout, ($cur)) if ($prev ne $cur);
      $prev = $cur;
    }
    unshift (@fout, $head);
    push (@hout, (join (':', @fout)));
  }
  $prev = '';
  foreach $cur (sort (@hout)) {
    push (@fields, ($cur)) if ($prev ne $cur);
    $prev = $cur;
  }
  print @fields;
}
