#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Morsulus' ) || print "Bail out!\n";
}

diag( "Testing App::Morsulus $App::Morsulus::VERSION, Perl $], $^X" );
