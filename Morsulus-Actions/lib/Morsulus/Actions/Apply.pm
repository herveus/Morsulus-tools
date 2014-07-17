package Morsulus::Actions::Apply;
use warnings;
use strict;
use Carp;

use Moose;
extends 'Morsulus::Actions';

our $VERSION = '2014.006.001';

has 'db' => (
    isa => 'Morsulus::Ordinary::Classic',
    is => 'ro',
    );

sub kingdom_of
{
    my $self = shift;
    if ($self->source_of =~ /^[0-9]{6}(.+)$/)
    {
        return $1;
    }
    return;
}

sub date_of
{
    my $self = shift;
    if ($self->source_of =~ /^([0-9]{6})(.+)?$/)
    {
        return $1;
    }
    return;
}

my %transforms = get_transforms();

my $SEPARATOR = q{|};
my $EMPTY_STR = q{};
my $PERIOD    = q{.};
my $NEWLINE = qq{\n};
my $SPACE = qr/[ ]/;
my $BRANCH = qr/(?: Kingdom | Principality | Barony |
        Province | Region | Shire | Canton | Stronghold | Port |
        College | Crown $SPACE Province | March | Dominion | Barony-Marche )/xms;

sub is_name_registered
{
    my $self = shift;
    my ($name, $types) = @_;
    if (ref($types) ne 'ARRAY')
    {
        $types = [ $types ];
    }
    my @regs = $self->db->Registration->search({
        reg_owner_name => $name,
        action => { '-in' => $types },
        release_kingdom => '',
        release_date => '',
        })->all;
    return @regs > 0;
}

sub is_primary_name_registered
{
    my $self = shift;
    my ($name) = @_;
    return $self->is_name_registered($name, ['N','BN','D','B','BD']);
}

sub is_armory_registered
{
    my $self = shift;
    my ($blazon) = @_;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        'text_blazon.blazon' => $blazon,
        },
        {
            join => 'text_blazon',
        });
    return @regs > 0;
}

sub is_armory_registered_as
{
    my $self = shift;
    my ($blazon, $type) = @_;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        action => $type,
        'text_blazon.blazon' => $blazon,
        },
        {
            join => 'text_blazon',
        });
    return @regs > 0;
}

sub normalize_cooked_action {
    my $self = shift;
    my $cooked_form = $self->cooked_action_of;
    $cooked_form =~ s{"[^"]+"}{"x"}gxsm;
    $cooked_form = lc $cooked_form;
    $self->cooked_action_of($cooked_form);
}

sub NAME_FOR_ARMORY_REG 
{
    my ($self) = @_;
    if (!$self->is_primary_name_registered($self->name_of))
    {
        die "Name for armory not registered: ".$self->name_of.":".$self->as_str;
    }
}

sub NAME_FOR_OWNED_NAME_REG 
{
    my ($self) = @_;
    if (!$self->is_primary_name_registered($self->name_of))
    {
        die "Name for owned name not registered: ".$self->name_of.":".$self->as_str;
    }
}

sub OWNED_NAME_NOT_REG
{
    my ($self, $type) = @_;
    my $owned_name = $self->permute($self->quoted_names_of->[0]);
    if ($self->is_name_registered($owned_name, [ $type ]))
    {
        die "Owned name already registered: $owned_name:".$self->as_str;
        # may need to refine this; what if title == household name? type should cover
    }
}

sub OWNED_NAME2_NOT_REG
{
    my ($self, $type) = @_;
    my $owned_name = $self->permute($self->quoted_names_of->[1]);
    if ($self->is_name_registered($owned_name, [ $type ]))
    {
        die "Owned name already registered: $owned_name:".$self->as_str;
        # may need to refine this; what if title == household name? type should cover
    }
}

sub OWNED_NAME_REG
{
    my ($self, $type) = @_;
    my $owned_name = $self->permute($self->quoted_names_of->[0]);
    if (!$self->is_name_registered($owned_name, [ $type ]))
    {
        die "Owned name is not registered: $owned_name:".$self->as_str;
        # may need to refine this; what if title == household name? type should cover
    }
}

sub OWNED_NAME2_REG
{
    my ($self, $type) = @_;
    my $owned_name = $self->permute($self->quoted_names_of->[1]);
    if (!$self->is_name_registered($owned_name, [ $type ]))
    {
        die "Owned name is not registered: $owned_name:".$self->as_str;
        # may need to refine this; what if title == household name? type should cover
    }
}

sub NAME_NOT_REG
{
    my ($self, $type) = @_;
    if ($self->is_name_registered($self->name_of, [ $type ]))
    {
        die "Name already registered: ".$self->name_of.":".$self->as_str;
    }
}

sub NAME_REG
{
    my ($self, $type) = @_;
    if (!$self->is_name_registered($self->name_of, [ $type ]))
    {
        die "Name is not registered: ".$self->name_of.":".$self->as_str;
    }
}

sub PRIMARY_OWNER_NAME_NOT_REG
{
    my ($self) = @_;
    if (!$self->is_name_registered($self->name_of, [ 'N' ]))
    {
        die "Primary owner name not registered: ".$self->name_of.":".$self->as_str;
    }
}

sub SECONDARY_OWNER_NAME_NOT_REG
{
    my ($self) = @_;
    if (!$self->is_name_registered($self->quoted_names_of->[0], [ 'N' ]))
    {
        die "Secondary owner name not registered: ".$self->quoted_names_of->[0].":".$self->as_str;
    }
}

sub ARMORY_NOT_REG
{
    my ($self) = @_;
    if ($self->is_armory_registered($self->armory_of))
    {
        die "Armory already registered: ".$self->as_str;
    }
}

sub ARMORY_REG
{
    my ($self) = @_;
    if (!$self->is_armory_registered($self->armory_of))
    {
        die "Armory not registered: ".$self->as_str;
    }
}

