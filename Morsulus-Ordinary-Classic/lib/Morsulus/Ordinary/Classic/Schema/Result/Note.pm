use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Note;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Note

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<notes>

=cut

__PACKAGE__->table("notes");

=head1 ACCESSORS

=head2 note_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 note_text

  data_type: 'text'
  is_nullable: 0

=head2 note_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "note_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "note_text",
  { data_type => "text", is_nullable => 0 },
  "note_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</note_id>

=back

=cut

__PACKAGE__->set_primary_key("note_id");

=head1 RELATIONS

=head2 note_name

Type: belongs_to

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Name>

=cut

__PACKAGE__->belongs_to(
  "note_name",
  "Morsulus::Ordinary::Classic::Schema::Result::Name",
  { name => "note_name" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 registration_notes

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote>

=cut

__PACKAGE__->has_many(
  "registration_notes",
  "Morsulus::Ordinary::Classic::Schema::Result::RegistrationNote",
  { "foreign.note_id" => "self.note_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 regs

Type: many_to_many

Composing rels: L</registration_notes> -> reg

=cut

__PACKAGE__->many_to_many("regs", "registration_notes", "reg");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-11-29 18:05:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wTzwBLP/KHV7CoAnQw6b6A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
