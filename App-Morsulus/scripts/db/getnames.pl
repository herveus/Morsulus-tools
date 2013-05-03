#!/usr/local/bin/perl

#%  Extract names from an ordinary database.

$\ = "\n";
$[ = 1;
$, = "\n";

while ($_ = $ARGV[1], /^-./) {
  shift;
  last if (/^--$/);
  if (/^-mr$/) { $get_minimal_registrants = 1; next; }
  if (/^-r$/) { $get_registrants = 1; $get_minimal_registrants = 1; $get_current_registrants; next; }
  if (/^-cr$/) { $get_current_registrants = 1; next; }

  if (/^-f1$/) { $get_name_field_names = 1; next; }
  if (/^-f4$/) { $get_text_field_names = 1; next; }
  if (/^-f5$/) { $get_notes_field_names = 1; next; }
  die "Bad option: $_\n";
}

while (<>) {
  chop;  # Strip off the record separator.

  # Split the record into fields.
  ($name, $s, $type, $text, $notes, $other) = split (/\|/);
  if ($type eq 'N' || $type eq 'BN') {
    if ($get_name_field_names || $get_minimal_registrants || $get_current_registrants) {
      print $name;
    }

  } elsif ($type eq 'NC' || $type eq 'BNC') {
    $ahonc = ($notes =~
/(alternate|household|order) name (variant )?(change|correction|verification)/);
    $correction = ($notes =~ /variant correction/);
    $inaccurate = ($notes =~ /inaccurate/);
    if ($get_name_field_names ||
        $get_minimal_registrants && !$ahonc && !$correction && !$inaccurate) {
      print $name;
    }
    if ($get_text_field_names || $get_registrants && !$ahonc) {
      $targets = $text;
      $targets =~ s/^See //;
      print $targets;
    }

  } elsif ($type eq 'OC' || $type eq 'ANC' || $type eq 'HNC'
        || $type eq 'Nc' || $type eq 'BNc') {
    if ($get_name_field_names) {
      print $name;
    }
    if ($get_text_field_names) {
      print $text;
    }

  } elsif ($type eq 'T') {
    print $name
     if ($get_name_field_names || $get_current_registrants);
    print $text if ($get_text_field_names);

  } elsif ($type =~ /^[ABDSabdgs]$/ || $type eq 'D?' || $type eq 'BD') {
    print $name
     if ($get_name_field_names || $get_minimal_registrants || $get_current_registrants);

  } elsif ($type eq 'AN') {
    if ($get_name_field_names) {
      print $name;
    }
    if ($get_text_field_names || $get_current_registrants) {
      $targets = $text;
      $targets =~ s/^For //;
      print $targets;
    }

  } elsif ($type =~ /^(HN|O|t)$/) {
    if ($get_name_field_names) {
      print $name;
    }
    if ($get_text_field_names || $get_current_registrants) {
      $targets = $text;
      $targets = $1 if ($targets =~ /^\"(.*)\"$/);
      @targs = split (/\" and \"/, $targets);
      print @targs;
    }

  } elsif ($type eq 'R') {
    if ($get_name_field_names) {
      print $name;
    }
    if ($get_registrants || $get_text_field_names) {
      $targets = $text;
      if ($targets =~ /^See joint badge for (.+) under (.+)$/) {
        print $2;
      } else {
        $targets =~ s/^See (also |joint badge under )?//;
        if ($targets =~ /^\"(.*)\"$/) {
          $targets = $1;
        }
        @targs = split (/\" or \"/, $targets);
        print @targs;
      }
    }

  } elsif ($type eq 'j') {
    if ($get_name_field_names || $get_current_registrants) {
      print $name;
    }
    if ($get_text_field_names || $get_current_registrants) {
      print $text;
    }

  } elsif ($type eq 'v' || $type eq 'Bv') {
    $ahov = ($notes =~ /(alternate|household|order) name variant/);
    if ($get_name_field_names) {
      print $name;
    }
    if ($get_text_field_names || $get_registrants && !$ahov) {
      print $text;
    }

  } else {
    if ($get_name_field_names) {
      print $name;
    }
  }

  if ($notes =~ /^\((.*)\)$/) {
    foreach (split (/\)\(/, $1)) {
      if (/^Also the arms of( the)? (.+)$/) {
        print $2 if ($get_notes_field_names || $get_current_registrants);
      } elsif (/^JB: (.+)$/) {
        print $1 if ($get_notes_field_names || $get_current_registrants);
      } elsif (/^same (person|branch) as ( the)? (.+)$/) {
        print $3 if ($get_notes_field_names || $get_current_registrants);
      } elsif (/^-?transferred to( the)? (.+)$/) {
        print $2 if ($get_notes_field_names || $get_current_registrants);
      } elsif (/^For( the)? (.+)$/) {
        $listing = $2;
        if ($listing =~
          /^(award|bard|borough|college|compagnie|guild|honou?r of the|orde[nr]|ord[eo]|ordre|braithrean|brotherhood|casa|castle of|castrum|ch[a\342]teau|ch\{a\^\}teau|clan|clann|company|fellowship|freehold|house|household|h[ao]?us|keep|league|maison|office) (.*)/i) {
	  $listing = "$2, $1";
	  if ($listing =~
            /^(a[fn]|aus|d[eou]|de[ils]|della|in|na|of?|van|vo[mn]) (.*)/i) {
	    $listing = "$2 $1";
          }
	  if ($listing =~
             /^(das|de[mn]|der|die|el|l[ae]|les|the) (.*)/i) {
             $listing = "$2 $1";
          }
	}
	print $listing if ($get_notes_field_names);
      }
    }
  } # if $get_notes_field
}
