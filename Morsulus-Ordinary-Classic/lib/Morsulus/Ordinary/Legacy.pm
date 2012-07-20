package Morsulus::Ordinary::Legacy;

use 5.14.0;
use Moose;
use namespace::autoclean;

has 'name' => ( is => 'rw' );
has 'source' => ( is => 'rw' );
has 'type' => ( is => 'rw' );
has 'text' => ( is => 'rw' );
has 'notes' => ( is => 'rw' );
has 'descs' => ( is => 'rw' );

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
    return $self->type ~~ [qw/a b d g s B D BD/];
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
    my @parts;
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
