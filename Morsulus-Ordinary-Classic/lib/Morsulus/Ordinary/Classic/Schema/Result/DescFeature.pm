use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::DescFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::DescFeature

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<desc_features>

=cut

__PACKAGE__->table("desc_features");

=head1 ACCESSORS

=head2 desc_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 feature

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "desc_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "feature",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</desc_id>

=item * L</feature>

=back

=cut

__PACKAGE__->set_primary_key("desc_id", "feature");

=head1 RELATIONS

=head2 desc

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Description>

=cut

__PACKAGE__->belongs_to(
  "desc",
  "Morsulus::Ordinary::Classic::Schema::Result::Description",
  { desc_id => "desc_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 feature

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Feature>

=cut

__PACKAGE__->belongs_to(
  "feature",
  "Morsulus::Ordinary::Classic::Schema::Result::Feature",
  { feature => "feature" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aGTzOGyJFKYwsnt6lg/TBg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
