use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Morsulus::Actions',
    AUTHOR              => 'Michael Houghton <herveus@cpan.org>',
    VERSION_FROM        => 'lib/Morsulus/Actions.pm',
    ABSTRACT_FROM       => 'lib/Morsulus/Actions.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Morsulus-Actions-*' },
);
