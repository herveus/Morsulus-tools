#!/usr/bin/env perl
$|++;
use Daud;

#%  check database format on a record-by-record basis

# modified 4/18/00 to correct bugs resulting from not capturing $1, etc
# immediately after the RE match and counting on them to survive the next RE.

$, = '|';
$\ = "\n";
#$[ = 1;

$firstdate = 197002; # earliest entry in the database
$splitdate = 197909; # first month for which all names & armory are split
$lastdate  = shift; # latest entry in the database

$armorial_mode = 0;

#  Parse the command-line options, if any.
while ($_ = $ARGV[0], /^-./) {
  shift;
  last if (/^--$/);    #  end of options
  $armorial_mode = 1 if (/^-a$/);
}

%count = ();

%known_daud = ();
#$unicode_filename = '/Users/herveus/aux/coa.tab';
#open (TAB, $unicode_filename) || die "cannot open $unicode_filename";
#while (<TAB>) {
for (Daud::_raw_data) {
  $known_daud{$1} = 1 if (/^([^;]{1,3});/);
}
close TAB;

%known_category = ();
%known_feature = ();
$cat_filename = '/Users/herveus/aux/mike.cat';
open (CATS, $cat_filename) || die "cannot open $cat_filename";
while (<CATS>) {
  chomp;
  if (/^[|]([0-9a-z_]+)[:]([ 0-9a-z_~]+)/) {
    $known_feature{$2} = $1;
  } elsif (/^[ 0-9a-z,'&]+[|]([ 0-9A-Z_,'&.*()+-]+)([|][0-9a-z:_]*)?$/) {
    $known_category{$1} = 1;
  }
}
close CATS;

# The following features have been completely broken down in the database:
delete $known_feature{'2 or more'};
delete $known_feature{'3 or more'};
delete $known_feature{'5 or more'};
delete $known_feature{'neutral'};
delete $known_feature{'of 3 or 4'};
delete $known_feature{'other bird posture'};

# The following features have been abbreviated out of the database:
delete $known_feature{'sole primary not alone'};
delete $known_feature{'sole primary alone'};
delete $known_feature{'group primary not alone'};
delete $known_feature{'group primary alone'};
delete $known_feature{'uncharged'};
delete $known_feature{'plain line'};
delete $known_feature{'secondary'};

