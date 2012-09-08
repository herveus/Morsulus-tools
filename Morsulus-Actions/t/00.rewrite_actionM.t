use Test::More 'no_plan';
use Test::Exception;

BEGIN {
    use_ok( 'Morsulus::ActionsMoose' );
}

diag("Testing Morsulus::ActionsMoose $Morsulus::ActionsMoose::VERSION");

my @actions_and_results = test_actions_and_results();

while (@actions_and_results)
{
    my $before_action = shift @actions_and_results;
    my $expected_result = shift @actions_and_results;
    my $expected_cooked_action = shift @$expected_result;
    my $quoted_names = $expected_result;
    
    my $act = Morsulus::ActionsMoose->new(
        {   action => $before_action,
            source => "9999X",
            name   => '',
            armory => '',
            name2  => '',
        }
    );
    my $actual_result = $act->cooked_action_of;
    my $got_quoted_names = [@{$act->quoted_names_of}];
    is $actual_result, $expected_cooked_action, $before_action;
    is_deeply $got_quoted_names, $quoted_names, $before_action;
}

sub test_actions_and_results {
    return (
        'Heraldic title "Double Quaterfoyle Herald"' => [
            'heraldic title "x"',
            'Double Quaterfoyle< Herald>', ],
        'Heraldic title "Double Quaterfoyle Herald Extraordinary"' => [
            'heraldic title "x"',
            'Double Quaterfoyle< Herald Extraordinary>', ],
        'Transfer of heraldic title Double Quaterfoyle Herald to "Yin Mei Li"' => [
            'transfer of heraldic title "x" to "x"',
            'Double Quaterfoyle< Herald>',
            'Yin Mei Li', ],
        'Branch name "Artemisia, Kingdom of"' => [
            'branch name "x"',
            'Artemisia<, Kingdom of>', ],
        'Branch name "Bright Hills, Barony of the"' => [
            'branch name "x"',
            'Bright Hills,< Barony of> the', ],
        'Heraldic title "Most Pursuivant Extraordinary"' => [
            'heraldic title "x"',
            'Most< Pursuivant Extraordinary>', ],
        'Heraldic title "Most Pursuivant"' => [
            'heraldic title "x"',
            'Most< Pursuivant>', ],
        'Branch name "Crois Brigte, Canton of"' => [
            'branch name "x"',
            'Crois Brigte<, Canton of>', ],
        'Branch name change from "Small Grey Bear, Shire of the"' => [
            'branch name change from "x"',
            'Small Grey Bear,< Shire of> the', ],
        'Branch name "Small Gray Bear, Barony of"' => [
            'branch name "x"',
            'Small Gray Bear<, Barony of>', ],
        'Branch name "Atenveldt, Barony of"' => [
            'branch name "x"',
            'Atenveldt, Barony of', ],
    );
}
