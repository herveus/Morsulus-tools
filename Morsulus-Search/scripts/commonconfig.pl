
# Common config function to advise user on machine questions.

sub machine_questions {
  my ($pptag, $afitag, $sstag) = @_;

  print <<'EOF';


Now I need you to answer a few questions about this machine.

For each question:
 +  The default answer is given in [brackets].
 +  To override the default answer, enter the
      correct answer in the space next to the brackets.
 +  To accept the default answer, enter a blank line.


EOF

  # Set $PerlPath.
  my $PerlPath = set_perl_path ($pptag);

  # Set $AF_INET and $SOCK_STREAM.
  &set_network_constants ($afitag, $sstag);
  return ($PerlPath);
}

# Common config function to read input from terminal unless $Y is set to 'y'.

sub input {
  #global ($Y);
  my ($default) = @_;
  my $input = '';
  if ($Y eq 'y') {
    printf "\n";
  } else {
    $input = <>;
  }
  $input =~ s/\s//g;
  $input = $default if ($input eq '');
  return $input;
}

# Common config function to get AF_INET and SOCK_STREAM. 

sub set_network_constants {
  #global ($AF_INET, $SOCK_STREAM, %config);
  local ($tag_AF_INET, $tag_SOCK_STREAM) = @_;

  $AF_INET = $config{$tag_AF_INET};
  $AF_INET = 2 if ($AF_INET eq '');
  print <<'EOF';

What is the numeric code (AF_INET) defined
for the Internet domain in `/usr/include/sys/socket.h'?

EOF
  print "[$AF_INET] ";
  $AF_INET = &input ($AF_INET);
  $config{$tag_AF_INET} = $AF_INET;

  $SOCK_STREAM = $config{$tag_SOCK_STREAM};
  $SOCK_STREAM = 1 if ($SOCK_STREAM eq '');
  print <<'EOF';

What is the numeric code (SOCK_STREAM) defined
for the `stream' socket type in `/usr/include/sys/socket.h'?

EOF
  print "[$SOCK_STREAM] ";
  $SOCK_STREAM = &input ($SOCK_STREAM);
  $config{$tag_SOCK_STREAM} = $SOCK_STREAM;
}

# Common config function to read the configuration from $conf_file.

sub read_config_file {
  #global (%config, $conf_file);
    my ($conf_file) = @_;
    my %config;
    return unless -r $conf_file;
    print "\nReading previous configuration from $conf_file ...";
    open my $CONF, '<', $conf_file or die "Can't open config file $conf_file: $?";
    while (<$CONF>)
    {
        next if /^#/;
        chomp;
        my ($tag, $value) = split(/\|/);
        $config{$tag} = $value;
    }
    print " done.\n";
    return %config;
}

# Common config function to save the configuration to $conf_file.

sub save_config {
    my ($conf_file) = @_;
    open my $CONF, '>', $conf_file;
    print "\nSaving new configuration to $conf_file ...";
    
    for my $tag (sort keys %config)
    {
        next if $tag eq 'CONF_FILE';
        my $value = $config{$tag};
        print $CONF "$tag|$value\n";
    }
    print " done.\n";
}

# Common config function to configure a text string.

sub configure {
  #global (%config);
  local ($tag, $value);
  local ($_) = @_;

  print "\nConfiguring $what.\n";

  while (($tag, $value) = each %config) {
    s/$tag/$value/g;
  }
  return $_;
}


# Common config function to install a text string in a file,
# taking the path from %config.

sub key_install {
  #global (%config);
  local ($text, $tag, $mode, $what) = @_;

  &install ($text, $config{'XX'.$tag.'PathXX'}, $mode, $what);
}

# Common config function to install a text string in a file.

sub install {
  #global ($Y);
  local ($text, $path, $mode, $what) = @_;

  $text = &configure ($text);

  printf "Installing $what at\n `$path'\n with mode 0%03o.\n", $mode;
  if (-e $path) {
    if (-w $path) {
      print "Is it okay to overwrite existing file\n `$path'? [$Y] ";
      $_ = &input ($Y);
      die "\nUnable to complete installation" unless (/^y/i);
    } elsif ($Rcs) {
      print "Checking out `$path'.\n";
      system ('co', '-l', $path);
      die if ($?);
    } else {
      print "Is it okay to delete existing file\n `$path' first? [$Y] ";
      $_ = &input ($Y);
      die "\nUnable to complete installation" unless (/^y/i);
      unlink ($path) || die "Cannot delete `$path'";
    }
  }
  &makeparent ($path, 0755);

  # Create (or overwrite) the file.
  open (OUT, ">$path") || die "Cannot open `$path' in sub install";
  print OUT $text;
  close (OUT) || die "Cannot close `$path'";

  # Set the permissions.
  chmod $mode, $path || die "Cannot chmod `$path'";
  if ($Rcs) {
    print "Checking `$path' back in.\n";
    system ('ci', '-u', $path);
    die if ($?);
  }
}

