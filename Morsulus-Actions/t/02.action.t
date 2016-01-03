use Test::More 'no_plan';
use Test::Exception;

BEGIN {
    use_ok( 'Morsulus::Actions' );
}

diag("Testing Morsulus::Actions $Morsulus::Actions::VERSION");

my $action_line = 'ufo000119|C|Joint household name change to "Company of Saint Martin de Tours" from "Company of Martin de Tours" and badge|Juliana Neuneker Hirsch von Schutzhundheim and Arion Hirsch von Schutzhundheim|Azure, two scarpes argent between two furisons Or|
';

my ( undef, $kingdom, $action, $name, $armory, $name2, $notes )
        = split( /[|]/, $action_line );
my $act = Morsulus::Actions->new(
{   action => $action,
    source => "9999$kingdom",
    name => $name,
    armory => $armory,
    name2 => $name2,
    notes => $notes
});

is $act->quoted_names_of->[0], "Company of Saint Martin de Tours", "first quoted name";
is $act->quoted_names_of->[1], "Company of Martin de Tours", "second quoted name";