sub get_transforms
{
my %transforms = (
    'acceptance of badge transfer from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'armory' => [ 'b' ] },
    'acceptance of badge transfer for "x" from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'badge_for' => [] },
    '-acceptance of badge transfer from "x" and designation as for "x"' => { 'badge_for_2' => [] },
    'acceptance of device transfer from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'armory' => [ 'd' ], },
    'acceptance of transfer of heraldic title "x" from "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'name_owned_by' => [ 't' ] },
    '-acceptance of order name transfer "x" from "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ] },
    '-acceptance of transfer of household name "x" and badge from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'ARMORY_NOT_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ],
        'badge_for' => [], },
    'acceptance of transfer of household name "x" from "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ], },
    '-acceptance of household name transfer "x" from "x" as branch name' => { 'NAME_NOT_REG' => [ 'BN' ],
        'name' => [ 'BN' ], },
    '-acceptance of transfer of alternate name "x" and badge from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_owned_by' => [ 'AN' ],
        'badge_for' => [], },
    '-addition of joint owner "x" for badge' => { 'PRIMARY_OWNER_NAME_NOT_REG' => [],
        'SECONDARY_OWNER_NAME_NOT_REG' => [],
        'joint' => [], 
        'joint_badge' => [] },
    'addition of joint owner "x" of household badge for "x"' => { 'NAME_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'OWNED_NAME2_REG' => [ 'HN' ],
        'joint' => [], 
        'joint_badge' => [] ,
        'armory_release' => [ 'b', 'joint owner added' ],},
    'alternate name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_for' => [ 'AN' ], 
        'badge_for' => [] },
    '-alternate name "x" and badge association' => { 'NAME_FOR_ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_for' => [ 'AN' ], 
        'badge_for' => [],
        'armory_release' => [ 'b', 'associated with alternate name' ],},
    'alternate name "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_for' => [ 'AN' ] },
    '-alternate name change from "x" to "x"' => { 'order_name_change' => [ 'ANC' ], },
    '-alternate name correction to "x" from "x"' => { 'owned_name_correction' => [ 'Nc' ], },
    'alternate name reconsideration to "x" from "x"' => { 'NAME_REG' => [ 'N' ],
        'OWNED_NAME2_REG' => [ 'AN' ],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'owned_name_correction_reversed' => [ 'AN' ], },
    '-ancient arms' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b' , 'Ancient Arms' ], },
    '-arms' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'd' ], },
    '-arms reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'reblazoned' ] },
    '-association of alternate name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'associated with alternate name' ],
        'badge_for' => [],},
    '-association of household name "x" and badge' => {  'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'associated with household name' ],
        'badge_for' => [],},
    '-augmentation change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'a' ], },
    '-augmentation changed/released' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'a', 'changed/released' ] },
    '-augmentation reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'a', 'reblazoned' ] },
    'augmentation' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'a' ], },
    'augmentation of arms' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'a' ], },
    '-award name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ], 
        'armory' => [ 'b' ], },
    '-award name "x" and badge association' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    '-award name "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ] },
    '-badge and association with order name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [ ] },
    'badge association with award name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with award name' ], },
    'badge association with alternate name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with alternate name' ], },
    'badge association for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with usage' ],
        'reference' => [ ], },
    '-badge association with "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with usage' ],
        'reference' => [ ], },
    '-badge association with guild name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with guild name' ], 
        'reference' => [ ] },
    '-badge association with order name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    'badge change' => { 'NAME_FOR_ARMORY_REG' => [],,
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b' ], },
    '-badge change and association for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ],
        'armory_release' => [ 'b', 'associated with order name' ],},
    'badge changed/released' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'changed/released' ] },
    '-badge correction' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'corrected blazon' ] },
    'badge for alternate name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [] },
    'badge for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [] },
    'badge change for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [] },
    '-badge for "x" reference' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [ ],
        'reference' => [ ],},
    '-badge for the "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [ "the " ] },
    'badge reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'reblazoned' ] },
    '-badge for the "x" reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'reblazoned' ] },
    'badge for "x" reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'reblazoned' ] },
    '-badge release' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'released' ] },
    '-badge transfer to "x"' => {  'transfer_armory' => [ 'b', ], },
    'badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b' ], },
    'blanket permission to conflict with alternate name "x"' => { 'OWNED_NAME_REG' => [ 'AN' ],
        'blanket_permission_secondary_name' => [ 'AN', 'alternate name' ], },
    'blanket permission to conflict with badge' => { 'ARMORY_REG' => [],
        'blanket_permission_armory' => [ 'b', 'badge' ], },
    'blanket permission to conflict with badge for alternate name "x"' => { 'ARMORY_REG' => [],
        'blanket_permission_armory' => [ 'b', 'badge' ], },
    '-blanket permission to conflict with device "x"' => { 'ARMORY_REG' => [],
        'blanket_permission_armory' => [ 'd', 'device' ], },
    'blanket permission to conflict with device' => { 'ARMORY_REG' => [],
        'blanket_permission_armory' => [ 'd', 'device' ], },
    '-blanket permission to conflict with augmented device' => { 'ARMORY_REG' => [],
        'blanket_permission_armory' => [ 'a', 'device' ], },
    '-blanket permission to conflict with heraldic title "x"' => {
        'blanket_permission_secondary_name' => [ 't', 'heraldic title' ],  },
    '-blanket permission to conflict with household name "x"' => {
        'blanket_permission_secondary_name' => [ 'HN', 'household name' ],  },
    '-blanket permission to conflict with name "x"' => { 'NAME_REG' => [ 'N' ],
        'blanket_permission_name' => [ 'N', 'name' ],  },
    'blanket permission to conflict with name and device' => { 'NAME_REG' => [ 'N' ],
        'ARMORY_REG' => [],
        'blanket_permission_name' => [ 'N', 'name' ], 
        'blanket_permission_armory' => [ 'd', 'device' ], },
    '-blanket permission to conflict with alternate name "x" and badge' => { 'ARMORY_REG' => [],
        'blanket_permission_secondary_name' => [ 'AN', 'alternate name' ], 
        'blanket_permission_armory' => [ 'b', 'badge' ], },
    '-blanket permission to conflict with name and device "x"' => { 'NAME_REG' => [ 'N' ],
        'ARMORY_REG' => [],
        'blanket_permission_name' => [ 'N', 'name' ], 
        'blanket_permission_armory' => [ 'd', 'device' ], },
    'blanket permission to conflict with name' => { 'NAME_REG' => [ 'N' ],
        'blanket_permission_name' => [ 'N', 'name' ],  },
    '-blazon correction for badge for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [] },
    '-branch name and badge' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'BN' ],
        'name' => [ 'BN' ], 
        'armory' => [ 'b'], },
    'branch name and device' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'BN' ],
        'name' => [ 'BN' ], 
        'armory' => [ 'd'], },
    '-branch name change from "x"' => { 'name_change' => [ 'BNC' ], },
    '-branch name change from "x" and device change' => { 'ARMORY_NOT_REG' => [],
        'name_change' => [ 'BNC' ], 
        'armory' => [ 'd' ], },
    '-branch name correction from "x"' => { 'NAME_NOT_REG' => [ 'BN'],
        'OWNED_NAME_REG' => [ 'BN' ],
        'name_correction' => [ 'BNc' ], },
    'branch name' => { 'NAME_NOT_REG' => [ 'BN' ],
        'name' => [ 'BN' ], },
    '-change of alternate name to "x" from "x"' => { 'order_name_change_reversed' => [ 'ANC' ], },
    'change of badge to device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    '-change of badge association from "x" to "x"' => { 'badge_for_2' => [ ], 
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'associated with new usage' ], },
    '-change of badge association to "x" from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with new usage' ], },
    'change of device to badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'converted to badge' ], 
        'armory' => [ 'b' ], },
    'corrected blazon' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'corrected blazon' ] }, # not necessarily 'b' type...
    '-correction of badge association to "x" from "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'ARMORY_REG' => [],
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'association corrected' ], },
    '-correction of heraldic title from "x"' => { 'NAME_NOT_REG' => [ 't'],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], },
    '-correction of name from "x"' => { 'NAME_NOT_REG' => [ 't'],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], },
    '-designation of badge as standard augmentation' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'a', 'Standard augmentation' ], },
    '-designator change from "x" and device change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'designator_change' => [ 'u' ], 
        'armory' => [ 'd' ], },
    'designator change from "x"' => { 'NAME_NOT_REG' => [ 'BN' ],
        'OWNED_NAME_REG' => [ 'BN' ],
        'name_change' => [ 'u' ], },
    'designator change to "x" from "x"' => { 'NAME_REG' => [ 'BN' ],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'OWNED_NAME2_REG' => [ 'O' ],
        'order_name_change_reversed' => [ 'OC', 'designator changed' ], },
    'device important' => { 'ARMORY_NOT_REG' => [],
        'armory' => [ 'd', 'Important non-SCA armory' ], },
    'device change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'd' ], },
    'device changed/released' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'changed/released' ] },
    '-device changed/retained as ancient arms' => { 
        'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'changed/retained as Ancient Arms' ], 
        'armory' => [ 'b' , 'Ancient Arms' ], },
    'device changed/retained' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'changed/retained' ], 
        'armory' => [ 'b' ], },
    'device corrected blazon' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'corrected blazon' ] },
    'device reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'reblazoned' ] },
    '-device released' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'released' ] },
    'device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'd' ], },
    '-device and blanket permission to conflict with device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'd' ], 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    '-exchange of device and badge' => {}, 
    'exchange of primary and alternate name "x"' => { 'NAME_REG' => [ 'AN' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ], 
        'name_release' => [ 'AN', 'converted to primary name' ] },
    'exchange of alternate and primary name "x"' => { 'NAME_REG' => [ 'AN' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ], 
        'owned_name_release_reverse' => [ 'AN', 'converted to primary name' ] },
    '-exchange of primary and alternate name "x" and device' => { 'NAME_FOR_ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'ARMORY_NOT_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ], 
        'owned_name_release' => [ 'AN', 'converted to primary name' ],
        'armory' => [ 'd' ],},
    '-flag' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b' ], },
    'flag important' => { 'ARMORY_NOT_REG' => [],
        'armory' => [ 'b', 'Important non-SCA armory' ], },
    'guild name "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN', 'Guild' ], },
    'heraldic title "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 't' ],
        'name_owned_by' => [ 't' ] },
    '-heraldic title' => { 'non_sca_title' => [ ] },
    'heraldic will' => { 'name' => [ 'W' ], },
    'heraldic will for badge' => { 'name' => [ 'W' ], },
    'heraldic will for device' => { 'name' => [ 'W' ], },
    '-heraldic will for heraldic title "x"' => { 'name' => [ 'W' ], },
    '-heraldic will for household name "x"' => { 'name' => [ 'W' ], },
    '-holding name' => { 'holding_name' => [] },
    'holding name and badge' => { 'ARMORY_NOT_REG' => [],
        'holding_name' => [], 
        'armory' => [ 'b' ] },
    'holding name and device' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'holding_name' => [], 
        'armory' => [ 'd' ] },
    '-holding name and household name "x"' => { 'holding_name' => [], 
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ], },
    'household badge for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [], },
    '-household name change to "x" from "x"' => { 'order_name_change_reversed' => [ 'HNC' ], },
    '-household name "x" and badge change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ],  
        'badge_for' => [], },
    'household name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ], 
        'badge_for' => [], },
    'household name "x" and badge association' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ], 
        'armory_release' => [ 'b', 'associated with household name' ], 
        'badge_for' => [], },
    '-household name "x" and joint badge' => { 'normalize_joint_household_name' => [ 'nojoint' ], 
        'normalize_joint_badge_for' => [], },
    'household name "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'HN' ],
        'name_owned_by' => [ 'HN' ], },
    '-important non-sca arms' => { 'ARMORY_NOT_REG' => [],
        'armory' => [ 'd', 'Important non-SCA armory' ], },
    '-important non-sca badge' => { 'ARMORY_NOT_REG' => [],
        'armory' => [ 'b', 'Important non-SCA badge' ], },
    '-important non-sca flag' => { 'ARMORY_NOT_REG' => [],
        'armory' => [ 'b', 'Important non-SCA flag' ], },
    '-joint badge for "x"' => { 'normalize_joint_badge_for' => [] },
    'joint household badge for "x"' => { 'normalize_joint_badge_for' => [] },
    'joint household badge change for "x"' => { 'normalize_joint_badge_for' => [] },
    'joint badge with "x"' => { 'PRIMARY_OWNER_NAME_NOT_REG' => [],
        'SECONDARY_OWNER_NAME_NOT_REG' => [],
        'joint' => [], 
        'joint_badge' => [] },
    'joint badge' => { 'normalize_joint_badge' => [] },
    'joint badge reblazoned' => { 'ARMORY_REG' => [],
        'joint_armory_release' => [ 'b', 'reblazoned' ] },
    '-joint badge transfer to "x"' => { 'transfer_joint_armory' => [ 'b', ], 
        'joint_transfer' => [] },
    'joint household name "x" and badge' => { 'ARMORY_NOT_REG' => [],
        'normalize_joint_household_name' => [ 'nojoint' ], 
        'normalize_joint_badge_for' => [], },
    '-joint household name "x" and badge association' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'normalize_joint_household_name' => [ 'nojoint' ], 
        'armory_release' => [ 'b', 'associated with household name' ],
        'normalize_joint_badge_for' => [], },
    '-joint household name "x"' => { 'normalize_joint_household_name' => [] },
    '-joint household name change to "x" from "x" and badge' => { 'order_name_change_reversed' => [ 'HNC' ], 
        'normalize_joint_badge_for' => [], 
        },
    'name and badge' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'name' => [ 'N' ], 
        'armory' => [ 'b' ], },
    'name and device' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'name' => [ 'N' ], 
        'armory' => [ 'd' ], },
    '-name and acceptance of device transfer from "x"' => { 'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'name' => [ 'N' ], 
        'armory' => [ 'd' ] },
    '-name change from "x" and badge change for "x"' => { 'name_change' => [ 'NC' ], 
        'badge_for_2' => [  ], },
    'name change from "x" and badge' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    '-name change from "x" and badge change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    '-name change from "x" and flag change' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from "x" and device change' => { 'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from "x" and device' => { 'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    '-name change from "x" and change of badge to device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    'name change from "x" retained' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC', 'retained' ], },
    'name change from "x" retained and device' => { 'NAME_NOT_REG' => [ 'N' ],
        'ARMORY_NOT_REG' => [],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'd' ], },
    'name change from "x" retained and badge' => { 'NAME_NOT_REG' => [ 'N' ],
        'ARMORY_NOT_REG' => [],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'b' ], },
    'name change from "x" retained and device change' => { 'ARMORY_NOT_REG' => [],
        'OWNED_NAME_REG' => [ 'N' ],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'd' ], },
    'name change from "x"' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_change' => [ 'NC' ], },
    'name change from holding name "x" and badge' => { 'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from holding name "x" and device change' => { 'NAME_NOT_REG' => [ 'N' ],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    '-name change from holding name "x" and device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from holding name "x"' => { 'name_change' => [ 'NC' ], },
    '-name correction from "x" and device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], 
        'armory' => [ 'd' ], },
    'name correction from "x"' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], },
    '-name correction from "x" to "x"' => { 'owned_name_correction_reversed' => [ 'NC', '-corrected' ], },
    'name reconsideration from "x" and device' => {'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], 
        'armory' => [ 'd' ], },
    '-name reconsideration from "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], 
        'armory' => [ 'b' ], },
    'name reconsideration from "x"' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], },
    'request for name reconsideration from "x"' => { 'NAME_NOT_REG' => [ 'N' ],
        'OWNED_NAME_REG' => [ 'N' ],
        'name_correction' => [ 'Nc' ], },
    '-name reconsideration to "x" from "x"' => { 'owned_name_correction' => [ 'Nc' ], },
    'name reconsideration for alternate name to "x" from "x"' => { 'OWNED_NAME2_REG' => [ 'AN' ],
        'OWNED_NAME_NOT_REG' => [ 'AN' ],
        'owned_name_correction_reversed' => [ 'AN' ], },
    'name' => { 'NAME_NOT_REG' => [ 'N' ],
        'name' => [ 'N' ], },
    'order name "x" and badge association' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    'order name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], },
    'order name "x"' => { 'NAME_FOR_OWNED_NAME_REG' => [],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'name_owned_by' => [ 'O' ] },
    '-order name change from "x" to "x"' => { 'order_name_change' => [ 'OC' ], },
    'order name change to "x" from "x"' => { 'NAME_REG' => [ 'BN' ],
        'OWNED_NAME_NOT_REG' => [ 'O' ],
        'OWNED_NAME2_REG' => [ 'O' ],
        'order_name_change_reversed' => [ 'OC', 'changed' ], },
    '-order name correction to "x" from "x"' => { 'owned_name_correction' => [ 'OC', '-corrected' ], },
    '-reblazon and redesignation of badge for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [ ], },
    '-reblazon of augmentation' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'a' ], },
    'reblazon of badge for "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [] },
    '-reblazon of badge for the "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'badge_for' => [ "the " ] },
    'reblazon of badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b' ], },
    'reblazon of joint badge' => { 'reblazon_normalize_joint_badge' => [] },
    'reblazon of device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'd' ], },
    '-reblazon of important non-sca flag' => { 'ARMORY_NOT_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b', 'Important non-SCA flag' ], },
    '-reblazon of important non-sca arms' => { 'ARMORY_NOT_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 'b', 'Important non-SCA arms' ], },
    '-reblazon of seal' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory' => [ 's' ], },
    '-redesignation of badge as device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    '-redesignation of device as badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'armory_release' => [ 'd', 'converted to badge' ], 
        'armory' => [ 'b' ], },
    'release of alternate name "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'NAME_REG' => [ 'N' ],
        'owned_name_release' => [ 'AN', 'released' ] },
    '-release of alternate name "x" and association of device with primary name' => 
        { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'ARMORY_NOT_REG' => [],
        'owned_name_release' => [ 'AN', 'released' ],
        'armory_release' => [ 'b', 'associated with primary name' ],
        'armory' => [ 'd' ],},
    '-release of badge for the "x"' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'released' ] },
    'release of badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'released' ] },
    '-release of branch name and device' => { 'NAME_FOR_ARMORY_REG' => [],
         'ARMORY_REG' => [],
       'name_release' => [ 'BN', 'released' ], 
        'armory_release' => [ 'd', 'released' ] },
    '-release of branch name' => { 'name_release' => [ 'BN', 'released' ], },
    'release of device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'released' ] },
    'release of device (non-sca armory)' => { 'ARMORY_REG' => [],
        'armory_release' => [ 'd', 'released' ] },
    '-release of heraldic title "x"' => { 'owned_name_release' => [ 't', 'released' ] },
    '-release of heraldic title' => { 'name_release' => [ 't', 'released' ] },
    '-release of household name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'owned_name_release' => [ 'HN', 'released' ], 
        'armory_release' => [ 'b', 'released' ] },
    '-release of joint badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 'b', 'released' ],
        'joint_release' => [],},
    'release of name' => { 'name_release' => [ 'N', 'released' ], },
    'release of name "x"' => { 'owned_name_release' => [ 'AN', 'released' ] },
    'release of name and device' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'name_release' => [ 'N', 'released' ], 
        'armory_release' => [ 'd', 'released' ] },
    '-release of order name "x" and badge' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'owned_name_release' => [ 'O', 'released' ], 
        'armory_release' => [ 'b', 'released' ] },
    'release of order name "x"' => {  'NAME_FOR_ARMORY_REG' => [],
        'NAME_REG' => [ 'BN' ],
        'owned_name_release' => [ 'O', 'released' ], },
    'removal of joint owner "x" for badge' => { 'remove_joint_badge_owner' => [ ], },
    '-seal reblazoned' => { 'NAME_FOR_ARMORY_REG' => [],
        'ARMORY_REG' => [],
        'armory_release' => [ 's', 'reblazoned' ] },
    'split combined entry' => { 'ARMORY_REG' => [],
        'NAME_FOR_ARMORY_REG' => [],
        'split_combined_entry' => [], },
    'standard augmentation' => { 'NAME_FOR_ARMORY_REG' => [],
        'armory' => [ 'a', 'Standard augmentation' ], },
    '-transfer of alternate name "x" to "x"' => {  'transfer_owned_name' => [ 'AN', ], },
    'transfer of badge to "x"' => {  'ARMORY_REG' => [],
        'NAME_FOR_ARMORY_REG' => [],
        'transfer_armory' => [ 'b', ], },
    'transfer of device to "x"' => {  'ARMORY_REG' => [],
        'NAME_FOR_ARMORY_REG' => [],
        'transfer_armory' => [ 'd', ], },
    'transfer of heraldic title "x" to "x"' => {  'NAME_FOR_OWNED_NAME_REG' => [ 't' ],
        'OWNED_NAME_REG' => [ 't' ],
        'transfer_name' => [ 't', ], },
    'transfer of household name "x" to "x"' => {  'NAME_FOR_OWNED_NAME_REG' => [ 'HN' ],
        'OWNED_NAME_REG' => [ 'HN' ],
        'transfer_name' => [ 'HN', ], },
    '-transfer of household name "x" and badge to "x"' => {  'transfer_owned_name' => [ 'HN', ],
        'transfer_armory' => [ 'b', ], },
    '-transfer of name and device to "x"' => {  'transfer_name' => [ 'N' ], 'transfer_armory' => [ 'd', ], },
    '-transfer of order name "x" to "x"' => {  'transfer_owned_name' => [ 'O', ], },
    'variant correction from "x"' => { 'NAME_REG' => [ 'N' ],
        'OWNED_NAME_NOT_REG' => [ 'N' ],
        'name_correction' => [ 'vc' ], },
    'variant name "x"' => { #'NAME_REG' => [],
        'variant_name' => [ 'v' ], },
    );
}

