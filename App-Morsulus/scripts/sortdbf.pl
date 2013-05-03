#!/usr/bin/perl

#  Sort a database by name.

foreach (sort armorder <>) { print $_; }

sub armorder {
  # split into fields
  ($na, $da, $ta, $ja) = split (/\|/, $a);
  ($nb, $db, $tb, $jb) = split (/\|/, $b);

  if ($na ne $nb) {
    #  Different names; sort on normalized name.
    $nna = $na;
    $nna =~ s/\bSt\./Saint/g;   # expand St.
    $nna =~ s/\bSte\./Sainte/g; # expand Ste.
#    $nna =~ s/\{([Aa])o\}/$1a/g;# convert ring-a (commented 10/98)
    $nna =~ s/\{([A-Za-z])[nouv,-]\}/$1/g;# delete breves, carons, other rings
    $nna =~ tr/A-Z\-,/a-z  /;     # convert to lower case
#    $nna =~ s/\{([a-z])\:\}/$1e/g;# convert umlaut to e (commented 10/98)
#    $nna =~ s/\{o\/\}/oe/g;     # convert slash-o to oe (commented 10/98)
    $nna =~ tr/ a-z//cd;        # delete non-alphabetic characters exc. blanks

    $nnb = $nb;
    $nnb =~ s/\bSt\./Saint/g;   # expand St.
    $nnb =~ s/\bSte\./Sainte/g; # expand Ste.
#    $nnb =~ s/\{([Aa])o\}/$1a/g;# convert ring-a (commented 10/98)
    $nnb =~ s/\{([A-Za-z])[nouv,-]\}/$1/g;# delete breves, carons, other rings
    $nnb =~ tr/A-Z\-,/a-z  /;     # convert to lower case
#    $nnb =~ s/\{([a-z])\:\}/$1e/g;# convert umlaut to e (commented 10/98)
#    $nnb =~ s/\{o\/\}/oe/g;     # convert slash-o (commented 10/98)
    $nnb =~ tr/ a-z//cd;        # delete non-alphabetic characters exc. blanks

    $cmp = ($nna cmp $nnb);
    return $cmp ? $cmp : ($na cmp $nb);

  } else {
    #  Identical names; sort on type and date.
    $ta =~ tr/A-Z/a-z/;        # convert to lower case
    $ta = '' if ($ta eq 'n' || $ta eq 'bn');
    $ta = ' ' if ($ta eq 'd' || $ta eq 'bd');

    $tb =~ tr/A-Z/a-z/;        # convert to lower case
    $tb = '' if ($tb eq 'n' || $tb eq 'bn');
    $tb = ' ' if ($tb eq 'd' || $tb eq 'bd');

    $cmp = ($ta cmp $tb);
    return $cmp ? $cmp : ($da cmp $db);
  }
}
