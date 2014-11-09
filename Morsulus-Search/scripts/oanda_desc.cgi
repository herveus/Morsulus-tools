#!XXPerlPathXX

# This is a CGI script to do a desc search of the oanda database.
# It is to be installed at XXDescSearchPathXX on XXServerNameXX.

# Set URL for this script.
$cgi_url = 'XXDescSearchUrlXX';

# Set title for form.
$form_title = 'Armory Description Search Form';

require 'XXCommonClientPathXX';

# Process arguments.
foreach $pair (split (/\&/, $ENV{'QUERY_STRING'})) {
  ($left, $right) = split (/[=]/, $pair, 2);
  $left = &decode ($left);
  $right = &decode ($right);

  $p = $right if ($left =~ 'p');
}

&print_header ();
if ($p ne '') {
  &connect_to_data_server ();

  print S 'd0 1 ', fixcase($p);
  print S 'EOF';

  $n = &get_matches ();
  
  $scoresort = 0;
  @matches = sort byblazon @matches;
}

print '<p>There are <a href="XXSearchMenuUrlXX">other search forms</a> available.';
print 'For help using this form, please refer to the <a href="XXDescHintsPageUrlXX">hints page</a>.';


print '<p>Enter a description of the armory for which you are searching ->;';
print '<input type="text" name="p" value="', $p, '" size=30>';

print '<h3>Actions:</h3>';
print '<input type="submit" value="search for items matching the above description">';
print '</form>';

if ($p ne '') {
  print '<hr>';
  &print_results ("description=\"<i>".&escape($p)."</i>\"", $n, $scoresort);

  print '<a href="XXComplexSearchUrlXX?a=', $arm_descs, '&d=', $era, '&g=', $gloss_links, '&l=500&s=blazon&w1=1&m1=armory+description&p1=', &encode ($p), '">convert to complex search</a>'
}
&print_trailer ();
# end of XXDescSearchPathXX
