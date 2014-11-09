use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Morsulus-Search';
all_from 'lib/Morsulus/Search.pm';
author   q{Michael Houghton <herveus@cpan.org>};
license  'artistic2';

perl_version 5.006;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Morsulus-Search',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/Michael Houghton/Morsulus-Search.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Morsulus-Search',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

print <<'EOF';

This Perl module configures and installs web-based tools for viewing
the SCA Ordinary and searching the SCA Armorial.

This portion of the installation should be performed ON THE WEBSERVER.
EOF

my %pages = pages();
my %scripts = scripts();
my $Y = '';
my $Cgibin = 0;
my $Rcs = 0;
my %config;

sub pages
{
    return (
        'SearchMenu', 'search menu:index',  
        'NameHintsPage', 'name search hints:hints_name',
        'DateHintsPage', 'date search hints:hints_date',
        'DescHintsPage', 'armory description search hints:hints_desc',
        'NpHintsPage', 'name pattern search hints:hints_np',
        'BpHintsPage', 'blazon pattern search hints:hints_bp',
        'ComplexHintsPage', 'complex search hints:hints_complex',
        'OverviewPage', 'about SCA heraldry:heraldry_overview',
        'LimitPage', 'about search limits:search_limits',
        'DownloadPage', 'about obtaining the database:data_obtain',
        'DbFormatPage', 'about the database format:data_format',
        'DbSymbolsPage', 'non-ASCII symbols:data_symbols',
    );
}

sub scripts
{
    return (
        'Glossary', 'glossary:glossary',
        'Copyright', 'database copyright:data_copyright',
        'Version', 'database version:version',
        'NameSearch', 'name search:oanda_name',
        'DescSearch', 'armory description search:oanda_desc',
        'NpSearch', 'name pattern search:oanda_np',
        'BpSearch', 'blazon pattern search:oanda_bp',
        'DateSearch', 'date/kingdom search:oanda_date',
        'ComplexSearch', 'complex search:oanda_complex',
        #  'Correction', 'correction request:correction',
    );
}

require "scripts/commonconfig.pl";

print "\nThe following web pages will be installed on the webserver:\n";
print_list (values %pages);

print "\nThe following CGI scripts will be installed on the webserver:\n";
print_list (values %scripts);

print "\nThe following other files will also be installed on the webserver:\n";
print_list (
  'ordinary master index',
  'common Perl code',
  'database server config script',
  'ordinary index pages (A-Z)'
);

my $cwd = `pwd`; chomp $cwd;

print "\nPress Enter to proceed, or else interrupt the installation now.\n";
input ('');

# Get old config values, if available.

my $conf_file = '.configweb';
%config = read_config_file ($conf_file);
$config{CONF_FILE} = $conf_file;

$config{XXPrimerUrlXX} = 'http://www.sca.org/heraldry/primer';
$config{XXLoARUrlXX} = 'http://www.sca.org/heraldry/loar';
my $config_version = 20130909;
$config{XXVersionXX} = $config_version;
$config{XXHeadXX} = '';

$config{XXTrailerXX} = "<hr><address>config.web version $config_version ";
$config{XXTrailer2XX} = '';
$config{XXCloseHtmlXX} = '</address></body></html>';

#============================#
# Set webserver parameters.  #
#============================#

my ($PerlPath) = machine_questions ();
$config{XXPerlPathXX} = $PerlPath;


# Set $ServerName.
my $ServerName;

while (1)
{
    $ServerName = $config{XXServerNameXX};
    $ServerName ||= 'oanda.sca.org';
    print <<'EOF';

    What is the DNS hostname of this machine?

      (This should be listed as the ServerName
      in the webserver configuration file.)

EOF
    print "[$ServerName] ";
    $ServerName = input ($ServerName);
    my @a = gethostbyname ($ServerName);
    if (@a != 5 && $ServerName ne 'localhost') {
        print "Sorry, `$ServerName' is not an accessible host.\n";
        print "Try again...\n";
        next;
    }
    $config{XXServerNameXX} = $ServerName;
    last;
}

# Set $ServerPort.

my $ServerPort;
 
