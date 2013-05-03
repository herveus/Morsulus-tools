#!/usr/bin/perl
#  Sort a database by date, kingdom, and name -- approximate LoAR order.

$[ = 1;

foreach (sort loar_order <>) { print $_; }

sub loar_order {
  # split into fields
  @Fa = split (/\|/, $a);
  @Fb = split (/\|/, $b);

  $srca = $Fa[2];
  $srcb = $Fb[2];

  if ($srca =~ /\-/) {
    ($srca, $s2) = split (/\-/, $srca);
    $srca = $s2
      if ($Fa[3] =~ /^ANC|BNC|BNc|Bv|Bvc|NC|Nc|u|v|vc$/ || $srca eq '');
  }
  if ($srcb =~ /\-/) {
    ($srcb, $s2) = split (/\-/, $srcb);
    $srcb = $s2
      if ($Fb[3] =~ /^ANC|BNC|BNc|Bv|Bvc|NC|Nc|u|v|vc$/ || $srcb eq '');
  }

  if ($srca ne $srcb) {
    $datea = substr ($srca, 1, 4);
    $dateb = substr ($srcb, 1, 4);
    if ($datea ne $dateb) {
      $datea += 10000 if ($datea ne '' && $datea < 6600);
      $dateb += 10000 if ($dateb ne '' && $dateb < 6600);
      return $datea cmp $dateb;
    }

    $ka = substr ($srca, 5);
    $kb = substr ($srcb, 5);
    $ka =~ tr/HNXRAQCKDmELwSMOTW/abcdefghijklmnopqr/;
    $kb =~ tr/HNXRAQCKDmELwSMOTW/abcdefghijklmnopqr/;
    return $ka cmp $kb;
  }

  $nna = $Fa[1];
  if ($Fa[3] eq 'NC' || $Fa[3] eq 'BNC') {
    $nna = $Fa[4];
    $nna = $1 if ($nna =~ /^See (.+)$/);
  } elsif ($Fa[3] eq 'AN') {
    $nna = $Fa[4];
    $nna = $1 if ($nna =~ /^For (.+)$/);
  } elsif ($Fa[3] eq 'HN' || $Fa[3] eq 'O' || $Fa[3] eq 't') {
    $nna = $Fa[4];
  }
  $nnb = $Fb[1];
  if ($Fb[3] eq 'NC' || $Fb[3] eq 'BNC') {
    $nnb = $Fb[4];
    $nnb = $1 if ($nnb =~ /^See (.+)$/);
  } elsif ($Fb[3] eq 'AN') {
    $nnb = $Fb[4];
    $nnb = $1 if ($nnb =~ /^For (.+)$/);
  } elsif ($Fb[3] eq 'HN' || $Fb[3] eq 'O' || $Fb[3] eq 't') {
    $nnb = $Fb[4];
  }

  $nna =~ s/\bSt\./Saint/g;   # expand St.
  $nna =~ s/\bSte\./Sainte/g; # expand Ste.
#  $nna =~ s/\{([Aa])o\}/$1a/g;# convert ring-a (commented 10/98)
  $nna =~ s/\{(.)[nou,-]\}/$1/g;# delete breves and other rings
  $nna =~ tr/A-Z\-,/a-z  /;     # convert to lower case
#  $nna =~ s/\{(.)\:\}/$1e/g;  # convert umlaut to e (commented 10/98)
#  $nna =~ s/\{o\/\}/oe/g;     # convert slash-o (commented 10/98)
  $nna =~ tr/ a-z//cd;        # delete non-alphabetic characters exc. blanks

  $nnb =~ s/\bSt\./Saint/g;   # expand St.
  $nnb =~ s/\bSte\./Sainte/g; # expand Ste.
#  $nnb =~ s/\{([Aa])o\}/$1a/g;# convert ring-a (commented 10/98)
  $nnb =~ s/\{(.)[nou,-]\}/$1/g;# delete breves and other rings
  $nnb =~ tr/A-Z\-,/a-z  /;     # convert to lower case
#  $nnb =~ s/\{(.)\:\}/$1e/g;  # convert umlaut to e (commented 10/98)
#  $nnb =~ s/\{o\/\}/oe/g;     # convert slash-o (commented 10/98)
  $nnb =~ tr/ a-z//cd;        # delete non-alphabetic characters exc. blanks

  return $nna cmp $nnb;
}
