#!/usr/bin/perl

$\ = "\n";     # print a newline after every print statment.
$[ = 1;        # index of first element in a list
$, = "\n";

while (<>) {
  chop;  #  Strip off the newline.

  #  Process each line of the category-file.
  #  There are four types of lines in the file.

  if (/^[#]/) {
    #  The line begins with a "#", so it is a comment.
    print $_;

  } elsif (/^[|]/) {
    #  The line begins with a "|", so it defines a feature.
    push (@features, $_);

  } elsif (/^(.*) - see (.*)$/) {
    #  The line contains " - see ", so it defines a cross-reference.
    push (@crefs, $_);

  } else {
    #  None of the above cases apply, so the line defines a heading.
    ($long, $rest) = split (/\|/);
    die if ($defs{$long} ne '');
    $defs{$long} = $_;
  }
}

print sort @features;
foreach (sort keys %defs) {
  print $defs{$_};
}
print sort @crefs;
