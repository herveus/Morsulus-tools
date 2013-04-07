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

sub canonicalize
{
    my $self = shift;
    $self->descs(join('|', sort $self->split_descs));
    $self->notes('('.join(')(', sort $self->split_notes).')') if $self->notes;
    return $self;
}

sub has_blazon
{
    my $self = shift;
    return $blazon_types{$self->type};
    #return $self->type ~~ [qw/a b d g s B D BD D?/];
}

sub registers_name
{
    my $self = shift;
    return $self->type ~~ [qw/N BN O OC AN ANC NC BNC Nc BNc HN HNC u D BD D/];
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
    my @parts = ('', '', '', '');
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

sub make_source
{
    my $self = shift;
    my @parts = @_;
    die "too many pieces in make_source" if @parts > 4;
    my $source = '';
    if ($parts[0])
    {
        $parts[0] =~ /^[0-9]{6}$/ or die "malformed registration date (yyyymm)";
        $source .= $parts[0];
    }
    if ($parts[1])
    {
        $parts[1] =~ /^[A-Za-z]$/ or die "malformed registration kingdom";
        $source .= $parts[1];
    }
    $source .= '-' if ($parts[2] || $parts[3]);
    if ($parts[2])
    {
        $parts[2] =~ /^[0-9]{6}$/ or die "malformed release date (yyyymm)";
        $source .= $parts[2];
    }
    if ($parts[3])
    {
        $parts[3] =~ /^[A-Za-z]$/ or die "malformed release kingdom";
        $source .= $parts[3];
    }
    $self->source($source);
}

sub set_reg_date
{
    my $self = shift;
    my ($date) = @_;
    $date =~ /^[0-9]{6}$/ or die "malformed date (yyyymm)";
    my @parts = $self->parse_source;
    $parts[0] = $date;
    $self->make_source(@parts);
}

sub set_rel_date
{
    my $self = shift;
    my ($date) = @_;
    $date =~ /^[0-9]{6}$/ or die "malformed date (yyyymm)";
    my @parts = $self->parse_source;
    $parts[2] = $date;
    $self->make_source(@parts);
}

sub set_reg_kingdom
{
    my $self = shift;
    my ($kingdom) = @_;
    $kingdom =~ /^[A-Za-z]$/ or die "malformed kingdom";
    my @parts = $self->parse_source;
    $parts[1] = $kingdom;
    $self->make_source(@parts);
}

sub set_rel_kingdom
{
    my $self = shift;
    my ($kingdom) = @_;
    $kingdom =~ /^[A-Za-z]$/ or die "malformed kingdom";
    my @parts = $self->parse_source;
    $parts[3] = $kingdom;
    $self->make_source(@parts);
}

sub split_descs
{
    my $self = shift;
    return unless defined $self->descs;
    return split(/\|/, $self->descs);
}

sub add_descs
{
    my $self = shift;
    my (@descs) = @_;
    $self->descs(join('|', $self->split_descs, @descs));
}

sub split_notes
{
    my $self = shift;
    return unless defined $self->notes;
    my $pad = $self->notes;
    $pad =~ s/^.(.+).$/$1/;
    return split(/\)\(/, $pad);
}

sub add_notes
{
    my $self = shift;
    my (@notes) = @_;
    $self->notes($self->notes . 
        join('', map {"($_)"} @notes));
}

__PACKAGE__->meta->make_immutable;
1;
