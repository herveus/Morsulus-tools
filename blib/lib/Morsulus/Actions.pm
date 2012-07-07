package Morsulus::Actions;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('2012.005.002');
use Class::Std;
use Carp;
use Daud;
use Readonly;
use List::MoreUtils qw(uniq);

{
    my %raw_form_of : ATTR;
    my %cooked_form_of : ATTR;
    my %source_of : ATTR;
    my %name_of : ATTR;
    my %armory_of : ATTR;
    my %quoted_names_of : ATTR;
    my %second_name_of : ATTR;
    my %notes_of : ATTR;

    Readonly my $SEPARATOR => q{|};
    Readonly my $EMPTY_STR => q{};
    Readonly my $PERIOD    => q{.};
    Readonly my $NEWLINE => qq{\n};
    Readonly my $SPACE => qr/[ ]/;
    Readonly my $BRANCH => qr/(?: Kingdom | Principality | Barony |
        Province | Region | Shire | Canton | Stronghold | Port |
        College | Crown $SPACE Province | March | Dominion | Barony-Marche )/xms;
        
    sub as_str : STRINGIFY {
        my ( $self, $ident ) = @_;
        return sprintf '%s', join $SEPARATOR, $raw_form_of{$ident},
            $cooked_form_of{$ident}, $source_of{$ident}, $name_of{$ident},
            $armory_of{$ident}, $second_name_of{$ident},
            @{ $quoted_names_of{$ident}}, $notes_of{$ident};
    }

    sub BUILD {
        my ( $self, $ident, $arg_ref ) = @_;

        # suck in values, defaults
        $raw_form_of{$ident}    = Daud::daudify( $arg_ref->{action} );
        $source_of{$ident}      = $arg_ref->{source};
        $name_of{$ident}        = Daud::daudify( $arg_ref->{name} );
        $armory_of{$ident}      = Daud::daudify( $arg_ref->{armory} );
        $second_name_of{$ident} = exists $arg_ref->{name2}
            ? Daud::daudify( $arg_ref->{name2} )
            : $EMPTY_STR;
        $quoted_names_of{$ident} = [];
        $notes_of{$ident}        = $arg_ref->{notes} || $EMPTY_STR;

        # clean up raw action
        $cooked_form_of{$ident} = $raw_form_of{$ident};
        $cooked_form_of{$ident} =~ s{[ ][(]see[^)]+[)]\z}{}xsmi;
        if ( $cooked_form_of{$ident}
            =~ m{\A([^(]+)[ ]([(]important[ ]non-sca[ ].+[)])\z}ixsm )
        {
            $cooked_form_of{$ident} = $1;
            $notes_of{$ident}       .= $2;
        }
        $cooked_form_of{$ident} =~ s{\s+\z}{}xsm;
        
        $self->quote_names();
        $self->extract_quoted_names();
        $self->bracket_names();
        $self->normalize_cooked_action();
        $self->normalize_armory();
    }
    
    sub cooked_form_of_action
    {
        my ($self) = @_;
        return $cooked_form_of{ident($self)};
    }
    
    sub quoted_names
    {
        my ($self) = @_;
        return (@{$quoted_names_of{ident($self)}});
    }

    sub quote_names
    {
        my ($self) = @_;
        my $ident = ident($self);
        my $cooked_form = $cooked_form_of{$ident};
        if ($cooked_form =~ m/[Hh]eraldic $SPACE title $SPACE (.+
            $SPACE (?:Herald|Pursuivant) (?:$SPACE Extraordinary)?)
            /xsm)
        {
            my $title = $1;
            $cooked_form =~ s/$title/"$title"/ if $title !~ /"/;
            $cooked_form_of{$ident} = $cooked_form;
        }
    }
    
    sub bracket_names
    {
        my ($self) = @_;
        my $ident = ident($self);
        QNAME:
        for my $q_name (@{$quoted_names_of{$ident}}, $second_name_of{$ident}, $name_of{$ident})
        {
            if ($q_name =~ m/($SPACE 
                (?: Herald | Pursuivant | King $SPACE of $SPACE Arms | Herault) 
                (?: $SPACE Extraordinary)?)/xms)
            {
                my $title = $1;
                $q_name =~ s/$title/<$title>/;
            }
            elsif ($q_name =~ m/\A(.+)(, $SPACE $BRANCH (?: $SPACE of )? )\z/xms)
            {
                my $name = $1;
                my $branch = $2;
                next QNAME if $name eq 'Atenveldt';
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
        }
    }
    
    sub normalize_armory {
        my ($self) = @_;
        my $ident = ident($self);
        if ( $armory_of{$ident} ) {
            $armory_of{$ident} =~ s{\A\s+}{}xsm;
            $armory_of{$ident} =~ s{\s+\Z}{}xsm;
            $armory_of{$ident} =~ s{\s{2,}}{ }xsmg;
            $armory_of{$ident} .= $PERIOD;
        }
    }

    sub extract_quoted_names {
        my ($self) = @_;
        my $ident = ident($self);
        $quoted_names_of{$ident}
            = [ $cooked_form_of{$ident} =~ m{ " ([^"]+) " }gxsm ];
    }

    sub normalize_cooked_action {
        my ($self) = @_;
        my $ident = ident($self);
        $cooked_form_of{$ident} =~ s{"[^"]+"}{"x"}gxsm;
        $cooked_form_of{$ident} = lc $cooked_form_of{$ident};
        $cooked_form_of{$ident} =~ s{acceptance\ of\ transfer\ of\ (.+)\ from\ "x"}{$1}xsm;
    }

    sub permute {
        my ( $self, $string ) = @_;
        return $string if $string =~ /,/;

        $string =~ s/^the //i;
        if ( $string
            =~ /^(award|barony|braithrean|brotherhood|canton|casa|chateau|clann?|companions|companionate|company|crown principality|domus|dun|fellowship|freehold|guild|honou?r of the|house|household|hous|ha?us|h\{u'\}sa|keep|kingdom|league|l'ordre|la companie|maison|orde[nr]|ord[eo]|ordre|principality|province|riding|shire|university) (.*)/i
            )
        {
            $string = "$2, $1";
            if ( $string
                =~ /^(af|an|aus|d[eou]|de[ils]|dell[ao]|in|na|of?|van|vo[mn]) (.*)/i
                )
            {
                $string = "$2 $1";
            }
            if ( $string =~ /^(das|de[mn]?|der|die|el|l[ae]|les|the) (.*)/i )
            {
                $string = "$2 $1";
            }
        }
        return $string;
    }
    
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
        my ($self) = shift;
        my $ident = ident($self);
        if (not exists $transforms{$cooked_form_of{$ident}})
        {
            carp "Unknown action in $self";
            return;
        }
        
        my @entries;
        foreach my $act_sub (keys %{$transforms{$cooked_form_of{$ident}}})
        {
            my @action_results = $self->$act_sub(@{$transforms{$cooked_form_of{$ident}}->{$act_sub}});
            foreach my $action_result (@action_results)
            {
                push @entries, join($SEPARATOR, @$action_result);
            }
        }
        return join($NEWLINE, uniq(@entries), '');
    }
    
    sub name_for
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, "For $name_of{$ident}", 
            $notes_of{$ident} ];
    }
    
    sub name_change
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, "See $name_of{$ident}",
            $notes_of{$ident} ];
    }
    
    sub designator_change
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, $name_of{$ident},
            $notes_of{$ident} ];
    }
    
    sub order_name_change
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, $self->permute($quoted_names_of{$ident}->[1]),
            $notes_of{$ident} ];
    }
    
    sub order_name_change_reversed
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[1]),
            $source_of{$ident}, $type, $self->permute($quoted_names_of{$ident}->[0]),
            $notes_of{$ident} ];
    }
    
    sub name_correction
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, $name_of{$ident},
            $notes_of{$ident} ];
    }
    
    sub owned_name_correction
    {
        my ($self, $type, $note) = @_;
        my $ident = ident($self);
        $note = "($note)" if $note;
        $note ||= '';
        return [ $self->permute($quoted_names_of{$ident}->[1]),
            $source_of{$ident}, $type, $self->permute($quoted_names_of{$ident}->[0]),
            $notes_of{$ident}.$note ];
    }
    
    sub owned_name_correction_reversed
    {
        my ($self, $type, $note) = @_;
        my $ident = ident($self);
        $note = "($note)" if $note;
        $note ||= '';
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, $self->permute($quoted_names_of{$ident}->[1]),
            $notes_of{$ident}.$note ];
    }
    
    sub non_sca_title
    {
        my ($self) = @_;
        my $ident = ident($self);
        # yes, this is a bit of a hack to deal with hand jamming the source
        # ..and we need to chop the . off the end of the "blazon" which will
        # really be the real owner...
        $armory_of{$ident} =~ s/[.] \Z//x;
        return [ $name_of{$ident}, $source_of{$ident},
            't', $armory_of{$ident}, '(Owner: Laurel - admin)(Important Non-SCA title)' ];
    }
    
    sub name_owned_by
    {
        my ($self, $type, $note) = @_;
        my $ident = ident($self);
        $note = "($note)" if $note;
        $note ||= '';
        return [ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, $type, $self->quote_joint($name_of{$ident}),
            $notes_of{$ident}.$note ];
    }
    
    sub reference
    {
        my ($self) = @_;
        my $ident = ident($self);
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
            $notes_of{ident($self)} .= '(FIXME: add j record)';
            return join(" and ", map { "\"$_\"" } @parts);
        }
    }
    
    sub name
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        $type ||= 'N';
        return [ $name_of{$ident}, $source_of{$ident}, $type, $EMPTY_STR, 
            $notes_of{$ident}];
    }
    
    sub holding_name
    {
         my ($self) = @_;
         local $notes_of{ident($self)} .= "(Holding name)";
         return $self->name();
    }
    
    sub joint
    {
        my ($self) = @_;
        my $ident = ident($self);
        return [ $quoted_names_of{$ident}->[0], $source_of{$ident}, 'j',
            $name_of{$ident}, $notes_of{$ident} ];
    }
    
    sub badge_for
    {
        my ($self, $article) = @_;
        my $ident = ident($self);
        $article ||= $EMPTY_STR;
        return [ $name_of{$ident}, $source_of{$ident}, 'b', $armory_of{$ident},
            "$notes_of{$ident}(For $article$quoted_names_of{$ident}->[0])" ];
    }
    
    sub badge_for_2
    {
        my ($self, $article) = @_;
        my $ident = ident($self);
        $article ||= $EMPTY_STR;
        return [ $name_of{$ident}, $source_of{$ident}, 'b', $armory_of{$ident},
            "$notes_of{$ident}(For $article$quoted_names_of{$ident}->[1])" ];
    }
    
    sub normalize_joint_badge
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        $name_of{$ident} = $names[0];
        $quoted_names_of{$ident}->[0] = $names[1];
        return ($self->joint_badge(), $self->joint());
    }
    
    sub reblazon_joint_badge
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        $name_of{$ident} = $names[0];
        $quoted_names_of{$ident}->[0] = $names[1];
        return ($self->joint_badge());
    }
    
    sub joint_release
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        return [ $names[1], "-$source_of{$ident}", 'j',
            $names[0], "$notes_of{$ident}(-released)" ];
    }
    
    sub joint_transfer
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        return [ $names[1], "-$source_of{$ident}", 'j',
            $names[0], "$notes_of{$ident}(-transferred to $quoted_names_of{$ident}->[-1])" ];
    }
    
    sub normalize_joint_badge_for
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        my $joint_badge;
        {
            local $notes_of{$ident} .= "(For $quoted_names_of{$ident}->[0])";
            $quoted_names_of{$ident}->[0] = $names[1];
            $name_of{$ident} = $names[0];
            $joint_badge = $self->joint_badge();
        }
        return ($joint_badge, $self->joint());
    }
    
    sub normalize_joint_household_name
    {
        my ($self) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        return ([ $self->permute($quoted_names_of{$ident}->[0]),
            $source_of{$ident}, 'HN', join(" and ", map { "\"$_\"" } @names),
            $notes_of{$ident} ], 
            [$names[1], $source_of{$ident}, 'j', $names[0], $notes_of{$ident} ]);
    }
    
    sub joint_badge
    {
        my ($self) = @_;
        my $ident = ident($self);
        return $self->armory('b', "JB: $quoted_names_of{$ident}->[0]");
    }
    
    sub armory
    {
        my ($self, $type, $note) = @_;
        my $ident = ident($self);
        $note = "($note)" if $note;
        $note ||= '';
        return [ $name_of{$ident}, $source_of{$ident}, $type, $armory_of{$ident},
            $notes_of{$ident}.$note ];
    }
    
    sub armory_release
    {
        my ($self, $type, $reason) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        return [ $names[0], "-$source_of{$ident}", $type, 
            $armory_of{$ident}, "$notes_of{$ident}(-$reason)" ];
    }
    
    sub name_release
    {
        my ($self, $type, $reason) = @_;
        my $ident = ident($self);
        return [ $name_of{$ident}, "-$source_of{$ident}", $type, $EMPTY_STR,
            "$notes_of{$ident}(-$reason)" ];
    }
        
    sub owned_name_release
    {
        my ($self, $type, $reason) = @_;
        my $ident = ident($self);
        my $for = $type eq 'AN' ? 'For ' : '';
        return [ $self->permute($quoted_names_of{$ident}->[0]), "-$source_of{$ident}", $type, $for.$name_of{$ident},
            "$notes_of{$ident}(-$reason)" ];
    }
        
    sub owned_name_release_reverse
    {
        my ($self, $type, $reason) = @_;
        my $ident = ident($self);
        my $for = $type eq 'AN' ? 'For ' : '';
        return [ $name_of{$ident}, "-$source_of{$ident}", $type, $for.$self->permute($quoted_names_of{$ident}->[0]),
            "$notes_of{$ident}(-$reason)" ];
    }
        
    sub transfer_armory
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $name_of{$ident}, "-$source_of{$ident}", $type, 
            $armory_of{$ident}, "$notes_of{$ident}(-transferred to $quoted_names_of{$ident}->[-1])" ];
    }
    
    sub transfer_joint_armory
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        my @names = split(/ and /, $name_of{$ident});
        return [ $names[0], "-$source_of{$ident}", $type, 
            $armory_of{$ident}, "$notes_of{$ident}(JB: $names[1])(-transferred to $quoted_names_of{$ident}->[-1])" ];
    }
    
    sub transfer_name
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        return [ $quoted_names_of{$ident}->[0], "-$source_of{$ident}", $type, 
            $name_of{$ident}, "$notes_of{$ident}(-transferred to $quoted_names_of{$ident}->[-1])" ];
    }
    
    sub transfer_owned_name
    {
        my ($self, $type) = @_;
        my $ident = ident($self);
        my $text = $name_of{$ident};
        $text = "For $text" if $type eq 'AN';
        return [ $self->permute($quoted_names_of{$ident}->[0]), "-$source_of{$ident}", $type, 
            $text, "$notes_of{$ident}(-transferred to $quoted_names_of{$ident}->[-1])" ];
    }
    
    sub blanket_permission_name
    {
        my ($self, $type, $item_type) = @_;
        my $ident = ident($self);
        local ($notes_of{$ident});
        my $notes = $notes_of{$ident};
        if ($notes)
        {
            $notes =~ s/[(] with/(Blanket permission to conflict with $item_type granted $source_of{$ident} with/xsm;
        }
        else
        {
            $notes = "(Blanket permission to conflict with $item_type granted $source_of{$ident})";
        }
        $type ||= 'N';
        return [ $name_of{$ident}, $source_of{$ident}, $type, $EMPTY_STR, 
            $notes ];
    }
    
    sub blanket_permission_secondary_name
    {
        my ($self, $type, $item_type) = @_;
        my $ident = ident($self);
        my $notes = $notes_of{$ident};
        if ($notes)
        {
            $notes =~ s/[(] with/(Blanket permission to conflict with $item_type granted $source_of{$ident} with/xsm;
            $notes_of{$ident} = $notes;
        }
        else
        {
            $notes_of{$ident} = "(Blanket permission to conflict with $item_type granted $source_of{$ident})";
        }
        $type ||= 'N';
        return [ $quoted_names_of{$ident}->[0], $source_of{$ident}, $type, $name_of{$ident}, 
            $notes_of{$ident} ];
    }
    
    sub blanket_permission_armory
    {
        my ($self, $type, $item_type) = @_;
        my $ident = ident($self);
        my $additional_note = $quoted_names_of{$ident}->[0] || '';
        $additional_note = ' '.$additional_note if $additional_note;
        $type ||= 'd';
        my $notes = $notes_of{$ident};
        if ($notes)
        {
            $notes =~ s/[(] with/(Blanket permission to conflict with $item_type$additional_note granted $source_of{$ident} with/xsm;
        }
        else
        {
            $notes = "(Blanket permission to conflict with $item_type$additional_note granted $source_of{$ident})";
        }
        return [ $name_of{$ident}, $source_of{$ident}, $type, $armory_of{$ident}, 
            $notes];
    }
    
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Morsulus::Actions - Convert actions extracted from the XML into useful forms.


=head1 VERSION

This documentation refers to Morsulus::Actions version 0.0.1.


=head1 SYNOPSIS

    use Morsulus::Actions;
    
    # $action_line is output from the xml2actions filter
    # $date is yymm
    my (undef, $kingdom, $action, $name, $armory, $name2) = split(/[|]/, $action_line);
    
    my $action = Morsulus::Actions->new({action => $action,
        source => "$kingdom$date", 
        name => $name,
        armory => $armory,
        name2 => $name2});
    
    # output for db file format
    print $action->make_db_entries();
    
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Morsulus::Actions requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-morsulus-actions@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Michael Houghton  C<< <herveus@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Michael Houghton C<< <herveus@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
