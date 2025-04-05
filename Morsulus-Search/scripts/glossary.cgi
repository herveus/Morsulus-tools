#!XXPerlPathXX

# This is a CGI script to do a lookup on the glossary of heraldic terms.
# It is to be installed at XXGlossaryPathXX on XXServerNameXX.

# Set URL for this script.
$cgi_url = 'XXGlossaryUrlXX';

# Set title for form.
$form_title = 'Heraldic Glossary';

require 'XXCommonClientPathXX';

# Process arguments.
foreach $pair (split (/\&/, $ENV{'QUERY_STRING'})) {
  ($left, $right) = split (/[=]/, $pair, 2);
  $left = &decode ($left);
  $right = &decode ($right);

  $p = $right if ($left eq 'p');
}

%definition = (
'Or', '#adj. (usually capitalized) in yellow or gold.',
'abased', '#adj. moved downward from its usual position (a chevron abased).',
'addorsed', '#adj. (of charges or wings) arranged back-to-back.',
'affronty', '#adj. (of creatures) seen from the front.',
'alaunt', '#n. a type of dog.',
'annulet', '#n. a circular ring.',
'antelope', '#n. a monster with the body of a stag, the tail of a unicorn, and a tusked nose. #n. (natural antelope) a straight-horned deer.',
'appaumy', '#adj. (of a hand) with the palm toward the viewer.',
'argent', '#adj. in white or silver.',
'armed', '#adj. having means of defense (beak, claws, horns, teeth, etc.) especially if they are in a contrasting tincture.',
'arrondi', '#adj. spiraling around the center (gyronny arrondi).',
'azure', '#adj. in blue.',
'barbed', '#adj. (of an arrow) having barbs of a contrasting tincture.',
'barrulet', '#n. a very narrow horizontal stripe across the middle.',
'barry', '#adj. divided into an even number of horizontal stripes of different tinctures.',
'bar', '#n. a narrow horizontal stripe across the middle.',
'bascinet', '#n. a close-fitting helmet.',
'base', '#n. a horizontal stripe covering the bottom point of the shield (a base azure).  #n. the bottom portion of the shield (to base, in base).',
'baton sinister', '#n. a narrow diagonal stripe connecting the viewer\'s upper right and lower left.',
'battle axe', '#n. a spiked axe with a single outward-curving blade.',
'beaked', '#adj. having a beak in a contrasting tincture.',
'bellied', '#adj. having the belly in a contrasting tincture.',
'bendlet', '#n. a narrow diagonal stripe connecting the viewer\'s upper left and lower right.',
'bendwise sinister', '#adj. (of a charge) oriented so that the long axis lies diagonally, facing the viewer\'s upper right.',
'bendwise', '#adj. (of a charge) oriented so that the long axis lies diagonally, facing the viewer\'s upper left.',
'bendy', '#adj. divided into an even number of diagonal stripes oriented as a bend.',
'bend', '#n. a broad diagonal stripe connecting the viewer\'s upper left and lower right.',
'bezanty', '#adj. strewn with an indeterminate number of yellow or gold circular disks.',
'bezant', '#n. a yellow or gold circular disc.',
'billet', '#n. a charge representing a slab of wood, drawn as a featureless rectangle.',
'blazon', '#n. a heraldic description of a design.  #vb. to describe a design in heraldic language.',
'bleu celeste', '#adj. in sky-blue.',
'bordure', '#n. a thick stripe covering all edges of the shield.',
'brunatre', '#adj. in brown.',
'canton', '#n. a large, square figure covering the corner in the viewer\'s upper left.  #n. the corner in the viewer\'s upper left (in canton).',
'cartouche', '#n. an oval with straight sides.',
'celtic cross', '#n. a cross debruised by a small annulet.',
'cendree', '#adj. in light grey.',
'charged', '#adj. having another charge placed so it lies entirely on the first (a roundel charged with a mullet).',
'charge', '#n. an object or figure used as a distinct element of a heraldic design.  #vb. to place a charge so that it lies entirely on another.',
'checky', '#adj. divided in a checker-board pattern with two tinctures.',
'chevron', '#n. a bent stripe that runs from side to side, rising to a sharp corner in the middle.',
'chief', '#n. a horizontal stripe covering the top edge of the shield (a chief gules).  #n. the upper portion of the shield (in chief, to chief).',
'compass rose', '#n. a figure used to indicate the cardinal directions in a map.',
'compass star', '#n. a star with eight alternately long and short straight rays.',
'conjoined', '#adj. (of charges) touching.',
'contourny', '#adj. (of a creature or head) turned to the viewer\'s right (a raven contourny).',
'cotised', '#adj. (of an ordinary) flanked by two very narrow stripes, one to each side.',
'counterchanged', '#adj. (of a charge) in the same two tinctures as the underlying area, but the tinctures transposed.',
'counterermine', '#adj. in black, powdered with white or silver ermine spots.',
'couped', '#adj. (of a charge) the end(s) severed with a straight cut (a chevron couped).',
'courant', '#adj. (of a creature) running to the left, with all limbs in the air.',
'cross', '#n. an ordinary formed by two stripes, one vertical and one horizontal, that cross each other in the middle (a cross engrailed). #n. any of numerous conventional representation of the instrument upon which Jesus died (a Celtic cross).',
'crux ansata', '#n. a cross with the upper limb replaced by a loop, in other words, an ankh.',
'debruised', '#adj. partly obscured by a charge that lies partly on the field.',
'debruising', '#adj. partly obscuring another a charge but not lying entirely on it.',
'decrescent', '#n. a crescent with its opening to the viewer\'s right.',
'delf', '#n. a solid square.',
'dexter chief', '#n. the corner in the viewer\'s upper left.',
'dexter', '#n. the side to the viewer\'s left, which would be the shield-bearer\'s right.  #adj. (of a left-right pair) right (a dexter glove).',
'displayed', '#adj. (of a creature) with its belly toward the viewer and its limbs splayed outward like a mounted butterfly (an eagle displayed).',
'dovetailed', '#adj. (of an edge) drawn with in a pattern resembling a dovetail joint.',
'drakkar', '#n. a Viking longship.',
'eclipsed', '#adj. (of a sun) obscured by a round disk of a contrasting tincture.',
'embattled', '#adj. (of an edge) drawn so as to resemble the battlements of a castle or a square wave.',
'emblazon', '#n. a graphical portrayal of a heraldic design.  #vb. to portray a heraldic design graphically.',
'embowed', '#adj. bent.',
'endorsed', '#adj. (of a pale) flanked by two very narrow vertical stripes, one to each side.',
'engrailed', '#adj. (of an edge) drawn with circular bites taken from it.',
'erased', '#adj. (of a limb) severed with a jagged cut.',
'ermine spot', '#n. any conventional representation of the tail of an ermine.',
'ermines', '#adj. in black, powdered with white or silver ermine spots.  #pl. n. weasels prized for their fur.',
'ermine', '#adj. in white or silver, powdered with black ermine spots.  #n. a weasel prized for its fur.',
'erminois', '#adj. in yellow or gold, powdered with black ermine spots.',
'estencele', '#adj. strewn with triangular groupings of three dots, representing sparks.',
'estoile', '#n. a charge, representing a star, composed of wavy rays (usually six) radiating from a common center.',
'fesswise', '#adj. (of charges) oriented so that the long axis lies horizontally, facing to the viewer\'s left.',
'fess', '#n. a broad horizontal stripe across the middle of the shield.',
'fieldless', '#adj. a design which may be presented on any background, for example, a maker\'s mark.',
'field', '#n. the background of a heraldic design.',
'fimbriated', '#adj. surrounded by a thin outline with a contrasting tincture.',
'flaunches', '#n. large, rounded figures covering each side of the shield.',
'fret', '#n. a saltire interlaced with a mascle.',
'fructed', '#adj. (of a plant) bearing fruits or nuts, possibly in a contrasting tincture.',
'golpe', '#n. a purple circular disk.',
'goute', '#adj. a teardrop.',
'goutty', '#adj. strewn with an indeterminate number of teardrops.',
'guardant', '#adj. (of a creature) looking toward the viewer.',
'gules', '#adj. in red.',
'gunstone', '#n. a black circular disk.',
'gyron', '#n. a wedge-shaped figure reaching half-way across the shield.',
'gyronny', '#adj. divided into many parts by lines issuant from a central point.',
'harpy', '#n. a vulture with human head and breasts.',
'haurient', '#adj. swimming toward the top of the shield.',
'hurty', '#adj. strewn with an indeterminate number of blue circular disks.',
'hurt', '#n. a blue circular disk.',
'in annulo', '#adj. (of charges) arranged as if lying on an invisible circular ring.',
'in base', '#adj. (of charges) placed in the bottom of the shield.',
'in bend', '#adj. (of charges) arranged as if lying on an invisible bend.',
'in canton', '#adj. (of charges) placed in the viewer\'s upper left.',
'in chief', '#adj. (of charges) arranged as if lying on an invisible chief.',
'in cross', '#adj. (of charges) arranged as if lying on an invisible cross.',
'in fess', '#adj. (of charges) arranged as if lying on an invisible fess.',
'in pale', '#adj. (of charges) arranged as if lying on an invisible pale.',
'in saltire', '#adj. (of charges) arranged as if lying on an invisible saltire.',
'increscent', '#n. a crescent with its opening to the viewer\'s left.',
'indented', '#adj. (of edges) drawn so as to represent the teeth of a saw.',
'invected', '#adj. (of edges) drawn with circular bumps issuing from it.',
'inverted', '#adj. (of charges) having top and bottom transposed (a chevron inverted).',
'issuant', '#adj. (of charges) appearing to issue or emerge (issuant from chief).',
'label', '#n. a horizontal stripe with an embattled or dovetailed lower edge.',
'latin cross', '#n. a cross with the lower limb extended.',
'leaved', '#adj. (of plants) having leaves, often in a contrasting tincture.',
'lion', '#n. a ferocious cat with small rounded ears, long tongue and tail, and tufts of fur all over its body.',
'lozenge', '#n. a solid, conventional represenation of a diamond, namely, a rhombus standing on end.',
'lozengy', '#n. divided into diamond-shaped pieces by diagonal lines.',
'martlet', '#n. a bird with tufts of feathers in place of feet.',
'mascle', '#n. a hollow, conventional representation of a diamond, namely, a rhombus standing on end.',
'maunch', '#n. a charge representing the long sleeve of a gown.',
'mound', '#n. a symbol of royal authority consisting of a jewelled ball topped with a cross.',
'mount', '#n. an rounded figure covering the bottom point of the shield, a base enarched.',
'mullet', '#n. a charge representing a star or spur rowel, composed of a symmetric arrangement of straight rays or points.',
'naiant', '#adj. swimming to the viewer\'s left.',
'ogress', '#n. a black circular disk.',
'on', '#prep. obscuring part of (on a fess).',
'ordinary', '#n. a simple figure partly delimited by one or more edges of the shield.',
'orle', '#n. a stripe parallel to, and just inside, the edges of the shield.',
'palewise', '#adj. (of charges) oriented so that the long axis lies vertically, facing upwards.',
'pale', '#n. a vertical stripe through the middle of the shield.',
'pall', '#n. a Y-shaped figure, formed by three stripes that meet at the center of the shield.',
'paly', '#adj. divided into an even number of vertical stripes of different tinctures.',
'passant', '#adj. (of creatures) with one foot in the air, as if walking to the viewer\'s left (a bear passant).',
'pean', '#adj. in black, powdered with yellow or gold ermine spots.',
'pellety', '#adj. strewn with an indeterminate number of black circular disks.',
'pellet', '#n. a black circular disk.',
'pendant', '#adj. (of a crescent) opening toward the bottom of the shield.',
'per bend', '#adj. divided into two equal parts by a diagonal line connecting the viewer\'s upper left and lower right.',
'per chevron', '#adj. divided into equal upper and lower parts by a line that rises to a sharp corner in the middle.',
'per fess', '#adj. divided into two equal parts by a horizontal line (per fess argent and sable).',
'per pale', '#adj. divided into two equal parts by a vertical line.',
'per pall', '#adj. divided into three equal parts by a Y-shaped boundary.',
'per saltire', '#adj. divided into four equal parts by two diagonal lines that cross in the middle.',
'pheon', '#n. an arrowhead.',
'pheonix', '#n. the front half of a bird, issuant from flames.',
'pile', '#n. a triangular wedge, reaching from the top edge of the shield almost to the bottom point.',
'pily', '#adj. divided into long triangular wedges.',
'pithon', '#n. a bat-winged snake.',
'plate', '#n. a white or silver circular disc.',
'platy', '#adj. strewn with an indeterminate number of white or silver circular disks.',
'point', '#n. (of a star or weapon) any sharp tip. #n. a corner of the shield, especially the bottom one.',
'pomme', '#n. a green circular disk.',
'potent', '#adj. in a pattern of blue and white "T"-shaped pieces.  #adj. (of a cross or edge) drawn with "T"-shaped limbs.',
'proper', '#adj. (of a charge) in its natural or most common coloration.',
'purpure', '#adj. in purple.',
'python', '#n. a type of serpent.',
'quarterly', '#adj. divided into four equal parts by two lines, one vertical and one horizontal, that cross each other in the middle.',
'rampant', '#adj. (of a creature) standing upon one hind-limb, facing the viewer\'s left.',
'rayonny', '#adj. (of an edge) drawn with wavy rays emerging from it.',
'reguardant', '#adj. (of a creature) looking back over its shoulder.',
'reversed', '#adj. (of a charge) having left and right transposed (an arrow fesswise reversed).',
'rose', '#n. a flower whose blossom consists of a circular seed surrounded by five symmetric lobes alternating with spiky barbs.  #n. (garden rose) a flower with a blossom resembling a small cabbage.  #adj. in pink.',
'roundel', '#n. a circular disc.',
'sable', '#adj. in black.',
'salient', '#adj. (of a creature) standing upon both hind-limbs, facing the viewer\'s left.',
'reguardant', '#adj. (of a creature) looking back over its shoulder.',
'saltire', '#n. a figure formed by two diagonal stripes that cross each other in the middle and extend to the edges of the shield.',
'saltorel', '#n. a figure formed by two diagonal segments that cross each other in the middle but do not extend to the edges of the shield.',
'scarpe', '#n. a narrow diagonal stripe connecting the viewer\'s upper right and lower left.',
'sejant', '#adj. (of creatures) seated, facing the viewer\'s left.',
'semy', '#adj. strewn with an indeterminate number (semy of bells).',
'shield', '#n. the conventional medium for heraldic display, a hand-held defensive armament.',
'sinister chief', '#n. the corner in the viewer\'s upper right.',
'sinister', '#n. the side to the viewer\'s right, which would be the shield-bearer\'s left (passant to sinister).  #adj. having left and right transposed (a bend sinister).  #adj. (of any left-right pair) left (a sinister foot).',
'slipped', '#adj. (of a plant) having a visible stem (a rose gules slipped vert).',
'sphinx', '#n. a monster composed of a lion with a human head.',
'tenne', '#adj. in orange.',
'tergiant', '#adj. (of a creature) with its back to the viewer.',
'tierce', '#n. a stripe covering one side of the shield from top to bottom.',
'tincture', '#n. one of the standard a heraldic colorations.',
'tinctureless', '#adj. a design which may be presented in any combination of colorations, for example, a seal.',
'torteau', '#n. a red circular disk.',
'tressure', '#n. a narrow stripe parallel to, and just inside, the edges of the shield.',
'trippant', '#adj. (of hoofed beasts) with one foot in the air, as if walking to the viewer\'s left (a stag trippant).',
'unicorn', '#n. a four-legged creature with single spiral horn, a beard, and a tuft at the end of its tail.',
'urdy', '#adj. (of an edge) drawn with hexagonal bumps emerging from it.',
'vair', '#adj. in a pattern of blue and white "bells".',
'vert', '#adj. in green.',
'voided', '#adj. hollowed out, so that the background is visible in the center.',
'volant', '#adj. (of a winged creature) flying toward the viewer\'s left.',
'wavy', '#adj. (of an edge) drawn so as to represent the curves of a river.',
'wyvern', '#n. a two-legged creature composed of the front half of a dragon joined to the rear half of a serpent.'
);

