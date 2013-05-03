#!/usr/bin/perl

# initialize global variables

$unicode_filename = '/Users/herveus/unicode/coa.tab';

$Yymm = shift;

%Ctab = (
   9, ' ',
#   0x3f, "'", # curly apostrophe map to '
);

%Etab = (
  'amp' , '&',
  'gt' , '>',
  'lt' , '<',
  'quot' , '"'
);

%Ttab = (
   'alternate name', 'AN',
   'alternate persona name', 'AN',

   'name and badge', 'B',
   'holding name and badge', 'B',
   'change of name and badge', 'B',

   'branch name', 'BN',
   'branch name and device', 'BD',
   
   'branch name change', 'BNC',
   
   'branch name correction', 'BNc',

   'name and device', 'D',
   'holding name and device', 'D',
   'change of name and device', 'D',

   'household name', 'HN',
   'guild name', 'HN',
   
   'household name change', 'HNC',
   'change of household name', 'HNC',

   'order name change', 'HNC',
   'change of order name', 'HNC',

   'name', 'N',
   'new name', 'N',
   'primary name', 'N',
   'holding name', 'N',

   'name change', 'NC',
   'name change from holding name', 'NC',
   'change of name', 'NC',
   'change of holding name', 'NC',
   'change of name from holding name', 'NC',

   'reconsideration of name', 'Nc',
   'name reconsideration', 'Nc',
   'correction of name', 'Nc',
   'name correction', 'Nc',
   'award name', 'O',
   'order name', 'O',
   'cross reference', 'R',

   'augmentation', 'a',
   'augmentation of arms', 'a',
   'change of augmentation of arms', 'a',
   'augmentation change', 'a',

   'badge', 'b',
   'change of badge', 'b',
   'badge change', 'b',
   'flag', 'b',
   'flag (former)', 'b',
   'ensign', 'b',
   'naval ensign', 'b',

   'arms', 'd',
   'device', 'd',
   'device change', 'd',
   'change of device', 'd',

   'blazon change', 'D?',
   'blazon correction', 'D?',

   'regalia', 'g',
   'seal', 's',
   'heraldic title', 't',
   'joint badge', 'j',
   'joint household name', 'j',
);

unless (open (TAB, $unicode_filename))
{ 
	warn "cannot open $unicode_filename";
}
else
{
	while (<TAB>) {
	  chop;
	  ($daud, $x, $hex, $e, @rest) = split(/[;]/);
	  if ($e =~ /^[&]([A-Za-z0-9_]+)$/) {
	    $Etab{$1} = "{$daud}";
	    #print ">> adding entity &$1;\n"
	  }
	  $ord = hex($hex);
	  if ($ord >= 127 && $ord <= 255) {
	    $Ctab{$ord} = "{$daud}";
	    #print ">> adding character $ord\n"
	  }
	}
	close TAB;
}

# Read from standard input, or files specified on the command-line.

while (<>) {
  chop;
  &print_actions($_);
}

#----------------------------------------------------

sub make_source {
  local ($id, $kingdom) = @_;
  # global $Yymm
  local ($k, $let, $seq, $yymm);

  if (1) {  # bypass obsolete code
    $yymm = $Yymm;

  } elsif ($id =~ /^loar\d\d(\d\d[01]\d)(\d+)([a-d]?)/) {
    $yymm = $1;
    $seq = $2;
    $let = $3;

    $id =~ /^loar(....)(..)/;
    die "Item id $id contains an invalid year ($1)."
      if ($1 < 1970 || $1 > 2060);
    die "Item id $id contains an invalid month ($2)."
      if ($2 < 1 || $2 > 12);

    $Yymm = $yymm if ($Yymm eq '');
    if ($Yymm ne $yymm) {
      print STDERR
        "$0: *** Item id $id contains a different date -- expected $Yymm.\n";
      $yymm = $Yymm;
    }

  } elsif ($id eq '') {
    die "Empty item id.";

  } else {
    die "Bogus item id ($id).";
  }

  die "Invalid kingdom id ($kingdom)"
    if (length($kingdom) != 1);

  return $yymm . $kingdom;
}

sub print_actions {
  local ($line) = @_;
  local ($armory, $id, $kingdom, $name, $name2, $notes, $source, $type);

  ($id, $kingdom, $_, $name, $armory, $name2) = split(/[|]/, $line, 6);

  $notes = '';
  if (/^(.+) [(]see (PENDING|RETURNS|PENDS|PENDED) for [^)]+[)]$/i) {
    $_ = $1;
  }
  if (/^(.+) (\(important non-SCA .+\))$/i)
  {
  	$_ = $1;
  	$notes = $2;
  }
  $source = &make_source($id, $kingdom);

