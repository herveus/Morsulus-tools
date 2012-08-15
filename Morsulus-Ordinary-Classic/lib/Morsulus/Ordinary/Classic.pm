package Morsulus::Ordinary::Classic;

use 5.14.0;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use DBI;
use Morsulus::Ordinary::Classic::Schema;
use Morsulus::Ordinary::Legacy;
# VERSION is way down below in POD area

has 'schema' => (
    isa => 'Object',
    is  => 'ro',
    lazy => 1,
    default => \&build_schema,
    );

has 'dbh' => (
    isa => 'Object',
    is  => 'ro',
    lazy => 1,
    default => \&build_dbh,
    );

has 'dbname' => (
    isa => 'Str',
    is => 'ro',
    );

has 'category_file' => (
    isa => 'Str',
    is => 'ro',
    );
    
has 'db_flat_file' => (
    isa => 'Str',
    is => 'ro',
    );

sub build_dbh
{
    my $self = shift;
    my $dbname = $self->dbname;
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=$dbname",
        "",
        "",
        {RaiseError => 1}
    ) or die "Cannot connect to DB $DBI::errstr";
    return $dbh;
}

sub build_schema
{
    my $self = shift;
    my $schema = Morsulus::Ordinary::Classic::Schema
        ->connect(sub {$self->dbh});
    return $schema;
}

sub makeDB
{
    my $self = shift;
    for my $sql (get_creates())
    {
        $self->dbh->do($sql) or die "Cannot execute $sql; $DBI::errstr";
    }
    $self->load_kingdoms;
    $self->load_dates;
    $self->load_actions;
    $self->load_categories;
    $self->load_database;
}

sub load_dates
{
    my $self = shift;
    $self->schema->txn_begin;
    for my $year (1960..2020)
    {
        for my $month ('01'..'12')
        {
            $self->schema->resultset('Date')->create(
                {
                    date => "$year$month",
                    year => $year,
                    month => $month+0,
                })->update;
        }
    }
    $self->schema->txn_commit;
}

sub load_actions {
    my $self = shift;
    $self->schema->txn_begin;
    my $sth = $self->dbh->prepare(
        'insert into actions (action_id, action_description) values (?,?)');
    for my $action (get_actions())
    {
        $self->schema->resultset('Action')->create(
            {
                action_id => $action->[0],
                action_description => $action->[1],
            })->update;
    }
    $self->schema->txn_commit;
}

sub get_actions
{
    return (
        [ 'a', 'augmentation' ],
        [ 'b', 'badge' ],
        [ 'D?','armory' ],
        [ 'd', 'device' ],
        [ 'g', 'regalia' ],
        [ 't', 'heraldic title' ],
        [ 's', 'seal' ],
        [ 'N', 'name' ],
        [ 'BN', 'branch name' ],
        [ 'O', 'order name' ],
        [ 'OC', 'order name change' ],
        [ 'AN','alternate name' ],
        [ 'ANC','alternate name change' ],
        [ 'NC','name change' ],
        [ 'Nc','name correction' ],
        [ 'BNC','branch-name change' ],
        [ 'BNc','branch-name correction' ],
        [ 'HN','household name' ],
        [ 'HNC','household name change' ],
        [ 'C', 'database comment' ],
        [ 'j', 'joint badge reference' ],
        [ 'u', 'branch designator update' ],
        [ 'v', 'uncorrected variant spelling' ],
        [ 'Bv', 'uncorrected variant branch-name spelling' ],
        [ 'vc', 'corrected variant spelling' ],
        [ 'Bvc', 'corrected variant branch-name spelling' ],
        [ 'R', 'cross-reference' ],
        [ 'D', 'combined name and device' ],
        [ 'BD', 'combined branch name and device' ],
        [ 'B', 'combined name and badge' ]
    );
}

sub load_categories
{
    my $self = shift;
    my $catfile = $self->category_file;
    defined $catfile or die "No category file specified";
    -r $catfile or die "Category file $catfile not readable";
    
    my $count = 0;
    $self->schema->txn_begin;
    open my $catfile_fh, '<', $catfile;
    while (<$catfile_fh>)
    {
        s/\r?\n$//;
        next if /^#/;
        if (/^\|/)
        {
            $self->process_feature($_);
        }
        elsif (/\|/)
        {
            $self->process_heading($_);
        }
        $count++;
        if ($count % 100)
        {
            $self->schema->txn_commit;
            $self->schema->txn_begin;
        }
    }
    $self->schema->txn_commit;
}

