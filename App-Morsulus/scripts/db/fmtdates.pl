#!/usr/bin/perl

#%  Format dates (edit type, text, and notes) for printing an armorial.

$\ = "\n";
$, = '|';
$[ = 1;

@month_name = ('January', 'February', 'March', 'April', 'May', 'June',
 'July', 'August', 'September', 'October', 'November', 'December');
%kingdom_name = ('A' , 'Atenveldt', 'C' , 'Caid', 'D' , 'Drachenwald',
 'E' , 'East',   'H' , 'AEthelmearc', 'K' , 'Calontir',
 'L' , 'Laurel', 'M' , 'Middle', 'm', 'Ealdormere', 'n', 'Northshield', 
 'N' , 'An Tir', 'O' , 'Outlands',
 'Q' , 'Atlantia', 'R' , 'Artemisia', 'S' , 'Meridies',
 'T' , 'Trimaris', 'W' , 'West',
 'w' , 'Lochac',   'X' , 'Ansteorra');

for (1 .. $#month_name) {
  $month_name[$_] = substr ($month_name[$_], 1, 3);
}

# generate table of (four-letter) Kingdom-name abbreviations
while (($a,$b) = each(%kingdom_name)) {
  $b =~ s/ //;
  $kingdom_name{$a} = substr ($b, 1, 4);
}

while (<>) {
  chop;                               # Strip off the record separator.
  @fields = split (/\|/, $_, 99);     # Split the record into fields.
  $sources = $fields[2];
  $type = $fields[3];
  $text = $fields[4];
  $notes = $fields[5];

  if ($type eq 'NC' || $type eq 'BNC') {
    $text =~ s/^See //;
  } elsif ($type eq 'AN') {
    $text =~ s/^For //;
  }
  # 'R' records keep their 'See' prefix

  if ($sources !~ /\-/) {
    if ($sources ne '') {
      $ce = substr ($sources, 3, 2);
      $month = substr ($sources, 5, 2);
      $kingdom = substr ($sources, 6, 1);
      $date = "$month_name[$month] '$ce";
      $date .= " $kingdom_name{$kingdom}" if ($kingdom ne '');
      $date .= '?' if ($type =~ /^B?[ABDS]$/);
    } else {
      $date = 'date?';
    }
    if ($type =~ /^(.+)C$/) {
      $date = "changed $date";
      $type = $1;
      $text = "to $text";
    } elsif ($type =~ /^(.+)c$/) {
      $date = "corrected $date";
      $type = $1;
      $text = "to $text";
    } elsif ($type eq 'u') {
      $date = "updated $date";
      $type = 'N';
      $text = "to $text";
    }

  } else {
    ($d1, $d2) = split (/\-/, $sources);
    if ($d1 ne '') {
      $ce = substr ($d1, 3, 2);
      $month = substr ($d1, 5, 2);
      $kingdom = substr ($d1, 6, 1);
      $date1 = "$month_name[$month] '$ce";
      $date1 .= " $kingdom_name{$kingdom}" if ($kingdom ne '');
    } else {
      $date1 = "date?";
    }
    if ($d2 ne '') {
      $ce = substr ($d2, 3, 2);
      $month = substr ($d2, 5, 2);
      $kingdom = substr ($d2, 6, 1);
      $date2 = "$month_name[$month] '$ce";
      $date2 .= " $kingdom_name{$kingdom}" if ($kingdom ne '');
    } else {
      $date2 = "date?";
    }

    $formatted = 0;
    if ($type =~ /^(.+)C$/) {
      $date = $date1;
      $type = $1;
      $type = 'Name' if ($type eq 'N');
      $text = "changed ($date2) to $text";
    } elsif ($type =~ /^(.+)c$/) {
      $date = $date1;
      $type = $1;
      $type = 'Name' if ($type eq 'N');
      $text = "corrected ($date2) to $text";
    } elsif ($type eq 'u') {
      $date = $date1;
      $type = 'Name';
      $text = "designator updated ($date2) to $text";
    } elsif ($notes =~ /^(.*)[(]-([^)]+)[)](.*)$/) {
      $notes = $1.$3;
      $resolution = $2;
      $date = $date1;
      $text = "-$text";
      if ($notes eq '') {
        $notes = "$resolution ($date2)";
      } else {
        $notes .= " $resolution ($date2)";
      }
    } else {
      $date = "$date1 to $date2";
      $text = "-$text" if ($text ne '');
    }
  }

  if ($type =~ /^[abdst]$/) {
    # note that 'g' records remain lower-case
    $type =~ tr/abdst/ABDST/;
  }
  $fields[2] = $date;
  $fields[3] = $type;
  $fields[4] = $text;
  $fields[5] = $notes;
  print @fields;
}
