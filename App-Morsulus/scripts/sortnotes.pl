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
  my @fields = split (/\|/, $_, 99);     # Split the record into fields.
  my @notes = split_notes($fields[4]);
  if (@notes)
  {
    $fields[4] = '('.join(')(', @notes).')';
  }
  print @fields;
}

sub split_notes
{
    my $notes = shift;
    return unless defined $notes;
    my $pad = $notes;
    $pad =~ s/^.(.+).$/$1/;
    return split(/\)\(/, $pad);
}
