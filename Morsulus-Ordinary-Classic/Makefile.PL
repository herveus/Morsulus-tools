use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

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
