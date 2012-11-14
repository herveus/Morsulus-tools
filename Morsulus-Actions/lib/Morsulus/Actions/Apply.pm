package Morsulus::Actions::Apply;
use warnings;
use strict;
use Carp;

use Moose;
extends 'Morsulus::Actions';

has 'db' => (
    isa => 'Morsulus::Ordinary::Classic',
    is => 'ro',
    );

my %transforms = get_transforms();

sub get_transforms
{
my %transforms = (
    'acceptance of badge transfer from "x"' => { 'armory' => [ 'b' ] },
    'acceptance of badge transfer from "x" and designation as for "x"' => { 'badge_for_2' => [] },
    'acceptance of device transfer from "x"' => { 'armory' => [ 'd' ] },
    'acceptance of transfer of heraldic title "x" from "x"' => { 'name_owned_by' => [ 't' ] },
    'acceptance of order name transfer "x" from "x"' => { 'name_owned_by' => [ 'O' ] },
    'acceptance of transfer of household name "x" and badge from "x"' => { 'name_owned_by' => [ 'HN' ],
        'badge_for' => [], },
    'acceptance of household name transfer "x" from "x" as branch name' => { 'name' => [ 'BN' ], },
    'acceptance of transfer of alternate name "x" and badge from "x"' => { 'name_owned_by' => [ 'AN' ],
        'badge_for' => [], },
    'addition of joint owner "x" for badge' => { 'joint' => [], 'joint_badge' => [] },
    'alternate name "x" and badge' => { 'name_for' => [ 'AN' ], 'badge_for' => [] },
    'alternate name "x" and badge association' => { 'name_for' => [ 'AN' ], 'badge_for' => [],
        'armory_release' => [ 'b', 'associated with alternate name' ],},
    'alternate name "x"' => { 'name_for' => [ 'AN' ] },
    'alternate name change from "x" to "x"' => { 'order_name_change' => [ 'ANC' ], },
    'alternate name correction to "x" from "x"' => { 'owned_name_correction' => [ 'Nc' ], },
    'ancient arms' => { 'armory' => [ 'b' , 'Ancient Arms' ], },
    'arms' => { 'armory' => [ 'd' ], },
    'arms reblazoned' => { 'armory_release' => [ 'd', 'reblazoned' ] },
    'association of alternate name "x" and badge' => { 'armory_release' => [ 'b', 'associated with alternate name' ],
        'badge_for' => [],},
    'association of household name "x" and badge' => {  'armory_release' => [ 'b', 'associated with household name' ],
        'badge_for' => [],},
    'augmentation change' => { 'armory' => [ 'a' ], },
    'augmentation changed/released' => { 'armory_release' => [ 'a', 'changed/released' ] },
    'augmentation reblazoned' => { 'armory_release' => [ 'a', 'reblazoned' ] },
    'augmentation' => { 'armory' => [ 'a' ], },
    'augmentation of arms' => { 'armory' => [ 'a' ], },
    'award name "x" and badge' => { 'name_owned_by' => [ 'O' ], 'armory' => [ 'b' ], },
    'award name "x" and badge association' => { 'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    'award name "x"' => { 'name_owned_by' => [ 'O' ] },
    'badge and association with order name "x"' => { 'badge_for' => [ ] },
    'badge association for "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with usage' ],
        'reference' => [ ], },
    'badge association with "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with usage' ],
        'reference' => [ ], },
    'badge association with guild name "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with guild name' ], 
        'reference' => [ ] },
    'badge association with order name "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    'badge change' => { 'armory' => [ 'b' ], },
    'badge change and association for "x"' => { 'badge_for' => [ ],
        'armory_release' => [ 'b', 'associated with order name' ],},
    'badge changed/released' => { 'armory_release' => [ 'b', 'changed/released' ] },
    'badge correction' => { 'armory_release' => [ 'b', 'corrected blazon' ] },
    'badge for alternate name "x"' => { 'badge_for' => [] },
    'badge for "x"' => { 'badge_for' => [] },
    'badge for "x" reference' => { 'badge_for' => [ ],
        'reference' => [ ],},
    'badge for the "x"' => { 'badge_for' => [ "the " ] },
    'badge reblazoned' => { 'armory_release' => [ 'b', 'reblazoned' ] },
    'badge for the "x" reblazoned' => { 'armory_release' => [ 'b', 'reblazoned' ] },
    'badge for "x" reblazoned' => { 'armory_release' => [ 'b', 'reblazoned' ] },
    'badge release' => { 'armory_release' => [ 'b', 'released' ] },
    'badge transfer to "x"' => {  'transfer_armory' => [ 'b', ], },
    'badge' => { 'armory' => [ 'b' ], },
    'blanket permission to conflict with alternate name "x"' => { 
        'blanket_permission_secondary_name' => [ 'BP', 'alternate name' ], },
    'blanket permission to conflict with badge' => { 
        'blanket_permission_armory' => [ 'BP', 'badge' ], },
    'blanket permission to conflict with device "x"' => { 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'blanket permission to conflict with device' => { 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'blanket permission to conflict with augmented device' => { 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'blanket permission to conflict with heraldic title "x"' => {
        'blanket_permission_secondary_name' => [ 'BP', 'heraldic title' ],  },
    'blanket permission to conflict with household name "x"' => {
        'blanket_permission_secondary_name' => [ 'BP', 'household name' ],  },
    'blanket permission to conflict with name "x"' => { 
        'blanket_permission_name' => [ 'BP', 'name' ],  },
    'blanket permission to conflict with name and device' => { 
        'blanket_permission_name' => [ 'BP', 'name' ], 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'blanket permission to conflict with alternate name "x" and badge' => { 
        'blanket_permission_secondary_name' => [ 'BP', 'alternate name' ], 
        'blanket_permission_armory' => [ 'BP', 'badge' ], },
    'blanket permission to conflict with name and device "x"' => { 
        'blanket_permission_name' => [ 'BP', 'name' ], 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'blanket permission to conflict with name' => { 
        'blanket_permission_name' => [ 'BP', 'name' ],  },
    'blazon correction for badge for "x"' => { 'badge_for' => [] },
    'branch name and badge' => { 'name' => [ 'BN' ], 'armory' => [ 'b'], },
    'branch name and device' => { 'name' => [ 'BN' ], 'armory' => [ 'd'], },
    'branch name change from "x"' => { 'name_change' => [ 'BNC' ], },
    'branch name change from "x" and device change' => { 'name_change' => [ 'BNC' ], 
         'armory' => [ 'd' ], },
    'branch name correction from "x"' => { 'name_correction' => [ 'BNc' ], },
    'branch name' => { 'name' => [ 'BN' ], },
    'change of alternate name to "x" from "x"' => { 'order_name_change_reversed' => [ 'ANC' ], },
    'change of badge to device' => { 'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    'change of badge association from "x" to "x"' => { 'badge_for_2' => [ ], 
        'armory_release' => [ 'b', 'associated with new usage' ], },
    'change of badge association to "x" from "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with new usage' ], },
    'change of device to badge' => { 'armory_release' => [ 'd', 'converted to badge' ], 
        'armory' => [ 'b' ], },
    'corrected blazon' => { 'armory_release' => [ 'b', 'corrected blazon' ] },
    'correction of badge association to "x" from "x"' => { 'badge_for' => [ ], 
        'armory_release' => [ 'b', 'association corrected' ], },
    'correction of heraldic title from "x"' => { 'name_correction' => [ 'Nc' ], },
    'correction of name from "x"' => { 'name_correction' => [ 'Nc' ], },
    'designation of badge as standard augmentation' => { 'armory' => [ 'a', 'Standard augmentation' ], },
    'designator change from "x" and device change' => { 'designator_change' => [ 'u' ], 
        'armory' => [ 'd' ], },
    'designator change from "x"' => { 'designator_change' => [ 'u' ], },
    'device (important non-sca armory)' => { 'armory' => [ 'd', 'Important non-SCA armory' ], },
    'device change' => { 'armory' => [ 'd' ], },
    'device changed/released' => { 'armory_release' => [ 'd', 'changed/released' ] },
    'device changed/retained as ancient arms' => { 
        'armory_release' => [ 'd', 'changed/retained as Ancient Arms' ], 
        'armory' => [ 'b' , 'Ancient Arms' ], },
    'device changed/retained' => { 'armory_release' => [ 'd', 'changed/retained' ], 
        'armory' => [ 'b' ], },
    'device reblazoned' => { 'armory_release' => [ 'd', 'reblazoned' ] },
    'device released' => { 'armory_release' => [ 'd', 'released' ] },
    'device' => { 'armory' => [ 'd' ], },
    'device and blanket permission to conflict with device' => { 'armory' => [ 'd' ], 
        'blanket_permission_armory' => [ 'BP', 'device' ], },
    'exchange of device and badge' => {}, 
    'exchange of primary and alternate name "x"' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ], 
        'owned_name_release_reverse' => [ 'AN', 'converted to primary name' ] },
    'exchange of primary and alternate name "x" and device' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ], 
        'owned_name_release' => [ 'AN', 'converted to primary name' ],
        'armory' => [ 'd' ],},
    'flag' => { 'armory' => [ 'b' ], },
    'guild name "x"' => { 'name_owned_by' => [ 'HN', 'Guild' ], },
    'heraldic title "x"' => { 'name_owned_by' => [ 't' ] },
    'heraldic title' => { 'non_sca_title' => [ ] },
    'heraldic will' => { 'name' => [ 'W' ], },
    'heraldic will for heraldic title "x"' => { 'name' => [ 'W' ], },
    'heraldic will for household name "x"' => { 'name' => [ 'W' ], },
    'holding name' => { 'holding_name' => [] },
    'holding name and badge' => { 'holding_name' => [], 'armory' => [ 'b' ] },
    'holding name and device' => { 'holding_name' => [], 'armory' => [ 'd' ] },
    'holding name and household name "x"' => { 'holding_name' => [], 
        'name_owned_by' => [ 'HN' ], },
    'household badge for "x"' => { 'badge_for' => [], },
    'household name change to "x" from "x"' => { 'order_name_change_reversed' => [ 'HNC' ], },
    'household name "x" and badge change' => { 'name_owned_by' => [ 'HN' ],  
        'badge_for' => [], },
    'household name "x" and badge' => { 'name_owned_by' => [ 'HN' ], 
        'badge_for' => [], },
    'household name "x" and badge association' => { 'name_owned_by' => [ 'HN' ], 
        'armory_release' => [ 'b', 'associated with household name' ], 
        'badge_for' => [], },
    'household name "x" and joint badge' => { 'normalize_joint_household_name' => [], 
        'normalize_joint_badge_for' => [], },
    'household name "x"' => { 'name_owned_by' => [ 'HN' ], },
    'important non-sca arms' => { 'armory' => [ 'd', 'Important non-SCA armory' ], },
    'important non-sca badge' => { 'armory' => [ 'b', 'Important non-SCA badge' ], },
    'important non-sca flag' => { 'armory' => [ 'b', 'Important non-SCA flag' ], },
    'joint badge for "x"' => { 'normalize_joint_badge_for' => [] },
    'joint badge with "x"' => { 'joint' => [], 'joint_badge' => [] },
    'joint badge' => { 'normalize_joint_badge' => [] },
    'joint badge reblazoned' => { 'armory_release' => [ 'b', 'reblazoned' ] },
    'joint badge transfer to "x"' => { 'transfer_joint_armory' => [ 'b', ], 
        'joint_transfer' => [] },
    'joint household name "x" and badge' => { 'normalize_joint_household_name' => [], 
        'normalize_joint_badge_for' => [], },
    'joint household name "x" and badge association' => { 'normalize_joint_household_name' => [], 
        'armory_release' => [ 'b', 'associated with household name' ],
        'normalize_joint_badge_for' => [], },
    'joint household name "x"' => { 'normalize_joint_household_name' => [] },
    'joint household name change to "x" from "x" and badge' => { 'order_name_change_reversed' => [ 'HNC' ], 
        'normalize_joint_badge_for' => [], 
        },
    'name and badge' => { 'name' => [ 'N' ], 'armory' => [ 'b'], },
    'name and device' => { 'name' => [ 'N' ], 'armory' => [ 'd'], },
    'name and acceptance of device transfer from "x"' => { 'name' => [ 'N' ], 'armory' => [ 'd' ] },
    'name change from "x" and badge change for "x"' => { 'name_change' => [ 'NC' ], 
        'badge_for_2' => [  ], },
    'name change from "x" and badge' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from "x" and badge change' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from "x" and flag change' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from "x" and device change' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from "x" and device' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from "x" and change of badge to device' => { 'name_change' => [ 'NC' ], 
        'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    'name change from "x" retained' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ]},
    'name change from "x" retained and device' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'd' ], },
    'name change from "x" retained and badge' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'b' ], },
    'name change from "x" retained and device change' => { 'name_change' => [ 'NC' ], 
        'name_for' => [ 'AN' ],
        'armory' => [ 'd' ], },
    'name change from "x"' => { 'name_change' => [ 'NC' ], },
    'name change from holding name "x" and badge' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'b' ], },
    'name change from holding name "x" and device change' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from holding name "x" and device' => { 'name_change' => [ 'NC' ], 
        'armory' => [ 'd' ], },
    'name change from holding name "x"' => { 'name_change' => [ 'NC' ], },
    'name correction from "x" and device' => { 'name_correction' => [ 'Nc' ], 
        'armory' => [ 'd' ], },
    'name correction from "x"' => { 'name_correction' => [ 'Nc' ], },
    'name correction from "x" to "x"' => { 'owned_name_correction_reversed' => [ 'NC', '-corrected' ], },
    'name reconsideration from "x" and device' => { 'name_correction' => [ 'Nc' ], 
        'armory' => [ 'd' ], },
    'name reconsideration from "x" and badge' => { 'name_correction' => [ 'Nc' ], 
        'armory' => [ 'b' ], },
    'name reconsideration from "x"' => { 'name_correction' => [ 'Nc' ], },
    'name reconsideration to "x" from "x"' => { 'owned_name_correction' => [ 'Nc' ], },
    'name' => { 'name' => [ 'N' ], },
    'order name "x" and badge association' => { 'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], 
        'armory_release' => [ 'b', 'associated with order name' ], },
    'order name "x" and badge' => { 'name_owned_by' => [ 'O' ], 
        'badge_for' => [ ], },
    'order name "x"' => { 'name_owned_by' => [ 'O' ] },
    'order name change from "x" to "x"' => { 'order_name_change' => [ 'OC' ], },
    'order name change to "x" from "x"' => { 'order_name_change_reversed' => [ 'OC' ], },
    'order name correction to "x" from "x"' => { 'owned_name_correction' => [ 'OC', '-corrected' ], },
    'reblazon and redesignation of badge for "x"' => { 'badge_for' => [ ], },
    'reblazon of augmentation' => { 'armory' => [ 'a' ], },
    'reblazon of badge for "x"' => { 'badge_for' => [] },
    'reblazon of badge for the "x"' => { 'badge_for' => [ "the " ] },
    'reblazon of badge' => { 'armory' => [ 'b' ], },
    'reblazon of joint badge' => { 'reblazon_joint_badge' => [ 'b' ], },
    'reblazon of device' => { 'armory' => [ 'd' ], },
    'reblazon of important non-sca flag' => { 'armory' => [ 'b', 'Important non-SCA flag' ], },
    'reblazon of important non-sca arms' => { 'armory' => [ 'b', 'Important non-SCA arms' ], },
    'reblazon of seal' => { 'armory' => [ 's' ], },
    'redesignation of badge as device' => { 'armory_release' => [ 'b', 'converted to device' ], 
        'armory' => [ 'd' ], },
    'redesignation of device as badge' => { 'armory_release' => [ 'd', 'converted to badge' ], 
        'armory' => [ 'b' ], },
    'release of alternate name "x"' => { 'owned_name_release' => [ 'AN', 'released' ] },
    'release of alternate name "x" and association of device with primary name' => 
        { 'owned_name_release' => [ 'AN', 'released' ],
        'armory_release' => [ 'b', 'associated with primary name' ],
        'armory' => [ 'd' ],},
    'release of badge for the "x"' => { 'armory_release' => [ 'b', 'released' ] },
    'release of badge' => { 'armory_release' => [ 'b', 'released' ] },
    'release of branch name and device' => { 'name_release' => [ 'BN', 'released' ], 
        'armory_release' => [ 'd', 'released' ] },
    'release of branch name' => { 'name_release' => [ 'BN', 'released' ], },
    'release of device' => { 'armory_release' => [ 'd', 'released' ] },
    'release of heraldic title "x"' => { 'owned_name_release' => [ 't', 'released' ] },
    'release of heraldic title' => { 'name_release' => [ 't', 'released' ] },
    'release of household name "x" and badge' => { 'owned_name_release' => [ 'HN', 'released' ], 
        'armory_release' => [ 'b', 'released' ] },
    'release of joint badge' => { 'armory_release' => [ 'b', 'released' ],
        'joint_release' => [],},
    'release of name' => { 'name_release' => [ 'N', 'released' ], },
    'release of name and device' => { 'name_release' => [ 'N', 'released' ], 
        'armory_release' => [ 'd', 'released' ] },
    'release of order name "x" and badge' => { 'owned_name_release' => [ 'O', 'released' ], 
        'armory_release' => [ 'b', 'released' ] },
    'release of order name "x"' => { 'owned_name_release' => [ 'O', 'released' ], },
    'seal reblazoned' => { 'armory_release' => [ 's', 'reblazoned' ] },
    'standard augmentation' => { 'armory' => [ 'a', 'Standard augmentation' ], },
    'transfer of alternate name "x" to "x"' => {  'transfer_owned_name' => [ 'AN', ], },
    'transfer of badge to "x"' => {  'transfer_armory' => [ 'b', ], },
    'transfer of device to "x"' => {  'transfer_armory' => [ 'd', ], },
    'transfer of heraldic title "x" to "x"' => {  'transfer_name' => [ 't', ], },
    'transfer of household name "x" to "x"' => {  'transfer_owned_name' => [ 'HN', ], },
    'transfer of household name "x" and badge to "x"' => {  'transfer_owned_name' => [ 'HN', ],
        'transfer_armory' => [ 'b', ], },
    'transfer of name and device to "x"' => {  'transfer_name' => [ 'N' ], 'transfer_armory' => [ 'd', ], },
    'transfer of order name "x" to "x"' => {  'transfer_owned_name' => [ 'O', ], },
    'variant correction from "x"' => { 'name_correction' => [ 'vc' ], },
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

