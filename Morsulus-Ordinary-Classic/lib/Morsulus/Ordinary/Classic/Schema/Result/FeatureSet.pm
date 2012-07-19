use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::FeatureSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::FeatureSet

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<feature_sets>

=cut

__PACKAGE__->table("feature_sets");

=head1 ACCESSORS

=head2 feature_set_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("feature_set_name", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</feature_set_name>

=back

=cut

__PACKAGE__->set_primary_key("feature_set_name");

=head1 RELATIONS

=head2 features

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Feature>

=cut

__PACKAGE__->has_many(
  "features",
  "Morsulus::Ordinary::Classic::Schema::Result::Feature",
  { "foreign.feature_set" => "self.feature_set_name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:85WArA0yUQvLQOnmmalSEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
