#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Encode::Daud' ) || print "Bail out!\n";
}

diag( "Testing Encode::Daud $Encode::Daud::VERSION, Perl $], $^X" );
