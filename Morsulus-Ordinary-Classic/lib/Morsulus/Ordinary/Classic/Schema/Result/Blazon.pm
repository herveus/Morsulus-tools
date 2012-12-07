use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Blazon;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Blazon

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<blazons>

=cut

__PACKAGE__->table("blazons");

=head1 ACCESSORS

=head2 blazon_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 blazon

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "blazon_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "blazon",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</blazon_id>

=back

=cut

__PACKAGE__->set_primary_key("blazon_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<blazon_unique>

=over 4

=item * L</blazon>

=back

=cut

__PACKAGE__->add_unique_constraint("blazon_unique", ["blazon"]);

=head1 RELATIONS

=head2 descriptions

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Description>

=cut

__PACKAGE__->has_many(
  "descriptions",
  "Morsulus::Ordinary::Classic::Schema::Result::Description",
  { "foreign.blazon_id" => "self.blazon_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 registrations

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.text_blazon_id" => "self.blazon_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4AXpxacnhDY66+ql5WYsgA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