sub make_db_entries
{
    my $self = shift;
    if (not exists $transforms{$self->cooked_action_of})
    {
        carp "Unknown action in ".$self->as_str;
        return;
    }
    
    my @entries;
    foreach my $act_sub (keys %{$transforms{$self->cooked_action_of}})
    {
        my @action_results = $self->$act_sub(@{$transforms{$self->cooked_action_of}->{$act_sub}});
        foreach my $action_result (@action_results)
        {
            push @entries, join($SEPARATOR, @$action_result);
        }
    }
    return join($NEWLINE, uniq(@entries), '');
}

=pod 

sub name_for
{
    my ($self, $type) = @_;
    # 
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, "For ".$self->name_of, 
        $self->notes_of ];
}

sub name_change
{
    my ($self, $type) = @_;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, "See ".$self->name_of,
        $self->notes_of ];
}

sub designator_change
{
    my ($self, $type) = @_;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->name_of,
        $self->notes_of ];
}

sub order_name_change
{
    my ($self, $type) = @_;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[1]),
        $self->notes_of ];
}

sub order_name_change_reversed
{
    my ($self, $type) = @_;
    return [ $self->permute($self->quoted_names_of->[1]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[0]),
        $self->notes_of ];
}

sub name_correction
{
    my ($self, $type) = @_;
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->name_of,
        $self->notes_of ];
}

