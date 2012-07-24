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

$ord->makeDB;

# open my $db_flat_file_fh, '<', 't/test.db';
# # my @test_data = <$db_flat_file_fh>; chomp(@test_data);
# my @local_test_data = get_test_data();
# # for my $x (0..9)
# # {
# #     is $test_data[$x], $local_test_data[$x], "record $x";
# # }
# while (<$db_flat_file_fh>)
# # {
# #     chomp;
# #     is $_, $local_test_data[0], 'woof';
# #     shift @local_test_data;
# # }
# # for (get_test_data())
# {
#     chomp;
#     diag($_);
#     $ord->process_legacy_record($_);
# }
# 
#$ord->process_legacy_record('A. J. of Bonwicke|199404X|N||(Owner: A. J. of Bonwicke:199404X)(Holding name)
#');
#$ord->process_legacy_record('A. J. of Bonwicke|199404X|d|Per pall inverted gules, Or and argent, a cedar tree vert stocked sable and a bordure sable semy of lozenges Or.|(Owner: A. J. of Bonwicke:199404X)|BORDURE:charged:pl:sable:surrounding 1 only|FIELD DIV.-PER PALL*7:pl|FIELD:multicolor light|LOZENGE:or:pl:seme:tertiary:unc|TREE-PINE TREE SHAPE:1:spna:vert
#');

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

