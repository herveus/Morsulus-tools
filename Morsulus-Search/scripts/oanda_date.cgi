#!XXPerlPathXX

# This is a CGI script to do a date/kingdom search of the oanda database.
# It is to be installed at XXDateSearchPathXX on XXServerNameXX.

# Set URL for this script.
$cgi_url = 'XXDateSearchUrlXX';

# Set title for form.
$form_title = 'Date/Kingdom Search Form';

require 'XXCommonClientPathXX';

# option settings

$this_year = 1900 + (localtime time)[$[+5];
$last_year = $this_year - 1;

$month1 = 'January';  # default
$year1 = $last_year;  # default

$month2 = 'December'; # default
$year2 = $last_year;  # default

%kingdom_set = ();    # default

@sorts = ('name only', 'last action date', 'blazon');
$sort = 'name only';  # default

# Process arguments.
foreach $pair (split (/\&/, $ENV{'QUERY_STRING'})) {
  ($left, $right) = split (/[=]/, $pair, 2);
  $left = &decode ($left);
  $right = &decode ($right);

  $arm_descs = $right if ($left eq 'a');
  $era = $right if ($left eq 'd');
  $gloss_links = $right if ($left eq 'g');
  $kingdom_set{$1} = $right if ($left =~ /^k([A-Za-z])$/);
  $limit = $right if ($left eq 'l');
  $month1 = $right if ($left eq 'm1');
  $month2 = $right if ($left eq 'm2');
  $sort = $right if ($left eq 's');
  $year1 = $right if ($left eq 'y1');
  $year2 = $right if ($left eq 'y2');

  $p = 1;
}
$limit = 200 if ($limit !~ /^\d+$/);

&print_header ();

if ($p ne '') {
  &connect_to_data_server ();

  $year1 += 1900 if ($year1 > 66 && $year1 < 100);
  $year1 = 1970 if ($year1 < 1970);
  $year1 = $this_year if ($year1 > $this_year);
  $year2 += 1900 if ($year2 > 66 && $year2 < 100);
  $year2 = 1970 if ($year2 < 1970);
  $year2 = $this_year if ($year2 > $this_year);
  $kstring = '';
  while (($k, $v) = each %kingdom_set) {
    $kstring .= $k if ($v ne '');
  }

  print S "l $limit";
  print S 's 1 ', $year1, $mmap{$month1}, ' ', $year2, $mmap{$month2}, ' ', 
          $kstring;
  print S 'EOF';

  $n = &get_matches ();

  if ($sort eq 'name only') {
    $scoresort = 0;
    @matches = sort byname @matches;
  } elsif ($sort eq 'blazon') {
    $scoresort = 0;
    @matches = sort byblazon @matches;
  } elsif ($sort eq 'last action date') {
    $scoresort = 0;
    @matches = sort bylastdate @matches;
  }
}
  
print '<p>There are <a href="XXSearchMenuUrlXX">other search forms</a> available.';
print 'For help using this form, please refer to the <a href="XXDateHintsPageUrlXX">hints page</a>.';

print '<p>Starting date ->;';
&select ('m1', $month1, @month_name);
print '<input type="text" name="y1" value="', $year1, '" size=4>';

print '<p>Ending date ->;';
&select ('m2', $month2, @month_name);
print '<input type="text" name="y2" value="', $year2, '" size=4>';

foreach (sort keys %kingdom_name) {
  print '<br><input type="checkbox" name="k', $_, '" value="checked" ',
    $kingdom_set{$_}, '>', $kingdom_name{$_};
}

print '<p>Maximum number of items to display ->;';
print '<input type="text" name="l" value="', $limit, '" size=3>';

&display_options ();

print '<h3>Actions:</h3>';
print '<input type="submit" value="search for items matching the dates/kingdoms above">';
print '</form>';

if ($p ne '') {
  print '<hr>';
  &print_results ("date between $month1/$year1 and $month2/$year2 inclusive, from one of the specified kingdoms", $n, $scoresort);

}
&print_trailer ();
# end of XXDateSearchPathXX