sub owned_name_correction
{
    my ($self, $type, $note) = @_;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[1]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[0]),
        $self->notes_of.$note ];
}

sub owned_name_correction_reversed
{
    my ($self, $type, $note) = @_;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->permute($self->quoted_names_of->[1]),
        $self->notes_of.$note ];
}

sub non_sca_title
{
    my ($self) = @_;
    # yes, this is a bit of a hack to deal with hand jamming the source
    # ..and we need to chop the . off the end of the "blazon" which will
    # really be the real owner...
    (my $armory = $self->armory_of) =~ s/[.] \Z//x;
    return [ $self->name_of, $self->source_of,
        't', $armory, '(Owner: Laurel - admin)(Important Non-SCA title)' ];
}

sub name_owned_by
{
    my ($self, $type, $note) = @_;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, $type, $self->quote_joint($self->name_of),
        $self->notes_of.$note ];
}

sub reference
{
    my ($self) = @_;
    my $return_list = $self->name_owned_by('R');
    $return_list->[3] = "See $return_list->[3]";
    return $return_list;
}

sub quote_joint
{
    my ($self, $name) = @_;
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
    $type ||= 'N';
    return [ $self->name_of, $self->source_of, $type, $EMPTY_STR, 
        $self->notes_of];
}

sub holding_name
{
     my ($self) = @_;
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
    return [ $self->quoted_names_of->[0], $self->source_of, 'j',
        $self->name_of, $self->notes_of ];
}

