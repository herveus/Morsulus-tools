use 5.006;
use strict;
use warnings;
#use ExtUtils::MakeMaker;
use inc::Module::Install;

name 'Morsulus-Ordinary-Classic';
all_from 'lib/Morsulus/Ordinary/Classic.pm';

requires 'Moose' => 0;
requires 'namespace::autoclean' => 0;
requires 'DBD::SQLite' => 1.00;
requires 'DBIx::Class::Schema' => 0;
requires 'DBI' => 0;
requires 'Getopt::Euclid' => 0;
test_requires 'Test::More' => 0;

install_script 'check_blazons';
install_script 'load_db';


WriteAll;
__END__

WriteMakefile(
    NAME                => 'Morsulus::Ordinary::Classic',
    AUTHOR              => q{Michael Houghton <herveus@cpan.org>},
    VERSION_FROM        => 'lib/Morsulus/Ordinary/Classic.pm',
    ABSTRACT_FROM       => 'lib/Morsulus/Ordinary/Classic.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
		'Moose' => 0,
		'namespace::autoclean' => 0,
		'DBIx::Class::Schema' => 0,
		'DBD::SQLite' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Morsulus-Ordinary-Classic-*' },
);
