use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Action;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Action

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<actions>

=cut

__PACKAGE__->table("actions");

=head1 ACCESSORS

=head2 action_id

  data_type: 'text'
  is_nullable: 0

=head2 action_description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "action_id",
  { data_type => "text", is_nullable => 0 },
  "action_description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</action_id>

=back

=cut

__PACKAGE__->set_primary_key("action_id");

=head1 RELATIONS

=head2 registrations

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.action" => "self.action_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dw56oYp2w/aBraRpycf1Yw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
