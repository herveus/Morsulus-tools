use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Description;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Description

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<descriptions>

=cut

__PACKAGE__->table("descriptions");

=head1 ACCESSORS

=head2 desc_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 category

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 blazon_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "desc_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "category",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "blazon_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</desc_id>

=back

=cut

__PACKAGE__->set_primary_key("desc_id");

=head1 RELATIONS

=head2 blazon

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Blazon>

=cut

__PACKAGE__->belongs_to(
  "blazon",
  "Morsulus::Ordinary::Classic::Schema::Result::Blazon",
  { blazon_id => "blazon_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 category

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Morsulus::Ordinary::Classic::Schema::Result::Category",
  { category => "category" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 desc_features

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::DescFeature>

=cut

__PACKAGE__->has_many(
  "desc_features",
  "Morsulus::Ordinary::Classic::Schema::Result::DescFeature",
  { "foreign.desc_id" => "self.desc_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 features

Type: many_to_many

Composing rels: L</desc_features> -> feature

=cut

__PACKAGE__->many_to_many("features", "desc_features", "feature");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3pIOUK/5iz7rv8Eleu6QUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
