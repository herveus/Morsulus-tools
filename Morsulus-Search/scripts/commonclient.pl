
# This file contains Perl routines shared between XXNameSearchPathXX,
# XXDescSearchPathXX,
# XXNpSearchPathXX,
# XXBpSearchPathXX,
# XXDateSearchPathXX,
# and XXComplexSearchPathXX.
# This should be installed at XXCommonClientPathXX on XXServerNameXX.

#require 'ctime.pl';

# name of host running the database server code:
$them = 'XXDataHostXX';

# port number for contacting the database server:
$port = XXDataPortXX;

# display option settings:
@eras = ('modern', 'SCA');
@onoff = ('enabled', 'disabled');

# default display options:
$era = 'modern';
$gloss_links = 'disabled';
$arm_descs = 'disabled';

# networking constants:
$sockaddr = 'S n a4 x8';   # format of socket address
$AF_INET = XXAF_INETXX;
$SOCK_STREAM = XXSOCK_STREAMXX;

$[ = 1;
$" = '|';
$\ = "\n";

%gloss = (
'Or', 'Or',
'd\'or', 'Or',
'abased', 'abased',
'addorsed', 'addorsed',
'affronty', 'affronty',
'affronte', 'affronty',
'alaunt', 'alaunt',
'annulet', 'annulet',
'annulets', 'annulet',
'antelope', 'antelope',
'appaumy', 'appaumy',
'appaume', 'appaumy',
'argent', 'argent',
'armed', 'armed',
'arrondi', 'arrondi',
'arrondy', 'arrondi',
'azure', 'azure',
'barbed', 'barbed',
'barrulet', 'barrulet',
'barrulets', 'barrulet',
'barry', 'barry',
'barruly', 'barry',
'bar', 'bar',
'bars', 'bar',
'bascinet', 'bascinet',
'bascinets', 'bascinet',
'base', 'base',
'bases', 'base',
'baton sinister', 'baton+sinister',
'batons sinister', 'baton+sinister',
'battle axe', 'battle+axe',
'battleaxe', 'battle+axe',
'beaked', 'beaked',
'bellied', 'bellied',
'bendlet', 'bendlet',
'bendlets', 'bendlet',
'bendwise sinister', 'bendwise+sinister',
'bendwise', 'bendwise',
'bendy', 'bendy',
'bend', 'bend',
'bends', 'bend',
'bezanty', 'bezanty',
'bezant', 'bezant',
'bezants', 'bezant',
'billet', 'billet',
'billets', 'billet',
'blazon', 'blazon',
'bleu celeste', 'bleu+celeste',
'bordure', 'bordure',
'bordures', 'bordure',
'brunatre', 'brunatre',
'canton', 'canton',
'cartouche', 'cartouche',
'celtic cross', 'celtic+cross',
'cendree', 'cendree',
'charged', 'charged',
'charge', 'charge',
'charges', 'charge',
'checky', 'checky',
'chequy', 'checky',
'chevron', 'chevron',
'chevrons', 'chevron',
'chief', 'chief',
'chiefs', 'chief',
'compass rose', 'compass+rose',
'compass roses', 'compass+rose',
'compass star', 'compass+star',
'compass stars', 'compass+star',
'conjoined', 'conjoined',
'contourny', 'contourny',
'contourney', 'contourny',
'cotised', 'cotised',
'counterchanged', 'counterchanged',
'counterermine', 'counterermine',
'couped', 'couped',
'courant', 'courant',
'cross', 'cross',
'crosses', 'cross',
'crux ansata', 'crux+ansata',
'cruces ansatae', 'crux+ansata',
'debruised', 'debruised',
'debruising', 'debruising',
'decrescent', 'decrescent',
'delf', 'delf',
'delfs', 'delf',
'dexter chief', 'dexter+chief',
'dexter', 'dexter',
'displayed', 'displayed',
'dovetailed', 'dovetailed',
'drakkar', 'drakkar',
'drakkars', 'drakkar',
'eclipsed', 'eclipsed',
'embattled', 'embattled',
'emblazon', 'emblazon',
'embowed', 'embowed',
'endorsed', 'endorsed',
'engrailed', 'engrailed',
'erased', 'erased',
'ermine spot', 'ermine+spot',
'ermine spots', 'ermine+spot',
'ermine tail', 'ermine+spot',
'ermine tails', 'ermine+spot',
'ermines', 'ermines',
'ermine', 'ermine',
'erminois', 'erminois',
'estencele', 'estencele',
'estoile', 'estoile',
'estoiles', 'estoile',
'fesswise', 'fesswise',
'fess', 'fess',
'fieldless', 'fieldless',
'field', 'field',
'fields', 'field',
'fimbriated', 'fimbriated',
'flaunches', 'flaunches',
'flank', 'flaunches',
'fret', 'fret',
'fructed', 'fructed',
'golpe', 'golpe',
'golpes', 'golpe',
'goute', 'goute',
'goutty', 'goutty',
'guardant', 'guardant',
'gules', 'gules',
'gunstone', 'gunstone',
'gunstones', 'gunstone',
'gyron', 'gyron',
'gyronny', 'gyronny',
'harpy', 'harpy',
'haurient', 'haurient',
'hurty', 'hurty',
'hurt', 'hurt',
'hurts', 'hurt',
'in annulo', 'in+annulo',
'in base', 'in+base',
'in bend', 'in+bend',
'in canton', 'in+canton',
'in chief', 'in+chief',
'in cross', 'in+cross',
'in fess', 'in+fess',
'in pale', 'in+pale',
'in saltire', 'in+saltire',
'increscent', 'increscent',
'indented', 'indented',
'invected', 'invected',
'inverted', 'inverted',
'issuant', 'issuant',
'label', 'label',
'latin cross', 'latin+cross',
'latin crosses', 'latin+cross',
'leaved', 'leaved',
'lion', 'lion',
'lions', 'lion',
'lozenge', 'lozenge',
'lozengy', 'lozengy',
'martlet', 'martlet',
'mascle', 'mascle',
'maunch', 'maunch',
'mound', 'mound',
'orb', 'mound',
'mount', 'mount',
'mullet', 'mullet',
'mullets', 'mullet',
'naiant', 'naiant',
'ogress', 'ogress',
'ogresses', 'ogress',
'on', 'on',
'ordinary', 'ordinary',
'ordinaries', 'ordinary',
'orle', 'orle',
'palewise', 'palewise',
'pale', 'pale',
'pales', 'pale',
'pall', 'pall',
'paly', 'paly',
'passant', 'passant',
'pean', 'pean',
'pellety', 'pellety',
'pelletty', 'pellety',
'pellet', 'pellet',
'pellets', 'pellet',
'pendant', 'pendant',
'per bend', 'per+bend',
'per chevron', 'per+chevron',
'per fess', 'per+fess',
'per pale', 'per+pale',
'per pall', 'per+pall',
'per saltire', 'per+saltire',
'pheon', 'pheon',
'pheons', 'pheon',
'pheonix', 'pheonix',
'pile', 'pile',
'piles', 'pile',
'pily', 'pily',
'pithon', 'pithon',
'jaculus', 'pithon',
'plate', 'plate',
'plates', 'plate',
'platy', 'platy',
'point', 'point',
'points', 'point',
'pomme', 'pomme',
'pommes', 'pomme',
'potent', 'potent',
'proper', 'proper',
'purpure', 'purpure',
'python', 'python',
'pythons', 'python',
'quarterly', 'quarterly',
'rampant', 'rampant',
'rayonny', 'rayonny',
'rayonne', 'rayonny',
'reguardant', 'reguardant',
'reversed', 'reversed',
'rose', 'rose',
'roses', 'rose',
'roundel', 'roundel',
'sable', 'sable',
'salient', 'salient',
'reguardant', 'reguardant',
'saltire', 'saltire',
'saltires', 'saltire',
'saltorel', 'saltorel',
'saltorels', 'saltorel',
'scarpe', 'scarpe',
'scarpes', 'scarpe',
'sejant', 'sejant',
'semy', 'semy',
'seme', 'semy',
'shield', 'shield',
'shields', 'shield',
'sinister chief', 'sinister+chief',
'sinister', 'sinister',
'slipped', 'slipped',
'sphinx', 'sphinx',
'sphinxes', 'sphinx',
'tenne', 'tenne',
'tergiant', 'tergiant',
'tierce', 'tierce',
'tincture', 'tincture',
'tinctures', 'tincture',
'tinctureless', 'tinctureless',
'torteau', 'torteau',
'torteaux', 'torteau',
'tressure', 'tressure',
'trippant', 'trippant',
'unicorn', 'unicorn',
'urdy', 'urdy',
'vair', 'vair',
'vert', 'vert',
'voided', 'voided',
'volant', 'volant',
'wavy', 'wavy',
'wyvern', 'wyvern',
'wyverns', 'wyvern',
);

%kingdom_name = (
 'A', 'Atenveldt',
 'C', 'Caid',
 'D', 'Drachenwald',
 'E', 'the East',
 'G', 'Gleann Abhann',
 'H', 'AEthelmearc',
 'K', 'Calontir',
 'L', 'Laurel',
 'M', 'the Middle',
 'N', 'An Tir',
 'O', 'the Outlands',
 'Q', 'Atlantia',
 'R', 'Artemisia',
 'S', 'Meridies',
 'T', 'Trimaris',
 'W', 'the West',
 'm', 'Ealdormere',
 'n', 'Northshield',
 'w', 'Lochac',
 'X', 'Ansteorra',
 'V', 'Avacal',);

%mmap = (
 'January', '01',
 'February', '02',
 'March', '03',
 'April', '04',
 'May', '05',
 'June', '06',
 'July', '07',
 'August', '08',
 'September', '09',
 'October', '10',
 'November', '11',
 'December', '12');

@month_name = (
 'January',
 'February',
 'March',
 'April',
 'May',
 'June',
 'July',
 'August',
 'September',
 'October',
 'November',
 'December');

%type_name = (
 'a', 'augmentation',
 'b', 'badge',
 'D?','armory',
 'd', 'device',
 'g', 'regalia',
 't', 'heraldic title',
 's', 'seal',
 'N', 'name',
 'BN', 'branch name',
 'O', 'order name',
 'OC', 'order name change',
 'AN','alternate name',
 'ANC','alternate name change',
 'NC','name change',
 'Nc','name correction',
 'NC','branch-name change',
 'Nc','branch-name correction',
 'HN','household name',
 'HNC','household name change',
 'C', 'database comment',
 'j', 'joint badge reference',
 'u', 'branch designator update',
 'v', 'uncorrected variant spelling',
 'Bv', 'uncorrected variant branch-name spelling',
 'vc', 'corrected variant spelling',
 'Bvc', 'corrected variant branch-name spelling',
 'R', 'cross-reference');

# Set encoding type.
$enctype = 'application/x-www-form-urlencoded';

# Common client function to show display options for a search.
sub display_options {
  #global ($sort, @sorts, $era, @eras, $gloss_links, $arm_descs, @onoff);
  print '<h3>Display Options:</h3><ul>';

  print '<li>Sort items by ';
  &select ('s', $sort, @sorts);

  print '<li>Display dates in ';
  &select ('d', $era, @eras);
  print ' style.';

  print '<li>Glossary links ';
  &select ('g', $gloss_links, @onoff);

  print '<li>Armory descriptions ';
  &select ('a', $arm_descs, @onoff);

  print '</ul>';
}

# Common client function to replace escaped URL characters with text.
sub decode {
  local($in) = @_;
  local($out);
  
  $in =~ s/\+/\ /g;
  $out = '';
  while ($in =~ /\%/) {
    $in =~ /^([^%]*)\%([0-9A-Fa-f][0-9A-Fa-f])(.*)$/;
    $out .= $1 . pack ('c', hex $2);
    $in = $3;
  }
  return $out . $in;
}

# Common client function to generate a pop-up menu in a form.
sub select {
  local($name, $selected, @options) = @_;
  local($opt, $s);

  print '<select name="', $name, '">';
  foreach $opt (@options) {
    print '<option', ($opt eq $selected) ? ' selected' : '', '>', $opt;
  }
  print '</select>';
}

# Common client function to read response from database server.
sub get_matches {
  #global (*S, @matches, @messages, @lost, %m);
  local ($n, $_);

  $n = 0;
  while (<S>) {
    chop;
    if (/^\'(.*)$/) {
      push (@messages, $1);
    } elsif (/^\d+\+(\d+)$/) {
      push (@lost, $_);
      $n += $1;
    } elsif (/^(\d+)\|/) {
      push (@matches, $_);
      $n++;
      $m{$1}++;
    }
  }
  close S;
  return $n;
}
  
# Common client function to format an item into HTML.
sub print_match {
  #global ($prev_name, $arm_descs);
  local ($name, $source, $type, $text, $notes, @descs) = @_;
  local ($\) = '';
  local (@source);
  local ($disp) = 'altered or released';

  if ($notes =~ /^(.*)[(]-([^)]+)[)](.*)/) {
    $notes = $1.$3;
    $disp = $2;
  }
  @source = split (/-/, $source);
  print '</ul><li>', &name ($name), '<ul>' if ($name ne $prev_name);
  print '<li>';
  if ($type eq 'Nc') {
    print 'This name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was corrected to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'BNc') {
    print 'This branch-name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was corrected to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'u') {
    print 'This branch name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was updated to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'ANC') {
    print 'This alternate name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was changed to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'HNC') {
    print 'This household name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was changed to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'OC') {
    print 'This order name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was changed to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'BNC') {
    $text =~ s/^See //;
    print 'This branch-name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was changed to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'NC') {
    $text =~ s/^See //;
    print 'This name';
    if ($source =~ /-/) {
      print ', registered ', &source ($source[1]), ',';
      $source = $source[2];
    }
    print ' was changed to ', &name ($text);
    print ' ', &source ($source), '.';

  } elsif ($type eq 'j') {
    print 'This name was referenced ', &source ($source[1]);
    print ' as joint registrant of a badge';
    print ' with ', &name ($text), '.';

  } elsif ($type eq 'R') {
    $text =~ s/^See (also )?//;
    print 'This name was referenced ', &source ($source[1]);
    if ($text =~ /^\"(.+)\"$/) {
      print ' in registrations by ';
      @targs = split (/\" or \"/, $1);
      print &name (shift (@targs));
      foreach (@targs) {
        print ' and ', &name ($_);
      }
    } else {
      print ' in a registration by ', &name ($text), '.';
    }

  } elsif ($type eq 'vc' || $type eq 'Bvc') {
    if ($source !~ /-/) {
      $source[1] = $source[2];
      $source[2] = $source;
    }
    print 'This appeared ', &source ($source[1]);
    print ' as a mis-spelling of ', &name ($text), '. ';
    print 'The error was corrected ', &source ($source[2]);

  } elsif ($type eq 'v' || $type eq 'Bv') {
    print 'This appeared ', &source ($source[1]);
    print '.<br>It appears to have been a mis-spelling of ';
    print &name ($text), '.';

  } elsif ($type eq 'BN') {
    print 'This branch-name was registered ', &source ($source[1]);
    print ' and released ', &source ($source[2]) if ($source =~ /-/);
    print '.';

  } elsif ($type eq 'N') {
    print 'This name was registered ', &source ($source[1]);
    print ' and released ', &source ($source[2]) if ($source =~ /-/);
    print '.';

  } elsif ($type eq 't' || $type eq 'AN' || $type eq 'HN' || $type eq 'O') {
    $text =~ s/^For // if ($type eq 'AN');
    print 'This ', $type_name{$type}, ' was registered to ';
    print &name ($text), ' ', &source ($source[1]);
    print ' and ', $disp, ' ', &source ($source[2]) if ($source =~ /-/);
    print '.';

  } elsif ($type eq 'BD') {
    print 'Either the branch-name or the following arms';
    print ' associated it (or both) were registered ', &source ($source[1]);
    print ' and ', $disp, ' ', &source ($source[2]) if ($source =~ /-/);
    print ':<br><b>', &blazon ($text), '</b>';

  } elsif ($type =~ /^[ABDS]$/) {
    $type =~ tr/ABDS/abds/;
    print 'Either the name or the following ', $type_name{$type};
    print ' associated it (or both) were registered ', &source ($source[1]);
    print ' and ', $disp, ' ', &source ($source[2]) if ($source =~ /-/);
    print ':<br><b>', &blazon ($text), '</b>';

  } elsif ($type =~ /^[abdgs]$/ || $type eq 'D?') {
    print 'The following ', $type_name{$type};
    print ' associated with this name was registered ', &source ($source[1]);
    print ' and ', $disp, ' ', &source ($source[2]) if ($source =~ /-/);
    print ':<br><b>', &blazon ($text), '</b>';

  } elsif ($type eq 'W') {
    print 'An heraldic will was filed with Laurel ', source($source[1]);

  } elsif ($type eq 'C') {
    print 'A database comment:<br>', $text;

  } elsif ($type eq 'r') {
    print 'Is a reserved word or phrase noted ', source($source[1]);

  } else {
    print "An unknown record (type=`$type') was found in the database.";
  }

  if ($notes =~ /^\((.*)\)$/) {
    foreach (split (/\)\(/, $1)) {
        next if /^regid:/;
      if (/^JB: (.+)$/) {
        print '<br>registered jointly with ', &name ($1);
      } elsif (/^\-?transferred to (the )?(.+)$/) {
        print '<br>transferred to ', $1, &name ($2);
      } elsif (/^For (the )?(.+)$/) {
        print '<br>for ', $1, &name ($2);
      } else {
        print '<br>', &escape ($_);
      }
    }
  }

  if (@descs > 0 && $arm_descs eq 'enabled') {
    print '<br>Armory descriptions:<ul>';
    foreach (@descs) {
      print '<li><a href="XXDescSearchUrlXX?p=', &encodeway ($_);
      print '">', $_, '</a>';
    }
    print '</ul>';
  }
  $prev_name = $name;
}

# Common client function to print messages from the server.

sub print_messages {
  #global (@messages);

  if (@messages > 0) {
    print '<pre>';
    foreach (@messages) {
      print $_;
    }
    print '</pre>';
  }
}

# Common client function to summarize info about lost items.
sub print_lost {
  local ($score, $count, $lastscore) = @_;
  local ($other) = ($lastscore eq $score) ? ' other' : '';

  print '</ul></ul><h4>There ';
  if ($count == 1) {
    print 'was one', $other, ' item'; 
  } else {
    print 'were ', $count, $other, ' items'; 
  }
  printf ' with a score of %s', $score
    if ($score ne '');
  if ($count == 1) {
    print ' which was omitted ';
  } else {
    print ' which were omitted ';
  }
  print 'due to the <a href="XXLimitPageUrlXX">limit feature</a>.</h4><ul><ul>';
}

# Common client function to print messages and matching items.
sub print_results {
  #global (@matches, @lost, $prev_name, $prev_score);
  local ($criteria, $n, $scoresort) = @_;
  local ($_, @item, $total_lost, $score);

  print '<h3>Results:</h3>';

  &print_messages ();

  if (!$scoresort) {
    #  Print summary of matches.
    print '<h4>';
    if ($n == 0) {
      print 'No items';
    } elsif ($n == 1) {
      print 'One item';
    } else {
      print $n, ' items';
    }
    print 'matched ', $criteria, '.';
    if (@matches < $n) {
      if (@matches == 1) {
        print "Here's one of them.";
      } else {
        print 'Here are ', scalar(@matches), ' of them.';
      } 
    }
    print '</h4>';
  }

  #  Print each matching item.

  print '<ul><ul>'
    if ($n > 0);
  $prev_name = '';
  $prev_score = 0;
  foreach (@matches) {
    ($score, @item) = split (/\|/);
    if ($score =~ /^\d+$/ && $score > 0) {
      if ($scoresort && $score != $prev_score) {
        print '</ul></ul><h4>Here ';
        if ($m{$score} != 1) {
          print 'are ', $m{$score}, ' matching items';
        } else {
          print 'is one matching item';
        }
        print ' with a score of ', $score;
        print ':</h4><ul><ul>';
        $prev_name = '';
        $prev_score = $score;
      }
      &print_match (@item);
    } 
  }

  if (@lost > 0) {
    #  Summarize items lost due to the limit.
    $total_lost = 0;
    foreach (@lost) {
      if (/^(\d+)\+(\d+)$/ && $1 > 0) {
        $total_lost += $2;
        if ($scoresort) {
          &print_lost ($1, $2, $prev_score);
          $prev_score = $1;
        }
      } 
    }
    &print_lost ('', $total_lost, '')
      unless ($scoresort);
  }

  print '</ul></ul><h4>End of Results</h4>'
    if ($n > 0);
}

#  Common client comparison functions (for sorting).
sub byblazon {
  local($sa, $na, $da, $ya, $ba) = split (/\|/, $a);
  local($sb, $nb, $db, $yb, $bb) = split (/\|/, $b);
  return $ba cmp $bb;
}
sub bylastdate {
  local($sa, $na, $da) = split (/\|/, $a);
  local($sb, $nb, $db) = split (/\|/, $b);
  $da =~ s/^.*[-]//;
  $db =~ s/^.*[-]//;
  return &idate ($da) <=> &idate ($db);
}
sub byname {
  local($sa, $na) = split (/\|/, $a);
  local($sb, $nb) = split (/\|/, $b);
  return $na cmp $nb;
}
sub byscorename {
  local($sa, $na) = split (/\|/, $a);
  local($sb, $nb) = split (/\|/, $b);
  local($c) = ($sb <=> $sa);
  return $c if ($c);
  return $na cmp $nb;
}
sub byscoreblazon {
  local($sa, $na, $da, $ya, $ba) = split (/\|/, $a);
  local($sb, $nb, $db, $yb, $bb) = split (/\|/, $b);
  local($c) = ($sb <=> $sa);
  return (($sb <=> $sa) || ($ba cmp $bb));
  return $na cmp $nb;
}

#  Common client function to translate a Latin-1 string to HTML.
#  Non-ASCII chars, ampersands, angle-brackets, etc. are escaped.
sub escape {
  local($out) = '';
  foreach (split (//, $_[1])) {
    if (m&^[ !'()*+,./0-9:;?A-Za-z-]$&) {
      $out .= $_;
    } else {
      $out .= sprintf ('&#%u;', ord ($_));
    }
  }
  return $out;
}

# Common client function to translate a Latin-1 string into a URL fragment.

sub encodeway {
  local($_) = $_[1];

  tr/\300\301\302\303\304\305\307\310\311\312\313\314\315\316\317\321\322\323\324\325\326\330\331\332\333\334\335\340\341\342\343\344\345\347\350\351\352\353\354\355\356\357\361\362\363\364\365\366\370\371\372\373\374\375\377/AAAAAACEEEEIIIINOOOOOOUUUUYaaaaaaceeeeiiiinoooooouuuuyy/;
  s/\306/AE/g;
  s/\320/Dh/g;
  s/\336/Th/g;
  s/\337/sz/g;
  s/\346/ae/g;
  s/\360/dh/g;
  s/\376/th/g;
    
  return &encode ($_);
}

sub encode {
  local($out) = '';
  local($_) = $_[1];

  local(@chars) = split (//, $_);

  foreach (@chars) {
    if (/^[A-Za-z0-9]$/) {
      $out .= $_;
    } else {
      $out .= sprintf ('%%%02x', ord ($_));
    }
  }
  return $out;
}

# Common client function to format a date using style indicated
#  by the global variable $era.
sub source {
  #global ($date_links, $era);
  local ($source) = @_;
  if ($source eq '') {
    # The date is unknown -- be vague.
    return 'at some point';
  } else {
    local ($year, $out, $have_loar);
    my ($ce, $month, $kingdom);
    if (length($source) > 5) # full years
    {
        ($ce, $month, $kingdom) = unpack ( 'A4 A2 A1', $source);
    }
    else # two digit years
    {
        ($ce, $month, $kingdom) = unpack ( 'A2 A2 A1', $source);
        $ce += 1900;
        $ce += 100 if ($ce < 1966);
    }
    $have_loar = ($ce > 1993);

    if ($era eq 'SCA') {
      $year = $ce - 1966;
      ++$year if ($month > 4);

      # Convert the numeric SCA year (1 .. 99) to Roman numerals.
      $year = 'A.S. ' . ('', 'X', 'XX', 'XXX', 'XL', 'L',
                       'LX', 'LXX', 'LXXX', 'XC')[$[ + int($year/10)]
                    . ('', 'I', 'II', 'III', 'IV', 'V', 
                       'VI', 'VII', 'VIII', 'IX')[$[ + ($year%10)];
    } else {
      $year = $ce;
    }
    local ($mn) = $month_name[$month];
    $out = "in $mn of $year";
    $out .= " (via $kingdom_name{$kingdom})" if ($kingdom ne '');
    return $out if ($date_links eq 'disabled');

    local ($sopt) = "y1=$ce&m1=$mn&y2=$ce&m2=$mn";
    if ($kingdom ne '') {
      $sopt .= "&k$kingdom=checked";
    } else {
      local ($kn);
      foreach $kn (sort keys %kingdom_name) {
        $sopt .= "&k$kn=checked";
      }
    }
    return qq'<a href="XXDateSearchUrlXX?$sopt">$out</a>';
  }
} # sub source

# Common client function to convert a blazon into HTML (with
#  links to the glossary, if those are enabled).
sub blazon {
  #global ($gloss_links, %gloss);
  local ($_) = @_;
  local (@words, $i, $phrase);

  $_ = &escape ($_);
  return $_ if ($gloss_links eq 'disabled');

  # Split into words.
  @words = split (/([^A-Za-z0-9]+)/);
  for ($i = $[; $i <= $#words; $i += 2) {
    if ($i < $#words-1) {
      # Look up two-word phrase.
      $phrase = "$words[$i] $words[$i+2]";
      $phrase =~ tr/[A-Z]/[a-z]/;
      if ($gloss{$phrase} ne '') {
        $words[$i] = qq'<a href="XXGlossaryUrlXX?p=$gloss{$phrase}">$words[$i]';
        $i += 2;
        $words[$i] .= '</a>';
        next;
      }
    }

    # Look up one-word phrase.
    $phrase = $words[$i];
    $phrase =~ tr/[A-Z]/[a-z]/
      unless ($phrase eq 'Or');
    $words[$i] = qq'<a href="XXGlossaryUrlXX?p=$gloss{$phrase}">$words[$i]</a>'
      if ($gloss{$phrase} ne '');
  } 
  return join ('', @words);
} # sub blazon

# Permute the words of a name so that the first word is significant.
sub permute {
  local ($_) = @_; 

  s/^(the|la|le) +//i;
  if (
/^(award|bard|barony|borough|braithrean|brotherhood|canton|casa|castle of|castrum|ch[a\342]teau|ch\{a\^\}teau|clann?|college|compagnie|companionate|company|crown principality|domus|dun|fellowship|freehold|guild|honou?r of the|house|household|hous|h[ao]?us|h\{u'\}sa|keep|kingdom|league|l'ordre|maison|office|orde[nr]|ord[eo]|ordre|principality|province|riding|shire) (.*)/i) {
    $_ = "$2, $1";
    $_ = "$2 $1"
      if (/^(a[fn]|aus|d[eou]|de[ils]|dell[ao]|in|na|of?|van|vo[mn]) (.*)/i);
    $_ = "$2 $1"
      if (/^(das|de[mn]?|der|die|el|l[ae]|les|the) (.*)/i);
  }
  return $_;
}

# Common client function to print a name as a link to
#  the corresponding name search.
sub name {
  local ($text) = @_;
  local ($link) = &permute ($text);

  return '<a href="XXNameSearchUrlXX?p=' . &encodeway ($link) . '">'
      . &escape ($text) . '</a>';
}

# Common client function to convert a source string (from
#  the database) to numerical month.
sub idate {
  local ($source) = @_;
  return '' if ($source eq '');

  local ($ce, $month, $kingdom) = unpack ('A4 A2 A1', $source);
  #$ce += 100 if ($ce < 66);   # Be prepared!
  return $ce*12 + $month;
}

# Common client function to connect to the database server.
sub connect_to_data_server {
  # global ($AF_INET, $SOCK_STREAM);
 
  # Init global $hostname.
  chop ($hostname = `hostname`);

  local ($name, $aliases, $proto) = getprotobyname ('tcp');

  local ($type, $len, $thisaddr, $thataddr);
  ($name, $aliases, $type, $len, $thisaddr) = gethostbyname ($hostname);
  ($name, $aliases, $type, $len, $thataddr) = gethostbyname ($them);

  local ($this, $that);
  $this = pack ($sockaddr, $AF_INET, 0, $thisaddr);
  $that = pack ($sockaddr, $AF_INET, $port, $thataddr);

  # Open socket connection to port $port on host $them.
  # Note that S is a global filehandle.
  socket (S, $AF_INET, $SOCK_STREAM, $proto) || die "socket: $!";
  if (!connect (S, $that)) {
    $cast = "connect: $!";
    print '<h4>Sorry, database server ', $them;
    print ' refused the connection.  Try again later.</h4>';
    &print_trailer ();
    die $cast;
  }

  # Put the connection into line-buffered mode.
  select (S); $| = 1; select (STDOUT);
}

# Common client function to connect to print an HTML header.
sub print_header {
  # Print bogus MIME type.
  print "Content-Type:  text/html\n";

  # Print HTML header.
  print '<html><head><title>', $form_title, '</title></head>';

  # Print first part of HTML body.
  print '<body>';
  print '<form action="', $cgi_url, '",type="POST",enctype="', $enctype, '">';
  print '<h2>', $form_title, '</h2>';
}

# Common client function to connect to print an HTML trailer.
sub print_trailer {
  # Print the author's address and other important info.
  print 'XXTrailerXX';
  print 'XXTrailer2XX';
  print 'XXCloseHtmlXX';
  print "\n";
}

sub fixcase # make heading UC, features lc
{
    my $desc = shift;
    my ($hdg, $features) = split(/:/, $desc, 2);
    $hdg = uc($hdg);
    $features = lc($features) if defined $features;
    return defined $features ? "$hdg:$features" : $hdg;
}
1;
# end of XXCommonClientPathXX