sub list_transforms
{
    my ($with_actions) = shift;
    my @results;
    for my $action (sort keys %transforms)
    {
        push @results, $action;
        next if ! $with_actions;
    }
    return join("\n", @results);
}

sub apply_entries
{
    my $self = shift;
    if (not exists $transforms{$self->cooked_action_of})
    {
        croak "Unknown action in ".$self->as_str;
    }
    
    my @entries;
    foreach my $act_sub (sort keys %{$transforms{$self->cooked_action_of}})
    {
        $self->$act_sub(@{$transforms{$self->cooked_action_of}->{$act_sub}});
    }
    return 1;
}

sub name_for
{
    my ($self, $type) = @_;
    my $owned_name = $self->quoted_names_of->[0];
    my $oname = $self->db->add_name($owned_name);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $owned_name,
            action => $type,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_name => $self->name_of,
        })->update;
    for my $n ($self->split_notes)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    
    die $self->as_str; 
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, "For ".$self->name_of, 
        $self->notes_of ];
}

sub variant_name
{
    my ($self, $type) = @_;
    my $owned_name = $self->quoted_names_of->[0];
    my $oname = $self->db->add_name($owned_name);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $owned_name,
            action => $type,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_name => $self->name_of,
        })->update;
    return $reg;
    
    die $self->as_str; 
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, "For ".$self->name_of, 
        $self->notes_of ];
}

