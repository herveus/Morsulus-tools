package Morsulus::ActionsMoose;

use warnings;
use strict;
use Carp;

our $VERSION = '2012.005.003';
use Daud;
use Moose;
use namespace::autoclean;

has 'action_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'cooked_action_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'source_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'name_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'armory_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'quoted_names_of' => (
	isa => 'ArrayRef[Str]',
	is => 'ro',
	default => sub { [] },
	);
	
has 'second_name_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'notes_of' => (
	isa => 'Str',
	is => 'rw',
	);
	
my $SEPARATOR = q{|};
my $EMPTY_STR = q{};
my $PERIOD    = q{.};
my $NEWLINE = qq{\n};
my $SPACE = qr/[ ]/;
my $BRANCH = qr/(?: Kingdom | Principality | Barony |
        Province | Region | Shire | Canton | Stronghold | Port |
        College | Crown $SPACE Province | March | Dominion | Barony-Marche )/xms;

# overload "" to stringify
use overload
    '""' => 'as_str';

sub as_str
{
    my ( $self, $other, $swap ) = @_;
    return join $SEPARATOR, $self->raw_form_of,
        $self->cooked_form_of, $self->source_of, $self->name_of,
        $self->armory_of, $self->second_name_of,
        @{ $self->quoted_names_of}, $self->notes_of;
}

# BUILD process...
# call to new gives action, source, name, armory, name2, notes
# action goes into raw_form_of_action
# source, name, armory, name2, notes
sub BUILD
{
	my $self = shift;
	my $args = shift;
	$self->action_of(Daud::daudify($args->{action}));
	$self->name_of(Daud::daudify($args->{name}));
	$self->armory_of(Daud::daudify($args->{armory}));
	$self->second_name_of(Daud::daudify($args->{name2} || $EMPTY_STR));
	$self->notes_of($args->{notes} || $EMPTY_STR);
	$self->source_of($args->{source});
	
	# clean up the raw action
	my $action = $self->action_of;
	$action =~ s{[ ][(]see[^)]+[)]\z}{}xsmi;
	if ( $action =~ m{\A([^(]+)[ ]([(]important[ ]non-sca[ ].+[)])\z}ixsm )
    {
		$action = $1;
		$self->notes_of($self->notes_of . $2);
	}
	$action =~ s{\s+\z}{}xsm;
	$self->cooked_action_of($action);
	
	$self->quote_names;
	$self->extract_quoted_names();
	$self->bracket_names();
	$self->normalize_cooked_action();
	$self->normalize_armory();
}

sub quote_names
{
	my $self = shift;
	# look over the cooked form for unquoted heraldic titles
	my $cooked_form = $self->cooked_action_of;
	if ($cooked_form =~ m/[Hh]eraldic $SPACE title $SPACE (.+
		$SPACE (?:Herald|Pursuivant) (?:$SPACE Extraordinary)?)
		/xsm)
	{
		my $title = $1;
		$cooked_form =~ s/$title/"$title"/ if $title !~ /"/;
		$self->cooked_action_of($cooked_form);
	}	
}

sub extract_quoted_names {
    my $self = shift;
    push @{$self->quoted_names_of},
        $self->cooked_action_of =~ m{ " ([^"]+) " }gxsm;
}

sub bracket_names
{
	my $self = shift;
	$self->name_of($self->bracket_name($self->name_of));
	$self->second_name_of($self->bracket_name($self->second_name_of));
	for (@{$self->quoted_names_of})
	{
	    $_ = $self->bracket_name($_);
	}
}

sub bracket_name
{
    my $self = shift;
    my ($q_name) = @_;
    if ($q_name =~ m/($SPACE 
        (?: Herald | Pursuivant | King $SPACE of $SPACE Arms | Herault | Herold) 
        (?: $SPACE Extraordinary)?)/xms)
    {
        my $title = $1;
        $q_name =~ s/$title/<$title>/;
    }
    elsif ($q_name =~ m/\A(.+)(, $SPACE $BRANCH (?: $SPACE of )? )\z/xms)
    {
        my $name = $1;
        my $branch = $2;
        return $q_name if $name eq 'Atenveldt';
        $q_name =~ s/$branch/<$branch>/;
    }
    elsif ($q_name =~ m/,( $SPACE $BRANCH (?: $SPACE of )? ) $SPACE ( the | La )\z/xms)
    {
        my $branch = $1;
        my $article = $2;
        $q_name =~ s/$branch/<$branch>/;
    }
    elsif ($q_name =~ m/\A ($BRANCH (?: $SPACE of (?: $SPACE the)? )? )$SPACE (.+)\z/xms)
    {
        my $branch = $1;
        my $name = $2;
        if ($branch =~ /the\z/)
        {
            $branch =~ s/ the\z//;
            $q_name = "$name,< $branch> the";
        }
        else
        {
            $q_name = "$name<, $branch>";
        }
    }
    return $q_name;
}

sub normalize_cooked_action {
    my $self = shift;
    my $cooked_form = $self->cooked_action_of;
    $cooked_form =~ s{"[^"]+"}{"x"}gxsm;
    $cooked_form = lc $cooked_form;
    $cooked_form =~ s{acceptance\ of\ transfer\ of\ (.+)\ from\ "x"}{$1}xsm;
    $self->cooked_action_of($cooked_form);
}

sub normalize_armory {
    my $self = shift;
    my $armory = $self->armory_of or return;
    $armory =~ s{\A\s+}{}xsm;
    $armory =~ s{\s+\Z}{}xsm;
    $armory =~ s{\s{2,}}{ }xsmg;
    $armory .= $PERIOD unless $armory =~ /$PERIOD$/;
    $self->armory_of($armory);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

