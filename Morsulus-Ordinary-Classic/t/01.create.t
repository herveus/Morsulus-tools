#!perl -T

use Test::More tests => 2;

use Morsulus::Ordinary::Classic;

my $dbfile = 't/01.create.db';

unlink $dbfile if -e $dbfile;

my $ord = Morsulus::Ordinary::Classic->new(dbname => 't/01.create.db',
    category_file => 't/test.cat');

is $ord->dbname, 't/01.create.db', 'dbname set correctly';
is $ord->category_file, 't/test.cat', 'cat file set correctly';

$ord->makeDB;