sub name_change
{
    my ($self, $type, $retained) = @_;
    my $ntype = $type;
    $ntype =~ s/C$//;
    $ntype = 'BN' if $type eq 'u';
    my $pqname = $self->permute($self->quoted_names_of->[0]);
#     if (!$self->is_name_registered($pqname, [ $ntype ]))
#     {
#         die "Old name not registered: $pqname";
#     }
#     if ($self->is_name_registered($self->name_of, [ $ntype ]))
#     {
#         die "New name already registered: ".$self->name_of;
#     }
    my @regs = $self->db->Registration->search(
        {
            reg_owner_name => $pqname,
            action => { -not_in => [ qw/ NC C R u v vc Nc OC ANC HNC BNC BNc Bv Bvc/ ] },
        });
    my $got_the_primary_name = 0;
    for my $reg (@regs)
    {
        if ($reg->action->action_id ~~ [qw/B D BD/])
        {
            die "split unified record in name_change";
            # put the armory in the new record with the changed name and the old date
            # leave the current record alone for further processing
        }
    	my @name_types = qw/ BN N AN t O HN /;
        my @armory_types = qw/ a b d g j s D? W /; # W isn't really "armory", but that will do here
    	if ($reg->action->action_id ~~ @name_types && !$got_the_primary_name)
    	{
    	    my $reg_date = $reg->registration_date;
    	    my $reg_king = $reg->registration_kingdom;
    	    $reg->action($type);
    	    $reg->text_name($self->name_of);
    	    $reg->release_date($self->date_of);
    	    $reg->release_kingdom($self->kingdom_of);
    	    $reg->update;
    	    
    	    $self->db->add_name($self->name_of);
    	    $self->db->Registration->create(
    	        {
    	            reg_owner_name => $self->name_of,
    	            action => $ntype,
    	            registration_date => $self->date_of,
    	            registration_kingdom => $self->kingdom_of,
    	        })->update;
    	    $got_the_primary_name = 1;
    	}
    	elsif ($reg->action->action_id ~~ @name_types)
    	{
    	    die "hit the else case in name_change; got another name after changing primary name";
    	}
    	elsif ($reg->action->action_id ~~ @armory_types)
    	{
    	    $reg->reg_owner_name($self->name_of);
    	    $reg->update;
    	}
    	else
    	{
    	    die "unexpected type in name_change: ". $reg->action->action_id;
    	}
    }
    # now to look over the text
    @regs = $self->db->Registration->search(
        {
            action => 'AN',
            text_name => $pqname,
            reg_owner_name => { '!=', $self->name_of },
        });
    for my $reg (@regs)
    {
        $reg->text_name($self->name_of);
        $reg->update;
    }
    
    @regs = $self->db->Registration->search(
        {
            text_name => { like => '%'.$pqname.'%' },
            action => { -in => [ qw/ HN O t j / ] },
        });
    for my $reg (@regs)
    {
        if ($reg->text_name =~ /^"(.+)"$/)
        {
            my @tnames = split(/" and "/, $1);
            for my $tname (@tnames)
            {
                next unless $tname eq $pqname;
                $tname = $self->name_of;
            }
            $reg->text_name('"'.join('" and "', @tnames).'"');
            $reg->update;
        }
        elsif ($reg->text_name eq $pqname)
        {
            $reg->text_name($self->name_of);
            $reg->update;
        }
    }
    # now troll through the notes -- all the notes
    @regs = $self->db->Note->search({note_name => $pqname})->all;
    for my $reg (@regs)
    {
        my $note_text = $reg->note_text;
        $note_text =~ s/$pqname/$self->name_of/;
        $reg->note_name($self->name_of);
        $reg->update;
    }
    
    if ($retained)
    {
        $self->name_for('AN', 1);
    }
    return;
    die $self->as_str;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, "See ".$self->name_of,
        $self->notes_of ];
}

