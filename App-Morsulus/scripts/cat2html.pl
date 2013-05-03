#!/usr/bin/perl

#  path to category and print files
$cat_file_name = '/Users/herveus/aux/temp.cat';
$print_file_name = '/Users/herveus/aux/tprint.cat';

$\ = "\n";     # print a newline after every print statment.
$[ = 1;        # index of first element in a list
$" = ':';     # list separator for interpolation

read_cat_file ($cat_file_name);

$head = <<'XXXEOFXXX';
#
# config.web slurps up index page for the letter %s.
#

$IndexPage{'%s'} = <<'XXEOFXX';
<html>
<head><title>Index of the SCA Ordinary - The Letter %s</title>
<base href="XXIndexDirUrlXX/%s.html">XXHeadXX
</head><body>
<h2>Index of the SCA Ordinary - The Letter %s</h2>

<ul>
XXXEOFXXX

$tail = <<'XXXEOFXXX';
</ul>

XXTrailerXX
XXTrailer2XX
XXCloseHtmlXX
XXEOFXX
XXXEOFXXX

# read tprint.cat
open (PRINT_FILE, "$print_file_name") || die "cannot open $print_file_name";

open my $fh, '>', 'A.html';
my $letter = '';

while (<PRINT_FILE>) {
  chomp;
  
  @fields = split (', ');
  @cur = ();
  foreach (@fields) {
    push (@cur, $_);
    $t = join (', ', @cur);
    if ($target{$t}) {
      $urlt = $t;
      $urlt =~ s/[^A-Za-z0-9]//g;
      $this = substr ($urlt, 1, 1);
      $this =~ tr/[a-z]/[A-Z]/;
      if ($this ne $last) {
        print  $fh $tail unless ($last eq '');
        close $fh;
        open $fh, '>', "$this.html";
        printf $fh $head, $this, $this, $this, $this, $this;
        $last = $this;
      }
      print $fh qq'<a name="$urlt">';
      $target{$t} = 0;
    }
  }

  $heading = $_;
  @heading = split (/, /);
  @features = ();
  while ($short{$heading} eq '' && $heading ne '') {
    push (@features, pop (@heading));
    $heading = join (', ', @heading);
  }
  $desc = join (':', $short{$heading}, @features);
  $urldesc = encode ($desc);

  $cat = publish ($_);

  $this = substr ($_, 1, 1);
  $this =~ tr/[a-z]/[A-Z]/;
  if ($this ne $last) {
    print $fh $tail unless ($last eq '');
    close $fh;
    open $fh, '>', "$this.html";
    printf $fh $head, $this, $this, $this, $this, $this;
    $last = $this;
  }
  $cr = $cross_ref{$_};
  if ($heading ne '' && ($cr eq '' || $cr =~ /^also /)) {
    print $fh qq'<li><a href="XXDescSearchUrlXX?p=$urldesc">$cat</a>';
  } else {
    print $fh qq'<li>$cat';
  }

  if ($cr ne '') {
    $cr =~ /^(also )?/;
    $also = $1;
    $cr =~ s/^(also )//;
    @cr = split (/ and /, $cr); 
    grep ($_ = cref ($_), @cr);
    print $fh ' - see ', $also, join (' and ', @cr);
  } else {
    die if ($heading eq '');
  }
}
print $fh $tail unless ($last eq '');

sub read_cat_file {
  local ($cat_file_name) = @_;
  local (%set_features);

  open (CAT_FILE, $cat_file_name) || die "cannot open $cat_file_name";
  while (<CAT_FILE>) {
    chomp;  #  Strip off the newline.

    #  Process each line of the category-file.
    #  There are four types of lines in the file.

    if (/^[#]/) {
      #  The line begins with a "#", so it is a comment.
      skip;

    } elsif (/^[|]/) {
      #  The line begins with a "|", so it defines a feature.
  
    } elsif (/^(.*) - see (.*)$/) {
      #  The line contains " - see ", so it defines a cross-reference.
      $cross_ref{$1} = $2;
      $_ = $2;
      s/^also //; 
      @targets = split (/ and /);
      foreach (@targets) {
        $target{$_} = 1;
      }
  
    } else {
      #  None of the above cases apply, so the line defines a heading.
      #    Everything to the first "|" is the long-name of the heading.
      #    From there to the next "|" (or the end of line) is the
      #    name of the heading.
      ($long, $head, @rest) = split (/\|/);
      $short{$long} = $head;
    }
  } #  Now the entire category-file has been processed.
  close (CAT_FILE);
}

sub encode {
  # Encode non-alphanumeric characters when generating a URL.
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

sub publish {
  @f = split (/, /, @_[1]); 
  grep (substr($_,1,1) =~ tr/[a-z]/[A-Z]/, @f);
  $cat = join (', ', @f);
  $cat =~ s/,/ -/g;
  $cat =~ s/~//g;
  $cat =~ s/  / /g;
  $cat =~ s/-  /- /g;
  return $cat;
}

sub cref {
  local ($name) = @_[1];
  $letter = substr ($name, 1, 1);
  $letter =~ tr/a-z/A-Z/;
  $name =~ s/[^A-Za-z0-9]//g;
  return sprintf ('<a href="%s.html#%s">%s</a>',
    $letter, $name, publish ($_));
}
