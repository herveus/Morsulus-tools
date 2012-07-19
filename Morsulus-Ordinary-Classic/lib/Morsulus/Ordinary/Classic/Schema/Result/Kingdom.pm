use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Kingdom;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Kingdom

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<kingdoms>

=cut

__PACKAGE__->table("kingdoms");

=head1 ACCESSORS

=head2 kingdom_id

  data_type: 'text'
  is_nullable: 0

=head2 kingdom_name_nominative

  data_type: 'text'
  is_nullable: 0

=head2 kingdom_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "kingdom_id",
  { data_type => "text", is_nullable => 0 },
  "kingdom_name_nominative",
  { data_type => "text", is_nullable => 0 },
  "kingdom_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</kingdom_id>

=back

=cut

__PACKAGE__->set_primary_key("kingdom_id");

=head1 RELATIONS

=head2 kingdom_name

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->belongs_to(
  "kingdom_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { name => "kingdom_name" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 registrations_registration_kingdoms

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_registration_kingdoms",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.registration_kingdom" => "self.kingdom_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 registrations_release_kingdoms

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_release_kingdoms",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.release_kingdom" => "self.kingdom_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/WSPVu5Vh5i7w1TJ5J5ldg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