%plink = (
'Or', 'tinctures#or',
'annulet', 'geometrics#annulet',
'argent', 'tinctures#argent',
'azure', 'tinctures#azure',
'barry', 'fielddivisions#barry',
'bar', 'variants#bar',
'base', 'directions#base,ordinaries#base',
'bendlet', 'variants#bendlet',
'bendy', 'fielddivisions#bendy',
'bend', 'ordinaries#bend',
'billet', 'geometrics#billet',
'blazon', 'blazon#blazon_noun,blazon#blazon_verb',
'bleu celeste', 'tinctures#bleuceleste',
'bordure', 'ordinaries#bordure',
'brunatre', 'tinctures#brunatre',
'canton', 'ordinaries#canton',
'cartouche', 'geometrics#cartouche',
'cendree', 'tinctures#cendree',
'charge', 'layers1#charge',
'checky', 'fielddivisions#chequy',
'chevron', 'ordinaries#chevron',
'chief', 'directions#chief,ordinaries#chief',
'cotised', 'variants#cotised',
'counterermine', 'tinctures#counterermine',
'cross', 'geometrics#cross-couped,ordinaries#cross',
'delf', 'geometrics#delf',
'dexter', 'directions#dexter',
'dovetailed', 'complex#dovetailed',
'embattled', 'complex#embattled',
'emblazon', 'blazon#emblazon_noun,blazon#emblazon_verb',
'endorsed', 'variants#endorsed',
'engrailed', 'complex#engrailed',
'ermines', 'tinctures#ermines',
'ermine', 'tinctures#ermine',
'fess', 'ordinaries#fess',
'field', 'layers1#field',
'fimbriated', 'variants#fimbriated',
'fret', 'geometrics#fret',
'gules', 'tinctures#gules',
'gyron', 'ordinaries#gyron',
'gyronny', 'fielddivisions#gyronny',
'in bend', 'arrangements#in_bend',
'in fess', 'arrangements#in_fess',
'in pale', 'arrangements#in_pale',
'indented', 'complex#indented',
'invected', 'complex#invected',
'inverted', 'orientations#inverted',
'label', 'geometrics#label',
'lozenge', 'geometrics#lozenge',
'lozengy', 'fielddivisions#lozengy',
'mascle', 'geometrics#mascle',
'mullet', 'geometrics#mullet',
'on', 'layers1#on',
'orle', 'ordinaries#orle',
'pale', 'ordinaries#pale',
'pall', 'ordinaries#pall',
'paly', 'fielddivisions#paly',
'pean', 'tinctures#pean',
'per bend', 'fielddivisions#per-bend',
'per chevron', 'fielddivisions#per-chevron',
'per fess', 'fielddivisions#per-fess',
'per pale', 'fielddivisions#per-pale',
'per pall', 'fielddivisions#per-pall',
'per saltire', 'fielddivisions#per-saltire',
'pile', 'ordinaries#pile',
'pily', 'fielddivisions#pily',
'pomme', 'roundels#pomme',
'potent', 'tinctures#potent',
'purpure', 'tinctures#purpure',
'quarterly', 'fielddivisions#quarterly',
'rayonny', 'complex#rayonny',
'reversed', 'orientations#reversed',
'roundel', 'geometrics#roundel',
'sable', 'tinctures#sable',
'saltire', 'ordinaries#saltire',
'saltorel', 'geometrics#saltorel',
'scarpe', 'variants#scarpe',
'sinister', 'directions#sinister',
'tenne', 'tinctures#tenne',
'tierce', 'ordinaries#tierce',
'tincture', 'tinctures#tincture',
'tressure', 'variants#tressure',
'urdy', 'complex#urdy',
'vair', 'tinctures#vair',
'vert', 'tinctures#vert',
'voided', 'variants#voided',
'wavy', 'complex#wavy'
);

