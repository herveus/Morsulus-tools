#!/usr/bin/perl

#%  Remove branch designator updates ('u' records) from a database.

$\ = "\n";
$[ = 1;
$, = "\n";

while (<>) {
  chop;  # Strip off the record separator.

  # Split the record into fields.
  ($name, $dates, $type, $text, $other) = split (/\|/, $_, 5);
  if ($type eq 'u') {
    if ($dates =~ /^(.*)-(.*)$/) {
      $d1 = $1;
      $d2 = $2;
    } else {
      $d1 = '';
      $d2 = $dates;
    }

    # In the case of Marinus, two 'u' entries share the same d1, d2, and text!
    die "dup d1 entry for {$d2 $text}"
      if (defined $d1{"$d2 $text"} && $d1{"$d2 $text"} ne $d1);
    #die "dup n1 entry for {$d2 $text}" if defined $n1{"$d2 $text"};

    $d1{"$d2 $text"} = $d1;
    $n1{"$d2 $text"} = $name;
    #print "adding d1 and entries for {$d2 $text}\n";
  } elsif ($type =~ /^B(N[Cc]?|D)$/) {
    push (@list, $_);
  } else {
    print "$name|$dates|$type|$text|$other";
  }
}

while ($_ = shift(@list)) {
  # Split the record into fields.
  ($name, $dates, $type, $text, $other) = split (/\|/, $_, 5);
  if ($type eq 'BN') {
    if ($dates =~ /^(.*)-(.*)$/) {
      $d1 = $1;
      $d2 = $2;
    } else {
      $d1 = $dates;
      $d2 = '';
    }

    $lookup = "$d1 $name";
    while (defined ($d1{$lookup}) && defined ($n1{$lookup})) {
      $d1 = $d1{$lookup};
      $name = $n1{$lookup};
      die if ($n1{$lookup} eq '');
      $n1{$lookup} = '';
      $lookup = "$d1 $name";
    }

    if ($d2 eq '') {
      $dates = $d1;
    } else {
      $dates = "$d1-$d2";
    }

  } elsif ($type eq 'BD') {
    die if ($dates =~ /-/);

    $lookup = "$dates $name";
    if (defined ($d1{$lookup}) && defined ($n1{$lookup})) {
      print "$name||d|$text|$other";
      $type = 'BN';
      $text = '';
      $other = '';
    }

    while (defined ($d1{$lookup}) && defined ($n1{$lookup})) {
      $dates = $d1{$lookup};
      $name = $n1{$lookup};
      die if ($n1{$lookup} eq '');
      $n1{$lookup} = '';
      $lookup = "$dates $name";
    }
      
  } elsif ($type =~ /^BN[Cc]$/) {
    if ($dates =~ /^(.*)-(.*)$/) {
      $d1 = $1;
      $d2 = $2;
    } else {
      $d1 = '';
      $d2 = $dates;
    }

    $lookup = "$d1 $name";
    while (defined ($d1{$lookup}) && defined ($n1{$lookup})) {
      $d1 = $d1{$lookup};
      $name = $n1{$lookup};
      die if ($n1{$lookup} eq '');
      $n1{$lookup} = '';
      $lookup = "$d1 $name";
    }

    if ($d1 eq '') {
      $dates = $d2;
    } else {
      $dates = "$d1-$d2";
    }
  } else {
    die;
  }
  print "$name|$dates|$type|$text|$other";
}

# check that every 'u' record was used
foreach (keys %n1) {
  die $_ if ($n1{$_} ne '');
}