sub designator_change
{
    my ($self, $type) = @_;
    die $self->as_str;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->name_of,
        $self->notes_of ];
}

sub order_name_change
{
    my ($self, $type) = @_;
    die $self->as_str;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[1]),
        $self->notes_of ];
}

sub order_name_change_reversed
{
    my ($self, $type, $note) = @_;
    my $ntype = $type;
    $ntype =~ s/C$//;
    my $pqname = $self->permute($self->quoted_names_of->[1]);
    my @regs = $self->db->Registration->search(
        {
            reg_owner_name => $pqname,
            action => $ntype,
        });
    die "Multiple registrations of $pqname" unless @regs == 1;
    my $reg = $regs[0];
    my $owner_name = $reg->text_name;
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->action($type);
    $self->db->add_name($self->permute($self->quoted_names_of->[0]));
    $reg->text_name($self->permute($self->quoted_names_of->[0]));
    $reg->update;
    
    $self->db->add_note($reg, "-$note") if $note;
    
    $self->db->Registration->create(
        {
            reg_owner_name => $self->permute($self->quoted_names_of->[0]),
            action => $ntype,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_name => $owner_name,
        })->update;
    
    return;
    die $self->as_str;
    return [ $self->permute($self->quoted_names_of->[1]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[0]),
        $self->notes_of ];
}

