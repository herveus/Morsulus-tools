#!/usr/bin/perl

#%  Add permuted order-names to an ordinary database.

$\ = "\n";
$, = '|';
$[ = 1;

#  Process each input file.
while (<>) {
  chop;           # Strip the newline.

  #  Split the line into fields.
  ($name, @rest) = split (/\|/, $_, 5);

  print $name, @rest unless $rest[2] eq 'O*';

  if ($rest[2] eq 'O') {
    #  Reorder the elements of the order-name to eliminate commas.
    $realname = $name;
    @ff = split (/\,\ /, $realname);
    $realname = $ff[2] . &sp($ff[2]) . $ff[1] if $#ff == 2;

    #  Treat contracted French particles as separate words.
    $realname =~ s/([DLdl]['])([AEHIOU])/$1 $2/g;

    #  Split the order-name into words.
    @w = split (/\ /, $realname);

    @rest[2] = 'O*';
    for $i (1 .. $#w) {
      #  Form each permuation of the name.
      $out = $w[$i];
      for $j (1+$i .. $#w) {
        $out .= &sp($out) . $w[$j];
      }
      $out .= ',' if $i > 1;
      for $j (1 .. $i-1) {
        $out .= &sp($out) . $w[$j];
      }

      print $out, @rest
         unless ($out eq $name
      || $out =~ /^(and|award|barony|d[eu]|des|for|guild|honou?r of the)\b/i
      || $out =~ /^(l[ae]|of|ord[eo]|orde[nr]|ordre|the|van)\b/i
      || $out =~ /^[dl][']/i);
    }
  }
}

sub sp {
  if (@_[1] =~ /[dl][']$/i) {
    return ''
  } else {
    return ' ';
  }
}
