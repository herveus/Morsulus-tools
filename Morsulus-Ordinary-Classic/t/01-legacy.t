#!perl -T

use Test::More;

use Morsulus::Ordinary::Legacy;

my $entry = Morsulus::Ordinary::Legacy->from_string(
'A. J. of Bonwicke|199404X|N||(Owner: A. J. of Bonwicke:199404X)(Holding name)
');
is $entry->name, 'A. J. of Bonwicke', 'name';
is $entry->source, '199404X', 'source';
is $entry->type, 'N', 'type';
is $entry->text, '', 'text';
is $entry->notes, '(Owner: A. J. of Bonwicke:199404X)(Holding name)';
is $entry->descs, undef, 'descs';
ok !$entry->has_blazon, 'has no blazon';
ok !$entry->is_historical, 'is not historical';
my @notes = $entry->split_notes;
is scalar @notes, 2, 'there are two notes';
is $notes[1], 'Holding name', '...and the second is Holding name';
my @parts = $entry->parse_source;
is scalar @parts, 4, 'four pieces in source';
is $parts[0], '199404', 'reg year';
is $parts[1], 'X', 'reg kingdom';
is $parts[2], undef, 'rel year';
is $parts[3], undef, 'rel king';


$entry = Morsulus::Ordinary::Legacy->from_string('A. J. of Bonwicke|199404X|d|Per pall inverted gules, Or and argent, a cedar tree vert stocked sable and a bordure sable semy of lozenges Or.|(Owner: A. J. of Bonwicke:199404X)|BORDURE:charged:pl:sable:surrounding 1 only|FIELD DIV.-PER PALL*7:pl|FIELD:multicolor light|LOZENGE:or:pl:seme:tertiary:unc|TREE-PINE TREE SHAPE:1:spna:vert
');
is $entry->name, 'A. J. of Bonwicke', 'name';
is $entry->source, '199404X', 'source';
is $entry->type, 'd', 'type';
is $entry->text, 'Per pall inverted gules, Or and argent, a cedar tree vert stocked sable and a bordure sable semy of lozenges Or.', 'text';
is $entry->notes, '(Owner: A. J. of Bonwicke:199404X)';
is $entry->descs, 'BORDURE:charged:pl:sable:surrounding 1 only|FIELD DIV.-PER PALL*7:pl|FIELD:multicolor light|LOZENGE:or:pl:seme:tertiary:unc|TREE-PINE TREE SHAPE:1:spna:vert', 'descs';
ok $entry->has_blazon, 'has a blazon';
ok !$entry->is_historical, 'is not historical';
my @descs = $entry->split_descs;
is scalar @descs, 5, '5 descs';
is $descs[0], 'BORDURE:charged:pl:sable:surrounding 1 only', 'first desc is BORDURE...';


$entry = Morsulus::Ordinary::Legacy->from_string('Aarnimetsa<, Barony of>|199806D-200607D|Bvc|Aarnimets{a:}<, Barony of>|(Owner: Morsulus - admin)
');
is $entry->name, 'Aarnimetsa<, Barony of>', 'name';
is $entry->source, '199806D-200607D', 'source';
is $entry->type, 'Bvc', 'type';
is $entry->text, 'Aarnimets{a:}<, Barony of>', 'text';
is $entry->notes, '(Owner: Morsulus - admin)';
is $entry->descs, undef, 'descs';
ok !$entry->has_blazon, 'has no blazon';
ok $entry->is_historical, 'is historical';
@parts = $entry->parse_source;
is scalar @parts, 4, 'four pieces in source';
is $parts[0], '199806', 'reg year';
is $parts[1], 'D', 'reg kingdom';
is $parts[2], '200607', 'rel year';
is $parts[3], 'D', 'rel king';

$entry = Morsulus::Ordinary::Legacy->from_string('Atenveldt, Kingdom of|-201210A|b|Argent, a sun in splendor per saltire Or and azure and a bordure indented azure.|(-associated with usage)
');
is $entry->name, 'Atenveldt, Kingdom of', 'name';
is $entry->source, '-201210A', 'source';
is $entry->type, 'b', 'type';
is $entry->text, 'Argent, a sun in splendor per saltire Or and azure and a bordure indented azure.', 'text';
is $entry->notes, '(-associated with usage)';
is $entry->descs, undef, 'descs';
ok $entry->has_blazon, 'has blazon';
ok $entry->is_historical, 'is historical';
@parts = $entry->parse_source;
is scalar @parts, 4, 'four pieces in source';
is $parts[0], undef, 'reg year';
is $parts[1], undef, 'reg kingdom';
is $parts[2], '201210', 'rel year';
is $parts[3], 'A', 'rel king';

my %actions = (
    'a' => 1,
    'b' => 1,
    'D?' => 1,
    'd' => 1,
    'g' => 1,
    't' => 0,
    's' => 1,
    'N' => 0,
    'BN' => 0,
    'O' => 0,
    'OC' => 0,
    'AN' => 0,
    'ANC' => 0,
    'NC' => 0,
    'Nc' => 0,
    'BNC' => 0,
    'BNc' => 0,
    'HN' => 0,
    'HNC' => 0,
    'C' => 0,
    'j' => 0,
    'u' => 0,
    'v' => 0,
    'Bv' => 0,
    'vc' => 0,
    'Bvc' => 0,
    'R' => 0,
    'D' => 1,
    'BD' => 1,
    'B' => 1,
    );

for my $type (keys %actions)
{
    $entry->type($type);
    ok $entry->has_blazon, '$type has blazon' if ($actions{$type});
    ok !$entry->has_blazon, '$type has no blazon' unless ($actions{$type});
}


$entry->notes('');
$entry->add_notes('note1');
is $entry->notes, '(note1)', 'added note1';
$entry->add_notes(qw/note2 note3/);
is $entry->notes, '(note1)(note2)(note3)', 'added note2 and 3';

$entry->descs(undef);
@descs = $entry->split_descs;
is scalar @descs, 0, 'empty descs';
$entry->add_descs('desc1');
is $entry->descs, 'desc1', 'added desc1';
$entry->add_descs(qw/desc2 desc3/);
is $entry->descs, 'desc1|desc2|desc3', 'added desc2 and 3';


open my $fh, '<', 't/test.db';
while (my $test_input = <$fh>)
{
    chomp $test_input;
    my $entry = Morsulus::Ordinary::Legacy->from_string($test_input);
    my $has_blazon = $entry->has_blazon ? 1 : 0;
    my $type = (split(/\|/, $test_input))[2];
    is $has_blazon, $actions{$type}, "$test_input";
    is $entry->type, $type, "$type:$test_input";
    is $entry->to_string, $test_input, "stringify $test_input";
    is $entry->canonicalize->to_string, $test_input, "canonicalize $test_input";
}

for (test_data())
{
    chomp;
    my $entry = Morsulus::Ordinary::Legacy->from_string($_);
    my $has_blazon = $entry->has_blazon ? 1 : 0;
    my $type = (split(/\|/, $_))[2];
    is $has_blazon, $actions{$type}, "$_";
    is $entry->type, $type, "$type:$_";
}

done_testing();

sub test_data
{
return split(/\n/,<<EOD);
A. J. of Bonwicke|199404X|N||(Holding name)(Owner: A. J. of Bonwicke:199404X)
A. J. of Bonwicke|199404X|d|Per pall inverted gules, Or and argent, a cedar tree vert stocked sable and a bordure sable semy of lozenges Or.|(Owner: A. J. of Bonwicke:199404X)|BORDURE:charged:pl:sable:surrounding 1 only|FIELD DIV.-PER PALL*7:pl|FIELD:multicolor light|LOZENGE:or:pl:seme:tertiary:unc|TREE-PINE TREE SHAPE:1:spna:vert
A ma vie< Pursuivant>|200812N|t|Dukes of Brittany|(Important Non-SCA title)(Owner: Laurel - admin)
Aale Brunkarrkarl|198905X|N||(Owner: Aale Brunkarrkarl:198905X)
Aal{'e}s de Lironcourt|200208S|N||(Owner: Aal{'e}s de Lironcourt:200208S)
Aarnimetsa<, Barony of>|199806D-200607D|Bvc|Aarnimets{a:}<, Barony of>|(Owner: Morsulus - admin)
Aarnimets{a:}<, Barony of>|199608D|BN||(Owner: Aarnimets{a:}<, Barony of>:199608D)
Aarnimets{a:}<, Barony of>|199212E|d|Sable, a chevron throughout raguly on the upper edge, in base a wolf's head cabossed within a laurel wreath argent.|(Owner: Aarnimets{a:}<, Barony of>:199608D)|CHEVRON:1:argent:raguly:spna:unc|FIELD:sable|HEAD-BEAST,DOG,FOX AND WOLF:1:argent:second:unc|SA|WREATH-LAUREL:1:argent:second:surrounding 1 only
Aarnimets{a:}<, Barony of>|199706D|b|Sable, a chevron throughout raguly on the upper edge, in base a wolf's head caboshed argent.|(Owner: Aarnimets{a:}<, Barony of>:199608D)|CHEVRON:1:argent:raguly:spna:unc|FIELD:sable|HEAD-BEAST,DOG,FOX AND WOLF:1:argent:second|SA
Aarnimets{a:}<, Barony of>|199709D|b|Sable, a spoon Or between two wolf's heads cabossed argent.|(For Kultaisen Kapustan Kilta)(Owner: Aarnimets{a:}<, Barony of>:199608D)|FIELD:sable|FORK AND SPOON:1:or:spna|HEAD-BEAST,DOG,FOX AND WOLF:2:argent:second|SA
EOD
}