while (<>) {
  # strip record separator
  chomp;
  $record = $_;

  # split into fields
  @fields = split (/[|]/, $_, 99);
  ($name, $dates, $type, $text, $notes, @descriptions) = @fields;
  $num_stiles = $#fields;
  &report("too few stiles ($num_stiles) in record") if ($num_stiles < 4);

  if ($name eq $text) {
    &report("name and text fields are identical");
  }

  # look at third (type) field
  $has_blazon = 0;
  $combined = 0;
  $historical_type = 0;
  $name_only = 0;
  if ($type =~ /^([BD]|BD)$/) {
    $has_blazon = 1;
    $combined = 1;
  } elsif ($type =~ /^([abdgs]|D[?])$/) {
    $has_blazon = 1;
  } elsif ($type =~ /^(ANC|BNC|BNc|Bvc|HNC|NC|Nc|OC|u|vc)$/) {
    $historical_type = 1;  # change/correction/update
  } elsif ($type =~ /^(N|BN|ABN)$/) {
    $name_only = 1;
  } elsif ($type =~ /^([CORjtvWr]|AN|Bv|HN|BP)$/) {
  } else {
    &report("unknown record type ($type)");
  }
  
  # look at second (date) field
  @dates = split (/[-]/, $dates, 9);
  $num_dashes = @dates - 1;
  &report("too many dashes ($num_dashes) in date field") if ($num_dashes > 1);
  $historical = (@dates == 2);
  if ($historical_type && !$historical) {
    @dates = ('', $dates);
    $historical = 1;
  }
  &count('record');
  # TODO: should not be a registration date for inaccurate name ch or corr
  # TODO: should be only one date for B, D, and BD type records
  &count('missing registration date') if ($dates[0] eq '');
  $d1 = &check_date ($dates[0]);
  if ($historical) {
    if ($dates[1] eq '') {
      &count('missing disposition date');
    } else {
      &count('disposition date')
    }
    $d2 = &check_date ($dates[1]);
    &report("dates ($dates) are out-of-order") if ($d2 ne '' && $d1 > $d2);
    &report("dates ($dates) are same") if ($d2 ne '' && $d1 == $d2);
  }
  &report("name and armory ought to be split")
    if ($combined && $d1 ne '' && $d1 >= $splitdate);

  # look at fifth (notes) field
  $nonsca = 0;
	$notes =~ s/\(Owner: [^)]+\)//;
  if ($notes ne '') {
    &report("unexpected notes field")
      if ($type =~ /^([Cu]|ANC|BNc|Bvc|HNC|OC)$/);
    local ($temp_notes) = $notes;
    while ($temp_notes =~ /^[(]([^)]+)[)](.*)$/) {
      $temp_notes = $2;
      &check_note ($1);
    }
    &report("un-enclosed text ($temp_notes) in notes field")
      if ($temp_notes ne '');
  }

  # look at first (name) field
  if ($type eq 'C') {
    &report("name-field of comment should be blank")
      if ($name ne ' ');
  } elsif ($type =~ /^HNC?$/) {
    # household name
    &check_household_name ($name);
  } elsif ($type =~ /^([BDNOv]|AN|ANC|NC|Nc|OC|vc)$/) {
    # couldn't be a branch name or heraldic title
    &check_name ($name, 1);
  } elsif ($type =~ /^(BN|t)$/) {
  	&check_name ($name, 2);
  } else {
    # might be a branch name or heraldic title
    &check_name ($name, 0);
  }

  # look at final (description) fields
  if ($#fields > 5) {
    &report("record has descriptions but no blazon")
      unless ($has_blazon);
    &report("historical record has descriptions")
      if ($historical);
  } elsif ($has_blazon && !$historical && !$armorial_mode) {
    &report("record has blazon but no descriptions");
  }
  foreach $description (@descriptions) {
    &check_description ($description);
  }

  # look at the fourth (text) field
  if ($has_blazon) {
    &check_blazon ($text);
  } elsif ($type eq 'NC') {
    if ($text =~ /^See (.+)$/) {
      local ($t) = $1;
      &check_name ($t, 0);
      &report("names in accurate name change are identical ($notes)")
        if ($name eq $t && $notes !~ /inaccurate/);
    } else {
      &report("new name not prefixed with 'See'");
    }
  } elsif ($type eq 'AN') {
    if ($text =~ /^For (.+)$/) {
      local ($t) = $1;
      &check_name ($t, 1);
      &report("name and alt name are identical")
        if ($name eq $t);
    } else {
      &report("holder's name not prefixed with 'For'");
    }
  } elsif ($type eq 'R') {
    local ($t);
    if ($text =~ /^See "(.+)"$/) {
      local (@n) = split (/" or "/, $1, 99);
      foreach $t (@n) {
        &check_name ($t, 0);
        &report("name and xref are identical")
          if ($name eq $t);
      }
    } elsif ($text =~ /^See (.+)$/) {
      $t = $1;
      &check_name ($t, 0);
      &report("name and xref are identical")
        if ($name eq $t);
    } else {
      &report("cross reference not prefixed with 'See'");
    }
  } elsif ($type eq 'BNC') {
    if ($text =~ /^See (.+)$/) {
      local ($t) = $1;
      &check_name ($t, 0);
      &report("names in branch name change are identical")
        if (&delangle ($name) eq &delangle ($t));
    } else {
      &report("new branch name not prefixed with 'See'");
    }
  } else {
    if ($text =~ /^(See|For) (.+)$/) {
      &report("text field begins with '$1'");
    }
    if ($type eq 'u') {
      &report("names in designator update are not identical")
        if (&delangle ($name) ne &delangle ($text));
    }
	elsif ($type =~ /^(O|t)$/)
	{
		&check_name($text, 2);
	}
  }
}