sub process_heading
{
    my $self = shift;
    my ($input) = @_;
    my ($category, $heading, $feature_sets) = split(/\|/, $input);
    $self->schema->resultset('Category')->create(
        {
            category => $category,
            heading => $heading,
        })->update;
}

sub process_feature
{
    my $self = shift;
    my ($input) = @_;
    $input =~ /^\|[^:]+:[^<=]+(?:[<=][^,=]+)*$/
        or die "malformed feature definition '$input'";
    my ($set_name, $feature_name) = /^\|([^:]+):([^<=]+)/;
    $self->add_feature_set($set_name);
    $self->add_feature($feature_name, $set_name);
    my @relations = split(/([<=])/, $input);
    shift @relations;
    my ($relationship, $related_feature);
    while (@relations)
    {
        $relationship = shift @relations;
        $related_feature = shift @relations;
        $self->add_feature($related_feature, $set_name);
		#TODO: capture relationships when that is added to the database
    }
}

sub add_feature_set
{
    my $self = shift;
    my ($set_name) = @_;
    my $fs = $self->schema->resultset('FeatureSet');
    $fs->find($set_name) or 
        $fs->create({feature_set_name => $set_name})->update;
    return $fs->find($set_name);
}

sub add_feature
{
    my $self = shift;
    my ($feature_name, $set_name) = @_;
    my $feature = $self->schema->resultset('Feature');
    $feature->find($feature_name) or
        $feature->create(
            {
                feature => $feature_name,
                feature_set => $set_name,
            })->update;
    return $feature->find($feature_name);
}

sub add_name
{
    my $self = shift;
    my ($name) = @_;
    my $name_rs = $self->schema->resultset('Name');
    $name_rs->find($name) or
        $name_rs->create(
            {
                name => $name,
            })->update;
    return $name_rs->find($name);
}

sub add_blazon
{
    my $self = shift;
    my ($blazon) = @_;
    my $blazon_rs = $self->schema->resultset('Blazon');
    my $bz = $blazon_rs->find({blazon => $blazon}) ||
        $blazon_rs->create(
            {
                blazon => $blazon,
            })->update;
    return $bz;
}

sub add_note
{
    my $self = shift;
    my ($reg, $note_text) = @_;
    my $note_rs = $self->schema->resultset('Note');
    my $note = $note_rs->find({note_text => $note_text}) ||
        $note_rs->create({note_text => $note_text})->update;
    $self->schema->resultset('RegistrationNote')
        ->create(
            {
                reg_id => $reg->reg_id,
                note_id => $note->note_id,
            })->update;
}

sub add_desc
{
    my $self = shift;
    my ($desc_text, $blazon) = @_;
    $blazon = $self->schema->resultset('Blazon')->find($blazon) unless ref($blazon);
    my ($heading, @features) = split(/:/, $desc_text);
    my $category = $self->schema->resultset('Category')
        ->find({heading => $heading});
    my $desc = $self->schema->resultset('Description')->create(
        {
            category => $category->category,
            blazon_id => $blazon->blazon_id,
        })->update;
    my $df = $self->schema->resultset('DescFeature');
    for my $f (@features)
    {
        $df->create(
            {
                feature => $f,
                desc_id => $desc->desc_id,
            })->update;
    }
    return $desc;
}

sub get_blazon_registrations
{
    my $self = shift;
    my ($blazon) = @_;
    #find the list of registrations that refer to this blazon
    my $blazon_rs = $self->schema->resultset('Blazon');
    my @regs = $blazon_rs->search_related('registrations', 
        {blazon => $blazon})->all;
    my @entries;
    for my $reg (@regs)
    {
        push @entries, $self->get_registration($reg);
    }
    # get the descs for each
    # format them as Morsulus::Ordinary::Legacy objects
    return @entries;
}

sub get_registration
{
    my $self = shift;
    my ($reg) = @_;
    my $reg_rs = $self->schema->resultset('Registration');
    $reg = $reg_rs->find($reg) unless ref $reg;
    return unless $reg;
    my $entry = Morsulus::Ordinary::Legacy->new;
    $entry->name($reg->owner_name->name);
    $entry->type($reg->action->action_id);
    $entry->text($reg->text_blazon->blazon) if $entry->has_blazon;
    $entry->text($reg->text_name->name) unless $entry->has_blazon;
    # TODO: Account for For/See prefix on text
    $entry->source('');
    defined $reg->registration_date and 
        $entry->set_reg_date($reg->registration_date->date);
    defined $reg->registration_kingdom and
        $entry->set_reg_kingdom($reg->registration_kingdom->kingdom_id);
    defined $reg->release_date and
        $entry->set_rel_date($reg->release_date->date);
    defined $reg->release_kingdom and 
        $entry->set_rel_kingdom($reg->release_kingdom->kingdom_id);
    $entry->notes('');
    $entry->add_notes(map { $_->note_text } $reg->notes->all());
    if ($entry->has_blazon && ! $entry->is_historical)
    {
        for my $desc ($reg->text_blazon->descriptions())
        {
            $entry->add_descs(join(':', $desc->category->heading,
                map { $_->feature->feature } $desc->desc_features->all()));
        }
    }
    return $entry;
}

