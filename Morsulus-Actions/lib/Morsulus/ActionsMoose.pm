package Morsulus::ActionsMoose;

use warnings;
use strict;
use Carp;

our $VERSION = '2012.005.003';
use Daud
use Moose;
use namespace::autoclean;

has 'action' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'cooked_action' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'source' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'name' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'armory' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'quoted_names' => (
	isa => 'ArrayRef[Str]',
	is => 'ro',
	default => sub { [] },
	);
	
has 'second_name' => (
	isa => 'Str',
	is => 'rw',
	);
	
has 'notes' => (
	isa => 'Str',
	is => 'rw',
	);
	
my $SEPARATOR => q{|};
my $EMPTY_STR => q{};
my $PERIOD    => q{.};
my $NEWLINE => qq{\n};
my $SPACE => qr/[ ]/;
my $BRANCH => qr/(?: Kingdom | Principality | Barony |
        Province | Region | Shire | Canton | Stronghold | Port |
        College | Crown $SPACE Province | March | Dominion | Barony-Marche )/xms;

# overload "" to stringify

# BUILD process...
# call to new gives action, source, name, armory, name2, notes
# action goes into raw_form_of_action
# source, name, armory, name2, notes
sub BUILD
{
	my $self = shift;
	my $args = shift;
	$self->action(Daud::daudify($self->action()));
	$self->name(Daud::daudify($self->name()));
	$self->armory(Daud::daudify($self->armory()));
	$self->second_name(Daud::daudify($args->{name2} || $EMPTY_STR));
	
	# clean up the raw action
	my $action = $self->action;
	$action =~ s{[ ][(]see[^)]+[)]\z}{}xsmi;
	if ( $action =~ m{\A([^(]+)[ ]([(]important[ ]non-sca[ ].+[)])\z}ixsm )
    {
		$action = $1;
		$self->notes($self->notes . $2);
	}
	$action =~ s{\s+\z}{}xsm;
	$self->cooked_action($action);
	
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
	my $cooked_form = $self->cooked_action;
	if ($cooked_form =~ m/[Hh]eraldic $SPACE title $SPACE (.+
		$SPACE (?:Herald|Pursuivant) (?:$SPACE Extraordinary)?)
		/xsm)
	{
		my $title = $1;
		$cooked_form =~ s/$title/"$title"/ if $title !~ /"/;
		$cooked_action($cooked_form);
	}	
}

sub bracket_names
{
	my $self = shift;
	
}

__PACKAGE__->meta->make_immutable;
1;

__END__

