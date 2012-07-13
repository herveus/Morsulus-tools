#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Morsulus::Ordinary::Classic' ) || print "Bail out!\n";
}

diag( "Testing Morsulus::Ordinary::Classic $Morsulus::Ordinary::Classic::VERSION, Perl $], $^X" );
