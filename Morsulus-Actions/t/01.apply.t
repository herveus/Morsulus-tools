use Test::More 'no_plan';
use Test::Exception;

BEGIN {
    use_ok( 'Morsulus::Actions::Apply' );
    use_ok( 'Morsulus::Ordinary::Classic' );
}

diag("Testing Morsulus::Actions::Apply");

my $ordinary = Morsulus::Ordinary::Classic->new(dbname => 'oanda1206.db') or die "Can't open database";

my $act = Morsulus::Actions::Apply->new(
    {   action => 'N',
        source => "999999Z",
        name   => 'Thorgud',
        armory => '',
        name2  => '',
        notes => '',
        db => $ordinary,
    }
);
        
ok $act->is_primary_name_registered('A. J. of Bonwicke');
ok !$act->is_primary_name_registered('A J. of Bonwicke');
ok $act->is_name_registered('A. J. of Bonwicke', 'N');
ok $act->is_name_registered('A. J. of Bonwicke', ['N']);
ok !$act->is_name_registered('A. J. of Bonwicke', 'BN');
ok $act->is_primary_name_registered('Aarnimets{a:}<, Barony of>');
ok $act->is_name_registered('Aarnimets{a:}<, Barony of>', 'BN');
my $name = q[{A'}ed F{a'}id];
ok $act->is_primary_name_registered($name);
ok $act->is_name_registered($name, 'N');