sub name_correction
{
    my ($self, $type) = @_;
    my $ntype = $type;
    $ntype =~ s/c$//;
    my $pqname = $self->permute($self->quoted_names_of->[0]);
    my @regs = $self->db->Registration->search(
        {
            reg_owner_name => $pqname,
            action => { -not_in => [ qw/ NC C R u v vc Nc OC ANC HNC BNC BNc Bv Bvc/ ] },
        });
    my $got_the_primary_name = 0;
    for my $reg (@regs)
    {
        if ($reg->action->action_id ~~ [qw/B D BD/])
        {
            die "split unified record in name_change";
            # put the armory in the new record with the changed name and the old date
            # leave the current record alone for further processing
        }
    	my @name_types = qw/ BN N AN t O HN /;
        my @armory_types = qw/ a b d g j s D? W /;
    	if ($reg->action->action_id ~~ @name_types && !$got_the_primary_name)
    	{
    	    my $reg_date = $reg->registration_date;
    	    my $reg_king = $reg->registration_kingdom;
    	    $reg->action($type);
    	    $reg->text_name($self->name_of);
    	    $reg->release_date($self->date_of);
    	    $reg->release_kingdom($self->kingdom_of);
    	    $reg->update;
    	    
    	    $self->db->add_name($self->name_of);
    	    $self->db->Registration->create(
    	        {
    	            reg_owner_name => $self->name_of,
    	            action => $ntype,
    	            registration_date => $self->date_of,
    	            registration_kingdom => $self->kingdom_of,
    	        })->update;
    	    $got_the_primary_name = 1;
    	}
    	elsif ($reg->action->action_id ~~ @name_types)
    	{
    	    die "hit the else case in name_change; got another name after changing primary name";
    	}
    	elsif ($reg->action->action_id ~~ @armory_types)
    	{
    	    $reg->reg_owner_name($self->name_of);
    	    $reg->update;
    	}
    	else
    	{
    	    die "unexpected type in name_change: ". $reg->action->action_id;
    	}
    }
    # now to look over the text
    @regs = $self->db->Registration->search(
        {
            action => 'AN',
            text_name => 'For $pqname',
        });
    for my $reg (@regs)
    {
        $reg->text_name('For '.$self->name_of);
        $reg->update;
    }
    
    @regs = $self->db->Registration->search(
        {
            text_name => { like => '%'.$pqname.'%' },
            action => { -in => [ qw/ HN O t j / ] },
        });
    for my $reg (@regs)
    {
        if ($reg->text_name =~ /^"(.+)"$/)
        {
            my @tnames = split(/" and "/, $1);
            for my $tname (@tnames)
            {
                next unless $tname eq $pqname;
                $tname = $self->name_of;
            }
            $reg->text_name('"'.join('" and "', @tnames).'"');
            $reg->update;
        }
        elsif ($reg->text_name eq $pqname)
        {
            $reg->text_name($self->name_of);
            $reg->update;
        }
    }
    # now troll through the notes -- all the notes
    @regs = $self->db->Note->search({note_name => $pqname})->all;
    for my $reg (@regs)
    {
        my $note_text = $reg->note_text;
        $note_text =~ s/$pqname/$self->name_of/;
        $reg->note_name($self->name_of);
        $reg->update;
    }
    return;
    die $self->as_str;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->name_of,
        $self->notes_of ];
}

sub owned_name_correction_reversed
{
    my ($self, $type, $note) = @_;
    my $pqname = $self->permute($self->quoted_names_of->[1]);
    my @regs = $self->db->Registration->search({
        text_name => $self->name_of,
        reg_owner_name => $pqname,
        action => $type,
        release_date => '',
        release_kingdom => '',
        });
    
    die "No registration of $pqname to ". $self->name_of." as $type" if @regs == 0;
    die "Multiple registrations of $pqname to ". $self->name_of." as $type" if @regs > 1;
    
    $self->db->add_name($self->permute($self->quoted_names_of->[0]));
    my $reg = $regs[0];
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->text_name($self->permute($self->quoted_names_of->[0]));
    $reg->action('Nc');
    $reg->update;
    
    $self->name_owned_by($type, $note);
    return;
    
    die $self->as_str;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[1]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[0]),
        $self->notes_of.$note ];
}

sub owned_name_correction
{
    my ($self, $type, $note) = @_;
    die $self->as_str;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[1]),
        $self->notes_of.$note ];
}

sub non_sca_title
{
    my ($self) = @_;
    die $self->as_str;
    # yes, this is a bit of a hack to deal with hand jamming the source
    # ..and we need to chop the . off the end of the "blazon" which will
    # really be the real owner...
    (my $armory = $self->armory_of) =~ s/[.] \Z//x;
    return [ $self->name_of, $self->source_of,
        't', $armory, '(Owner: Laurel - admin)(Important Non-SCA title)' ];
}

sub name_owned_by
{
    my ($self, $type, $note, $owned_name_ok) = @_;
    my $owned_name = $self->permute($self->quoted_names_of->[0]);
    my $oname = $self->db->add_name($owned_name);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $oname->name,
            action => $type,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_name => $self->name_of,
        })->update;
    for my $n ($self->split_notes, $note)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    
    die $self->as_str;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->quote_joint($self->name_of),
        $self->notes_of.$note ];
}

sub reference
{
    my ($self) = @_;
    $self->name_owned_by('R');
    return;
    die $self->as_str;
    my $return_list = $self->name_owned_by('R');
    $return_list->[3] = "See $return_list->[3]";
    return $return_list;
}

sub quote_joint
{
    my ($self, $name) = @_;
    die $self->as_str;
    my @parts = split(/ and /, $name);
    if (@parts == 1)
    {
        return $name;
    }
    else
    {
        $self->add_note('(FIXME: add j record)');
        return join(" and ", map { "\"$_\"" } @parts);
    }
}

sub name
{
    my ($self, $type) = @_;
    $self->db->add_name($self->name_of);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $self->name_of,
            action => $type,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
        })->update;
    for my $n ($self->split_notes)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    $type ||= 'N';
    return [ $self->name_of, $self->source_of, $type, $EMPTY_STR, 
        $self->notes_of];
}

sub holding_name
{
    my ($self) = @_;
    my $reg = $self->name('N');
    $self->db->add_note($reg, 'Holding name');
    return;
    die $self->as_str;
    my @act = $self->name();
    for my $act (@act)
    {
    $act->[4] .= "(Holding name)";
    }
    return @act;
}

sub joint
{
    my ($self) = @_;
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $self->quoted_names_of->[0],
            action => 'j',
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_name => $self->name_of,
        })->update;
    for my $n ($self->split_notes)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    return [ $self->quoted_names_of->[0], $self->source_of, 'j',
        $self->name_of, $self->notes_of ];
}

sub badge_for
{
    my ($self, $article) = @_;
    $article //= '';
    my $blazon = $self->db->add_blazon($self->armory_of);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $self->name_of,
            action => 'b',
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_blazon_id => $blazon->blazon_id,
        })->update;
    for my $n ($self->split_notes, "For $article".$self->quoted_names_of->[0])
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    $article ||= $EMPTY_STR;
    return [ $self->name_of, $self->source_of, 'b', $self->armory_of,
        $self->notes_of."(For $article".$self->quoted_names_of->[0].")" ];
}

sub badge_for_2
{
    my ($self, $article) = @_;
    die $self->as_str;
    $article ||= $EMPTY_STR;
    return [ $self->name_of, $self->source_of, 'b', $self->armory_of,
        $self->notes_of."(For $article".$self->quoted_names_of->[1].")" ];
}

sub normalize_joint_badge
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    $self->name_of($names[0]);
    $self->quoted_names_of->[0] = $names[1];
    $self->PRIMARY_OWNER_NAME_NOT_REG();
    $self->SECONDARY_OWNER_NAME_NOT_REG();
    return ($self->joint(), $self->joint_badge());
}

