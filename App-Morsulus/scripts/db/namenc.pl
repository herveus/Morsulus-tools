#!/usr/local/bin/perl

#%  List name-changes -corrections, and -updates 
#%   that lack matching registration data.

$\ = "\n";

while (<>) {
  chop;  # Strip off the record separator.

  # Split the record into fields.
  ($name, $source, $type, $text, $notes, $other) = split (/\|/);
  $text =~ s/^See // if ($type eq 'NC' || $type eq 'BNC');
  ($reg, $rel) = split (/\-/, $source);
  if ($type eq 'u') {
    $type = 'BNC';
  }
  if ($type eq 'NC') {
    if ($notes =~ /variant/) {
      $type = 'vc';
    } elsif ($notes =~ /designation/) {
      $type = 'RC';
    } elsif ($notes =~ /branch/) {
      $type = 'BNC';
    } elsif ($notes =~ /title/) {
      $type = 'tC';
    } elsif ($notes =~ /household name/) {
      $type = 'HNC';
    } elsif ($notes =~ /order name/) {
      $type = 'OC';
    } elsif ($notes =~ /alternate name/) {
      $type = 'ANC';
    }
  }
  if ($type =~ /^(N|BN|t|HN|O|AN)[Cc]$/) {
    $class = $1;
    $name = "$class!$name";
    $text = "$class!$text";
    if ($source !~ /\-/) {
      $reg = '';
      $rel = $source;
    }
    if ($notes !~ /erroneous/ && $rel ne '' && $notes !~ /belated/) {
      $r = $referenced{$text};
      if ($r eq '') {
        $referenced{$text} = $rel;
      } elsif ($r ne $rel) {
        print "$text -- two change/correction/update sources: $r $rel";
      }
    }
    if ($notes !~ /inaccurate/ && $reg ne '') {
      $r = $registered{$name};
      if ($r eq '') {
        $registered{$name} = $reg;
      } elsif ($r ne $reg) {
        print "$name -- two registration sources: $r $reg";
      }
    }
    
  } elsif ($type =~ /^N|BN|t|HN|O|AN$/) {
    $name = "$type!$name";
    if ($reg ne '') {
      $r = $registered{$name};
      if ($r eq '') {
        $registered{$name} = $reg;
      } elsif ($r ne $reg) {
        print "$name -- two registration sources: $r $reg";
      }
    }
    
  }
}

while (($name, $date) = each %registered) {
  $r = $referenced{$name};
  if ($r eq '') {
    delete $referenced{$name};
  }
}

while (($name, $date) = each %referenced) {
  $reg = $registered{$name};
  if ($date ne '' && $date ne $reg) {
    if ($reg eq '') {
      print "$date $name -- missing registration source";
    } else {
      print "$name -- wrong registration source -- should be $date, not $reg";
    }
  }
}
