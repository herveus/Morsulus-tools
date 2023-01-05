#!XXPerlPathXX

# This is a CGI script to do a blazon pattern search of the oanda database.
# It is to be installed at XXBpSearchPathXX on XXServerNameXX.

# Set URL for this script.
$cgi_url = 'XXBpSearchUrlXX';

# Set title for form.
$form_title = 'Blazon Pattern Search Form';

require 'XXCommonClientPathXX';

# option settings
@cases = ('case-sensitive', 'case-insensitive');
$case = 'case-insensitive';

@sorts = ('name only', 'last action date', 'blazon');
$sort = 'name only';  # default

# Process arguments.
#$ENV{'QUERY_STRING'} ~= tr/<>//;
foreach $pair (split (/\&/, $ENV{'QUERY_STRING'})) {
  ($left, $right) = split (/[=]/, $pair, 2);
  $left = &decode ($left);
  $right = &decode ($right);

  $arm_descs = $right if ($left eq 'a');
  $case = $right if ($left eq 'c');
  $era = $right if ($left eq 'd');
  $gloss_links = $right if ($left eq 'g');
  $limit = $right if ($left eq 'l');
  $p = $right if ($left eq 'p');
  $sort = $right if ($left eq 's');
}
$limit = 500 if ($limit !~ /^\d+$/);

&print_header ();

if ($p ne '') {
  &connect_to_data_server ();

  print S 'l ', $limit;
  if ($case eq 'case-insensitive') {
    $i = 'i';
  } else {
    $i = '';
  }
  print S "eb$i 1 $p";
  print S 'EOF';

  $n = &get_matches ();

  if ($sort eq 'name only') {
    $scoresort = 0;
    @matches = sort byname @matches;
  } elsif ($sort eq 'last action date') {
    $scoresort = 0;
    @matches = sort bylastdate @matches;
  } elsif ($sort eq 'blazon') {
    $scoresort = 0;
    @matches = sort byblazon @matches;
  }
}
  
print '<p>There are <a href="XXSearchMenuUrlXX">other search forms</a> available.';
print 'For help using this form, please refer to the <a href="XXBpHintsPageUrlXX">hints page</a>.';

print '<p>Enter the blazon pattern for which you are searching ->;';
print '<input type="text" name="p" value="', $p, '" size=30>';

print '<p>Select type of search ->;';
&select ('c', $case, @cases);

print '<p>Maximum number of items to display ->;';
print '<input type="text" name="l" value="', $limit, '" size=3>';

&display_options ();

print '<h3>Actions:</h3>';
print '<input type="submit" value="search for items matching the blazon pattern">';
print '</form>';

if ($p ne '') {
  print '<hr>';
  &print_results ($case.' blazon pattern="<i>'.&escape($p).'</i>"', $n, $scoresort);

  print '<a href="XXComplexSearchUrlXX?a=', $arm_descs, '&d=', $era, '&g=', $gloss_links, '&l=', $limit, '&s=', $sort, '&w1=1&m1=blazon+pattern&p1=', &encode ($p), '">convert to complex search</a>'
}
&print_trailer ();
# end of XXBpSearchPathXX