sub badge_for
{
    my ($self, $article) = @_;
    $article ||= $EMPTY_STR;
    return [ $self->name_of, $self->source_of, 'b', $self->armory_of,
        $self->notes_of."(For $article".$self->quoted_names_of->[0].")" ];
}

sub badge_for_2
{
    my ($self, $article) = @_;
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
    return ($self->joint_badge(), $self->joint());
}

sub reblazon_joint_badge
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    $self->name_of($names[0]);
    $self->quoted_names_of->[0] = $names[1];
    return ($self->joint_badge());
}

sub joint_release
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    return [ $names[1], "-".$self->source_of, 'j',
        $names[0], $self->notes_of."(-released)" ];
}

sub joint_transfer
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    return [ $names[1], "-".$self->source_of, 'j',
        $names[0], $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub normalize_joint_badge_for
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    my $joint_badge;
    {
        my $household_name = $self->quoted_names_of->[0];
        $self->quoted_names_of->[0] = $names[1];
        $self->name_of($names[0]);
        $joint_badge = $self->joint_badge();
        $joint_badge->[4] = "(For $household_name)".$joint_badge->[4];
    }
    return ($joint_badge, $self->joint());
}

sub normalize_joint_household_name
{
    my ($self) = @_;
    my @names = split(/ and /, $self->name_of);
    return ([ $self->permute($self->quoted_names_of->[0]),
        $self->source_of, 'HN', join(" and ", map { "\"$_\"" } @names),
        $self->notes_of ], 
        [$names[1], $self->source_of, 'j', $names[0], $self->notes_of ]);
}