while (1)
{
    $ServerPort = $config{'XXServerPortXX'};
    $ServerPort ||= 80;
    $ServerPort = 80 if ($ServerPort < 1);
    print <<'EOF';

To which port does this machine listen for incoming HTTP requests?

(This should be listed as the ServerPort in the webserver
configuration file.)

EOF
    print "[$ServerPort] ";
    $ServerPort = &input ($ServerPort);
    if ($ServerPort < 1 || $ServerPort > 32767) {
        print "Sorry, `$ServerPort' is not a valid port.\n";
        print "Try again...\n";
        next;
    }
    $config{'XXServerPortXX'} = $ServerPort;
    last;
}

# Set $DocumentRoot.

my $DocumentRoot;

while (1)
{
    $DocumentRoot = $config{'XXDocumentRootXX'};
    $DocumentRoot ||= '/local';
    $DocumentRoot = "$cwd/$DocumentRoot" if ($DocumentRoot =~ m#^[^/]#);
    print "\nWhat is the pathname of the directory corresponding to\n`http://$ServerName:$ServerPort/'?\n\n  (This should be listed as the DocumentRoot\n  in the webserver configuration file.)\n\n";
    print "[$DocumentRoot] ";
    $DocumentRoot = &input ($DocumentRoot);
    $DocumentRoot = "$cwd/$DocumentRoot" if ($DocumentRoot =~ m#^[^/]#);
    if (!-e $DocumentRoot) {
        print "Sorry, `$DocumentRoot' does not exist.\n";
        print "Try again...\n";
        next;
    }
    if (!-d $DocumentRoot) {
        print "Sorry, `$DocumentRoot' is not a directory.\n";
        print "Try again...\n";
        next;
    }
    $config{'XXDocumentRootXX'} = $DocumentRoot;
    last;
}

##TODO revise setting ScriptAlias; perhaps a question first instead of a command line argument

my $ScriptAlias;

if ($Cgibin) {
  # Set $ScriptAlias.

  scriptalias:
  $ScriptAlias = $config{'XXScriptAliasXX'};
  $ScriptAlias ||= '/usr/local/etc/httpd/cgi-bin';
  $ScriptAlias = "$cwd/$ScriptAlias" if ($ScriptAlias =~ m#^[^/]#);
  print "\nWhat is the pathname of the directory corresponding to\n`http://$ServerName:$ServerPort/cgi-bin/'?\n\n  (This should be listed as the ScriptAlias\n  in the webserver configuration file.)\n\n";
  print "[$ScriptAlias] ";
  $ScriptAlias = &input ($ScriptAlias);
  $ScriptAlias = "$cwd/$ScriptAlias" if ($ScriptAlias =~ m#^[^/]#);
  if (!-e $ScriptAlias) {
    print "Sorry, `$ScriptAlias' does not exist.\n";
    print "Try again...\n";
    goto scriptalias;
  }
  if (!-d $ScriptAlias) {
    print "Sorry, `$ScriptAlias' is not a directory.\n";
    print "Try again...\n";
    goto scriptalias;
  }
  $config{'XXScriptAliasXX'} = $ScriptAlias;
}

#====================================#

print <<'EOF';


Now you get to choose where the files will be installed.

For each group of files:
 +  The default location is given in [brackets].
 +  To override the default location, enter your
      choice in the space next to the brackets.
 +  To accept the default location, enter a blank line.

EOF

#====================================#
# Set paths and URLs for HTML pages. #
#====================================#

my $PagePath = get_dirpath ('XXPagePathXX',
  'O&A web pages', $config{'XXPagePathXX'} || "$DocumentRoot/heraldry/OandA", $DocumentRoot);
$config{XXPagePathXX} = $PagePath;
my $PageUrl = get_html_url ('XXPageUrlXX', 'O&A web pages', $PagePath);

my $WebDataPath = get_filepath ('XXWebDataPathXX', 'database file',
   $config{'XXWebDataPathXX'} || 'oanda.db', $DocumentRoot);
$config{XXWebDataPathXX} = $WebDataPath;
my $WebDataUrl = get_html_url ('XXWebDataUrlXX', 'database file', $WebDataPath);

foreach my $tag (keys %pages) {
  set_page_info ($tag);
}

my $IndexDirPath = get_dirpath ('XXIndexDirPathXX',
  'SCA Ordinary index pages', $config{'XXIndexDirPathXX'} || "$PagePath/ordinary", $DocumentRoot);
$config{XXIndexDirPathXX} = $IndexDirPath;
my $IndexDirUrl = get_html_url ('XXIndexDirUrlXX',
   'SCA Ordinary index pages', $IndexDirPath);

#=====================================#
# Set paths and URLs for CGI scripts. #
#=====================================#

my $ScriptPath;
if ($Cgibin) {
  $ScriptPath = get_dirpath ('XXScriptPathXX',
    'CGI scripts', $ScriptAlias, $ScriptAlias);
} else {
  $ScriptPath = get_dirpath ('XXScriptPathXX',
    'CGI scripts', $PagePath, $DocumentRoot);
}
$config{XXScriptPathXX} = $ScriptPath;
my $ScriptUrl = get_cgi_url ('XXScriptUrlXX', 'CGI scripts', $ScriptPath);

foreach my $tag (keys %scripts) {
  set_script_info ($tag);
}

#========================#
# Set $CommonClientPath. #
#========================#
my $ccpath;
if ($Cgibin) {
  ($ccpath) = $ScriptAlias =~ m#^(.*)[/][^/]+[/]?$#;
} else {
  ($ccpath) = $PagePath =~ m#^(.*)[/][^/]+[/]?$#;
}
my $CommonClientPath = get_filepath ('XXCommonClientPathXX',
   'common Perl code', $config{'XXCommonClientPathXX'} || "$ccpath/common.pl", '/');
$config{XXCommonClientPathXX} = $CommonClientPath;
#=========================#
# Set $CorrectionLogPath. #
#=========================#

# $CorrectionLogPath = &get_filepath ('XXCorrectionLogPathXX',
#   'correction log', 'correction.log', '/');

save_config(\%config);

#====================================#
# Set parameters of database server. #
#====================================#

print <<'EOF';


Now I need you to answer a few questions about the database server.
This may or may not be the same machine as the webserver, but
it must be accessable via TCP/IP and it must have disk space to
install the 5MB Armorial database.

For each question:
 +  The default answer is given in [brackets].
 +  To override the default answer, enter the
      correct answer in the space next to the brackets.
 +  To accept the default answer, enter a blank line.

EOF

# Set $DataHost.
my $DataHost = $config{'XXDataHoseXX'} || $ServerName;
while (1)
{
    print "\nWhat is the DNS hostname of the database server?\n[$DataHost] ";
    $DataHost = input($DataHost);
    my @a        = gethostbyname($DataHost);
    if (@a != 5 && $$DataHost ne 'localhost')
    {
        print "Sorry, `$DataHost' is not an accessible host.\n";
        print "Try again...\n";
        next;
    }
    $config{'XXDataHostXX'} = $DataHost;
    last;
}

# Set $DataPort.
my $DataPort = $config{'XXDataPortXX'} || 1066;
$DataPort = 1066 if $DataPort < 1;
while (1)
{
    print "\nTo which port will the database server\nlisten for incoming database requests?\n[$DataPort] ";
    $DataPort = input ($DataPort);
    if ($DataPort < 1 || $DataPort > 32767) 
    {
        print "Sorry, `$DataPort' is not a valid port number.\n";
        print "Try again...\n";
        next;
    }
    $config{'XXDataPortXX'} = $DataPort;
    last;
}

# Set $ConfigDbPath.
my $ConfigDbPath = get_filepath ('XXConfigDbPathXX',
   'database server config script', $config{'XXConfigDbPathXX'} || 'configdb', '/');
$config{'XXConfigDbPathXX'} = $ConfigDbPath;
#=======================================#
# Save the new webserver configuration. #
#=======================================#

save_config(\%config);

print "Generating Ordinary index page templates\n";

my $cat_file_name = "scripts/temp.cat";
my $print_file_name = "scripts/tprint.cat";

read_cat_file($cat_file_name);

my $head = <<'XXXEOFXXX';
<html>
<head><title>Index of the SCA Ordinary - The Letter %s</title>
<base href="XXIndexDirUrlXX/%s.html">XXHeadXX
</head><body>
<h2>Index of the SCA Ordinary - The Letter %s</h2>

<ul>
XXXEOFXXX

my $tail = <<'XXXEOFXXX';
</ul>

XXTrailerXX
XXTrailer2XX
XXCloseHtmlXX
XXXEOFXXX

open my $PRINT_FILE, '<', $print_file_name;

open my $fh, '>', 'scripts/ordinary/A.html';
my $last = '';

while (my $print_line = <$PRINT_FILE>)
{
    chomp $print_line;
    $last = print_anchor($print_line, $last);
    my ($urldesc, $heading) = format_cat($print_line);
    my $cat = publish($print_line);
    $last = switch_output_file(uc(substr($cat,1,1)), $last);
    if ($heading && 
        (!exists $cross_ref{$print_line} || $cross_ref{$print_line} =~ /^also /))
    {
        print $fh qq'<li><a href="XXDescSearchUrlXX?p=$urldesc">$cat</a>\n';
    }
    else
    {
        print $fh qq'<li>$cat\n';
    }
    if (exists $cross_ref{$print_line})
    {
        my ($also, $cr) = $cross_ref{$print_line} =~ /^(also )?(.+)$/;
        my @cr = split(/ and /, $cr);
        print $fh ' - see ', $also, join(' and ', map {cref($_, $cat)} @cr), "\n";
    }
    else
    {
        die unless $heading;
    }
}
switch_output_file('', $last);

#============================================#
# Configure and install the webserver files. #
#============================================#

&page_install ($SearchMenu, 'SearchMenu');
&page_install ($NameHintsPage, 'NameHintsPage');
&page_install ($DateHintsPage, 'DateHintsPage');
&page_install ($DescHintsPage, 'DescHintsPage');
&page_install ($NpHintsPage, 'NpHintsPage');
&page_install ($BpHintsPage, 'BpHintsPage');
&page_install ($ComplexHintsPage, 'ComplexHintsPage');
&page_install ($OverviewPage, 'OverviewPage');
&page_install ($LimitPage, 'LimitPage');
&page_install ($DownloadPage, 'DownloadPage');
&page_install ($DbFormatPage, 'DbFormatPage');
&page_install ($DbSymbolsPage, 'DbSymbolsPage');

&install ($IndexPage, "$IndexDirPath/index.html", 0444,
  'ordinary master index');

for $letter ('A' .. 'Z') {
  &install ($IndexPage{$letter}, "$IndexDirPath/$letter.html", 0444,
    "ordinary index page ($letter)");
}

&script_install ($GlossaryScript, 'Glossary');
&script_install ($CopyrightScript, 'Copyright');
&script_install ($VersionScript, 'Version');
&script_install ($NameSearchScript, 'NameSearch');
&script_install ($DescSearchScript, 'DescSearch');
&script_install ($NpSearchScript, 'NpSearch');
&script_install ($BpSearchScript, 'BpSearch');
&script_install ($DateSearchScript, 'DateSearch');
&script_install ($ComplexSearchScript, 'ComplexSearch');
# &script_install ($CorrectionScript, 'Correction');

&key_install ($CommonClientCode, 'CommonClient', 0444, 'common Perl code');
&key_install ($ConfigDbScript, 'ConfigDb', 0444,
  'database server config script');

#=================================#
# Final message to the installer. #
#=================================#

print "\nYou have successfully installed the webserver files.\n";
print "Now copy `$ConfigDbPath' to the machine `$DataHost'\n";
print " and execute `perl $ConfigDbPath' there.\n";

install_as_cpan;
auto_install;
WriteAll;

#==============================================#
# Functions specific to the config.web script. #
#==============================================#

# config.web function to install an HTML page in a file,
# taking the path from %config.

sub page_install {
  my ($text, $tag) = @_;
  my ($what, $file) = split (/\:/, $pages{$tag});

  key_install ($text, $tag, 0444, $what);
}

# config.web function to install a CGI script in a file,
# taking the path from %config.

sub script_install {
  my ($text, $tag) = @_;
  my ($what, $file) = split (/\:/, $scripts{$tag});

  key_install ($text, $tag, 0555, $what);
}

# config.web function to print a list.

sub print_list {
  my ($i) = 0;

  foreach my $file (sort @_) {
    my ($what, $name) = split (/\:/, $file);
    printf " + %-35s", $what;
    if ($i++%2) {
      print "\n";
    } else {
      print ' ';
    }
  }
  print "\n" if ($i%2);
}

# config.web function to set the path and URL of an HTML page.

sub set_page_info {
  #global (%config, %pages);
  my ($tag) = @_;
  my ($what, $file) = split (/\:/, $pages{$tag});

  $config{'XX'.$tag.'PathXX'} = $config{'XXPagePathXX'} . "/$file.html";
  $config{'XX'.$tag.'UrlXX'}  = $config{'XXPageUrlXX' } . "/$file.html";
}

# config.web function to set the path and URL of a CGI script.

sub set_script_info {
  #global (%config, %scripts);
  my ($tag) = @_;
  my ($what, $file) = split (/\:/, $scripts{$tag});

  $config{'XX'.$tag.'PathXX'} = $config{'XXScriptPathXX'} . "/$file.cgi";
  $config{'XX'.$tag.'UrlXX'}  = $config{'XXScriptUrlXX' } . "/$file.cgi";
}

# config.web function to get the URL for an HTML page.

sub get_html_url {
  #global (%config, $ServerName, $ServerPort);
  my ($tag, $what, $path) = @_;

  my $url = $config{$tag};
  if (!defined $url || $url eq '') {
    $url = $path;
    $url =~ s/^$DocumentRoot//;
    $url = "http://$ServerName:$ServerPort$url";
  }
  print "\nURL for $what:\n[$url] ";
  $url = input ($url);
  $config{$tag} = $url;
  return $url;
}

# config.web function to set the URL for a CGI script.

sub get_cgi_url {
  #global (%config, $ServerName, $ServerPort, $Cgibin);
  my ($tag, $what, $path) = @_;

  my $url = $config{$tag};
  if (!defined $url || $url eq '') {
    $url = $path;
    if ($Cgibin) {
      $url =~ s/^$ScriptAlias//;
      $url = "http://$ServerName:$ServerPort/cgi-bin$url";
    } else {
      $url =~ s/^$DocumentRoot//;
      $url = "http://$ServerName:$ServerPort$url";
    }
  }
  print "\nURL for $what:\n[$url] ";
  $url = input ($url);
  $config{$tag} = $url;
  return $url;
}

sub print_anchor
{
    my ($print_line, $last) = @_;
    my @cur;
    for my $field (split(/, /, $print_line))
    {
        push @cur, $field;
        my $t = join(', ', @cur);
        if ($target{$t})
        {
            my $urlt = $t;
            $urlt =~ tr/[A-Za-z0-9]/[A-Za-z0-9]/cd;
            $last = switch_output_file(uc(substr($urlt,1,1)), $last);
            print $fh qq'<a name="$urlt">\n';
            $target{$t} = 0;
        }
    }
    return $last;
}

sub switch_output_file
{
    my ($this, $last) = @_;
    return $last if $this eq $last;
    print $fh <<'XXXEOFXXX' unless ($last eq '');
</ul>

XXTrailerXX
XXTrailer2XX
XXCloseHtmlXX
XXXEOFXXX
    close $fh;
    open $fh '>', "scripts/ordinary/$this.html";
    print $fh <<"XXXEOFXXX" unless $this eq '';
<html>
<head><title>Index of the SCA Ordinary - The Letter $this</title>
<base href="XXIndexDirUrlXX/$this.html">XXHeadXX
</head><body>
<h2>Index of the SCA Ordinary - The Letter $this</h2>

<ul>
XXXEOFXXX
    return $this;
}

sub format_cat
{
    my ($heading) = @_;
    my @heading = split(/, /, $heading);
    my @features;
    while (! exists $short{$heading} && $heading)
    {
        push @features, pop @heading;
        $heading = join(', ', @heading);
    }
    my $desc = join(':', $short{$heading}, @features);
    return (encode($desc), $heading);
}

sub encode
{
    my ($input) = @_;
    return join('', map
        {
            /[A-Za-z0-9]/ ? $_ : '%'.unpack('H2', $_)
        }
        split(//, $input));
}

sub publish
{
    my ($heading) = @_;
    my $cat = join(', ', 
        map { substr($_,1,1) =~ tr/[a-z]/[A-Z]/ }
        split(/, /, $heading);
    $cat =~ s/,/ -/g;
    $cat =~ s/~//g;
    $cat =~ s/  / /g;
    $cat =~ s/-  /- /g;
    return $cat;
}

sub cref
{
    my ($name, $cat) = @_;
    my $letter = uc(substr($name,1,1));
    $name =~ tr/[A-Za-z0-9]/[A-Za-z0-9]/cd;
    return qq'<a href="$letter.html#$name">$cat</a>\n';
}