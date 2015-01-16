#!/usr/bin/perl

use File::Slurp;

my %textblobs = (
    Helpers => 'commonconfig.pl',
    SearchMenu => 'index.html',
    NameHintsPage => 'hints_name.html',
    DateHintsPage => 'hints_date.html',
    DescHintsPage => 'hints_desc.html',
    NpHintsPage => 'hints_np.html',
    BpHintsPage => 'hints_bp.html',
    ComplexHintsPage => 'hints_complex.html',
    OverviewPage => 'heraldry_overview.html',
    LimitPage => 'search_limits.html',
    DownloadPage => 'data_obtain.html',
    DbFormatPage => 'data_format.html',
    DbSymbolsPage => 'data_symbols.html',
    IndexPage => 'ord_index.html',
    # IndexPage<letter> => 'ordinary/<letter>.html' for letter in A..Z
    IndexPageA => 'ordinary/A.html',
    IndexPageB => 'ordinary/B.html',
    IndexPageC => 'ordinary/C.html',
    IndexPageD => 'ordinary/D.html',
    IndexPageE => 'ordinary/E.html',
    IndexPageF => 'ordinary/F.html',
    IndexPageG => 'ordinary/G.html',
    IndexPageH => 'ordinary/H.html',
    IndexPageI => 'ordinary/I.html',
    IndexPageJ => 'ordinary/J.html',
    IndexPageK => 'ordinary/K.html',
    IndexPageL => 'ordinary/L.html',
    IndexPageM => 'ordinary/M.html',
    IndexPageN => 'ordinary/N.html',
    IndexPageO => 'ordinary/O.html',
    IndexPageP => 'ordinary/P.html',
    IndexPageQ => 'ordinary/Q.html',
    IndexPageR => 'ordinary/R.html',
    IndexPageS => 'ordinary/S.html',
    IndexPageT => 'ordinary/T.html',
    IndexPageU => 'ordinary/U.html',
    IndexPageV => 'ordinary/V.html',
    IndexPageW => 'ordinary/W.html',
    IndexPageX => 'ordinary/X.html',
    IndexPageY => 'ordinary/Y.html',
    IndexPageZ => 'ordinary/Z.html',
    GlossaryScript => 'glossary.cgi',
    CopyrightScript => 'data_copyright.cgi',
    VersionScript => 'version.cgi',
    NameSearchScript => 'oanda_name.cgi',
    DescSearchScript => 'oanda_desc.cgi',
    NpSearchScript => 'oanda_np.cgi',
    BpSearchScript => 'oanda_bp.cgi',
    DateSearchScript => 'oanda_date.cgi',
    ComplexSearchScript => 'oanda_complex.cgi',
    CorrectionScript => 'correction.cgi',
    CommonClientCode => 'commonclient.pl',
    ConfigDbScript => 'configdb.pl',
    ConfigDbScriptB => 'configdb.b.pl',
    );
    
my @textnames = qw/
    Helpers
    SearchMenu
    NameHintsPage
    DateHintsPage
    DescHintsPage
    NpHintsPage
    BpHintsPage
    ComplexHintsPage
    OverviewPage
    LimitPage
    DownloadPage
    DbFormatPage
    DbSymbolsPage
    IndexPage
    IndexPageA
    IndexPageB
    IndexPageC
    IndexPageD
    IndexPageE
    IndexPageF
    IndexPageG
    IndexPageH
    IndexPageI
    IndexPageJ
    IndexPageK
    IndexPageL
    IndexPageM
    IndexPageN
    IndexPageO
    IndexPageP
    IndexPageQ
    IndexPageR
    IndexPageS
    IndexPageT
    IndexPageU
    IndexPageV
    IndexPageW
    IndexPageX
    IndexPageY
    IndexPageZ
    GlossaryScript
    CopyrightScript
    VersionScript
    NameSearchScript
    DescSearchScript
    NpSearchScript
    BpSearchScript
    DateSearchScript
    ComplexSearchScript
    CorrectionScript
    CommonClientCode
    ConfigDbScript
    ConfigDbScriptB
    /;

#  path to category and print files
$cat_file_name = 'scripts/temp.cat';
$print_file_name = 'scripts/tprint.cat';

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
XXXEOFXXX

# read tprint.cat
open (PRINT_FILE, "$print_file_name") || die "cannot open $print_file_name";

open my $fh, '>', 'scripts/ordinary/A.html';
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
        open $fh, '>', "scripts/ordinary/$this.html";
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
    open $fh, '>', "scripts/ordinary/$this.html";
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

my $textblob = read_file('scripts/config.web.head');
for my $textname (@textnames)
{
    $textblob .= "\$$textname = <<'XXEOFXX';\n";
    $textblob .= read_file(join('/', 'scripts', $textblobs{$textname}));
    $textblob .= "\nXXEOFXX\n\n";
}
$textblob .= read_file('scripts/config.web.tail');

write_file('config.web', $textblob);

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