# sub get_feature
# {
#     my $self = shift;
#     my ($feature_name) = @_;
#     my $sth = $self->dbh->prepare_cached(
#         'select feature, feature_set from features where feature = ?');
#     $sth->execute($feature_name);
#     my $results = $sth->fetchall_arrayref;
#     return unless @$results;
#     return @$results;
# }
# 
# sub get_feature_set
# {
#     my $self = shift;
#     my ($feature_set_name) = @_;
#     my $sth = $self->dbh->prepare_cached(
#         'select feature_set_name from feature_sets where feature_set_name = ?');
#     $sth->execute($feature_set_name);
#     my $results = $sth->fetchall_arrayref;
#     return unless @$results;
#     return @$results;
# }
# 
sub load_database
{
    my $self = shift;
    my $dbfile = $self->db_flat_file;
    defined $dbfile or die "No legacy database file specified";
    -r $dbfile or die "Database file $dbfile not readable";
    $self->schema->txn_begin;
    my $count = 0;
    open my $dbfile_fh, '<', $dbfile;
    while (<$dbfile_fh>)
    {
        $self->process_legacy_record($_);
        $count++;
        if ($count)
        {
            $self->schema->txn_commit;
            $self->schema->txn_begin;
        }
    }
    $self->schema->txn_commit;
}

sub process_legacy_record
{
    my $self = shift;
    my ($record) = @_;
    $record =~ s/\r?\n$//;
    my $entry = Morsulus::Ordinary::Legacy->from_string($record);
    my ($reg_date, $reg_king, $rel_date, $rel_king) =
        $entry->parse_source;
    $self->add_name($entry->name);
    my $reg = $self->schema->resultset('Registration')->create(
        {
            owner_name => $entry->name,
            action => $entry->type,
            registration_date => $reg_date,
            release_date => $rel_date,
            registration_kingdom => $reg_king,
            release_kingdom => $rel_king,
        })->update;
    if ($entry->has_blazon)
    {
        my $blazon = $self->add_blazon($entry->text);
        $reg->text_blazon_id($blazon->blazon_id);
        $reg->update;
        if (! $entry->is_historical)
        {
            for my $desc ($entry->split_descs)
            {
                $self->add_desc($desc, $blazon);
            }
        }
    }
    elsif ($entry->text)
    {
        my $pad = $entry->text;
        $pad =~ s/^(?:See |For )//;
        $self->add_name($pad);
        $reg->text_name($pad);
        $reg->update;
    }
    
    for my $note ($entry->split_notes)
    {
        $self->add_note($reg, $note);
    }
}

sub get_next_reg_id
{
    my $self = shift;
    my $sth = $self->dbh->prepare_cached('select max(reg_id) from registrations');
    $sth->execute;
    my $max_reg_id = $sth->fetchrow_arrayref->[0];
    return $max_reg_id+1;
}

sub load_kingdoms
{
    my $self = shift;
    my $sth = $self->dbh->prepare(
        'insert into kingdoms (kingdom_id, kingdom_name_nominative) values (?,?)');
    for my $kingdom (get_kingdoms())
    {
        $sth->execute(@$kingdom) or die "Can't insert kingdom @$kingdom: $DBI::errstr";
    }
}

sub get_kingdoms
{
    return (
        [ 'A', 'Atenveldt' ],
        [ 'C', 'Caid' ],
        [ 'D', 'Drachenwald' ],
        [ 'E', 'the East' ],
        [ 'G', 'Gleann Abhann' ],
        [ 'H', 'AEthelmearc' ],
        [ 'K', 'Calontir' ],
        [ 'L', 'Laurel' ],
        [ 'M', 'the Middle' ],
        [ 'N', 'An Tir' ],
        [ 'O', 'the Outlands' ],
        [ 'Q', 'Atlantia' ],
        [ 'R', 'Atremisia' ],
        [ 'S', 'Meridies' ],
        [ 'T', 'Trimaris' ],
        [ 'W', 'the West' ],
        [ 'X', 'Ansteorra' ],
        [ 'm', 'Ealdormere' ],
        [ 'n', 'Northshield' ],
        [ 'w', 'Lochac' ],
    );
}

