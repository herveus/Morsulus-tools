#!/usr/bin/perl

#  Sort a database by blazon.

foreach (sort blaorder <>) { print $_; }

sub blaorder {
  # split into fields
  @Fa = split (/\|/, $a);
  @Fb = split (/\|/, $b);
  $blaa = $Fa[3];
  $blab = $Fb[3];

  if ($blaa eq $blab) {
    #  Same blazon; sort on whole record.
    return $a cmp $b;
  }
  $keya = $blaa;
  $keyb = $blab;

  #  Different blazons; sort on normalized blazon.

  $keya =~ s/\bSt\./Saint/g;    # expand St.
  $keya =~ s/\bSte\./Sainte/g;  # expand Ste.
#  $keya =~ s/\{([Aa])o\}/$1a/g; # convert ring-a (commented 10/98)
  $keya =~ s/\{(.)[nou-]\}/$1/g;# delete breves and other rings
  $keya =~ tr/A-Z/a-z/;         # convert to lower case
#  $keya =~ s/\{(.)\:\}/$1e/g;   # convert umlaut to e (commented 10/98)
#  $keya =~ s/\{o\/\}/oe/g;      # convert slash-o (commented 10/98)
  if ($keya =~ /^[(](field|tincture)less[)](.*)$/) {
    $keya = $2;
  }

  #  normalize variant spellings
  $keya =~ s/\bax\b/axe/g;
  $keya =~ s/\barrondy\b/arrondi/g;
  $keya =~ s/\bbarruly\b/barry/g;
  $keya =~ s/\bbillety\b/billetty/g;
  $keya =~ s/\bbret(a|e|te)ss(e|ed|ee|y)\b/bretessed/g;
  $keya =~ s/\bcaltrop/caltrap/g;
  $keya =~ s/\bchap(e|p)e\b/chape/g;
  $keya =~ s/\bchausee\b/chausse/g;
  $keya =~ s/\bchequ(e)?y\b/checky/g;
  $keya =~ s/\bcot(is|ti)se/cotise/g;
  $keya =~ s/\bgout(e)?/goutte/g;
  $keya =~ s/\bgouttee\b/goutty/g;
  $keya =~ s/\bgr[iy](ff|ph)[io]n/griffin/g;
  $keya =~ s/\bheris[a-y]+\b/herissonne/g;
  $keya =~ s/\bpapel[e-y]+\b/papillonne/g;
  $keya =~ s/\bpat(t)?(e|y)\b/patty/g;
  $keya =~ s/\bplum(m)?et(t)?y\b/plumetty/g;
  $keya =~ s/\bseme(e)?\b/semy/g;
  $keya =~ s/\bypotrill/ypotryll/g;
  $keya =~ tr/ a-z//cd;         # delete non-alphabetic characters exc. blanks

  $keyb =~ s/\bSt\./Saint/g;   # expand St.
  $keyb =~ s/\bSte\./Sainte/g; # expand Ste.
#  $keyb =~ s/\{([Aa])o\}/$1a/g;# convert ring-a (commented 10/98)
  $keyb =~ s/\{(.)[nou-]\}/$1/g;# delete breves and other rings
  $keyb =~ tr/A-Z/a-z/;     # convert to lower case
#  $keyb =~ s/\{(.)\:\}/$1e/g;  # convert umlaut to e (commented 10/98)
#  $keyb =~ s/\{o\/\}/oe/g;     # convert slash-o (commented 10/98)
  if ($keyb =~ /^[(](field|tincture)less[)](.*)$/) {
    $keyb = $2;
  }

  #  normalize variant spellings
  $keyb =~ s/\bax\b/axe/g;
  $keyb =~ s/\barrondy\b/arrondi/g;
  $keyb =~ s/\bbarruly\b/barry/g;
  $keyb =~ s/\bbillety\b/billetty/g;
  $keyb =~ s/\bbret(a|e|te)ss(e|ed|ee|y)\b/bretessed/g;
  $keyb =~ s/\bcaltrop/caltrap/g;
  $keyb =~ s/\bchap(e|p)e\b/chape/g;
  $keyb =~ s/\bchausee\b/chausse/g;
  $keyb =~ s/\bchequ(e)?y\b/checky/g;
  $keyb =~ s/\bcot(is|ti)se/cotise/g;
  $keyb =~ s/\bgout(e)?/goutte/g;
  $keyb =~ s/\bgouttee\b/goutty/g;
  $keyb =~ s/\bgr[iy](ff|ph)[io]n/griffin/g;
  $keyb =~ s/\bheris[a-y]+\b/herissonne/g;
  $keyb =~ s/\bpapel[e-y]+\b/papillonne/g;
  $keyb =~ s/\bpat(t)?(e|y)\b/patty/g;
  $keyb =~ s/\bplum(m)?et(t)?y\b/plumetty/g;
  $keyb =~ s/\bseme(e)?\b/semy/g;
  $keyb =~ s/\bypotrill/ypotryll/g;
  $keyb =~ tr/ a-z//cd;        # delete non-alphabetic characters exc. blanks

  $cmp = ($keya cmp $keyb);
  return $cmp ? $cmp : ($a cmp $b);
}
