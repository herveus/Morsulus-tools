#!/usr/local/bin/perl

#%  Remove branch designators from a text file.
#  Used to find incompatible branch designators.

$\ = "\n";

while (<>) {
  chop;

  s/<//;
  s/>//;
  s/ (Incipient )?(Crown )?(Bailiwick|Barony|Barony\-Marche|Borough|Canton|City\-State|College|Collegio|Dominion|Fortaleza|L'Universite|Kanton|Kingdom|March|Port|Principality|Province|Riding|Shire|Stronghold|University)( de| of)?( the| l'| la| los| nan)?$//i;
  s/schire$//i;
  s/scir$//i;
  s/shire$//i;

  print $_;
}
