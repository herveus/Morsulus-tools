exit
if ($not_running_Perl);

#=========================================================#
# Print introductory messages to the config.db installer. #
#=========================================================#

print <<'EOF';

This Perl script configures and installs the database server
used for searching the SCA Armorial.

Before proceeding, you must have downloaded
 + the category file
and
 + the database.

You don't need the most up-to-date versions, but it is a good
idea to check occasionally to see if there are newer versions
available.  (Make sure the files are gunziped before proceeding.)
EOF

$opt = shift;
$Y = 'n';
if ($opt eq '-f') {
  $Y = 'y';
  $opt = shift;
}
$Rcs = 0;
if ($opt eq '-r') {
  $Rcs = 1;
}

# Here configdb slurps up $DatabaseServerScript.

$DatabaseServerScript = <<'XEOFX';
#!XPerlPathX

#  Database server code, installed at XDatabaseServerPathX on XXDataHostXX.

#  port number for this service
$port = XXDataPortXX;

#  version of config script
$version = 'XXVersionXX';
$db_version = 'unknown';
$show_copyright = 0;
$show_version = 0;

#  path to category and database files
$cat_file_name = 'XCatFileNameX';
$db_file_name = 'XDbFileNameX';
$log_file_name = '';

# default limit on result-list size
$limit = 500;

# max number of waiting connections 
$listen_queue_length = 5;

#  a few definitions:
#   desc -- "BORDURE:argent" and "FAN:2 or more" are _descs_
#   heading -- "BORDURE" and "FAN" are _headings_
#   feature -- "argent" and "3 or more" are _features_
#   set -- "number" and "tincture" are _sets_

$\ = "\n";     # print a newline after every print statment.
$; = ':';      # separator for lookup arguments
$" = '.';      # separator for octets of IP address
$, = '';       # separator for print items

#  result indicating a failed search
$failed = $test{''};

#  socket constants
$AF_INET = XAF_INETX;
$SOCK_STREAM = XSOCK_STREAMX;
$sockaddr = 'S n a4 x8';

$SEEK_SET = 0;

if ($log_file_name ne '') {
  open (LOG_FILE, ">>$log_file_name") || die "cannot open $log_file_name";
} else {
  open (LOG_FILE, '>&STDERR') || die "cannot open STDERR";
}
select (LOG_FILE); $| = 1; select (stdout);

&log (': started intializing - not ready yet');

#  Get a socket address for the appropriate port on this host.
($name, $aliases, $proto) = getprotobyname ('tcp');
$this = pack ($sockaddr, $AF_INET, $port, "\0\0\0\0");

#  Force flushes on the new socket.
select (NS); $| = 1; select (stdout);

#  Create a generic socket, bind to it, and start listening.
socket (S, $AF_INET, $SOCK_STREAM, $proto) || die "socket: $!";
if (!bind (S, $this)) {
  &log (': A data server process is already running.');
  &log (': Please kill the old process and wait two minutes before retrying.');
  die "bind: $!";
}
listen (S, $listen_queue_length) || die "connect: $!";

#  Force flushes on the generic socket.
select (S); $| = 1; select (stdout);

&read_cat_file ($cat_file_name);
&read_db_file ($db_file_name);

&log (': ready');

