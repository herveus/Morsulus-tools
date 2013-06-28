#!perl -T

use Test::More ;#tests => 2;

use Morsulus::Ordinary::Classic;

my $dbfile = 't/01.create.db';

unlink $dbfile if -e $dbfile;

my $ord = Morsulus::Ordinary::Classic->new(dbname => 't/01.create.db',
    category_file => 't/test.cat',
    db_flat_file => 't/test.db',
    );

is $ord->dbname, 't/01.create.db', 'dbname set correctly';
is $ord->category_file, 't/test.cat', 'cat file set correctly';

my %test_data;
{
	open my $test_db, '<', $ord->db_flat_file;
	while (<$test_db>)
	{
		s/\r?\n$//;
		$test_data{$_} = 0;
	}
}

$ord->makeDB;

my @feature_sets = $ord->schema->resultset('FeatureSet')->all;
my %sets = map { $_ => 0 } (qw/ arrangement bird_posture chrelation count
	crescent_dir fish_posture group line number orientation posture 
	relation tertiaries tincture1 tincture2 tincture/);
for my $fs (@feature_sets)
{
	ok exists $sets{$fs->feature_set_name}, "feature set is in list";
	$sets{$fs->feature_set_name}++;
}
for my $fs (keys %sets)
{
	is $sets{$fs}, 1, "feature set $fs found in DB";
}

my $feature_rs = $ord->Feature;
for my $test_feat ("proper:tincture", "4 or fewer:number", "square:line", "g2pa:group")
{
	my ($test_feature, $test_feature_set) = split(/:/, $test_feat);
	my $feature = $feature_rs->find({feature => $test_feature});
	ok defined $feature, "found feature $test_feature in database";
	is $feature->feature_set->feature_set_name, $test_feature_set, "...and it has the right feature set";
}

my @regs = $ord->Registration->all;
for my $reg (@regs)
{
	my $entry = $ord->get_registration($reg)->canonicalize->to_string;
	ok exists $test_data{$entry}, "got the entry back: $entry";
	$test_data{$entry}++;
	is $test_data{$entry}, 1, "and haven't seen it before";
}

my $reg = $ord->Registration->find(10);
for my $note ($reg->notes)
{
    if ($note->note_text =~ /^For (.*)/)
    {
        is $note->note_name->name, 'Kultaisen Kapustan Kilta', "note has referenced name";
    }
}
$ord->drop_descs("Sable, a spoon Or between two wolf's heads cabossed argent.");
is $ord->get_registration($reg)->descs, undef, "drop_descs whacked descs";

done_testing();

sub get_test_data
{
return split(/\n/,<<EOD);
A. J. of Bonwicke|199404X|N||(Owner: A. J. of Bonwicke:199404X)(Holding name)
A. J. of Bonwicke|199404X|d|Per pall inverted gules, Or and argent, a cedar tree vert stocked sable and a bordure sable semy of lozenges Or.|(Owner: A. J. of Bonwicke:199404X)|BORDURE:charged:pl:sable:surrounding 1 only|FIELD DIV.-PER PALL*7:pl|FIELD:multicolor light|LOZENGE:or:pl:seme:tertiary:unc|TREE-PINE TREE SHAPE:1:spna:vert
A ma vie< Pursuivant>|200812N|t|Dukes of Brittany|(Owner: Laurel - admin)(Important Non-SCA title)
Aale Brunkarrkarl|198905X|N||(Owner: Aale Brunkarrkarl:198905X)
Aal{'e}s de Lironcourt|200208S|N||(Owner: Aal{'e}s de Lironcourt:200208S)
Aarnimetsa<, Barony of>|199806D-200607D|Bvc|Aarnimets{a:}<, Barony of>|(Owner: Morsulus - admin)
Aarnimets{a:}<, Barony of>|199608D|BN||(Owner: Aarnimets{a:}<, Barony of>:199608D)
Aarnimets{a:}<, Barony of>|199212E|d|Sable, a chevron throughout raguly on the upper edge, in base a wolf's head cabossed within a laurel wreath argent.|(Owner: Aarnimets{a:}<, Barony of>:199608D)|CHEVRON:1:argent:raguly:spna:unc|FIELD:sable|HEAD-BEAST,DOG,FOX AND WOLF:1:argent:second:unc|SA|WREATH-LAUREL:1:argent:second:surrounding 1 only
Aarnimets{a:}<, Barony of>|199706D|b|Sable, a chevron throughout raguly on the upper edge, in base a wolf's head caboshed argent.|(Owner: Aarnimets{a:}<, Barony of>:199608D)|CHEVRON:1:argent:raguly:spna:unc|FIELD:sable|HEAD-BEAST,DOG,FOX AND WOLF:1:argent:second|SA
Aarnimets{a:}<, Barony of>|199709D|b|Sable, a spoon Or between two wolf's heads cabossed argent.|(For Kultaisen Kapustan Kilta)(Owner: Aarnimets{a:}<, Barony of>:199608D)|FIELD:sable|FORK AND SPOON:1:or:spna|HEAD-BEAST,DOG,FOX AND WOLF:2:argent:second|SA
EOD
}

