#!XXPerlPathXX

# This is a CGI script to get the version data on the database and server.
# It is to be installed at XXVersionPathXX on XXServerNameXX.

# Set URL for this script.
$cgi_url = 'XXVersionUrlXX';

# Set title for form.
$form_title = 'Identify SCA Database Version';

require 'XXCommonClientPathXX';

&print_header ();
&connect_to_data_server ();

print S 'v';
print S 'EOF';

&get_matches ();

print '<hr>';
&print_messages ();
&print_trailer ();

# end of XXVersionPathXX
