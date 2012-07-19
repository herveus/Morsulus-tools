use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Name;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Name

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<names>

=cut

__PACKAGE__->table("names");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("name", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 kingdoms

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Kingdom>

=cut

__PACKAGE__->has_many(
  "kingdoms",
  "Morsulus::Ordinary::Classic::Schema::Result::Kingdom",
  { "foreign.kingdom_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 notes

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Note>

=cut

__PACKAGE__->has_many(
  "notes",
  "Morsulus::Ordinary::Classic::Schema::Result::Note",
  { "foreign.note_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 registrations_owner_names

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_owner_names",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.owner_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 registrations_text_names

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_text_names",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.text_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q/0MjPjQKBWYxVLZHy/e/g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