sub get_creates
{
    return split(/EOS/, <<EOSQL);
    drop table if exists blazons 
	EOS
    create table blazons (
        blazon_id integer not null primary key,
        blazon text not null unique
        )
	EOS
    drop table if exists names 
	EOS
    create table names (
        name text not null primary key
        )
	EOS
    drop table if exists dates 
	EOS
    create table dates (
        date text not null primary key,
        year integer not null,
        month integer not null
        )
	EOS
    drop table if exists kingdoms 
	EOS
    create table kingdoms (
        kingdom_id text not null primary key,
        kingdom_name_nominative text not null,
        kingdom_name text references names(name)
        )
	EOS
    drop table if exists actions 
	EOS
    create table actions (
        action_id text not null primary key,
        action_description text
        )
	EOS
    drop table if exists registrations 
	EOS
    create table registrations (
        reg_id integer not null primary key,
        owner_name text not null references names(name) default "",
        registration_date text references dates(date) default "",
        release_date text references dates(date) default "",
        registration_kingdom text references kingdoms(kingdom_id) default "",
        release_kingdom text references kingdoms(kingdom_id) default "",
        action text references actions(action_id) default "",
        text_blazon_id integer references blazons(blazon_id),
        text_name text references names(name) default ""
        )
	EOS
    drop table if exists notes 
	EOS
    create table notes (
        note_id integer not null primary key,
        note_text text not null,
        note_name text references names(name)
        )
	EOS
    drop table if exists registration_notes 
	EOS
    create table registration_notes (
        reg_id integer not null references registrations(reg_id),
        note_id integer not null references notes(note_id),
        primary key (reg_id, note_id)
        )
	EOS
    drop table if exists categories 
	EOS
    create table categories (
        category text not null primary key,
        heading text
        )
	EOS
    drop table if exists feature_sets 
	EOS
    create table feature_sets (
        feature_set_name text not null primary key
        )
	EOS
    drop table if exists features 
	EOS
    create table features (
        feature text not null primary key,
        feature_set text not null references feature_sets(feature_set_name)
        )
	EOS
    drop table if exists descriptions 
	EOS
    create table descriptions (
        desc_id integer not null primary key,
        category text not null references categories(category),
        blazon_id integer not null references blazons(blazon_id)
        )
	EOS
    drop table if exists desc_features 
	EOS
    create table desc_features (
        desc_id integer not null references descriptions(desc_id),
        feature text not null references features(feature),
        primary key (desc_id, feature)
        )
	EOS
    drop index if exists blazons_pkx 
	EOS
    create unique index blazons_pkx
        on blazons(blazon_id)
	EOS
    drop index if exists names_pkx 
	EOS
    create unique index names_pkx
        on names(name)
	EOS
    drop index if exists dates_pkx 
	EOS
    create unique index dates_pkx
        on dates(date)
	EOS
    drop index if exists kingdoms_pkx 
	EOS
    create unique index kingdoms_pkx
        on kingdoms(kingdom_id)
	EOS
    drop index if exists actions_pkx 
	EOS
    create unique index actions_pkx
        on actions(action_id)
	EOS
    drop index if exists registrations_pkx 
	EOS
    create unique index registrations_pkx
        on registrations(reg_id)
	EOS
    drop index if exists reg_owners_ix 
	EOS
    create index reg_owners_ix
        on registrations(owner_name)
	EOS
    drop index if exists reg_blazon_ix 
	EOS
    create index reg_blazon_ix
        on registrations(text_blazon_id)
	EOS
    drop index if exists reg_text_name_ix 
	EOS
    create index reg_text_name_ix
        on registrations(text_name)
	EOS
    drop index if exists reg_reg_date_ix 
	EOS
    create index reg_reg_date_ix
        on registrations(registration_date, registration_kingdom)
	EOS
    drop index if exists reg_rel_date_ix 
	EOS
    create index reg_rel_date_ix
        on registrations(release_date, release_kingdom)
	EOS
    drop index if exists reg_action_ix 
	EOS
    create index reg_action_ix
        on registrations(action)
	EOS
    drop index if exists notes_xpk 
	EOS
    create unique index notes_xpk
        on notes(note_id)
	EOS
    drop index if exists notes_note_name_ix 
	EOS
    create index notes_note_name_ix
        on notes(note_name)
	EOS
    drop index if exists registration_notes_xpk 
	EOS
    create unique index registration_notes_xpk
        on registration_notes(reg_id, note_id)
	EOS
    drop index if exists categories_xpk 
	EOS
    create unique index categories_xpk
        on categories(category)
	EOS
    drop index if exists category_headings_ix 
	EOS
    create index category_headings_ix
        on categories(heading, category)
	EOS
    drop index if exists feature_sets_xpk 
	EOS
    create unique index feature_sets_xpk
        on feature_sets(feature_set_name)
	EOS
    drop index if exists features_xpk 
	EOS
    create unique index features_xpk
        on features(feature)
	EOS
    drop index if exists features_feature_set_ix 
	EOS
    create index features_feature_set_ix
        on features(feature_set, feature)
	EOS
    drop index if exists descriptions_xpk 
	EOS
    create unique index descriptions_xpk
        on descriptions(desc_id)
	EOS
    drop index if exists descriptions_blazon_ix 
	EOS
    create index descriptions_blazon_ix
        on descriptions(blazon_id, category)
	EOS
    drop index if exists descriptions_category_ix 
	EOS
    create index descriptions_category_ix
        on descriptions(category, blazon_id)
	EOS
    drop index if exists desc_features_xpk 
	EOS
    create unique index desc_features_xpk
        on desc_features (desc_id, feature)
	EOS
	insert into names (name) 
	values ("")
	EOS
	insert into kingdoms (kingdom_id, kingdom_name_nominative, kingdom_name) 
	values ("","","")
	EOS
	insert into actions (action_id, action_description) 
	values ("","")
	EOS
	insert into dates (date, year, month) 
	values ("",0,0)
	EOS
EOSQL
}

