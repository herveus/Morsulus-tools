use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::NoteWithNames;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::NoteWithNames

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<notes_with_names>

=cut

__PACKAGE__->table("notes_with_names");

=head1 ACCESSORS

=head2 note_regex

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("note_regex", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</note_regex>

=back

=cut

__PACKAGE__->set_primary_key("note_regex");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PKro0zwFoyPOc7J0PZZGpw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
