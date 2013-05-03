use inc::Module::Install;

name     'App-Morsulus';
all_from 'lib/App/Morsulus.pm';
author   q{Michael Houghton <herveus@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