=head1 NAME

Morsulus::Ordinary::Classic - The Ordinary database, classic style, in an RDBMS

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Instantiate the SCA Ordinary in an RDBMS. Structure is little changed from 
the flat file form.

Perhaps a little code snippet.

    use Morsulus::Ordinary::Classic;

    my $foo = Morsulus::Ordinary::Classic->new();
    ...

=head1 METHODS

=head2 Adding registrations to a database

=over 4

#       add_blazon
#       add_desc
#       add_feature
#       add_feature_set
#       add_name
#       add_note
#       get_blazon_registrations
#       get_next_reg_id
#       get_registration
#       process_feature
#       process_heading
#       process_legacy_record

=back


=head2 Setting up a database

The typical invocation to set up a database is:

    my $ord = Morsulus::Ordinary::Classic->new({dbfile => ...,
		db_flat_file => ...,
		category_file => ...,}).
	$ord->makeDB;

=over 4

=item makeDB

Assumes an empty or non-existent database file. 

Creates the tables and indexes.

Loads static data (kingdoms, dates, actions).

Loads the category file.

Loads registration data from the flat file.

=item load_kingdoms

Loads the kingdom reference data.

=item get_kingdoms

Returns a list of lists containing the kingdom codes and their long names.

=item load_actions

Loads the registration action reference data.

=item get_actions

Returns a list of lists containing the actions and their long name.

=item load_dates

Loads the date table with Ordinary style dates for referential integrity.
Dates are yyyymm.

=item load_categories

Loads categories (with headings), features, and feature_sets.

TODO: Load cross-references and feature relationships once the database
expands to support them

=item get_creates

Returns a list of SQL statements to create the tables and indexes. 

=item build_schema

Lazy loader for instantiating the schema attribute when needed.

=item build_dbh

Lazy loader for instantating the dbh attribute when needed.

=back

=head1 ATTRIBUTES

Attributes must be specified in the call to new(). 

=over 4

=item dbname

The name of the SQLite database file. You must provide a value.

=item category_file

The name of the Ordinary category file. Only needed for building a new
database.

=item db_flat_file

The name of the Ordinary flat file. Only needed for building a new database.
If you want to build an database with no registrations, /dev/null or any empty
file will work.

=item schema

The DBIx::Class::Schema object/connection to the database. 

You do not need to provide this; it will be generated at need.

=item dbh

The plain DBI dbh available for use.

You do not need to provide this; it will be generated at need.

=back

=head1 AUTHOR

Michael Houghton, C<< <herveus at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-morsulus-ordinary-classic at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Morsulus-Ordinary-Classic>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Morsulus::Ordinary::Classic


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Morsulus-Ordinary-Classic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Morsulus-Ordinary-Classic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Morsulus-Ordinary-Classic>

=item * Search CPAN

L<http://search.cpan.org/dist/Morsulus-Ordinary-Classic/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Michael Houghton.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

__PACKAGE__->meta->make_immutable;

1; # End of Morsulus::Ordinary::Classic
