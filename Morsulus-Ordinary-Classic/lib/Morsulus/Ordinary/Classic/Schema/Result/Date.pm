use utf8;
package Morsulus::Ordinary::Classic::Schema::Result::Date;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Morsulus::Ordinary::Classic::Schema::Result::Date

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<dates>

=cut

__PACKAGE__->table("dates");

=head1 ACCESSORS

=head2 date

  data_type: 'text'
  is_nullable: 0

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 month

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "date",
  { data_type => "text", is_nullable => 0 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "month",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</date>

=back

=cut

__PACKAGE__->set_primary_key("date");

=head1 RELATIONS

=head2 registrations_registration_dates

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_registration_dates",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.registration_date" => "self.date" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 registrations_release_dates

Type: has_many

Related object: L<Morsulus::Ordinary::Classic::Schema::Result::Registration>

=cut

__PACKAGE__->has_many(
  "registrations_release_dates",
  "Morsulus::Ordinary::Classic::Schema::Result::Registration",
  { "foreign.release_date" => "self.date" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-17 19:27:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TgaxTVuHSauXCDrXCC9U/g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