# print statistics
printf "\n";

if ($count{'record'} > 0) {
  foreach $what (
    'record', 
    'missing registration date',
    'disposition date',
    'missing disposition date',
    'note date'
  ) {
    printf "%7d %s (%.2f%%)\n",
      $count{$what}, &s($what), 100 * $count{$what} / $count{'record'};
  }

  $total_dates = $count{'record'} + $count{'historical date'}
    - $count{'missing registration date'} + $count{'note date'};
  printf "%7d dates, total\n", $total_dates;
}

sub check_note {
  # global $type, $nonsca
  local($note) = @_;
  
  #print "note: ($note)\n";
  if ($note =~ /^For (.+)$/) {
    # designation
	my $chk = $1;
    &report("unexpected designation note ($note)")
      unless ($type =~ /^[Babdgjst]$/);
    &check_name ($chk, 0);
  } elsif ($note =~ /^JB: (.+)$/) {
    # joint badge
	my $chk = $1;
    &report("unexpected joint-badge note ($note)")
      unless ($type =~ /^[Bb]$/);
    &check_name ($chk, 0);
  } elsif ($note =~ /^JHN: (.+)$/) {
    # joint household name
	my $chk = $1;
    &report("unexpected joint-household-name note ($note)")
      unless ($type =~ /^HN$/);
    &check_name ($chk, 0);
  } elsif ($note =~ /^(Banner|Ensign|Flag|Seal|Standard)$/
       || $note =~ /^((Civil|Household|Naval|Royal|War) (badge|banner|ensign))$/
       || $note eq "King's battle flag"
       || $note =~ /^(Household|Secondary) mon$/) {
    # badge subtype
    &report("unexpected SCA badge subtype ($type)")
      unless ($type =~ /^[Bb]$/);
  } elsif ($note =~ /^([A-Za-z]+)'s arms$/ || $note eq 'Mon') {
    # device subtype
    &report("unexpected SCA device subtype ($type)")
      if ($type ne 'd' && $type ne 'D');
  } elsif ($note =~ /^Important non-SCA (.+)$/) {
    $nonsca = 1;
	my $chk = $1;
    # non-SCA registration
    if ($type eq 'b') {
      &report("unrecognized non-SCA badge subtype ($chk)")
        if ($chk ne 'm{o^}n' && $chk ne 'badge' && $chk ne 'flag'
         && $chk ne 'battle flag' && $chk ne 'royal badge');
    } elsif ($type eq 'a') {
      &report("unrecognized non-SCA augmentation subtype ($chk)")
        if ($chk ne 'augmentation' && $chk ne 'arms');
    } elsif ($type eq 'd' || $type eq 'R') {
      &report("unrecognized non-SCA device subtype ($chk)")
        if ($chk ne 'arms');
    } else {
      &report("unexpected non-SCA registration type ($type)");
    }
  } elsif ($note eq 'alternate branch designator') {
    &report("unexpected note ($note)")
      if ($type ne 'R');
  } elsif ($note =~ /^([?] )?duplicate name registration$/) {
    &report("unexpected note ($note)")
      if ($type ne 'N');
  } elsif ($note =~ /^([?] )?should have been a name change$/) {
    &report("unexpected note ($note)")
      if ($type ne 'N');
  } elsif ($note =~ /^([?] )?missing name change$/) {
    &report("unexpected note ($note)")
      if ($type ne 'v');

  } elsif ($note =~
          m#^(.*)(designation|name|title) (change(/conversion)?|correction)$#) {
    # name-change or correction
    local ($rem, $ct) = ($1, $2);

    if ($rem =~ /^(erroneous |inaccurate (and erroneous )?|redundant )?(.*)$/) {
      $rem = $3;
    } else {
      &report("unparseable historical $ct note ($rem)")
    }
    if ($rem =~ /^(administrative |belated )?(.*)$/) {
      $rem = $2;
    } else {
      &report("unparseable historical $ct note ($rem)")
    }
    if ($ct eq 'name') {
      if ($rem =~ /^(branch |household |order )?$/) {
        $ct = $rem.$ct;
      } else {
        &report("unparseable historical $ct note ($note)")
      }
    } else {
      &report("unparseable historical $ct note ($note)")
        if ($rem ne '');
    }
    if ($ct eq 'branch name') {
      &report("unexpected historical $ct note ($note)")
        if ($type ne 'BNC');
    } else {
      &report("unexpected historical $ct note ($note)")
        if ($type ne 'NC');
    }

  } elsif ($note =~ m#^(.*)(designation|name|title) variant( correction)?$#) {
    # name-variant
    local ($rem, $ct, $corr) = ($1, $2, $3);

    if ($rem =~ /^(erroneous |inaccurate (and erroneous )?|redundant )?(.*)$/) {
      $rem = $3;
    } else {
      &report("unparseable $ct variant note ($rem)")
    }
    if ($rem =~ /^(administrative |belated )?(.*)$/) {
      $rem = $2;
    } else {
      &report("unparseable $ct variant note ($rem)")
    }
    if ($ct eq 'name') {
      &report("unparseable $ct variant note ($note)")
        if ($rem !~ /^(household |order )?$/);
      $ct = $rem.$ct;
    } else {
      &report("unparseable $ct variant note ($note)")
        if ($rem ne '');
    }

    if ($corr eq '') {
      if ($ct eq 'branch name') {
        &report("unexpected branch variant note ($note)")
          if ($type ne 'Bv');
      } else {
        &report("unexpected variant note ($note)")
          if ($type ne 'v');
      }
    } else {
      if ($ct eq 'branch name') {
        &report("unexpected branch variant correction note ($note)")
          if ($type ne 'Bvc')
      } else {
        &report("unexpected variant correction note ($note)")
          if ($type ne 'vc');
      }
    }

  } elsif ($note =~ /^-(.+)$/) {
    # disposition
    $note = $1;
    &report("unexpected disposition note ($note) with historical type")
      if ($historical_type);
    &report("unexpected disposition note ($note) with single date")
      unless ($dates =~ /-/);
    if ($note =~ /^transferred to (.+)$/) {
      &check_name ($1, 0);
    } elsif ($note =~ /^converted to branch name for (.+)$/) {
      &check_name ($1, 0);
    } elsif ($note eq 'reblazoned') {
      &report("unexpected reblazoning note ($note) with blazonless type")
        unless ($has_blazon);
    } elsif ($note =~ /^(belatedly |erroneously |should have been )?(add|chang|convert|correct|redesignat|releas|remov|return|transferr|associat)ed/) {
      # ok
    } elsif ($note eq 'designator changed') {
      # ok
    } else {
      &report("unrecognized disposition note ($note)")
    }
  } elsif ($note eq 'Closed') {
    &report("unexpected order note ($note)")
      unless ($type eq 'O');
  } elsif ($note eq 'Deceased') {
    &report("unexpected personal note ($note)")
      if ($type eq 'BN' || $type eq 'BD');
  } elsif ($note =~ /^(Defunct|Disbanded)( as of (.*))?$/) {
    &report("unexpected branch note ($note)")
      if ($type eq 'N' || $type eq 'D');
    &check_note_date ($3) if ($3 ne '');

  } elsif ($note =~ /^re-(register|correct)ed (with new blazon )?(.+)$/) {
    # duplication
    &check_note_date ($3);
  } elsif ($note =~ /^(blazon|name) appeared in (.+)$/) {
    # belated info
    &check_note_date ($2);
  } elsif ($note =~ /^clarified (.+)$/) {
    # clarification
    &check_note_date ($1);

  } elsif ($note =~ /^([?] )?blazon typo for "[^"]+"$/) {
    &report("unexpected blazon note ($note)")
      unless ($has_blazon);
  } elsif ($note =~ /^([?] )?name typo for "[^"]+"$/) {
    # ok

  } elsif ($note =~ /^([?] )?same as (.+)$/) {
    &check_name ($2, 0);
  } elsif ($note =~ /^([?] )?(not the )?same branch as (.+)$/) {
    &check_name ($3, 0);
  } elsif ($note =~ /^([?] )?(not the )?same person as (.+)$/) {
    local($namesake) = $3;
    if ($namesake =~ /^(\d\d\d\d\S) registration$/) {
      &check_date ($1);
      &count('note date');
    } elsif ($namesake =~ /^["]([^"]+)["] or ["]([^"]+)["]$/) {
		my $chk = $1;
		my $chk2 = $2;
      &check_name ($chk, 1);
      &check_name ($chk2, 1);
    } else {
      &check_name ($namesake, 1);
    }
  } elsif ($note =~ /^Also the arms of (.+)$/) {
    &report("unexpected device note ($note)")
      unless ($type eq 'd');
    &check_name ($1, 0);
  } elsif ($note =~ /^([?] )?same badge also registered to ([^;]+)/) {
  	my $chk = $2;
    &report("unexpected badge note ($note)")
      unless ($type =~ /^[Bb]$/);
    &check_name ($chk, 0);
  } elsif ($note =~ /^([?] )?same household name also registered to (.+)$/) {
    &report("unexpected household name note ($note)")
      if ($type ne 'HN');
    &check_name ($2, 0);

  } elsif ($note eq 'attributed' || $note eq 'cant' || $note eq 'pun') {
    &report("unexpected blazon note ($note)")
      unless ($has_blazon);
  } elsif ($note =~ /^(first|second) use of this holding name$/) {
    # ok
  } elsif ($note =~ /^(first|second) registration of this name$/) {
    # ok
  } elsif ($note eq 'name appeal') {
    &report("unexpected name-change note ($note)")
      unless ($type eq 'NC');
  } elsif ($note eq 'branch name appeal') {
    &report("unexpected branch name-change note ($note)")
      unless ($type eq 'BNC');
  } elsif ($note eq '?') {
    # ok
  } elsif ($note =~ /^Owner:/) {
    # ok

  } else { # misc
    &report("unexpected character ($1) in miscellaneous note")
      if ($note =~ m#([^ 0-9A-Za-z'.,:";?/{}-])#);
    #&report("miscellaneous note ($note)")
    #  unless ($note =~ /^(An?|The) .+ (is,?|are|looks? like|points) .+[.]$/);
  }
}