sub reblazon_normalize_joint_badge
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    $self->name_of($names[0]);
    $self->quoted_names_of->[0] = $names[1];
    $self->PRIMARY_OWNER_NAME_NOT_REG();
    $self->SECONDARY_OWNER_NAME_NOT_REG();
    return ($self->joint_badge());
}

sub joint_armory_release
{
    my ($self, $type, $reason) = @_;
    my @names = split(/ and /, $self->name_of);
    $self->name_of($names[0]);
    $self->quoted_names_of->[0] = $names[1];
    return ($self->armory_release($type, $reason));
}

sub reblazon_joint_badge
{
    my ($self) = @_;
    die $self->as_str;
    my @names = split(/ and /, $self->name_of);
    $self->name_of($names[0]);
    $self->quoted_names_of->[0] = $names[1];
    return ($self->armory_release());
}

sub joint_release
{
    my ($self) = @_;
    die $self->as_str;
    my @names = split(/ and /, $self->name_of);
    return [ $names[1], "-".$self->source_of, 'j',
        $names[0], $self->notes_of."(-released)" ];
}

sub remove_joint_badge_owner
{
    my ($self) = @_;
    $self->armory_release('b', 'joint owner removed');
    # find the (now released) badge registration 
    my @regs = $self->db->Registration->search({
        reg_owner_name => $self->name_of,
        action => 'b',
        'text_blazon.blazon' => $self->armory_of,
        release_date => $self->date_of,
        release_kingdom => $self->kingdom_of,
        },
        {
            join => 'text_blazon',
        });
    my $reg = $regs[0];
    my @notes = $reg->notes->search({note_text => { like => 'JB:%' }, });
    #my $jname = $notes[0]->note_name;
    my $jname = $self->quoted_names_of->[0];
    
    @regs = $self->db->Registration->search({
            reg_owner_name => $jname,
            action => 'j',
            text_name => $self->name_of,
        });
    my $jreg = $regs[0] or die "Joint record missing";
    $jreg->release_date($self->date_of);
    $jreg->release_kingdom($self->kingdom_of);
    $jreg->update;
    $self->db->add_note($jreg, "-joint owner removed");
    
    $self->armory('b');
    return;
}

sub joint_transfer
{
    my ($self) = @_;
    die $self->as_str;
    my @names = split(/ and /, $self->name_of);
    return [ $names[1], "-".$self->source_of, 'j',
        $names[0], $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub normalize_joint_badge_for
{
    my ($self, $nojoint) = @_;
    my @names = split(/ and /, $self->name_of);
    my $joint_badge;
    my $household_name = $self->quoted_names_of->[0];
    $self->quoted_names_of->[0] = $names[1];
    $self->name_of($names[0]);
    $joint_badge = $self->joint_badge();
    $self->db->add_note($joint_badge, "For $household_name");
    $self->joint() unless defined $nojoint;
    
    $self->name_of(join(' and ', @names));
    $self->quoted_names_of->[0] = $household_name;
    return $joint_badge;
    die $self->as_str;
}

sub normalize_joint_household_name
{
    my ($self, $nojoint) = @_;
    my @names = split(/ and /, $self->name_of);
    my $joint_badge;
    my $household_name = $self->quoted_names_of->[0];
    $self->name_of($names[0]);
    $self->name_owned_by('HN', 'JHN: '.$names[1]);
    $self->quoted_names_of->[0] = $names[1];
    $self->joint() unless defined $nojoint;
    
    $self->name_of(join(' and ', @names));
    $self->quoted_names_of->[0] = $household_name;
    return $joint_badge;
    die $self->as_str;
}

sub joint_badge
{
    my ($self) = @_;
    return $self->armory('b', "JB: ".$self->quoted_names_of->[0]);
}

sub armory
{
    my ($self, $type, $note, $name_ok) = @_;
    my $blazon = $self->db->add_blazon($self->armory_of);
    my $reg = $self->db->Registration->create(
        {
            reg_owner_name => $self->name_of,
            action => $type,
            registration_date => $self->date_of,
            registration_kingdom => $self->kingdom_of,
            text_blazon_id => $blazon->blazon_id,
        })->update;
    for my $n ($self->split_notes, $note)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->name_of, $self->source_of, $type, $self->armory_of,
        $self->notes_of.$note ];
}

sub split_combined_entry
{
    my ($self) = @_;
    my %splittypes = qw/ B b D d BD d/;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        'text_blazon.blazon' => $self->armory_of,
        reg_owner_name => $self->name_of,
        },
        {
            join => 'text_blazon',
        });
    if (@regs > 1)
    {
        die "Armory registered multiple times to ".$self->name_of.'/'.$self->armory_of;
    }
    my $reg = $regs[0];
    my $atype = $splittypes{$reg->action->action_id};
    my $areg = $self->db->Registration->create(
        {
            reg_owner_name => $self->name_of,
            action => $atype,
            registration_date => $reg->registration_date,
            registration_kingdom => $reg->registration_kingdom,
            text_blazon_id => $reg->text_blazon_id,
        })->update;
    for my $n ($reg->notes)
    {
        $self->db->add_note($areg, $n->note_text);
    }
    
    $reg->action($reg->action->action_id eq 'BD' ? 'BN' : 'N');
    $reg->update;
    return;
}

sub armory_release
{
    my ($self, $type, $reason) = @_;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        action => $type,
        'text_blazon.blazon' => $self->armory_of,
        reg_owner_name => $self->name_of,
        },
        {
            join => 'text_blazon',
        });
    if (@regs > 1)
    {
        die "Armory registered multiple times to ".$self->name_of.'/'.$self->armory_of;
    }
    my $reg = $regs[0];
    if (!defined $reg) # split unified record
    {
        die "Split unified record in armory change";
        # create fresh record for name with old date 
    }
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    for my $n ($self->split_notes, "-$reason")
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    my @names = split(/ and /, $self->name_of);
    return [ $names[0], "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(-$reason)" ];
}

sub name_release
{
    my ($self, $type, $reason) = @_;
    my @regs = $self->db->Registration->search({
        reg_owner_name => $self->name_of,
        action => $type,
        release_date => '',
        release_kingdom => '',
        });
    die "No registration of ".$self->name_of." as $type" if @regs == 0;
    die "Multiple registrations of ". $self->name_of." as $type" if @regs > 1;
    
    my $reg = $regs[0];
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    
    $self->db->add_note($reg, "-$reason");
    return;
    die $self->as_str;
    return [ $self->name_of, "-".$self->source_of, $type, $EMPTY_STR,
        $self->notes_of."(-$reason)" ];
}
    