while (1) {
  #  Fork when data is received from the new socket.
  $addr = accept (NS, S); die "accept: $!" unless $addr;
  while (waitpid (-1, XWNOHANGX) > 0) {}
  $child = fork ();
  if ($child == 0) {
    #  The child process executes the following.
    open (DB_FILE, $db_file_name);

    #  Note the IP address of the client.
    ($af, $port, $inetaddr) = unpack ($sockaddr, $addr);
    @inetaddr = unpack ('C4', $inetaddr);

    #  Start with an empty result.
    %total = ();

    #  Read and execute search commands from the client.
    while (<NS>) {
      chop;  #  Strip off the newline.
      &log ("< $_");
    
      if (/^c$/) {
        $show_copyright = 1;

      } elsif (/^d(\d?) ([+&]?)(\d+) (.+)$/) {
        # compatible armory description search w/tolerance
        local ($tol, $op, $weight, @descs, $desc);

        $tol = 0+$1;
        $op = $2;
        $weight = $3;
        @descs = split (/\|/, $4);

        %match = ();
        foreach $desc (@descs) {
          &insert_matching_items ($desc, $tol);
        }
        &operation ($op, $weight);

      } elsif (/^e([1-5b])(i?) ([+&]?)(\d+) (.+)$/) {
        # pattern search on field or blazons, w/flags
        local ($ind, $flags, $op, $weight, $pat, $cond, $pos);

        $ind = $1;
        $flags = $2;
        $op = $3;
        $weight = $4;
        $pat = $5;
        $pat =~ s#[/]##g;

        if ($ind eq 'b') {
          $cond = sprintf ('$f4=~/%s/%s&&$f3=~/^[abdgs]d?$/i', $pat, $flags);
        } else {
          $cond = sprintf ('$f%s=~/%s/%s', $ind, $pat, $flags);
        }

        if ($op eq '+' || $op eq '&') {
          # promotion or intersection
          %match = ();
          eval sprintf (q@
          while (($pos, $tot) = each %%total) {
            ($f1,$f2,$f3,$f4,$f5) = split (/\|/, &get_item ($_));
            $match{$pos} = 1 if (%s);
          }@, $cond);
          &operation ($op, $weight);

        } else {
          # sum -- must scan the file
          seek (DB_FILE, 0, $SEEK_SET) || die "seek failed: $!";
          $pos = tell (DB_FILE);
          eval sprintf (q@
          while (<DB_FILE>) {
            chop;
            next if (/^NOTICE[:]$/ .. /^END OF NOTICE[.]$/);
            ($f1,$f2,$f3,$f4,$f5) = split (/\|/);
            $total{$pos} += %s if (%s);
            $pos = tell (DB_FILE);
          }@, $weight, $cond);
        }

      } elsif (/^en(i?) ([+&]?)(\d+) (.+)$/) {
        # pattern search on cooked names, w/flags
        local ($flags, $op, $weight, $pat, @pos);

        $flags = $1;
        $op = $2;
        $weight = $3;
        $pat = $4;
        $pat =~ s#[/]##g;

        %match = ();
        eval sprintf (q^
        while (($n,$items) = each %%itemsn) {
          if ($n =~ /%s/%s) {
            @pos = unpack ('L*', $items);
            foreach (@pos) {
              $match{$_} = 1;
            }
          }
        }^, $pat, $flags);
        &operation ($op, $weight);

      } elsif (/^l (\d+)$/) {
        # change the output limit
        $limit = $1 if ($limit > 0);

      } elsif (/^n ([+&]?)(\d+) (.+)$/) {
        # exact search on cooked names
        local ($op, $weight, $pat, @pos);
        $op = $1;
        $weight = $2;
        $pat = ascii($3);
 
        %match = ();
        @pos = unpack ('L*', $itemsn{$pat});
        foreach (@pos) {
          $match{$_} = 1;
        }
        &operation ($op, $weight);

      } elsif (/^s ([+&]?)(\d+) ([12][09]\d\d[0-1]\d) ([12][09]\d\d[0-1]\d) ([A-Za-z]+)$/) {
        # range search on dates
        local ($op, $weight, $d1, $d2, $kstring);

        $op = $1;
        $weight = $2;
        $date1 = $3;
        $date2 = $4;
        $kstring = $5;

        if ($op eq '+' || $op eq '&') {
          # promotion or intersection
          %match = ();
          while (($pos, $tot) = each %total) {
            ($f1,$f2,$f3,$f4,$f5) = split (/\|/, &get_item ($_));
            ($d1,$d2) = split (/\-/, $f2);
            $flag = 0;
            if ($d1 ne '') {
              $k1 = substr($d1, 6);
              if ($k1 eq '' || index($kstring, $k1) != $[-1) {
                $d1 = substr($d1, 0, 6);
                $d1 += 10000 if ($d1 < 196600);
                $flag = 1 if ($d1 >= $date1 && $d1 <= $date2);
              }
            }
            if ($d2 ne '' && $flag eq 0) {
              $k2 = substr($d2, 6);
              if ($k2 eq '' || index($kstring, $k2) != $[-1) {
                $d2 = substr($d2, 0, 6);
                $d2 += 10000 if ($d2 < 196600);
                $flag = 1 if ($d2 >= $date1 && $d2 <= $date2);
              }
            }
            $match{$pos} = 1 if ($flag);
          }
          &operation ($op, $weight);

        } else {
          # sum -- must scan the file
          seek (DB_FILE, 0, $SEEK_SET) || die "seek failed: $!";
          $pos = tell (DB_FILE);
          while (<DB_FILE>) {
            chop;
            next if (/^NOTICE[:]$/ .. /^END OF NOTICE[.]$/);
            ($f1,$f2,$f3,$f4,$f5) = split (/\|/);
            ($d1,$d2) = split (/\-/, $f2);
            $flag = 0;
            if ($d1 ne '') {
              $k1 = substr($d1, 6);
              if ($k1 eq '' || index($kstring, $k1) != $[-1) {
                $d1 = substr($d1, 0, 6);
                $d1 += 10000 if ($d1 < 196600);
                $flag = 1 if ($d1 >= $date1 && $d1 <= $date2);
              }
            }
            if ($d2 ne '' && $flag eq 0) {
              $k2 = substr($d2, 6);
              if ($k2 eq '' || index($kstring, $k2) != $[-1) {
                $d2 = substr($d2, 0, 6);
                $d2 += 10000 if ($d2 < 196600);
                $flag = 1 if ($d2 >= $date1 && $d2 <= $date2);
              }
            }
            $total{$pos} += $weight if ($flag);
            $pos = tell (DB_FILE);
          }
        }

      } elsif (/^t (\d+) (\d+)$/) {
        # threshold function
        $output = $1;
        $thresh = $2;
        while (($pos, $tot) = each %total) {
          if ($tot < $thresh) {
            delete $total{$pos};
          } elsif ($output > 0) {
            $total{$pos} = $output;
          }
        }

      } elsif (/^v$/) {
        $show_version = 1;

      } elsif (/^EOF/) {
        last;
      }
    }

    #  Make a list of the top matches.
    @tops = ();
    while (($key, $tot) = each %total) {
      for ($i = $#tops; $i >= $[; $i--) {
        ($itot, $ikey) = unpack ('N2', $tops[$i]);
        last if ($itot > $tot || ($itot == $tot && $ikey <= $key));
        $tops[$i+1] = $tops[$i];
      }
      $tops[$i+1] = pack ('N2', $tot, $key);
      while (@tops > $limit) {
        $lost{unpack ('N', pop (@tops))}++;
      }
    }
    
    #  Respond to the client.
    if ($#err >= $[) {
      foreach (@err) {
        print NS q^'ERROR:  ^, $_;
        #&log ("> 'ERROR:  $_");
      }
      print NS q^'^;
      #&log ("> '");
    }
    if (@tops > 50 || $show_copyright) {
      foreach (@copyright) {
        print NS q^'^, $_;
        #&log ("> '$_");
      }
    }
    foreach $rec (@tops) {
      ($total, $pos) = unpack ('N2', $rec);
      $_ = &get_item ($pos);
      print NS $total, '|', $_;
      #&log ("> $total|$_");
    }
    foreach (sort bynumber keys %lost) {
      print NS $_, '+', $lost{$_};
      #&log ("> $_+$lost{$_}");
    }
    if ($show_version) {
      # display version info
      $ver = 0+$];
      print NS "'Database server version ", $version;
      print NS "'Database version ", $db_version;
      print NS "'Perl version ", $ver;
      #&log ("> 'Database server version $version");
      #&log ("> 'Database version $db_version");
      #&log ("> 'Perl version $ver");
    }
    print NS '0';
    #&log ('> 0');

    #  Write requester's IP address to the log.
    #&log (". @inetaddr");

    close (NS);
    close DB_FIle;
    exit;
  } 
  close (NS);
}

sub bynumber { $b <=> $a }; # note: reverse order!

#  Database server function to write to log.
sub log {
  #global (*LOG_FILE);
  local (@time, $ts);
  local ($msg) = @_;

  #  Note the time.
  @time = localtime time;
  $ts = sprintf ('%02u%02u%02u %02u:%02u:%02u(%u)',
    $time[5], $time[4]+1, $time[3], $time[2], $time[1], $time[0], $$);
  print LOG_FILE $ts, $msg;
}

#  Database server function to do set operations.
sub operation {
  #global (%matches, %total);
  local ($pos, $tot, $mat);
  local ($op, $weight) = @_;

  if ($op eq '+') {
    # promotion
    while (($pos, $tot) = each %total) {
      if ($match{$pos}) {
        $total{$pos} += $weight * $match{$pos};
      } else {
        delete $total{$pos};
      }
    }

  } elsif ($op eq '&') {
    # intersection
    while (($pos, $tot) = each %total) {
      if ($match{$pos}) {
        $total{$pos} = $weight * $match{$pos};
      } else {
        delete $total{$pos};
      }
    }

  } else {
    # sum
    while (($pos, $mat) = each %match) {
      $total{$pos} += $weight * $mat;
    }
  }
}

#  Database server function to get an item given its offset.
sub get_item {
  local ($pos) = @_;
  seek (DB_FILE, $pos, $SEEK_SET) || die "seek: $!";
  $_ = <DB_FILE>;
  chop;
  return $_;
}

#  This script uses info from a category-file to recognize overlapping
#  categories.  For instance, it understands that an item indexed as
#  "FAN:3" matches the pattern "FAN:2 or more".

#  Database server function to read the cat file.
sub read_cat_file {
  local ($cat_file_name) = @_;
  local (%set_features);

#  Read the category-file, creating two tables, %set_name and %compatible.

#    %set_name is used to look up the name of the set to which a
#    particular feature belongs.
#      For instance, the feature "1" belongs to the
#      set named "number".
#      Hence $setname{"1"} yields "number".

#    %compatible is used to check the compatibility of a
#    pair of features which both belonging to the same set.

#      If the lookup yields a "=", then the features
#      are compatible -- they could potentially describe
#      the same charactistic.  
#        For instance, "4 or fewer" is compatible with
#        "3 or more", since both features describe the
#        numbers "3" and "4".
#        Hence $compatible{"4 or fewer:3 or more"} yields "=".

#      If the lookup yields a "<", then the features
#      are compatible AND the first feature is a subset
#      of the second feature; in other words, any
#      characteristic described by the first is also
#      described by the second (but not vice versa).
#        For instance, "4 or more" is a subset of
#        "3 or more", since any number described by
#        "4 or more" could also be described
#        by "3 or more".
#        Hence $compatible{"4 or more:3 or more"} yields "<".

#      If the lookup fails (and the features really
#      belong to the same set) then the features are 
#      are incompatible.
#        For instance, "4 or more" is incompatible with "3".
#        Hence $compatible{"4 or more:3"} fails.

  open (CAT_FILE, $cat_file_name) || die "cannot open $cat_file_name";
  while (<CAT_FILE>) {
    chop;  #  Strip off the newline.

    #  Process each line of the category-file.
    #  There are four types of lines in the file.

    if (/^\#/) {
      #  The line begins with a "#", so it is a comment.
      skip;

    } elsif (/^\|/) {
      local ($set_name, $feature_name);

      #  The line begins with a "|", so it defines a feature.
      #    Everything to the first ":" is the set-name.
      #    From there to the first "<" or "=" is the feature-name.
      /^([^:]+)[:]([^<=]+)(.*)$/ || die 'cannot parse feature definition';
      ($set_name, $feature_name, $_) = ($1, $2, $3);

      #  Record the set to which the feature belongs
      #  in the %set_name table.
      $set_name{$feature_name} = $set_name;
      $set_features{$set_name} .= ':' . $feature_name;
  
      #  Each "<" or "=" in the line begins a
      #  relationship to another feature.
      while ($_ ne '') {
        local ($relationship, $feature2);

        /^([<=])([^<=]+)(.*)$/ || die 'cannot parse feature relationship';
        ($relationship, $feature2, $_) = ($1, $2, $3);
  
        #  Record each relationship in the %compatible table.
        $compatible{$feature_name, $feature2} = $relationship;
      }
  
    } elsif (/ - see /) {
      #  The line contains " - see ", so it defines a cross-reference.
      skip;
  
    } else {
      #  None of the above cases apply, so the line defines a heading.
      #    Everything to the first "|" is the long-name of the heading.
      #    From there to the next "|" (or the end of line) is the
      #    name of the heading.
      skip;
    }
  } #  Now the entire category-file has been processed.
  close (CAT_FILE);

  #  Flesh out the %compatible table.

  #    The category-file only contains the bare minimum
  #    info on feature compatibility; the rest of the table
  #    is inferred from the data in the file.

  while (1) {
    local ($progress, @entries);

    $progress = 0;   #  Reset the progress indicator.

    @entries = keys (%compatible);
    foreach (@entries) {
      #  For each entry in the table ...

      #  Split the key into two features.
      #    (I assume that ":" is used to separate features.)
      local ($feature1, $feature2) = split ($;);
  
      #  If $feature1 is compatible with $feature2,
      #  then $feature2 is compatible with $feature1.
  
      if ($compatible{$feature2, $feature1} eq $failed) {
  
        #  That fact was missing from the table, so we made progress.
        $compatible{$feature2, $feature1} = '=';
        $progress = 1;
      }
  
      #  If $feature1 is a subset of $feature2
      #  and $feature2 is a subset of $feature3, 
      #  then $feature1 is a subset of $feature3.
  
      if ($compatible{$_} eq '<') {
        local ($feature3);
        local (@feature_names)
          = split (/[:]/, $set_features{$set_name{$feature1}});

        #  Try all features.
        foreach $feature3 (@feature_names) {
          if ($compatible{$feature2, $feature3} eq '<') {
            if ($compatible{$feature1, $feature3} ne '<') {
  
              #  That fact was missing from the table, so we made progress.
              $compatible{$feature1, $feature3} = '<';
              $progress = 1;
            }
          }
        }
      }
  
      #  If $feature1 is compatible with $feature2
      #  and $feature2 is a subset of $feature3, 
      #  then $feature1 is compatible with $feature3.
  
      elsif ($compatible{$_} eq '=') {
        foreach $feature3 (@feature_names) {
          if ($compatible{$feature2, $feature3} eq '<') {
            if ($compatible{$feature1, $feature3} eq $failed) {
  
              #  That fact was missing from the table, so we made progress.
              $compatible{$feature1, $feature3} = '=';
              $progress = 1;
            }
          }
        }
      }
    }
    last if $progress == 0;
  } #while ($progress > 0);
  #  Keep expanding the %compatible table until no more progress is made.
}
  
# Database server function to insert items which match a particular
# desc into %match.

sub insert_matching_items {
  #global (%match, @err);
  local ($_, $approx) = @_;
  local ($search_heading, @search_features) = split (/\:/);
  local ($pos, $i, @pos);

  $i = $items{$search_heading};
  if ($i eq '') {
    push (@err, $_.' is not a valid description!');
    return;
  }
  @pos = unpack ('L*', $i);

  if (@search_features == 0) {
    foreach $pos (@pos) {
      $match{$pos} = 1 if ($match{$pos} < 1);
    }

  } else {
    foreach $pos (@pos) {
      $_ = &get_item ($pos);

      #  Split the record into fields.
      #    Everything to the first "|" is the name.
      #    From there to the next "|" are the dates.
      #    From there to the next "|" is the type.
      #    From there to the next "|" is the text.
      #    From there to the next "|" are the notes.
      #    Each successive "|" begins a desc.
      ($name, $dates, $type, $text, $notes, @db_descs) = split (/\|/);

      foreach $db_desc (@db_descs) {
        local ($db_heading, @db_features) = split (/[:]/, $db_desc);

        if ($db_heading eq $search_heading) {
          #  The database heading and the search heading are the same,
          #  so the current pair of descs will match if all of their
          #  features are compatible.

          #  Test each database feature against each search feature.
          $slack = $approx; pair:
          foreach $db_feature (@db_features) {
            foreach $search_feature (@search_features) {
              if ($db_feature ne $search_feature
               && $set_name{$db_feature} eq $set_name{$search_feature}
               && $compatible{$db_feature, $search_feature} eq $failed) {
 
                #  We now have found:
                #    two distinct features ...
                #    belonging to the same set ...
                #    which are not marked compatible ...
                #  so the match of the current pair of descs is spoiled.
                $slack--;
                last pair if ($slack < 0);
              }
            }
          }
          if ($slack >= 0) {
            #  None of the features spoiled the match, so set the
            #  match indicator for this record.
            $match{$pos} = 1 + $slack if ($match{$pos} < 1 + $slack);
          }
        }
      } #  Now all the descs for the current record have been tried.
    } #  Now each candidate record has been tried.
  }
} # end sub insert_matching_items

# Database server function to read the database file and
# create lookup tables for headings and cooked names.

sub read_db_file {
  #global ($db_version, *DB_FILE, @copyright, %items, %itemsn);
  local ($db_file_name) = @_;
  local ($pos, $_, $name, $date, $type, $text, $notes, @db_descs);
  local ($listing, $heading, @features);

  #  Read the database, creating a list of items for each heading.

  open (DB_FILE, $db_file_name) || die "cannot open $db_file_name";
  $pos = pack ('L', tell (DB_FILE));
  while (<DB_FILE>) {
    #  Process each record of the database.

    chop;  #  Strip off the record separator.

    if (/^NOTICE[:]$/ .. /^END OF NOTICE[.]$/) {
      #  copyright notice
      push (@copyright, $_);
      next;
    }

    #  Split the record into fields.
    #    Everything to the first "|" is the name.
    #    From there to the next "|" are the dates.
    #    From there to the next "|" is the type.
    #    From there to the next "|" is the text.
    #    From there to the next "|" or EOL are the notes.
    #    Each successive "|" or EOL begins a desc.
    ($name, $dates, $type, $text, $notes, @db_descs) = split (/\|/);

    if ($type eq 'C') {
      $db_version = $1
        if ($text =~ /^Last update:\s+(.+)\s+by Morsulus$/)
    } else {
      $itemsn{&ascii ($name)} .= $pos;
    }

    if ($type eq 'NC' || $type eq 'R' || $type eq 'BNC') {
      $text =~ s/^See (also )?//;
      $text = $1 if ($text =~ /^\"(.*)\"$/);
      @targs = split (/\" or \"/, $text);
      foreach (@targs) {
        $itemsn{&ascii ($_)} .= $pos;
      }
    } elsif ($type eq 'AN') {
      $text =~ s/^For //;
      $itemsn{&ascii ($text)} .= $pos;
    } elsif ($type =~ /^T|t|HN|O|j|v$/) {
      $text = $1 if ($text =~ /^\"(.*)\"$/);
      @targs = split (/\" and \"/, $text);
      foreach (@targs) {
        $itemsn{&ascii ($_)} .= $pos;
      }
    } elsif ($type =~ /^ANC|HNC|BNc|Nc|OC|u|Bvc|vc$/) {
      $itemsn{&ascii ($text)} .= $pos;
    }

    if ($notes =~ /^\((.*)\)$/) {
      foreach (split (/\)\(/, $1)) {
        if (/^Also the arms of (.+)$/) {
          $listing = &permute ($1);
          $itemsn{&ascii ($listing)} .= $pos;
        } elsif (/^JB: (.+)$/) {
          $itemsn{&ascii ($1)} .= $pos;
        } elsif (/^same (person|branch) as (.+)$/) {
          $listing = &permute ($2);
          $itemsn{&ascii ($listing)} .= $pos;
        } elsif (/^\-?transferred to (the )?(.+)$/) {
          $listing = &permute ($2);
          $itemsn{&ascii ($listing)} .= $pos;
        } elsif (/^For (.+)$/) {
          $listing = &permute ($1);
          $itemsn{&ascii ($listing)} .= $pos;
        }
      }
    } 

    foreach (@db_descs) {
      ($heading, @features) = split (/\:/);
      # TODO remove dups
      $items{$heading} .= $pos;
    }
    
    $pos = pack ('L', tell (DB_FILE));
  }
  close DB_FILE;
  # don't close DB_FILE; we'll use it again later
}

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

# Database server function to convert Latin-1 strings to ASCII.
sub ascii {
  local ($_) = $_[0];
  tr/\300\301\302\303\304\305\307\310\311\312\313\314\315\316\317\321\322\323\324\325\326\330\331\332\333\334\335\340\341\342\343\344\345\347\350\351\352\353\354\355\356\357\361\362\363\364\365\366\370\371\372\373\374\375\377/AAAAAACEEEEIIIINOOOOOOUUUUYaaaaaaceeeeiiiinoooooouuuuyy/;
  s/\306/AE/g;
  s/\320/Dh/g;
  s/\336/Th/g;
  s/\337/sz/g;
  s/\346/ae/g;
  s/\360/dh/g;
  s/\376/th/g;
  return $_;
}
#end of XDatabaseServerPathX version XXVersionXX
XEOFX

#=================================================#
# configdb has slurped $DatabaseServerScript      #
# into memory.                                    #
#=================================================#

# The common config functions are inserted into
# XXConfigDbPathXX after this line.
