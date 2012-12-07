use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Owner;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Owner

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<owners>

=cut

__PACKAGE__->table("owners");

=head1 ACCESSORS

=head2 owner_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 owner_name

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 owner_name_date

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 owner_name_ordinal

  data_type: 'text'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "owner_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "owner_name",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "owner_name_date",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "owner_name_ordinal",
  { data_type => "text", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</owner_id>

=back

=cut

__PACKAGE__->set_primary_key("owner_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<owner_name_owner_name_date_owner_name_ordinal_unique>

=over 4

=item * L</owner_name>

=item * L</owner_name_date>

=item * L</owner_name_ordinal>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "owner_name_owner_name_date_owner_name_ordinal_unique",
  ["owner_name", "owner_name_date", "owner_name_ordinal"],
);

=head1 RELATIONS

=head2 registrations

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.owner_id" => "self.owner_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uEJn8uUdiRlbR60HeWA/Pg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
