
# Get the path to the current working directory.

$cwd = `pwd`; chop ($cwd);

# Check the hostname.

$host = `hostname`; chop ($host);
print "\nWarning:  this script should be run only on machine `XXDataHostXX',\n but it appears to be running on machine `$host'.\n"
  if ($host ne 'XXDataHostXX');

print "\nPress Enter to proceed, or else interrupt the installation now.\n";
$_ = &input ('');

# Get old config values, if available.

$conf_file = '.configdb';
%config = &read_config_file ($conf_file);

#=================================#
# Set database server parameters. #
#=================================#

$config{XPerlPathX} = &machine_questions ('XPerlPathX', 'XAF_INETX', 'XSOCK_STREAMX');

# Set $WNOHANG.

$WNOHANG = 1;
print <<'EOF';

What is the numeric code (WNOHANG) defined
for wait-without-suspend in `/usr/include/sys/wait.h'?

EOF
print "[$WNOHANG] ";
$WNOHANG = &input ($WNOHANG);
$config{'XWNOHANGX'} = $WNOHANG;

#====================#
# Set install paths. #
#====================#

print <<'EOF';


Now I need to you tell me where the database and the
category file are installed.

For each file:
 +  The default location is given in [brackets].
 +  To override the default location, enter the
      actual location in the space next to the brackets.
 +  To accept the default location, enter a blank line.

EOF

# Set $CatFileName.

catfilename:
$CatFileName = $config{'XCatFileNameX'};
$CatFileName = '/usr/local/data/my.cat' if ($CatFileName eq '');
$CatFileName = "$cwd/$CatFileName" if ($CatFileName =~ m#^[^/]#);
print "\nPath to category (my.cat) file:\n[$CatFileName] ";
$CatFileName = &input ($CatFileName);
$CatFileName = "$cwd/$CatFileName" if ($CatFileName =~ m#^[^/]#);
if (!-e $CatFileName) {
  print "Sorry, `$CatFileName' does not exist.\n";
  print "Download it from http://heraldry.sca.org/OandA/my.cat and try this step again.\n";
  die;
}
if (!-f $CatFileName) {
  print "Sorry, `$CatFileName' is not a normal file.\n";
  print "Try again...\n";
  goto catfilename;
}
$config{'XCatFileNameX'} = $CatFileName;

# Set $DbFileName.

dbfilename:
$DbFileName = $config{'XDbFileNameX'};
$DbFileName = '/usr/local/data/oanda' if ($DbFileName eq '');
$DbFileName = "$cwd/$DbFileName" if ($DbFileName =~ m#^[^/]#);
print "\nPath to database (oanda) file:\n[$DbFileName] ";
$DbFileName = &input ($DbFileName);
$DbFileName = "$cwd/$DbFileName" if ($DbFileName =~ m#^[^/]#);
if (!-e $DbFileName) {
  print "Sorry, `$DbFileName' does not exist.\n";
  print "Download it from http://heraldry.sca.org/OandA/oanda and try this step again.\n";
  die;
}
if (!-f $DbFileName) {
  print "Sorry, `$DbFileName' is not a normal file.\n";
  print "Try again...\n";
  goto dbfilename;
}
$config{'XDbFileNameX'} = $DbFileName;

print <<'EOF';


Now you get to decide where the database server script should
be installed and where the logfile should go.

For each file:
 +  The default location is given in [brackets].
 +  To override the default location, enter your
      choice in the space next to the brackets.
 +  To accept the default location, enter a blank line.

EOF

# Set $DatabaseServerPath.

$DatabaseServerPath = &get_filepath ('XDatabaseServerPathX',
   'database server script', '/usr/local/bin/oanda_server.pl', '/');

# Set $LogFileName.

logfilename:
$LogFileName = $config{'XLogFileNameX'};
$LogFileName = '/tmp/dbserver.log' if ($LogFileName eq '');
$LogFileName = "$cwd/$LogFileName" if ($LogFileName =~ m#^[^/]#);
print "\nPath for database server log:\n[$LogFileName] ";
$LogFileName = &input ($LogFileName);
$LogFileName = "$cwd/$LogFileName" if ($LogFileName =~ m#^[^/]#);
if (-e $LogFileName && !-f $LogFileName) {
  print "Sorry, `$LogFileName' is not a normal file.\n";
  print "Try again...\n";
  goto logfilename;
}
$config{'XLogFileNameX'} = $LogFileName;

#=============================#
# Save the new configuration. #
#=============================#

&save_config ($conf_file);

#==================================================#
# Configure and install the database server files. #
#==================================================#

&install ($DatabaseServerScript, $DatabaseServerPath, 0555,
  'database server');

# Hints to the installer.

print "\n\nTo start the database server, execute\n";
print " (csh) nice $DatabaseServerPath >>& $LogFileName &\n";
print "and allow a couple minutes for it to initialize.\n";

print "\nShall I start it for you right now? [$Y] ";
$_ = &input ($Y);
if ($_ !~ /^n/i) {
  print "\nStarting the server ...";
  if ($pid = fork) {
    print " done.\n";
    print "\nYou can monitor the server's progress by examining `$LogFileName'\n";
  } elsif (defined $pid) {
    open (STDOUT, ">> $LogFileName") || die "Unable to open $LogFileName";
    open (STDERR, ">> $LogFileName") || die "Unable to open $LogFileName";
    exec $DatabaseServerPath;
    exit;
  } else {
    die "Can't fork: $!\n";
  }
}

print "\nYou should probably add the startup command to /etc/rc or something.\n";
# end of XXConfigDbPathXX
