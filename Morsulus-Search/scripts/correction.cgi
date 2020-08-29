#!XXPerlPathXX

# This is a CGI script to submit a correction to the Ordinary or Armorial.

$[ = 1;
$, = '';
$\ = "\n";

$form_title = 'Request a Correction to the SCA Ordinary or SCA Armorial';
$outfile = 'XXCorrectionLogPathXX';

# Set encoding type.
$enctype = 'application/x-www-form-urlencoded';

# Replace escaped URL characters with text.
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

#  Common client function to translate a text string to HTML.
sub escape {
  local($out) = '';
  local(@chars) = split (//, $_[1]);
  foreach (@chars) {
    if (/^[ A-Za-z0-9]$/) {
      $out .= $_;
    } else {  
      $out .= sprintf ('&#%u;', ord ($_));
    } 
  }
  return $out; 
}

# Process arguments.
foreach $pair (split (/\&/, $ENV{'QUERY_STRING'})) {
  ($left, $right) = split (/[=]/, $pair, 2);
  $left = &decode ($left);
  $right = &decode ($right);

  $p = $right if ($left eq 'p');
  $own = $right if ($left eq 'own');
  $misname = $right if ($left eq 'misname');
  $missing = $right if ($left eq 'missing');
  $misindex = $right if ($left eq 'misindex');
  $checked = $right if ($left eq 'checked');
  $date = $right if ($left eq 'date');
  $text = $right if ($left eq 'text');
  $email = $right if ($left eq 'email');
  $rights{$left} = $right;
}

# Print bogus MIME type.
print "Content-Type:  text/html\n";

# Print HTML header.
print '<html><head><title>', $form_title, '</title></head>';

# Print first part of HTML body.
print '<body>';
print q{XXSiteHeadXX};

$valid = 0;

if ($own ne '' || $misname ne '' || $missing ne ''
 || $misindex ne '' || $checked ne '' || $date ne '' || $text ne ''
 || $email ne '') {
  # A request was submitted; check to see whether it might be valid.
  $valid = 1;
  @err = ();

  if ($p eq '') {
    push (@err, '<li>You didn\'t provide the SCA name in step 1.');
    $valid = 0;
  }
  if ($missing ne '' && $date eq '') {
    push (@err, '<li>You didn\'t provide the date of registration in step 3.');
    $valid = 0;
  }
  if ($text eq '') {
    push (@err, '<li>You didn\'t provide an explanation in step 4.');
    $valid = 0;
  }
  if ($email eq '') {
    push (@err, '<li>You didn\'t provide an email address in step 5.');
    $valid = 0;
  }
  if ($valid && !open (LOG, ">>$outfile")) {
    push (@err, '<li>Our computer is misconfigured.');
    $valid = 0;
  }
  if ($valid) {
    $number = $$;
    print LOG "----begin $number";
    while (($l, $r) = each (%rights)) {
      $r =~ s"\r?\n" / "g;
      print LOG "$l($number)=[$r]";
    }
    print LOG "----end $number";
    close (LOG);

    print '<h3>Your correction request has been recorded as follows:</h3><hr>';
    print '<p>Subject:';

    $name = &escape ($p);
    if ($own ne '') {
      print "my registration ($name)";
    } else {
      print "a registation by <i>$name</i>";
    }
    $xdate = &escape ($date);
    if ($date ne '') {
      print "dated $xdate";
    }

    print '<ul>';
    if ($missing ne '') {
      print '<li>It is missing from the <i>SCA Armorial</i>.';
    }
    if ($misname ne '') {
      print '<li>The name is mis-spelled in the <i>SCA Armorial</i>,';
      print 'as detailed below.';
    }
    if ($misindex ne '') {
      print '<li>It is mis-indexed in the <i>SCA Ordinary</i>,';
      print 'as detailed below.';
    }
    print '</ul>';

    $xtext = &escape ($text);
    print "<p><pre>$xtext</pre>";

    if ($checked ne '') {
      print '<p>I have checked this information against the';
      print "$xdate Laurel letter.";
    }

    $xemail = &escape ($email);
    print "<p>Please send e-mail to me at <b>$xemail</b> when my request";
    print 'has been looked at by a human being.<p>';

  } else {
    print '<h2>Your correction request was not processed because:</h3><ul>';
    print @err;
    print '</ul>Try again.<hr>';
  }
}

if ($valid == 0) {
  print '<form action="XXCorrectionUrlXX",type="POST",enctype="', $enctype, '">';
  print '<h2>', $form_title, '</h2>';
  print <<'EOF';
<p>NOTE!  This service is primarily for correcting
errors that occurred between the
<a href="http://heraldry.sca.org/loar/">Laurel letters</a>
and the SCA Armorial.
Errors that reflect errors in the Laurel letters will take
several months to correct.
This service is specifically <b>not</b> for changes and appeals.
Changes to properly-registered items and appeals of questionable
Laurel decisions should be submitted through the heralds in your
kingdom.<p>
<ol>
<li>Type the full SCA <b>name</b> of the person or branch
that registered the item
(as it currently appears in the <i>Armorial</i>).
If the name is missing from the <i>Armorial</i>,
type the name as it <i>should</i> appear. (required)
EOF

  print '<input type="text" name="p" value="', $p, '" size=50>';

  print '<br><br>';
  print '<li>Click on any applicable boxes (optional):';

  print '<br><input type="checkbox" name="own" value="checked" ', $own, '>';
  print 'The item in question is registered <b>to you</b>.';

  print '<br><input type="checkbox" name="misname" value="checked" ',
    $misname, '>';
  print 'The name is <b>misspelled</b> in the <i>Armorial</i>';
  print '-- be sure to provide the correct spelling.';

  print '<br><input type="checkbox" name="missing" value="checked" ',
    $missing, '>';
  print 'The item is <b>missing</b> from the <i>Armorial</i>';
  print '-- be sure to provide the <b>month and year</b> of registration.';

  print '<br><input type="checkbox" name="misindex" value="checked" ',
    $misindex, '>';
  print 'The armory appears under an inappropriate <b>heading</b>';
  print 'in the <i>Ordinary</i>';
  print '-- be sure to specify the heading in question.';

  print '<br><input type="checkbox" name="checked" value="checked" ',
    $checked, '>';
  print 'You have <b>checked</b> the item against the Laurel Letter.';

  print '<br><br>';
  print '<li>Type the month and year in which the item was registered';
  print '(if known).';
  print '<input type="text" name="date" value="', $date, '" size=15>';

  print '<br><br>';
  print '<li>Briefly explain the correction you are requesting,';
  print 'including all pertinent information (required).<br>';
  print '<textarea name="text" rows=8 cols=50></textarea>';

  print '<br><br>';
  print '<li>For e-mail confirmation of your request,';
  print 'type your full e-mail address below (required).<br>';
  print '<input type="text" name="email" value="', $email, '" size=50>';

  print '</ol>';

  print '<h3>Actions:</h3>';
  print '<input type="submit" value="submit the request">';
  print '<input type="reset" value="reset the form">';
  print '</form>';
}

print <<'EOF';
<hr><address>
XXTrailer2XX
XXCloseHtmlXX
EOF

# end of XXCorrectionScriptXX
