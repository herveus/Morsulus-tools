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

=head2 unpermuted_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "unpermuted_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 UNIQUE CONSTRAINTS

=head2 C<unpermuted_name_unique>

=over 4

=item * L</unpermuted_name>

=back

=cut

__PACKAGE__->add_unique_constraint("unpermuted_name_unique", ["unpermuted_name"]);

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

=head2 name

Type: might_have

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->might_have(
  "base_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { "foreign.unpermuted_name" => "self.name" },
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

=head2 registrations_reg_owner_names

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_reg_owner_names",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.reg_owner_name" => "self.name" },
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

=head2 unpermuted_name

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->belongs_to(
  "unpermuted_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { name => "unpermuted_name" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-01 13:08:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ieutZY5M9vlC6C2oKWYvdw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