return if /^(armory)? disposition$/;

  if (/^branch name$/i) {
    die if ($armory ne '');
    print_record($name, $source, $_, $armory, $notes, __LINE__);

  } elsif (/^release of (heraldic title|order name|household name) "(.+)"$/i) {
    $notes .= "(-released)";
    print_record($2, "-$source", $1, $name, $notes, __LINE__);

  } elsif (/^release of (alternate name) "(.+)"$/i) {
    $notes .= "(-released)";
    print_record($2, "-$source", $1, $name, $notes, __LINE__);

  } elsif (/^release of (.+)$/i) {
    $notes .= "(-released)";
    print_record($name, "-$source", $1, $armory, $notes, __LINE__);

  } elsif (/^association of (.+) with (.+ name) "(.+)"$/i) {
    die if ($armory eq '');
    $notes .= "(For $3)";
    print_record($name, $source, $1, $armory, $notes, __LINE__);

  } elsif (/^joint (badge) with "(.+)"$/i) {
    die if ($armory eq '');
    print_record($name, $source, $1, $armory, $notes."(JB: $2)", __LINE__);
	print_record($2, $source, 'joint badge', $name, $notes, __LINE__);

  } elsif (/^joint (badge)$/i) {
    die if ($armory eq '');
	my ($primary, $secondary) = split(/ and /, $name);
    print_record($primary, $source, $1, $armory, $notes."(JB: $secondary)", __LINE__);
	print_record($secondary, $source, 'joint badge', $primary, $notes, __LINE__);

  } elsif (/^joint (badge) for (the )?"(.+)"$/i) {
    die if ($armory eq '');
	my ($n1, $n2) = split(/ and /, $name);
    print_record($n1, $source, 'badge', $armory, $notes."(JB: $n2)(For $2$3)", __LINE__);
	print_record($n2, $source, 'joint badge', $n1, $notes."(For $2$3)", __LINE__);

  } elsif (/^joint (household name) (the )?"(.+)" and badge with "(.+)"$/i) {
    die if ($armory eq '');
    print_record($name, $source, 'badge', $armory, $notes."(JB: $4)(For $2$3)", __LINE__);
    print_record("$2$3", $source, $1, $name, $notes."(JHN: $4)", __LINE__);
	print_record($4, $source, 'joint badge', $name, $notes, __LINE__);

  } elsif (/^joint (household name) (the )?"(.+)" and badge$/i) {
    die if ($armory eq '');
	my ($n1, $n2) = split(/ and /, $name);
    print_record($n1, $source, 'badge', $armory, $notes."(JB: $n2)(For $2$3)", __LINE__);
    print_record("$2$3", $source, $1, $n1, $notes."(JHN: $n2)", __LINE__);
	print_record($n2, $source, 'joint badge', $n1, $notes, __LINE__);

  } elsif (/^(.+ name) (the )?"(.+)" and (badge)$/i) {
    die if ($armory eq '');
    print_record($2.$3, $source, $1, $name, $notes, __LINE__);
    $notes .= "(For $2$3)";
    print_record($name, $source, $4, $armory, $notes, __LINE__);

  } elsif (/^acceptance of transfer of (.+ name|heraldic title) "(.+)"/i) {
    die if ($armory ne '');
    print_record($2, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(.+ name|heraldic title) (the )?"(.+)"$/i) {
    die if ($armory ne '');
    print_record($3, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(heraldic title) (the )?"(.+)" for (.+)$/i) {
    die if ($armory ne '');
    $notes .= "(For $4)";
    print_record($3, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(holding name)$/i) {
    print_record($name, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(.+ name|heraldic title)$/i) {
    die if ($name2 eq '');
    print_record($name2, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(device|badge|seal|augmentation) changed\/(retained|released)$/i) {
    die if ($armory eq '');
	$notes .= "(-changed/$2)";
    print_record($name, "-$source", $1, $armory, $notes, __LINE__);

  } elsif (/^(device|badge|seal) (reblazoned|corrected blazon)$/i) {
    die if ($armory eq '');
	$notes .= "(-$2)";
    print_record($name, "-$source", $1, $armory, $notes, __LINE__);

  } elsif (/^(badge|device change|seal|badge change) for (the )?"(.+)"$/i) {
    die if ($armory eq '');
    print_record($name, $source, $1, $armory, $notes."(For $2$3)", __LINE__);
    $office = $3;
    if ($1 =~ /seal/i) {
      print_record($office, $source, 'cross reference',
        "Heralds' Seals: $office", $notes, __LINE__);
      print_record($name, $source, 'cross reference',
        "also Heralds' Seals: $office", $notes, __LINE__);
    }

  } elsif (/^(change of holding name|change of name|name change) from( holding name)? "(.+)" and blazon correction for (.+)$/i) {
    die if ($armory eq '');
    print_record($3, $source, $1, $name, $notes, __LINE__);
    print_record($name, $source, $4, $armory, $notes, __LINE__);

  } elsif (/^(.+ from holding name) "(.+)"$/i) {
    die if ($armory ne '');
    print_record($2, $source, $1, $name, $notes, __LINE__);

  } elsif (/^acceptance of transfer of (badge) from "(.+)"/i) {
    die if ($armory eq '');
    print_record($name, $source, $1, $armory, $notes, __LINE__);
    #print_record($2, "-$source", $1, $armory, $notes, __LINE__);

  } elsif (/^transfer of (badge|device) to (the )?"(.+)"/i) {
    die if ($armory eq '');
	$notes .= "(-transferred to $2$3)";
    print_record($name, "-$source", $1, $armory, $notes, __LINE__);
    #print_record($2, $source, $1, $armory, $notes, __LINE__);

  } elsif (/^(branch name change|change of holding name|change of name|name change) from( holding name| the)? "(.+)" and (.+)$/i) {
    die if ($armory eq '');
    print_record($3, $source, $1, $name, $notes, __LINE__);
    print_record($name, $source, $4, $armory, $notes, __LINE__);

  } elsif (/^(branch name change|change of holding name|change of name|name change) from( holding name| the)? "(.+)"$/i) {
    die if ($armory ne '');
    print_record($3, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(correction of name|name correction) and (.+)$/i) {
    die if ($armory eq '');
    print_record($name2, $source, $1, $name, $notes, __LINE__);
    print_record($name, $source, $2, $armory, $notes, __LINE__);

  } elsif (/^(reconsideration of name|name reconsideration) from "(.+)"$/i) {
    die if ($armory ne '');
    print_record($2, $source, $1, $name, $notes, __LINE__);

  } elsif (/^(correction of name|name correction) from "(.+)"$/i) {
    die if ($armory ne '');
    print_record($2, $source, $1, $name, $notes, __LINE__);

  } elsif (/^reblazon of "?(badge|device|flag|seal)"?( for (the )?"(.+)")?$/i) {
    die if ($armory eq '');
	$notes .= "(For $3$4)" if defined $4;
    print_record($name, $source, $1, $armory, $notes, __LINE__);

  } elsif (/^transfer between (.+) and (.+)$/i) {
    print_record($name, "-$source", $1, $armory,
      $notes."(-converted to $2)", __LINE__);
    print_record($name, "-$source", $2, $armory,
      $notes."(-converted to $1)", __LINE__);
    print_record($name, "$source", $1, $armory, $notes, __LINE__);
    print_record($name, "$source", $2, $armory, $notes, __LINE__);

  } elsif (/^change of (.+) to (.+)$/i) {
    print_record($name, "-$source", $1, $armory,
      $notes."(-converted to $2)", __LINE__);
    print_record($name, "$source", $2, $armory, $notes, __LINE__);

  } elsif (/^(household|order) name change from (.+) to "(.+)"$/i) {
    die if ($armory ne '');
    print_record($1, "-$source", "$1 name change", $3, $notes, __LINE__);

  } elsif (/^(household|order) name change to (.+) from "(.+)"$/i) {
    die if ($armory ne '');
    print_record($1, "-$source", "$1 name change", $2, $notes, __LINE__);

  } elsif (/^transfer of (.+ name|heraldic title) "(.+)" (to .+)$/i) {
    die if ($armory ne '');
    $notes .= "(-transferred $3)";
    print_record($2, "-$source", $1, $name, $notes, __LINE__);

  } elsif (/^transfer of (name) (to .+)$/i) {
    die if ($armory ne '');
    $notes .= "(-transferred $2)";
    print_record($name, "-$source", $1, $armory, $notes, __LINE__);

  } elsif (/^(name) [(]see pends for device[)]$/i) {
    die if ($armory ne '');
    print_record($name, $source, $1, $armory, $notes, __LINE__);

  } else {
    print_record($name, $source, $_, $armory, $notes, __LINE__);
  }
}

sub daudify {
  local ($_) = @_;
  local ($c, $e);

  while (/^([^&]*)[&]([A-Za-z0-9_]+)[;](.*)/) {
    $e = $Etab{$2};
    if ($e eq '') {
      printf STDERR
          "$0: *** Unknown entity &%s; in line $. of input.\n", $2;
      $e = '.';
    }
    $_ = $1 . $e . $3;
  }
  
  while (/^(.*)&#(.+);(.*)$/)
  {
  	my $ch = $2;
	my $c = $Ctab{$ch};
	if ($c eq '') {
      $ch = sprintf('\\%03o', $ch)
         if ($ch ne '?');
      print STDERR "$0: *** Illegal character '$ch' in line $. of input.\n";
      $c = "'";
    }
    $_ = $1 . $c . $3;
  }

  while (/^(.*)([\000-\037?\177-\377])(.*)$/) {
    local($ch) = $2;
    $c = $Ctab{ord($ch)};
    if ($c eq '') {
      $ch = sprintf('\\%03o', ord($ch))
         if ($ch ne '?');
      print STDERR "$0: *** Illegal character '$ch' in line $. of input.\n";
      $c = "'";
    }
    $_ = $1 . $c . $3;
  }

  return $_; 
}

sub print_record {
  local ($name, $source, $action, $text, $notes, $caller_line) = @_;
  local ($type);

  # convert action to lower case
  $action =~ tr/A-Z/a-z/;
  my $isholding = $action =~ /^holding/;

  # look up type code in Ttab
  $type = $Ttab{$action};
  if ($type eq '') {
    print STDERR <<END
$0: *** Unknown action:
  action=$action
  name=$name
  line $. of input
  print_record called from line $caller_line
END
  }

  if ($action =~ /^flag/i) {
    $notes .= '(Flag)';
  }
  elsif ($action =~ /^ensign/i)
  {
  	$notes .= "(Ensign)";
  }

  if ($name eq '') {
      print STDERR <<END;
$0: *** Action lacks name:
  action=$action
  text=$text
  line $. of input
  print_record called from line $caller_line
END
    $name = 'unknown name';
  }

  if ($type =~ /^[abdgs]$/i || $type eq 'BD') {
    if ($text eq '') {
      print STDERR <<END;
$0: *** Armory action lacks blazon:
  action=$action
  name=$name
  line $. of input
  print_record called from line $caller_line
END
      $text = 'unknown blazon';
    }
    $text .= '.';
  }

  $name = &daudify(&listing($name));
  $text = &daudify($text);
  $notes = &daudify($notes);

  if ($type eq 'B') {
    printf "%s|%s|N||%s\n", $name, $source, join("", $notes, $isholding ? '(holding name)' : '');
    printf "%s|%s|b|%s|%s\n", $name, $source, $text, $notes;
  } elsif ($type eq 'BD') {
    printf "%s|%s|BN||%s\n", $name, $source, $notes;
    printf "%s|%s|d|%s|%s\n", $name, $source, $text, $notes;
  } elsif ($type eq 'D') {
    printf "%s|%s|N||%s\n", $name, $source, join("", $notes, $isholding ? '(holding name)' : '');
    printf "%s|%s|d|%s|%s\n", $name, $source, $text, $notes;
  } elsif ($type eq 'NC' || $type eq 'R' || $type eq 'BNC') {
    printf "%s|%s|%s|See %s|%s\n", $name, $source, $type, $text, $notes;
  } elsif ($type eq 'AN') {
    printf "%s|%s|%s|For %s|%s\n", $name, $source, $type, $text, $notes;
  } else {
    printf "%s|%s|%s|%s|%s\n", $name, $source, $type, $text, $notes;
  }
}

sub listing {
  local ($_) = @_; 

  s/^(the|la|le) +//i;
  if (
/^(award|barony|braithrean|brotherhood|canton|casa|chateau|clann?|companionate|company|crown principality|domus|dun|fellowship|freehold|guild|honou?r of the|house|household|hous|ha?us|h\{u'\}sa|keep|kingdom|league|l'ordre|maison|orde[nr]|ord[eo]|ordre|principality|province|riding|shire) (.*)/i) {
    $_ = "$2, $1";
    if (/^(af|an|aus|d[eou]|de[ils]|dell[ao]|in|na|of?|van|vo[mn]) (.*)/i) {
      $_ = "$2 $1";
    }
    if (/^(das|de[mn]?|der|die|el|l[ae]|les|the) (.*)/i) {
      $_ = "$2 $1";
    }
  }
  return $_;
}
