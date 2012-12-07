use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Registration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Registration

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<registrations>

=cut

__PACKAGE__->table("registrations");

=head1 ACCESSORS

=head2 reg_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 reg_owner_name

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 0

=head2 registration_date

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 release_date

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 registration_kingdom

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 release_kingdom

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 action

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 text_blazon_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 text_name

  data_type: 'text'
  default_value: (empty string)
  is_foreign_key: 1
  is_nullable: 1

=head2 owner_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "reg_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "reg_owner_name",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "registration_date",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "release_date",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "registration_kingdom",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "release_kingdom",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "action",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "text_blazon_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "text_name",
  {
    data_type      => "text",
    default_value  => "",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "owner_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</reg_id>

=back

=cut

__PACKAGE__->set_primary_key("reg_id");

=head1 RELATIONS

=head2 action

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Action>

=cut

__PACKAGE__->belongs_to(
  "action",
  "Morsulus::Ordinary::Classic::Schema::Result::Action",
  { action_id => "action" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 owner

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Owner>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "Morsulus::Ordinary::Classic::Schema::Result::Owner",
  { owner_id => "owner_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 reg_owner_name

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->belongs_to(
  "reg_owner_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { name => "reg_owner_name" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 registration_date

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Date>

=cut

__PACKAGE__->belongs_to(
  "registration_date",
  "Morsulus::Ordinary::Classic::Schema::Result::Date",
  { date => "registration_date" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 registration_kingdom

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Kingdom>

=cut

__PACKAGE__->belongs_to(
  "registration_kingdom",
  "Morsulus::Ordinary::Classic::Schema::Result::Kingdom",
  { kingdom_id => "registration_kingdom" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 registration_notes

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote>

=cut

__PACKAGE__->has_many(
  "registration_notes",
  "Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote",
  { "foreign.reg_id" => "self.reg_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 release_date

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Date>

=cut

__PACKAGE__->belongs_to(
  "release_date",
  "Morsulus::Ordinary::Classic::Schema::Result::Date",
  { date => "release_date" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 release_kingdom

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Kingdom>

=cut

__PACKAGE__->belongs_to(
  "release_kingdom",
  "Morsulus::Ordinary::Classic::Schema::Result::Kingdom",
  { kingdom_id => "release_kingdom" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 text_blazon

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Blazon>

=cut

__PACKAGE__->belongs_to(
  "text_blazon",
  "Morsulus::Ordinary::Classic::Schema::Result::Blazon",
  { blazon_id => "text_blazon_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 text_name

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->belongs_to(
  "text_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { name => "text_name" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 notes

Type: many_to_many

Composing rels: L</registration_notes> -> note

=cut

__PACKAGE__->many_to_many("notes", "registration_notes", "note");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-01 13:08:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rjR078sSZoiNRlFA50lMZw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
