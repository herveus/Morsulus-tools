use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Feature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Feature

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<features>

=cut

__PACKAGE__->table("features");

=head1 ACCESSORS

=head2 feature

  data_type: 'text'
  is_nullable: 0

=head2 feature_set

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "feature",
  { data_type => "text", is_nullable => 0 },
  "feature_set",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</feature>

=back

=cut

__PACKAGE__->set_primary_key("feature");

=head1 RELATIONS

=head2 desc_features

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::DescFeature>

=cut

__PACKAGE__->has_many(
  "desc_features",
  "Morsulus::Ordinary::Classic::Schema::Result::DescFeature",
  { "foreign.feature" => "self.feature" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feature_set

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::FeatureSet>

=cut

__PACKAGE__->belongs_to(
  "feature_set",
  "Morsulus::Ordinary::Classic::Schema::Result::FeatureSet",
  { feature_set_name => "feature_set" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 descs

Type: many_to_many

Composing rels: L</desc_features> -> desc

=cut

__PACKAGE__->many_to_many("descs", "desc_features", "desc");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fdkswUQpamp08kM9TRgmEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
