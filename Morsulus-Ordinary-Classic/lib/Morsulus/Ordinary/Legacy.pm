package Morsulus::Ordinary::Legacy;

use Moose;
use namespace::autoclean;

has 'name' => ( is => 'rw' );
has 'source' => ( is => 'rw' );
has 'type' => ( is => 'rw' );
has 'text' => ( is => 'rw' );
has 'notes' => ( is => 'rw' );
has 'descs' => ( is => 'rw' );

my %blazon_types = (
    'a' => 1,
    'b' => 1,
    'D?' => 1,
    'd' => 1,
    'g' => 1,
    't' => 0,
    's' => 1,
    'N' => 0,
    'BN' => 0,
    'O' => 0,
    'OC' => 0,
    'AN' => 0,
    'ANC' => 0,
    'NC' => 0,
    'Nc' => 0,
    'BNC' => 0,
    'BNc' => 0,
    'HN' => 0,
    'HNC' => 0,
    'C' => 0,
    'j' => 0,
    'u' => 0,
    'v' => 0,
    'Bv' => 0,
    'vc' => 0,
    'Bvc' => 0,
    'R' => 0,
    'D' => 1,
    'BD' => 1,
    'B' => 1,
    );
sub from_string
{
    my $self = shift;
    my $db_string = shift;
    chomp $db_string;
    my ($name, $source, $type, $text, $notes, $descs) = split(/\|/, $db_string, 6);
    my $entry = $self->new(name => $name, source => $source, 
        type => $type,
        text => $text, notes => $notes, descs => $descs);
    return $entry;
}

sub to_string
{
    my $self = shift;
    my $string = join('|', $self->name, $self->source, $self->type,
        $self->text, $self->notes);
    $string .= '|'.$self->descs if $self->descs;
    return $string;
}

sub has_blazon
{
    my $self = shift;
    return $blazon_types{$self->type};
    #return $self->type ~~ [qw/a b d g s B D BD D?/];
}

sub is_historical
{
    my $self = shift;
    return $self->source =~ /-/;
}

sub parse_source
{
    my $self = shift;
    my ($reg, $rel) = split(/-/, $self->source);
    my @parts = (undef, undef, undef, undef);
    if (defined $reg)
    {
        $reg =~ /^([0-9]{6})([A-Za-z])?$/;
        $parts[0] = $1;
        $parts[1] = $2;
    }
    if (defined $rel)
    {
        $rel =~ /^([0-9]{6})([A-Za-z])?$/;
        $parts[2] = $1;
        $parts[3] = $2;
    }
    return @parts;
}

sub split_descs
{
    my $self = shift;
    return split(/\|/, $self->descs);
}

sub split_notes
{
    my $self = shift;
    return unless $self->notes;
    my $pad = $self->notes;
    $pad =~ s/^.(.+).$/$1/;
    return split(/\)\(/, $pad);
}

__PACKAGE__->meta->make_immutable;
1;
