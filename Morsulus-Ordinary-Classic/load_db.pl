#!/usr/local/bin/perl

use strict;
use warnings;
use Morsulus::Ordinary::Classic;

my $ord = Morsulus::Ordinary::Classic->new(dbname => 't/01.create.db',
    db_flat_file => '/Users/herveus/oanda.tail.db',
    );

$ord->load_database;