sub joint_badge
{
    my ($self) = @_;
    return $self->armory('b', "JB: ".$self->quoted_names_of->[0]);
}

sub armory
{
    my ($self, $type, $note) = @_;
    $note = "($note)" if $note;
    $note ||= '';
    return [ $self->name_of, $self->source_of, $type, $self->armory_of,
        $self->notes_of.$note ];
}

sub armory_release
{
    my ($self, $type, $reason) = @_;
    my @names = split(/ and /, $self->name_of);
    return [ $names[0], "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(-$reason)" ];
}

sub name_release
{
    my ($self, $type, $reason) = @_;
    return [ $self->name_of, "-".$self->source_of, $type, $EMPTY_STR,
        $self->notes_of."(-$reason)" ];
}
    
sub owned_name_release
{
    my ($self, $type, $reason) = @_;
    my $for = $type eq 'AN' ? 'For ' : '';
    return [ $self->permute($self->quoted_names_of->[0]), "-".$self->source_of, $type, $for.$self->name_of,
        $self->notes_of."(-$reason)" ];
}
    
sub owned_name_release_reverse
{
    my ($self, $type, $reason) = @_;
    my $for = $type eq 'AN' ? 'For ' : '';
    return [ $self->name_of, "-".$self->source_of, $type, $for.$self->permute($self->quoted_names_of->[0]),
        $self->notes_of."(-$reason)" ];
}
    
sub transfer_armory
{
    my ($self, $type) = @_;
    return [ $self->name_of, "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_joint_armory
{
    my ($self, $type) = @_;
    my @names = split(/ and /, $self->name_of);
    return [ $names[0], "-".$self->source_of, $type, 
        $self->armory_of, $self->notes_of."(JB: $names[1])(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_name
{
    my ($self, $type) = @_;
    return [ $self->quoted_names_of->[0], "-".$self->source_of, $type, 
        $self->name_of, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub transfer_owned_name
{
    my ($self, $type) = @_;
    my $text = $self->name_of;
    $text = "For $text" if $type eq 'AN';
    return [ $self->permute($self->quoted_names_of->[0]), "-".$self->source_of, $type, 
        $text, $self->notes_of."(-transferred to ".$self->quoted_names_of->[-1].")" ];
}

sub blanket_permission_name
{
    my ($self, $type, $item_type) = @_;
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

=cut

__PACKAGE__->meta->make_immutable;
1;

__END__

