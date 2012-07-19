use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<registration_notes>

=cut

__PACKAGE__->table("registration_notes");

=head1 ACCESSORS

=head2 reg_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 note_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "reg_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "note_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</reg_id>

=item * L</note_id>

=back

=cut

__PACKAGE__->set_primary_key("reg_id", "note_id");

=head1 RELATIONS

=head2 note

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Note>

=cut

__PACKAGE__->belongs_to(
  "note",
  "Morsulus::Ordinary::Classic::Schema::Result::Note",
  { note_id => "note_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 reg

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->belongs_to(
  "reg",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { reg_id => "reg_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cMOo7Yn1HRsoghH/mI3xqg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