sub check_description {
  # global %known_category, %known_feature
  local($description) = @_;

  local($category, @features) = split (/:/, $description, 99);
  &report("unknown category ($category) in description")
    if ($known_category{$category} eq '');
  local(%f) = ();
  foreach $feature (@features) {
    local($fg) = $known_feature{$feature}; 
    if ($fg eq '') {
      &report("unknown feature ($feature) in description")
    } elsif ($f{$fg} eq '') {
      $f{$fg} = $feature;
    } else {
      &report("multiple $fg features in description ($description)")
    }
    if ($feature eq 'proper' && $category !~ /^(?:HEAD-|LEG AND FOOT-)?BIRD/) {
      &report("proper is applied only to BIRD categories")
    }
    if ($category =~ /^..$/ && $category ne 'PS' && $fg ne 'tertiaries') {
      &report("$feature is never applied to $category")
    }
  }
  local ($fgr) = $f{'group'};
  local ($fnu) = $f{'number'};
  if ($fnu eq 'seme' || $fnu eq 'semy') {
    $fnu = 6;
  } elsif ($fnu =~ /^(\d+) or more$/) {
    $fnu = $1;
  } elsif ($fnu eq '' || $fnu =~ /^(\d+) or fewer$/) {
    $fnu = 1;
  } elsif ($fnu !~ /^(\d+)$/) {
    &report("unknown numeric feature ($fnu) in description ($description)")
  }
  if ($fnu > 1) {
    &report("more than one primary ($fnu) in description ($description)")
      if ($fgr =~ /^s[op]/);
    if ($fnu > 2) {
      &report("more than two primaries ($fnu) in description ($description)")
        if ($fgr =~ /^g2/);
      if ($fnu > 3) {
        &report("more than 3 primaries ($fnu) in description ($description)")
          if ($fgr =~ /^g3/);
      }
    }
  }
}