$def = $definition{$p};
$plink = $plink{$p};
$plink = ''; # suppress attempt to point to primer

&print_header ();

if ($p ne '') {
  $phrase = &blazon($p);
  if ($def eq '') {
    print '<h3>No definition available for "<em>', $phrase, '</em>".</h3>';
  } else {
    print '<h3>"<em>', $phrase, '</em>":</h3>';

    $def = &blazon($def);
    # insert list item tags and italicize parts of speech
    $def =~
      s^\&\#35\;(adj|n|pl\. n|prep|vb)\.^<li><i>$1.</i>^g;
    print '<large><ol>', $def, '</ol></large>';

    if ($plink ne '') {
      print '<ul>';
      @plinks = split (/[,]/, $plink);
      $i = 1;
      foreach (@plinks) {
        s/\#/.html#/;
        print '<li><a href="XXPrimerUrlXX', $_,
          '">primer link ', $i, '</a>';
        $i++;
      }
      print '</ul>';
    }
  }
  print '<hr>';
}

print '<p>Enter the word or phrase you want to look up in the glossary ->;';
print '<input type="text" name="p" value="', $p, '" size=30>';

print '<h3>Actions:</h3>';
print '<input type="submit" value="look up the definition">';

&print_trailer ();
# end of XXGlossaryPathXX
