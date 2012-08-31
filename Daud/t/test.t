# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
;

BEGIN
{
	use_ok 'Daud' ;
};

is Daud::get_style, 'ascii', 'check default style';
is Daud::set_style('latin1'), 'latin1', 'did set_style return the new style?';
is Daud::get_style, 'latin1', 'is style the latin1?';
ok !Daud::set_style('bogus'), 'bogus style rejected';
is Daud::get_style, 'latin1', 'is style still latin1?';

#Daud::set_style('latin1');

my $lossy_test    = '{cv}';
my $lossless_test = '{ae}';

ok Daud::lose_data($lossy_test), "$lossy_test loses data";
ok !Daud::lose_data($lossless_test), "$lossless_test does not lose data";

my $lossy_out = Daud::recode($lossy_test);

is $lossy_test, '{cv}', "$lossy_test unchanged";
is $lossy_out,  'c',    '...and the conversion is...';

Daud::recode($lossy_test);
is $lossy_test, 'c', '...and the inplace edit worked';

my $lossless_out = Daud::recode($lossless_test);

is $lossless_out, 'æ', "$lossless_test converted...";

my $round_trip = Daud::daudify($lossless_out);
is $round_trip, $lossless_test, 'round trip worked';

my @styles = Daud::get_styles;

is @styles, 5, 'get_styles returned the right number of items';
is join ( "", sort @styles ), 'asciihtmllatin1postscriptunicode',
  '...and they appear correct';

is Daud::recode('{i}'), 'i', 'lowercase i without dot OK';
