#!/usr/bin/perl

#%  expand a shorthand category list into tdesc.cat

$, = ', ';
$\ = "\n";
$[ = 1;

%map = (
'three_groups',
  'sole primary/group primary/secondary',
'four_postures',
  'couchant/passant/rampant/sejant',
'five_orientations',
  'decrescent/increscent/pendant/tilted/upright',
'eight_first_tinctures',
  'argent/azure/fur/gules/multicolor/or/purpure/sable',
'nine_tinctures',
  'argent/azure/fur/gules/multicolor/or/purpure/sable/vert',
'ten_tinctures',
  'argent/azure/fur/gules/multicolor/or/proper/purpure/sable/vert',
'surrounding 0/1/1+/2/3 or more',
  'not surrounding/surrounding 1 only/surrounding 1 plus/surrounding 2/surrounding 3 or more',

'37_tincture_pairs',
  '~ argent, ~and azure/~ argent, ~and fur/~ argent, ~and gules/~ argent, ~and multicolor/~ argent, ~and or/~ argent, ~and purpure/~ argent, ~and sable/~ argent, ~and vert/~ azure, ~and fur/~ azure, ~and gules/~ azure, ~and multicolor/~ azure, ~and or/~ azure, ~and purpure/~ azure, ~and sable/~ azure, ~and vert/~ fur, ~and fur/~ fur, ~and gules/~ fur, ~and multicolor/~ fur, ~and or/~ fur, ~and purpure/~ fur, ~and sable/~ fur, ~and vert/~ gules, ~and multicolor/~ gules, ~and or/~ gules, ~and purpure/~ gules, ~and sable/~ gules, ~and vert/~ multicolor, ~and or/~ multicolor, ~and purpure/~ multicolor, ~and sable/~ multicolor, ~and vert/~ or, ~and purpure/~ or, ~and sable/~ or, ~and vert/~ purpure, ~and sable/~ purpure, ~and vert/~ sable, ~and vert',

'38_tincture_pairs',
  'argent, ~and azure/argent, ~and fur/argent, ~and gules/argent, ~and multicolor/argent, ~and or/argent, ~and purpure/argent, ~and sable/argent, ~and vert/azure, ~and fur/azure, ~and gules/azure, ~and multicolor/azure, ~and or/azure, ~and purpure/azure, ~and sable/azure, ~and vert/fur, ~and fur/fur, ~and gules/fur, ~and multicolor/fur, ~and or/fur, ~and purpure/fur, ~and sable/fur, ~and vert/gules, ~and multicolor/gules, ~and or/gules, ~and purpure/gules, ~and sable/gules, ~and vert/multicolor, ~and multicolor/multicolor, ~and or/multicolor, ~and purpure/multicolor, ~and sable/multicolor, ~and vert/or, ~and purpure/or, ~and sable/or, ~and vert/purpure, ~and sable/purpure, ~and vert/sable, ~and vert',

'51_tincture_pairs',
  'argent, ~and azure/argent, ~and fur/argent, ~and gules/argent, ~and multicolor/argent, ~and or/argent, ~and purpure/argent, ~and sable/argent, ~and vert/azure, ~and argent/azure, ~and fur/azure, ~and gules/azure, ~and multicolor/azure, ~and or/azure, ~and purpure/azure, ~and sable/azure, ~and vert/fur/gules, ~and argent/gules, ~and azure/gules, ~and fur/gules, ~and multicolor/gules, ~and or/gules, ~and purpure/gules, ~and sable/gules, ~and vert/multicolor/or, ~and argent/or, ~and azure/or, ~and fur/or, ~and gules/or, ~and multicolor/or, ~and purpure/or, ~and sable/or, ~and vert/purpure/sable, ~and argent/sable, ~and azure/sable, ~and fur/sable, ~and gules/sable, ~and multicolor/sable, ~and or/sable, ~and purpure/sable, ~and vert/vert, ~and argent/vert, ~and azure/vert, ~and fur/vert, ~and gules/vert, ~and multicolor/vert, ~and or/vert, ~and purpure/vert, ~and sable',

'58_tincture_pairs',
  'argent, ~and azure/argent, ~and fur/argent, ~and gules/argent, ~and multicolor/argent, ~and or/argent, ~and purpure/argent, ~and sable/argent, ~and vert/azure, ~and argent/azure, ~and fur/azure, ~and gules/azure, ~and multicolor/azure, ~and or/azure, ~and purpure/azure, ~and sable/azure, ~and vert/fur/gules, ~and argent/gules, ~and azure/gules, ~and fur/gules, ~and multicolor/gules, ~and or/gules, ~and purpure/gules, ~and sable/gules, ~and vert/multicolor/or, ~and argent/or, ~and azure/or, ~and fur/or, ~and gules/or, ~and multicolor/or, ~and purpure/or, ~and sable/or, ~and vert/purpure, ~and argent/purpure, ~and azure/purpure, ~and fur/purpure, ~and gules/purpure, ~and multicolor/purpure, ~and or/purpure, ~and sable/purpure, ~and vert/sable, ~and argent/sable, ~and azure/sable, ~and fur/sable, ~and gules/sable, ~and multicolor/sable, ~and or/sable, ~and purpure/sable, ~and vert/vert, ~and argent/vert, ~and azure/vert, ~and fur/vert, ~and gules/vert, ~and multicolor/vert, ~and or/vert, ~and purpure/vert, ~and sable'
);

while (<>) {
  chop;
  @a = split (/, /);

  for ($i = 1; $i <= $#a; $i++) {
    $b = $map{$a[$i]};
    $a[$i] = $b if ($b ne '');
  }

  $i = $#a;
  while ($a[$i] =~ /\//) { $i--; }

  if ($i == $#a) {
    print @a;
  } elsif ($i == $#a - 1) {
    @b = split (/\//, $a[$#a]);
    foreach $b (@b) {
      $a[$#a] = $b;
      print @a;
    }
  } elsif ($i == $#a - 2) {
    @b = split (/\//, $a[$#a-1]);
    @c = split (/\//, $a[$#a]);
    foreach $b (@b) {
      $a[$#a-1] = $b;
      for $c (@c) {
        $a[$#a] = $c;
        print @a;
      }
    }
  }
}