sub check_household_name {
  local($name) = @_;

  if ($name =~ /^([A-Za-z]+) /) {
    # look at the first word
    my $w1 = $1;
    if ($w1 =~ /^(braithrean|brotherhood|casa|clann?|company|fellowship|freehold|house?|household|hus|keep|league|maison)$/i) {
      &report("household name begins with designator ($w1)");
    } elsif (
        $w1 =~ /^(af|an|aus|d[eou]|de[ils]|della|in|na|o|of|van|vo[mn])$/i) {
      &report("household name begins with preposition ($w1)");
    } elsif (
        $w1 =~ /^(das|de[mnr]|die|els?|las?|les?|the)$/i) {
      &report("household name begins with article ($w1)");
    }
  }
  
  &check_name ($name, 1);
}

sub check_name {
  # global %known_daud
  local($name, $not_a_branch_or_title) = @_;

  #return if ($name eq 'name?');

  if ($name =~ /^(.*)<(.+)>(.*)$/) {
    &report("unexpected angle-brackets in name ($name)")
      if ($not_a_branch_or_title == 1);

    # remove one set of angle-brackets from name
    $name = "$1$2$3";
  }
  elsif ($not_a_branch_or_title == 2)
  {
  	my @exceptions = ( qr/^Atenveldt, /, qr/^Mists, /,
		qr/^Society for Creative Anachronism$/,
		qr/^Institute for the Preservation of Outlandish Culture$/,
		qr/^Great Britain$/, qr/^unknown owner$/,
		qr/^Leafolk Shire$/,
		); # groups that won't be bracketed; lowers false positives
	
	if ( !grep($name =~ $_, @exceptions) && $name =~ / /)
	{
  	  &report("designator not bracketed ($name)");
	}
  }

  &report("null name") if ($name eq '');

  while ($name =~ /^(.*)[{](.{1,3})[}](.*)$/) {
    &report("unknown daud-code ($2) in name ($name)")
      if ($known_daud{$2} eq '');

    # remove one (more) daud-code from the name
    $name = "$1x$3";
  }

  if ($name =~ /^(.+) [&] (.+)$/) {
    # remove one ampersand from the name
    $name = "$1 and $2";
  }

  &report("unexpected final character ($1) in name ($name)")
    if ($name =~ /([^a-zAIO'.)])$/);
  &report("unexpected character ($1) in name ($name)")
    if ($name =~ /([^ A-Za-z`'.,:()-])/);

  &report("leading blank in name ($name)") if ($name =~ /^ /);
  &report("trailing blank in name ($name)") if ($name =~ / $/);
  &report("extraneous blank in name ($name)")
    if ($name =~ /[ ][ .,:)-]|[`(-][ ]/);
  &report("missing blank in name ($name)") if ($name =~ /[^ ][(]|[,:)][^ ]/);
}

sub check_blazon {
  # global %known_daud, $nonsca, $type, $d1
  local($blazon) = @_;

  return if ($blazon eq 'blazon?');

  local($work) = $blazon;
  if ($blazon =~ /^[(](Light|Dark|Tinctureless)[)] (.*)$/) {
    $work = $2;
    &report("unexpected tinctureless armory")
      if ($type !~ /^([Bbgs])$/);
  } elsif ($blazon =~ /^[(]Fieldless[)] (.*)$/) {
    $work = $1;
    &report("unexpected fieldless armory")
      if ($type !~ /^([Babdg])$/);
  } else {
    &report("unexpected fielded armory")
      if ($type !~ /^([BDabd]|D[?]|BD)$/);
  }
  &report("core blazon ($work) does not begin with a capital letter")
    if ($work !~ /^[A-Z]/);

  while ($work =~ /^(.*)"([^"\[\]]+)"(.*)$/) {
    $work = "$1$2$3";
  }
  while ($work =~ /^(.+) \[[^"\[\]]+\](.*)$/) {
    $work = $1.$2;
  }
  while ($work =~ /^(.+)\(([^"\(\)]+)\)(.*)$/) {
    $work = "$1$2$3";
  }

  &report("word 'Or' not capitalized in recent blazon")
    if ($work =~ /\bor\b/ && $d1 > 198007);
  &report("blazon does not end with a dot")
    if ($work !~ /[.]$/);

  while ($blazon =~ /^(.*)[{](.{1,3})[}](.*)$/) {
    &report("unknown daud-code ($2) in blazon")
      if ($known_daud{$2} eq '');

    # remove one (more) daud-code from the blazon
    $blazon = "$1x$3";
  }
  while ($blazon =~ /^(.*)[(]([^()]+)[)](.*)$/) {
    # remove one (more) set of parentheses from blazon
    $blazon = "$1$2$3";
  }
  while ($blazon =~ /^(.*)"([^"\[\]]+)"(.*)$/) {
    # remove one pair of double-quotes from blazon
    $blazon = "$1$2$3";
  }
  while ($blazon =~ /^(.*)\[([^\]\[]+)\](.*)$/) {
    &report("unexpected square-brackets in blazon")
      if ($nonsca);

    # remove one set of square-brackets from blazon
    $blazon = "$1$2$3";
  }

  if ($blazon =~ /^(.+) [&] (.+)$/) {
    # remove one ampersand from the blazon
    $blazon = "$1 and $2";
  }

  &report("unexpected character ($1) in blazon")
    if ($blazon =~ m#([^ A-Za-z0-9'.,:;?!()-])#);

  &report("leading blank in blazon") if ($blazon =~ /^ /);
  &report("trailing blank in blazon") if ($blazon =~ / $/);
  &report("extraneous blank in blazon") if ($blazon =~ m#[ ][ .,:)-]|[`(-][ ]#);
  &report("missing blank in blazon") if ($blazon =~ /[^ ][(]|[,:)][^ ]/);
}

sub check_note_date {
  # global $d1
  local ($note_date) = @_;
  $note_date = &check_date ($note_date);
  &count('note date');
  &report("note date is out-of-order ($d1, $note_date)")
    if ($d1 >= $note_date);
}

sub check_date {
  # global $firstdate, $lastdate
  local($date) = @_;

  if ($date =~ /^(\d\d\d\d)(\d\d)([A-Za-z]?)$/) {
    local($loar, $mm, $k) = ("$1$2", $2, $3);
    &report("invalid month ($mm) in date") if ($mm < 1 || $mm > 12);
    if ($loar < 6600) {
      $loar += 200000;
    } elsif ($loar < 10000) {
      $loar += 190000;
    }
    &report("no LoAR with that date ($loar)")
      if ($loar == 197909 || $loar == 197912 || $loar == 199302);
    &report("LoAR date out of range ($loar)")
      if ($loar < $firstdate || $loar > $lastdate);
    if ($k eq '') {
      &count ('kingdom-less date');
      &report("missing kingdom id in date ($date)")
        if ($loar >= $splitdate);
    } elsif ($k !~ /^[ACDEGHKLMmnNOQRSTVWXw]$/) {
      &report("unknown kingdom id ($k) in date")
    }
    return $loar;
  } else {
    &report("invalid date ($date)")
      if ($date ne '');
    return '';
  }
}

sub count {
  # global %count
  local($label) = @_;
  $count{$label}++;
  #print "$label: $record\n" unless $label eq 'record';
}

sub report {
  # global $record
  local($message) = @_;
  print "-> $message in line $.:";
  print $record;
}

sub s {
  # global %count
  local ($label) = @_;
  return $label.'s' unless ($count{$label} == 1);
  return $label; 
}

sub delangle {
  local ($text) = @_;
  if ($text =~ /^([^<>]*)<([^<>]+)>([^<>]*)$/) {
    $text = $1.$3;
  }
  return $text;
}