sub owned_name_release
{
    my ($self, $type, $reason) = @_;
    my @regs = $self->db->Registration->search({
        text_name => $self->name_of,
        reg_owner_name => $self->permute($self->quoted_names_of->[0]),
        action => $type,
        release_date => '',
        release_kingdom => '',
        });
    die "No registration of ".$self->permute($self->quoted_names_of->[0]).
        " to ". $self->name_of." as $type" if @regs == 0;
    die "Multiple registrations of ".$self->permute($self->quoted_names_of->[0]).
        " to ". $self->name_of." as $type" if @regs > 1;
    
    my $reg = $regs[0];
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    
    $self->db->add_note($reg, "-$reason");
    return;
    die $self->as_str;
    my $for = $type eq 'AN' ? 'For ' : '';
    return [ $self->name_of, "-".$self->source_of, $type, $for.$self->permute($self->quoted_names_of->[0]),
        $self->notes_of."(-$reason)" ];
}

sub owned_name_release_reverse
{
    my ($self, $type, $reason) = @_;
    my @regs = $self->db->Registration->search({
        reg_owner_name => $self->name_of,
        text_name => $self->permute($self->quoted_names_of->[0]),
        action => $type,
        release_date => '',
        release_kingdom => '',
        });
    die "No registration of ".$self->permute($self->quoted_names_of->[0]).
        " to ". $self->name_of." as $type" if @regs == 0;
    die "Multiple registrations of ".$self->permute($self->quoted_names_of->[0]).
        " to ". $self->name_of." as $type" if @regs > 1;
    
    my $reg = $regs[0];
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    
    $self->db->add_note($reg, "-$reason");
    return;
    die $self->as_str;
    my $for = $type eq 'AN' ? 'For ' : '';
    return [ $self->name_of, "-".$self->source_of, $type, $for.$self->permute($self->quoted_names_of->[0]),
        $self->notes_of."(-$reason)" ];
}
    
sub transfer_armory
{
    my ($self, $type) = @_;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        action => $type,
        reg_owner_name => $self->permute($self->name_of),
        'text_blazon.blazon' => $self->armory_of,
        },
        {
            join => 'text_blazon',
        });
    if (@regs > 1)
    {
        die "Armory registered multiple times to ".$self->name_of.'/'.$self->quoted_names_of->[0];
    }
    my $reg = $regs[0];
    if (!defined $reg) # split unified record
    {
        die "Split unified record in armory change";
        # create fresh record for name with old date 
    }
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    $self->db->add_note($reg, '-transferred to ' .  $self->permute($self->quoted_names_of->[-1]));
    return;   
    die $self->as_str;
    return [ $self->name_of, "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_joint_armory
{
    my ($self, $type) = @_;
    die $self->as_str;
    my @names = split(/ and /, $self->name_of);
    return [ $names[0], "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(JB: $names[1])(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_name
{
    my ($self, $type) = @_;
    
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        action => $type,
        reg_owner_name => $self->permute($self->quoted_names_of->[0]),
        text_name => $self->name_of,
        });
    if (@regs > 1)
    {
        die "Name registered multiple times to ".$self->name_of.'/'.$self->quoted_names_of->[0];
    }
    my $reg = $regs[0];
    $reg->release_date($self->date_of);
    $reg->release_kingdom($self->kingdom_of);
    $reg->update;
    $self->db->add_note($reg, '-transferred to ' .  $self->permute($self->quoted_names_of->[-1]));
    return;   
    die $self->as_str;
    return [ $self->quoted_names_of->[0], "-".$self->source_of, $type, 
        $self->name_of, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_owned_name
{
    my ($self, $type) = @_;
    die $self->as_str;
    my $text = $self->name_of;
    $text = "For $text" if $type eq 'AN';
    return [ $self->permute($self->quoted_names_of->[0]), "-".$self->source_of, $type, 
        $text, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub blanket_permission_name
{
    my ($self, $type, $item_type) = @_;
    my $additional_note = $self->quoted_names_of->[0] || '';
    $additional_note = ' '.$additional_note if $additional_note;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        action => $type,
        reg_owner_name => $self->name_of,
        });
    if (@regs > 1)
    {
        die "Name registered multiple times to ".$self->name_of.'/'.$self->armory_of;
    }
    my $source = $self->source_of;
    my $note = "Blanket permission to conflict with $item_type$additional_note granted $source";
    my $reg = $regs[0];
    for my $n ($self->split_notes, $note)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    my $notes = $self->notes_of;
    if ($notes)
    {
        $notes =~ s/[(] with/(Blanket permission to conflict with $item_type granted $self->source_of with/xsm;
    }
    else
    {
        $notes = "(Blanket permission to conflict with $item_type granted ".$self->source_of.")";
    }
    $type ||= 'N';
    return [ $self->name_of, $self->source_of, $type, $EMPTY_STR, 
        $notes ];
}

sub blanket_permission_secondary_name
{
    my ($self, $type, $item_type) = @_;
    my $pqname = $self->quoted_names_of->[0];
    my $additional_note = $self->quoted_names_of->[1] || '';
    $additional_note = ' '.$additional_note if $additional_note;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        reg_owner_name => $pqname,
        text_name => $self->name_of,
        });
    if (@regs > 1)
    {
        die "Name registered multiple times to ".$self->name_of.'/'.$self->armory_of;
    }
    my $source = $self->source_of;
    my $note = "Blanket permission to conflict with $item_type$additional_note granted $source";
    my $reg = $regs[0];
    for my $n ($self->split_notes, $note)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    my $notes = $self->notes_of;
    if ($notes)
    {
        $notes =~ s/[(] with/(Blanket permission to conflict with $item_type granted $self->source_of with/xsm;
        $self->notes_of = $notes;
    }
    else
    {
        $self->notes_of("(Blanket permission to conflict with $item_type granted ".$self->source_of.")");
    }
    $type ||= 'N';
    return [ $self->quoted_names_of->[0], $self->source_of, $type, $self->name_of, 
        $self->notes_of ];
}

sub blanket_permission_armory
{
    my ($self, $type, $item_type) = @_;
    my $additional_note = $self->quoted_names_of->[0] || '';
    $additional_note = ' '.$additional_note if $additional_note;
    my @regs = $self->db->Registration->search({
        release_kingdom => '',
        release_date => '',
        'text_blazon.blazon' => $self->armory_of,
        reg_owner_name => $self->name_of,
        },
        {
            join => 'text_blazon',
        });
    if (@regs > 1)
    {
        die "Armory registered multiple times to ".$self->name_of.'/'.$self->armory_of;
    }
    my $source = $self->source_of;
    my $note = "Blanket permission to conflict with $item_type$additional_note granted $source";
    my $reg = $regs[0];
    for my $n ($self->split_notes, $note)
    {
        next unless $n;
        $self->db->add_note($reg, $n);
    }
    return $reg;
    die $self->as_str;
    $additional_note = $self->quoted_names_of->[0] || '';
    $additional_note = ' '.$additional_note if $additional_note;
    $type ||= 'd';
    my $notes = $self->notes_of;
    if ($notes)
    {
        my $source = $self->source_of;
        $notes =~ s/[(] with/(Blanket permission to conflict with $item_type$additional_note granted $source with/xsm;
    }
    else
    {
        $notes = "(Blanket permission to conflict with $item_type$additional_note granted ".$self->source_of.")";
    }
    return [ $self->name_of, $self->source_of, $type, $self->armory_of, 
        $notes];
}

__PACKAGE__->meta->make_immutable;
1;

__END__