# Common config function to create directories needed for install.

sub makeparent {
  local ($path, $mode) = @_;
  local ($parent);

  $path =~ m#^(.*)[/][^/]+[/]?$#;
  $parent = $1;
  return if ($parent eq '');
  if (!-e $parent) {
    &makeparent ($parent, $mode);
    print "Creating `$parent'\n";
    mkdir ($parent, $mode) || die "Cannot mkdir `$parent'";
  }
  die "$parent is not a directory" unless (-d $parent);
  die "$parent is not writeable" unless (-w $parent);
}

# Common config function to set a path for installing a normal file.

sub get_filepath {
  #global ($cwd, %config);
  local ($tag, $what, $default, $root) = @_;
  local ($path);
  while ($path eq '') {
    $path = $config{$tag};
    $path = $default if ($path eq '');
    $path = "$cwd/$path" if ($path =~ m#^[^/]#);
    print "\nLocal install-path of $what:\n[$path] ";
    $path = &input ($path);
    $path = "$cwd/$path" if ($path =~ m#^[^/]#);
    if (-e $path && !-f $path) {
      print "Sorry, `$path' exists and is not a normal file.\n";
      print "Try again...\n";
      $path = '';
    }
    if (index ($path, $root) != $[) {
      print "Sorry, `$path' must be under `$root'.\n";
      print "Try again...\n";
      $path = '';
    }
  }
  $config{$tag} = $path;
  return $path;
}

# Common config function to set a path for an installation directory.

sub get_dirpath {
  #global ($cwd, %config);
  local ($tag, $what, $default, $root) = @_;
  local ($path);
  while ($path eq '') {
    $path = $config{$tag};
    $path = $default if ($path eq '');
    $path = "$cwd/$path" if ($path =~ m#^[^/]#);
    print "\nLocal directory for $what:\n[$path] ";
    $path = &input ($path);
    $path = "$cwd/$path" if ($path =~ m#^[^/]#);
    if (-e $path && !-d $path) {
      print "Sorry, `$path' exists and is not a directory.\n";
      print "Try again...\n";
      $path = '';
    }
    if (index ($path, $root) != $[) {
      print "Sorry, `$path' must be under `$root'.\n";
      print "Try again...\n";
      $path = '';
    }
  }
  $config{$tag} = $path;
  return $path;
}

# Common config function to set $PerlPath.

sub set_perl_path {
  #global (%config, $PerlPath, $cwd);
  my $PerlPath;

  my $default = $^X;
  if ($default =~ m#^[^/]#) {
    my @apath = split (/:/, $ENV{'PATH'}, 9999);
    my $tmp = $default;
    foreach (reverse @apath) {
      $default = "$_/$tmp" if (m#^[/]# && -x "$_/$tmp");
    }
  }
  my $done = 'no';

  while ($done eq 'no') {
    $PerlPath = $config{$tag};
    $PerlPath = $default if ($PerlPath eq '');
    $PerlPath = "$cwd/$PerlPath" if ($PerlPath =~ m#^[^/]#);
    print <<'EOF';
What is the full pathname of the `Perl' executable on this machine?

EOF
    print "[$PerlPath] ";
    $PerlPath = input ($PerlPath);
    $PerlPath = "$cwd/$PerlPath" if ($PerlPath =~ m#^[^/]#);
    if (!-e $PerlPath) {
      print "Sorry, `$PerlPath' does not exist.\n";
    } elsif (!-f $PerlPath) {
      print "Sorry, `$PerlPath' is not a normal file.\n";
    } elsif (!-x $PerlPath) {
      print "Sorry, `$PerlPath' is not executable.\n";
    } else {
      $done = 'yes';
    }
    print "Try again...\n" if ($done eq 'no');
  }
  return $PerlPath;
}
  
# end of common config functions
1;
