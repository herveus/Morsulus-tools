use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Category

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<categories>

=cut

__PACKAGE__->table("categories");

=head1 ACCESSORS

=head2 category

  data_type: 'text'
  is_nullable: 0

=head2 heading

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "category",
  { data_type => "text", is_nullable => 0 },
  "heading",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</category>

=back

=cut

__PACKAGE__->set_primary_key("category");

=head1 RELATIONS

=head2 descriptions

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Description>

=cut

__PACKAGE__->has_many(
  "descriptions",
  "Morsulus::Ordinary::Classic::Schema::Result::Description",
  { "foreign.category" => "self.category" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FD7FnS8P1rdAd54oVZTN3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
