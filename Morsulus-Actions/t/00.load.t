use Test::More 'no_plan';
use Test::Exception;

BEGIN {
use_ok( 'Morsulus::Actions' );
}

diag( "Testing Morsulus::Actions $Morsulus::Actions::VERSION" );

my @actions_and_results = test_actions_and_results();
while (@actions_and_results)
{
    my $action_line = shift @actions_and_results;
    my $expected_result = shift @actions_and_results;
    my ( undef, $kingdom, $action, $name, $armory, $name2, $notes )
            = split( /[|]/, $action_line );
    my $act = Morsulus::Actions->new(
    {   action => $action,
        source => "9999$kingdom",
        name => $name,
        armory => $armory,
        name2 => $name2,
        notes => $notes
    });
    print $act->as_str."\n";
    my $actual_result = $act->make_db_entries;
    is $actual_result, $expected_result, $action_line;
}

sub test_actions_and_results
{
    return (
'ufo000570|L|Acceptance of transfer of heraldic title "Batonvert Herald" from "Society for Creative Anachronism"|Bruce Draconarius of Mistholme||' =>
'Batonvert< Herald>|9999L|t|Bruce Draconarius of Mistholme|
',
'ufo000572|L|Reblazon and redesignation of badge for "Office of the Chatelaine and Office of the Hospitaller"|Society for Creative Anachronism|Vert, a key palewise wards to sinister base Or|' =>
'Society for Creative Anachronism|9999L|b|Vert, a key palewise wards to sinister base Or.|(For Office of the Chatelaine and Office of the Hospitaller)
',
'ufo000617|T|device changed/retained|Gabriele Parr Pembroke|Purpure semy of mullets argent, a unicorn\'s head couped Or|' =>
'Gabriele Parr Pembroke|9999T|b|Purpure semy of mullets argent, a unicorn\'s head couped Or.|
Gabriele Parr Pembroke|-9999T|d|Purpure semy of mullets argent, a unicorn\'s head couped Or.|(-changed/retained)
',
'ufo000461|w|Addition of joint owner "Kaspar von Helmenstede" for badge|Eleyne de Comnocke|(Fieldless) A mascle quarterly purpure and Or|' =>
'Eleyne de Comnocke|9999w|b|(Fieldless) A mascle quarterly purpure and Or.|(JB: Kaspar von Helmenstede)
Kaspar von Helmenstede|9999w|j|Eleyne de Comnocke|
',
'ufo000492|O|Ancient Arms|Blackwater Keep<, Shire of>|Gules, eight scorpions in annulo, facing outward, all within a laurel wreath Or|' =>
'Blackwater Keep<, Shire of>|9999O|b|Gules, eight scorpions in annulo, facing outward, all within a laurel wreath Or.|(Ancient Arms)
',
'ufo000151|N|Branch name correction from "St. Bunstable<, College of>"|Saint Bunstable<, College of>||' =>
'St. Bunstable<, College of>|9999N|BNc|Saint Bunstable<, College of>|
',
'ufo000184|A|Joint household name "House Blade and Bone" and badge|Ysabel de Rouen and Gawayn Langknyfe|Per pale purpure and sable, in saltire a bone argent surmounting a sword Or|' =>
'Blade and Bone, House|9999A|HN|"Ysabel de Rouen" and "Gawayn Langknyfe"|
Gawayn Langknyfe|9999A|j|Ysabel de Rouen|
Ysabel de Rouen|9999A|b|Per pale purpure and sable, in saltire a bone argent surmounting a sword Or.|(For House Blade and Bone)(JB: Gawayn Langknyfe)
',
'err000000|E|variant correction from "Khadijah"|Khadijah of House Hakim||
' =>
'Khadijah|9999E|vc|Khadijah of House Hakim|
',
'err000022|C|Blazon correction for badge for "House Silverswan"|Thin Robert of Lawrence|Purpure, a swan volant and in dexter chief seven mullets of seven points in annulo argent|
' =>
'Thin Robert of Lawrence|9999C|b|Purpure, a swan volant and in dexter chief seven mullets of seven points in annulo argent.|(For House Silverswan)
',
'err000023|C|corrected blazon|Thin Robert of Lawrence|Purpure, a swan volant and in dexter chief seven mullets in annulo argent|
' =>
'Thin Robert of Lawrence|-9999C|b|Purpure, a swan volant and in dexter chief seven mullets in annulo argent.|(-corrected blazon)
',
'ufo000059|N|Branch name and badge|Wyverfeld<, Shire of>|Checky argent and vert, a wyvern\'s wing gules|
' =>
'Wyverfeld<, Shire of>|9999N|b|Checky argent and vert, a wyvern\'s wing gules.|
Wyverfeld<, Shire of>|9999N|BN||
',
'ufo000320|T|Order name "Order of the Golden Standard" and badge association|Marcaster<, Barony of>|Azure, issuant from the battlements of a demi-tower a banner Or, a tierce wavy paly wavy argent and azure|
' =>
'Marcaster<, Barony of>|-9999T|b|Azure, issuant from the battlements of a demi-tower a banner Or, a tierce wavy paly wavy argent and azure.|(-associated with order name)
Marcaster<, Barony of>|9999T|b|Azure, issuant from the battlements of a demi-tower a banner Or, a tierce wavy paly wavy argent and azure.|(For Order of the Golden Standard)
Golden Standard, Order of the|9999T|O|Marcaster<, Barony of>|
',
'ufo000328|T|Badge association with order name "Order of the Golden Lance of Trimaris"|Trimaris<, Kingdom of>|Azure semy of triskeles argent, a lance Or|
' =>
'Trimaris<, Kingdom of>|-9999T|b|Azure semy of triskeles argent, a lance Or.|(-associated with order name)
Trimaris<, Kingdom of>|9999T|b|Azure semy of triskeles argent, a lance Or.|(For Order of the Golden Lance of Trimaris)
',
'ufo000329|T|Badge association with guild name "Scribes Guild of Trimaris"|Trimaris<, Kingdom of>|Azure, two quill pens bases crossed in saltire, in chief a triskele, all within a bordure argent|
' =>
'Scribes Guild of Trimaris|9999T|R|See Trimaris<, Kingdom of>|
Trimaris<, Kingdom of>|-9999T|b|Azure, two quill pens bases crossed in saltire, in chief a triskele, all within a bordure argent.|(-associated with guild name)
Trimaris<, Kingdom of>|9999T|b|Azure, two quill pens bases crossed in saltire, in chief a triskele, all within a bordure argent.|(For Scribes Guild of Trimaris)
',
'ufo000077|Q|Augmentation change|Minowara Kiritsubo|Sable, an annulet surmounted by three dragon\'s claws in pall conjoined at the tips argent between, as an augmentation, in pale in annulo an Oriental dragon passant to sinister and another passant inverted and in fess two coronets Or|
' =>
'Minowara Kiritsubo|9999Q|a|Sable, an annulet surmounted by three dragon\'s claws in pall conjoined at the tips argent between, as an augmentation, in pale in annulo an Oriental dragon passant to sinister and another passant inverted and in fess two coronets Or.|
',
'ufo000078|Q|augmentation changed/released|Minowara Kiritsubo|Sable, an annulet surmounted by three dragon\'s claws in pall conjoined at the tips argent between, as an augmentation, in fess two bezants and in pale in annulo an Oriental dragon passant to sinister and another passant inverted Or|
' =>
'Minowara Kiritsubo|-9999Q|a|Sable, an annulet surmounted by three dragon\'s claws in pall conjoined at the tips argent between, as an augmentation, in fess two bezants and in pale in annulo an Oriental dragon passant to sinister and another passant inverted Or.|(-changed/released)
',
'ufo000091|D|alternate name change from "Aryanwy Lyghtefote" to "Aleyn Lyghtefote"|Aryanhwy merch Catmael||
' =>
'Aryanwy Lyghtefote|9999D|ANC|Aleyn Lyghtefote|
',
'ufo000117|E|Holding name and household name "House of the Two Loons" (see RETURNS for name)|Roland of Endeweard||
' =>
'Roland of Endeweard|9999E|N||(Holding name)
Two Loons, House of the|9999E|HN|Roland of Endeweard|
',
'ufo000146|S|Release of order name "Order of the Broken Bank"|Meridies<, Kingdom of>||
' =>
'Broken Bank, Order of the|-9999S|O|Meridies<, Kingdom of>|(-released)
',
'ufo000204|O|Acceptance of badge transfer from "Cathyn Fitzgerald"|Alia Marie de Blois|Argent, a cross triple-parted and fretted gules and a bordure potenty sable|
' =>
'Alia Marie de Blois|9999O|b|Argent, a cross triple-parted and fretted gules and a bordure potenty sable.|
',
'ufo000160|Q|Order name change to "Award of the Fountain" from "Order of the Fountain"|Atlantia<, Kingdom of>||
' =>
'Fountain, Order of the|9999Q|OC|Fountain, Award of the|
',
'ufo000160|Q|Order name change from "Award of the Fountain" to "Order of the Fountain"|Atlantia<, Kingdom of>||
' =>
'Fountain, Award of the|9999Q|OC|Fountain, Order of the|
',
'ufo000273|w|Blanket permission to conflict with device "at least one countable step"|John Bucstan de Glonn|Per chevron azure and gules, a fleur-de-lys and an orle Or|
' =>
'John Bucstan de Glonn|9999w|BP|Per chevron azure and gules, a fleur-de-lys and an orle Or.|(Blanket permission to conflict with device at least one countable step granted 9999w)
',
'ufo000100|m|Holding name and badge (see RETURNS for name and device)|Marsha of Ealdormere|(Fieldless) A peacock close to sinister proper|
' =>
'Marsha of Ealdormere|9999m|b|(Fieldless) A peacock close to sinister proper.|
Marsha of Ealdormere|9999m|N||(Holding name)
',
'ufo000167|L|Arms (Important non-SCA armory)|Andorra|Quarterly: first, bishopric of Urgel (Gules, a mitre Or); second, Foix (Or, three pallets gules); third, Catalonia (Or, four pallets gules); fourth, Bearn (Or, in pale two cows passant gules)|
' =>
'Andorra|9999L|d|Quarterly: first, bishopric of Urgel (Gules, a mitre Or); second, Foix (Or, three pallets gules); third, Catalonia (Or, four pallets gules); fourth, Bearn (Or, in pale two cows passant gules).|(Important non-SCA armory)
',
'ufo000168|L|Flag (Important non-SCA armory)|Lesotho|Per fess azure and vert, on a fess argent a conical hat sable|
' =>
'Lesotho|9999L|b|Per fess azure and vert, on a fess argent a conical hat sable.|(Important non-SCA armory)
',
'ufo000173|L|Ancient arms (Important non-SCA armory)|Venezuela|Per fess enarched, per pale gules and Or and azure, a garb Or, a sheaf of weapons proper surmounted by two banners in saltire per fess Or and gules, a fess azure, and a horse courant regardant contourny argent atop a base vert|
' =>
'Venezuela|9999L|b|Per fess enarched, per pale gules and Or and azure, a garb Or, a sheaf of weapons proper surmounted by two banners in saltire per fess Or and gules, a fess azure, and a horse courant regardant contourny argent atop a base vert.|(Important non-SCA armory)(Ancient Arms)
',
'ufo000166|K|Blanket permission to conflict with name "Kit Fox"|Kit Fox||
' =>
'Kit Fox|9999K|BP||(Blanket permission to conflict with name granted 9999K)
',
'ufo000049|N|Heraldic title "Black Antelope Herald"|An Tir, Kingdom of||
' => 
'Black Antelope< Herald>|9999N|t|An Tir<, Kingdom of>|
',
'ufo000026|A|Order name "Order of the Dogs Jambe" and badge (see RETURNS for other order name and badges)|Atenveldt, Barony of|(Fieldless) An annulet checky azure and argent fimbriated gules pendant therefrom five hawks\' bells Or|
' =>
'Atenveldt, Barony of|9999A|b|(Fieldless) An annulet checky azure and argent fimbriated gules pendant therefrom five hawks\' bells Or.|(For Order of the Dogs Jambe)
Dogs Jambe, Order of the|9999A|O|Atenveldt, Barony of|
',
'ufo000048|D|Heraldic will|John Peregrine of Restormel||
' =>
'John Peregrine of Restormel|9999D|W||
',
'ufo000055|E|Badge and association with order name "Order of the Sun and Soil"|Beyond the Mountain, Barony|Per fess azure and vert, in canton a bezant|
' =>
'Beyond the Mountain<, Barony>|9999E|b|Per fess azure and vert, in canton a bezant.|(For Order of the Sun and Soil)
',
'ufo000045|R|Heraldic title "Double Quaterfoyle Herald"|Artemisia, Kingdom of||
', =>
'Double Quaterfoyle< Herald>|9999R|t|Artemisia<, Kingdom of>|
',
'ufo000046|R|Transfer of heraldic title Double Quaterfoyle Herald to "Yin Mei Li"|Artemisia, Kingdom of||
' =>
'Double Quaterfoyle< Herald>|-9999R|t|Artemisia<, Kingdom of>|(-transferred to Yin Mei Li)
',
'ufo000248|E|Reblazon of badge|Abelard Kif de Marseilles| Sable, a tower conjoined to sinister with a wall, all issuant from sinister base, in chief a cloud Or|
' =>
'Abelard Kif de Marseilles|9999E|b|Sable, a tower conjoined to sinister with a wall, all issuant from sinister base, in chief a cloud Or.|
',
'ufo000080|R|Reblazon of badge for "Order of the Talon d\'Or"|One Thousand Eyes, Barony of|(Fieldless)  A dragon\'s jamb inverted couped Or maintaining in its talons a roundel, overall in saltire two rapiers inverted azure|
' =>
'One Thousand Eyes<, Barony of>|9999R|b|(Fieldless) A dragon\'s jamb inverted couped Or maintaining in its talons a roundel, overall in saltire two rapiers inverted azure.|(For Order of the Talon d\'Or)
',
'ufo000054|E|Order name "Order of the Companions of the Holly" and badge|Beyond the Mountain, Barony|(Fieldless) On a holly leaf bendwise vert an acorn bendwise argent|
' =>
'Beyond the Mountain<, Barony>|9999E|b|(Fieldless) On a holly leaf bendwise vert an acorn bendwise argent.|(For Order of the Companions of the Holly)
Companions of the Holly, Order of the|9999E|O|Beyond the Mountain<, Barony>|
',
'ufo000175|E|Guild name "Saint Bavons Company"|Brianna McBain||
' =>
'Saint Bavons Company|9999E|HN|Brianna McBain|(Guild)
',
'ufo000118|L|Correction of heraldic title from "Ormond of Ormonde Pursuivant"|Ormond Pursuivant||
' =>
'Ormond of Ormonde< Pursuivant>|9999L|Nc|Ormond< Pursuivant>|
',
'ufo000163|L|Important non-SCA arms|Rohan|Vert, a horse courant argent|
' => 
'Rohan|9999L|d|Vert, a horse courant argent.|(Important non-SCA armory)
',
'ufo000036|N|Badge transfer to "Tir Rígh, Principality of"|An Tir, Kingdom of|Azure, a compass star voided argent|
' =>
'An Tir<, Kingdom of>|-9999N|b|Azure, a compass star voided argent.|(-transferred to Tir R{i\'}gh<, Principality of>)
',
'ufo000002|N|Release of order name "Fellowship An Rose Dhu" and badge|An Tir, Kingdom of|Or, a rose sable within a bordure vert|
' =>
'An Tir<, Kingdom of>|-9999N|b|Or, a rose sable within a bordure vert.|(-released)
Rose Dhu, Fellowship An|-9999N|O|An Tir<, Kingdom of>|(-released)
',
'ufo000087|K|Alternate name correction to "Kumagaya Yatarou Moritomo" from "Kumagaya Yatarou Morimoto"|Gotfridus von Schwaben||
' =>
'Kumagaya Yatarou Morimoto|9999K|Nc|Kumagaya Yatarou Moritomo|
',
'ufo000227|N|Heraldic title (important non-SCA title)|Algarve King of Arms|Portugal|
' =>
'Algarve< King of Arms>|9999N|t|Portugal|(Owner: Laurel - admin)(Important Non-SCA title)
',
'ufo000002|L|Important non-SCA badge|Ulster|Argent, a dexter hand appaumy gules|
' =>
'Ulster|9999L|b|Argent, a dexter hand appaumy gules.|(Important non-SCA badge)
',
'ufo000114|K|Standard augmentation|Calontir, Kingdom of|Purpure, a cross of Calatrava and a bordure Or|
' =>
'Calontir<, Kingdom of>|9999K|a|Purpure, a cross of Calatrava and a bordure Or.|(Standard augmentation)
',
'ufo000060|A|Exchange of primary and alternate name "Tatiana Laski Krakowska"|Sancha Galindo de Toledo||
' =>
'Sancha Galindo de Toledo|-9999A|AN|For Tatiana Laski Krakowska|(-converted to primary name)
Tatiana Laski Krakowska|9999A|AN|For Sancha Galindo de Toledo|
Tatiana Laski Krakowska|9999A|NC|See Sancha Galindo de Toledo|
',
'ufo000060|A|Exchange of primary and alternate name "Tatiana Laski Krakowska" and device|Sancha Galindo de Toledo|Azure, an owl contourny Or between in cross four mullets and in saltire four roundels argent|
' =>
'Tatiana Laski Krakowska|9999A|AN|For Sancha Galindo de Toledo|
Tatiana Laski Krakowska|9999A|NC|See Sancha Galindo de Toledo|
Sancha Galindo de Toledo|9999A|d|Azure, an owl contourny Or between in cross four mullets and in saltire four roundels argent.|
Tatiana Laski Krakowska|-9999A|AN|For Sancha Galindo de Toledo|(-converted to primary name)
',
'ufo000119|T|Name change from "Richard of Marcaster" retained|Richard Clitherow||
' =>
'Richard of Marcaster|9999T|AN|For Richard Clitherow|
Richard of Marcaster|9999T|NC|See Richard Clitherow|
',
'ufo000073|C|Name change from "Islyle le Gannoker de Gavain" and badge change for "House Estoc"|Illuminada Eugenia de Guadalupe y Godoy|(Fieldless) An open book argent and overall a estoc inverted Or|
' =>
'Illuminada Eugenia de Guadalupe y Godoy|9999C|b|(Fieldless) An open book argent and overall a estoc inverted Or.|(For House Estoc)
Islyle le Gannoker de Gavain|9999C|NC|See Illuminada Eugenia de Guadalupe y Godoy|
',
q%ufo000101|K|Association of alternate name "Giudo di Niccolo Brunelleschi" and badge|Jibra'il `A{t.}{t.}{a-}r|Purpure, a pale argent surmounted by a slip of willow bendwise sinister throughout Or|
% =>
q%Jibra'il `A{t.}{t.}{a-}r|-9999K|b|Purpure, a pale argent surmounted by a slip of willow bendwise sinister throughout Or.|(-associated with alternate name)
Jibra'il `A{t.}{t.}{a-}r|9999K|b|Purpure, a pale argent surmounted by a slip of willow bendwise sinister throughout Or.|(For Giudo di Niccolo Brunelleschi)
%,
q%ufo000102|K|Association of household name "Compagnia dell'Arcangelo Gabriele" and badge|Jibra'il `A{t.}{t.}{a-}r|(Fieldless) A cross of four lozenges quarterly gules and Or|
% =>
q%Jibra'il `A{t.}{t.}{a-}r|-9999K|b|(Fieldless) A cross of four lozenges quarterly gules and Or.|(-associated with household name)
Jibra'il `A{t.}{t.}{a-}r|9999K|b|(Fieldless) A cross of four lozenges quarterly gules and Or.|(For Compagnia dell'Arcangelo Gabriele)
%,
'ufo000118|K|Change of alternate name to "Adam Lovecraft" from "Rinaldo Moretto da Brescia"|Modar Neznanich||
' =>
'Rinaldo Moretto da Brescia|9999K|ANC|Adam Lovecraft|
',
'ufo000145|E|Acceptance of device transfer from "Bearengaer hinn Raudi"|Raymond of Stratford|Gules, a hammer bendwise argent|
' =>
'Raymond of Stratford|9999E|d|Gules, a hammer bendwise argent.|
',
'ufo000139|E|Household name change to "Two Tigers Tavern" from "House of the Two Tigers"|Jehan Yves de Chateau Thiery||
' =>
'Two Tigers, House of the|9999E|HNC|Two Tigers Tavern|
',
q%ufo000106|K|Blanket permission to conflict with household name "Compagnia dell'Arcangelo Gabriele"|Jibra'il `A{t.}{t.}{a-}r||
% =>
q%Compagnia dell'Arcangelo Gabriele|9999K|BP|Jibra'il `A{t.}{t.}{a-}r|(Blanket permission to conflict with household name granted 9999K)
%,
'ufo000115|E|Order name "Order of the Sea Dog of Østgarðr" and badge|Østgarðr, Crown Province of|(Fieldless) A sea-dog rampant azure, finned Or|
' =>
'{O/}stgar{dh}r<, Crown Province of>|9999E|b|(Fieldless) A sea-dog rampant azure, finned Or.|(For Order of the Sea Dog of {O/}stgar{dh}r)
Sea Dog of {O/}stgar{dh}r, Order of the|9999E|O|{O/}stgar{dh}r<, Crown Province of>|
',
'ufo000029|X|Transfer of household name "Daoine Céud Fáilte" and badge to "Harold Shieldbearer"|Enoch Crandall mac Cranon|Counter-ermine, a cross engrailed gules, overall a crane rising, wings elevated and addorsed, argent|
' => 
q%Enoch Crandall mac Cranon|-9999X|b|Counter-ermine, a cross engrailed gules, overall a crane rising, wings elevated and addorsed, argent.|(-transferred to Harold Shieldbearer)
Daoine C{e'}ud F{a'}ilte|-9999X|HN|Enoch Crandall mac Cranon|(-transferred to Harold Shieldbearer)
%,
'ufo000124|K|Badge for alternate name "Szabó Maria"|Ki no Kotori|Argent, a fox doubly queued passant contourny gules, in chief two holly sprigs bendwise sinister vert fructed gules|
' =>
q%Ki no Kotori|9999K|b|Argent, a fox doubly queued passant contourny gules, in chief two holly sprigs bendwise sinister vert fructed gules.|(For Szab{o'} Maria)
%,
'ufo000111|C|Transfer of household name "La Companie du Chateau Corbeau" and badge to "Jason Thomas the Wanderer"|Morgaine FitzStephen|Per bend sable and argent, a castle and a corbie close contourny counterchanged|
' =>
'Morgaine FitzStephen|-9999C|b|Per bend sable and argent, a castle and a corbie close contourny counterchanged.|(-transferred to Jason Thomas the Wanderer)
Chateau Corbeau, La Companie du|-9999C|HN|Morgaine FitzStephen|(-transferred to Jason Thomas the Wanderer)
',
'ufo000108|E|Name change from "Lachlann mac Lachlainn" retained and device|Lachlann Graheme|Per pale argent and vert, on a tower per pale azure and argent an ivy vine bendwise sinister per pale argent and vert|
' =>
'Lachlann mac Lachlainn|9999E|AN|For Lachlann Graheme|
Lachlann mac Lachlainn|9999E|NC|See Lachlann Graheme|
Lachlann Graheme|9999E|d|Per pale argent and vert, on a tower per pale azure and argent an ivy vine bendwise sinister per pale argent and vert.|
',
'ufo000064|E|Badge|Black Rose, March of the|(Fieldless) A rose sable, barbed and charged with the letters "B" and "R"; argent|
' => 
'Black Rose,< March of> the|9999E|b|(Fieldless) A rose sable, barbed and charged with the letters "B" and "R"; argent.|
',
'ufo000004|H|Redesignation of badge as device|Cynwyl MacDaire|Argent, two piles in point sable, each charged with a plate|
' =>
'Cynwyl MacDaire|9999H|d|Argent, two piles in point sable, each charged with a plate.|
Cynwyl MacDaire|-9999H|b|Argent, two piles in point sable, each charged with a plate.|(-converted to device)
',
'ufo000062|C|Release of alternate name "Medb ingen uí Fháeláin" and association of device with primary name|Mayy bint Khalil|Sable, a pair of wings argent between three estoiles Or|
' => 
q%Mayy bint Khalil|9999C|d|Sable, a pair of wings argent between three estoiles Or.|
Mayy bint Khalil|-9999C|b|Sable, a pair of wings argent between three estoiles Or.|(-associated with primary name)
Medb ingen u{i'} Fh{a'}el{a'}in|-9999C|AN|For Mayy bint Khalil|(-released)
%,
'ufo000060|C|Name change from "Mæva Svansdóttir" retained|Mayy bint Khalil||
' =>
q%M{ae}va Svansd{o'}ttir|9999C|AN|For Mayy bint Khalil|
M{ae}va Svansd{o'}ttir|9999C|NC|See Mayy bint Khalil|
%,
'ufo000099|K|Transfer of badge to "Ravasz János and Kajsa Nikulasdotter"|Three Rivers, Barony of|Lozengy argent and vert, a pall wavy azure fimbriated Or|
' => 
q%Three Rivers<, Barony of>|-9999K|b|Lozengy argent and vert, a pall wavy azure fimbriated Or.|(-transferred to Ravasz J{a'}nos and Kajsa Nikulasdotter)
%,
'ufo000107|C|Acceptance of transfer of household name "La Companie du Chateau Corbeau" and badge from "Morgaine FitzStephen"|Jason Thomas the Wanderer|Per bend sable and argent, a castle and a corbie close contourny counterchanged|
' =>
'Jason Thomas the Wanderer|9999C|b|Per bend sable and argent, a castle and a corbie close contourny counterchanged.|(For La Companie du Chateau Corbeau)
Chateau Corbeau, La Companie du|9999C|HN|Jason Thomas the Wanderer|
',
'ufo000017|N|Household name "Fraternitas domus Sancti Jacobi Germanorum Acconensis"|Wilrich von Hessen||
' =>
'Fraternitas domus Sancti Jacobi Germanorum Acconensis|9999N|HN|Wilrich von Hessen|
',
'ufo000001|H|device reblazoned|Myrkfaelinn, Dominion of|Sable, a candle enflamed and environed of a laurel wreath proper|
' =>
'Myrkfaelinn<, Dominion of>|-9999H|d|Sable, a candle enflamed and environed of a laurel wreath proper.|(-reblazoned)
',
'err000000|X|Correction of name from "Dierdre de Clarik"|Deirdre de Clarik||
' =>
'Dierdre de Clarik|9999X|Nc|Deirdre de Clarik|
',
'ufo000180|N|Order name correction to "Calatrava, Order of" from "Calatrav, Order of" (important non-SCA order)|Spain||
' =>
'Calatrav, Order of|9999N|OC|Calatrava, Order of|(important non-SCA order)(-corrected)
',
'ufo000180|N|Order name correction to "Order of Calatrava" from "Calatrav, Order of" (important non-SCA order)|Spain||
' =>
'Calatrav, Order of|9999N|OC|Calatrava, Order of|(important non-SCA order)(-corrected)
',
'ufo000062|Q|Branch name change from "Canton of Hindscroft" and device change|Middlegate, Canton of|Or, a portcullis and on a base gules a laurel wreath Or|
' =>
'Hindscroft<, Canton of>|9999Q|BNC|See Middlegate<, Canton of>|
Middlegate<, Canton of>|9999Q|d|Or, a portcullis and on a base gules a laurel wreath Or.|
',
'ufo000062|Q|Branch name change from "Canton of the Hindscroft" and device change|Middlegate, Canton of|Or, a portcullis and on a base gules a laurel wreath Or|
' =>
'Hindscroft,< Canton of> the|9999Q|BNC|See Middlegate<, Canton of>|
Middlegate<, Canton of>|9999Q|d|Or, a portcullis and on a base gules a laurel wreath Or.|
',
'ufo000074|Q|Transfer of name and device to "Ysolt la Bretonne"|Wil Elmsford|Vert, a unicorn\'s head couped between three quatrefoils barbed argent|
' =>
'Wil Elmsford|-9999Q|d|Vert, a unicorn\'s head couped between three quatrefoils barbed argent.|(-transferred to Ysolt la Bretonne)
Ysolt la Bretonne|-9999Q|N|Wil Elmsford|(-transferred to Ysolt la Bretonne)
',
'ufo000075|Q|Acceptance of transfer of alternate name "Wil Elmsford" and badge from "Wil Elmsford"|Ysolt la Bretonne|Vert, a unicorn\'s head couped between three quatrefoils barbed argent|
' =>
'Wil Elmsford|9999Q|AN|For Ysolt la Bretonne|
Ysolt la Bretonne|9999Q|b|Vert, a unicorn\'s head couped between three quatrefoils barbed argent.|(For Wil Elmsford)
', 
'ufo000154|n|Badge association for "the populace"|Northshield, Kingdom of|(Fieldless) A griffin passant Or|
' =>
'populace|9999n|R|See Northshield<, Kingdom of>|
Northshield<, Kingdom of>|-9999n|b|(Fieldless) A griffin passant Or.|(-associated with usage)
Northshield<, Kingdom of>|9999n|b|(Fieldless) A griffin passant Or.|(For the populace)
',
'ufo000032|X|Release of order name "Companions of the Star of Merit"|Ansteorra, Kingdom of||
' =>
'Star of Merit, Companions of the|-9999X|O|Ansteorra<, Kingdom of>|(-released)
',
'ufo000218|n|Award name "Award of the Cygnus" and badge association|Northshield, Kingdom of|(Fieldless) A swan naiant contourny Or|
' =>
'Northshield<, Kingdom of>|-9999n|b|(Fieldless) A swan naiant contourny Or.|(-associated with order name)
Northshield<, Kingdom of>|9999n|b|(Fieldless) A swan naiant contourny Or.|(For Award of the Cygnus)
Cygnus, Award of the|9999n|O|Northshield<, Kingdom of>|
',
'ufo000033|K|Name change from "Derek Logan" retained and device change|Randal Logan of Knightsbridge|Per chevron sable and vert, a dragon couchant, in chief two mullets of seven points argent|
' =>
'Derek Logan|9999K|AN|For Randal Logan of Knightsbridge|
Derek Logan|9999K|NC|See Randal Logan of Knightsbridge|
Randal Logan of Knightsbridge|9999K|d|Per chevron sable and vert, a dragon couchant, in chief two mullets of seven points argent.|
',
'ufo000179|E|Device|Selve d\'Aure, Shire of La|Or, three pine trees couped vert and on a chief indented azure a laurel wreath between two mullets Or|
' =>
'Selve d\'Aure,< Shire of> La|9999E|d|Or, three pine trees couped vert and on a chief indented azure a laurel wreath between two mullets Or.|
',
'ufo000022|N|Badge for "University of Avacal" reference|Avacal, Principality of|(Fieldless) On an open book quarterly argent and Or, in fess an Arabic lamp reversed sable lit and a griffin\'s head erased gules|
' =>
'Avacal, University of|9999N|R|See Avacal<, Principality of>|
Avacal<, Principality of>|9999N|b|(Fieldless) On an open book quarterly argent and Or, in fess an Arabic lamp reversed sable lit and a griffin\'s head erased gules.|(For University of Avacal)
',
'ufo000025|N|Name change from "Muirgheal inghean Labhrain" and badge change|Doireann Dechti|(Fieldless) A bear rampant within and conjoined to an annulet sable|
' =>
'Muirgheal inghean Labhrain|9999N|NC|See Doireann Dechti|
Doireann Dechti|9999N|b|(Fieldless) A bear rampant within and conjoined to an annulet sable.|
',
'ufo000029|X|Blanket permission to conflict with badge|Darius of the Bells|(Fieldless) A mullet of four points within and conjoined to an annulet Or||(with non-identity)|
' =>
'Darius of the Bells|9999X|BP|(Fieldless) A mullet of four points within and conjoined to an annulet Or.|(Blanket permission to conflict with badge granted 9999X with non-identity)
',
'ufo000131|K|Name reconsideration to "Purple Quill Herald" from "Purpure Quill Herald"|Calontir, Kingdom of||
' =>
'Purpure Quill< Herald>|9999K|Nc|Purple Quill< Herald>|
',
'ufo000128|C|Name correction from "Hæmatite Pursivant" to "Hæmatite Pursuivant"|Gallavally, Canton of||
' =>
'H{ae}matite Pursivant|9999C|NC|H{ae}matite< Pursuivant>|(-corrected)
',
'ufo000178|M|Designation of badge as standard augmentation|Middle, Kingdom of the|Argent, a pale gules surmounted by a dragon passant vert|
' =>
'Middle,< Kingdom of> the|9999M|a|Argent, a pale gules surmounted by a dragon passant vert.|(Standard augmentation)
',
'ufo000114|Q|Redesignation of device as badge|Imran Yosuf le Scorpioun|Azure, a scorpion tergiant erect within a bordure argent|
' =>
'Imran Yosuf le Scorpioun|9999Q|b|Azure, a scorpion tergiant erect within a bordure argent.|
Imran Yosuf le Scorpioun|-9999Q|d|Azure, a scorpion tergiant erect within a bordure argent.|(-converted to badge)
',
'ufo000117|Q|Exchange of device and badge|Bj{o,}rn inn hávi||
' =>
'',
'ufo000057|X|Acceptance of household name transfer "Company of Hellsgate" from "Ioannes Dalassenos" as branch name|Hellsgate, Stronghold of||
' =>
'Hellsgate<, Stronghold of>|9999X|BN||
',
'ufo000289|O|Name change from "Kathryn Brian Chevreuil" retained and badge|Briatiz d\'Andrade|(Fieldless) A swan contourny ermine|
' =>
'Kathryn Brian Chevreuil|9999O|AN|For Briatiz d\'Andrade|
Kathryn Brian Chevreuil|9999O|NC|See Briatiz d\'Andrade|
Briatiz d\'Andrade|9999O|b|(Fieldless) A swan contourny ermine.|
',
'ufo000025|N|Household name "House of the Lion and Lily" and joint badge|Rhieinwylydd verch Einion Llanaelhaearn and Galeran Chanterel|(Fieldless) On a lion\'s face argent in chief a fleur-de-lys azure|
' =>
'Lion and Lily, House of the|9999N|HN|"Rhieinwylydd verch Einion Llanaelhaearn" and "Galeran Chanterel"|
Galeran Chanterel|9999N|j|Rhieinwylydd verch Einion Llanaelhaearn|
Rhieinwylydd verch Einion Llanaelhaearn|9999N|b|(Fieldless) On a lion\'s face argent in chief a fleur-de-lys azure.|(For House of the Lion and Lily)(JB: Galeran Chanterel)
',
'ufo000004|H|Name change from "Beautrice Hammeltoune" and change of badge to device|Beatrijs van Cleef|Barry azure and ermine|
' =>
'Beautrice Hammeltoune|9999H|NC|See Beatrijs van Cleef|
Beatrijs van Cleef|9999H|d|Barry azure and ermine.|
Beatrijs van Cleef|-9999H|b|Barry azure and ermine.|(-converted to device)
',
'ufo000023|N|Joint badge transfer to "Cecille de Beumund"|Iago ab Adam and Cecille de Beumund|(Fieldless) A griffin passant argent winged Or|
' =>
'Iago ab Adam|-9999N|b|(Fieldless) A griffin passant argent winged Or.|(JB: Cecille de Beumund)(-transferred to Cecille de Beumund)
Cecille de Beumund|-9999N|j|Iago ab Adam|(-transferred to Cecille de Beumund)
',
'ufo000060|R|Household name "House of the Fox and Bow" and badge association|Ruaidrí Campbell|(Fieldless) A quadricorporate fox Or|
' =>
'Ruaidr{i\'} Campbell|-9999R|b|(Fieldless) A quadricorporate fox Or.|(-associated with household name)
Ruaidr{i\'} Campbell|9999R|b|(Fieldless) A quadricorporate fox Or.|(For House of the Fox and Bow)
Fox and Bow, House of the|9999R|HN|Ruaidr{i\'} Campbell|
',
'ufo000184|S|Household badge for "Compagnie de la Souris"|François Souris|Sable, a mouse rampant Or and a sinister tierce paly Or and sable|
' =>
'Fran{c,}ois Souris|9999S|b|Sable, a mouse rampant Or and a sinister tierce paly Or and sable.|(For Compagnie de la Souris)
',
'ufo000135|E|Joint household name "Marshalls Ford Tavern" and badge association|John Marshall atte Forde and Elizabet Marshall|(Fieldless) An acorn Or between and conjoined to two bars wavy couped azure|
' =>
'Marshalls Ford Tavern|9999E|HN|"John Marshall atte Forde" and "Elizabet Marshall"|
Elizabet Marshall|9999E|j|John Marshall atte Forde|
John Marshall atte Forde|-9999E|b|(Fieldless) An acorn Or between and conjoined to two bars wavy couped azure.|(-associated with household name)
John Marshall atte Forde|9999E|b|(Fieldless) An acorn Or between and conjoined to two bars wavy couped azure.|(For Marshalls Ford Tavern)(JB: Elizabet Marshall)
',
'ufo000007|H|Acceptance of transfer of heraldic title "Comet Pursuivant" from "Æthelmearc, Kingdom of"|Debatable Lands, Barony-Marche of the||
' =>
'Comet< Pursuivant>|9999H|t|Debatable Lands,< Barony-Marche of> the|
',
'ufo000139|K|Augmentation of arms|Andreas Seljukroctonis|Per bend sinister gules and purpure, on a bend sinister dovetailed argent between two double-bitted axes Or a bull\'s head caboshed palewise sable and for augmentation, on a canton purpure a cross of Calatrava within a bordure Or|
' =>
'Andreas Seljukroctonis|9999K|a|Per bend sinister gules and purpure, on a bend sinister dovetailed argent between two double-bitted axes Or a bull\'s head caboshed palewise sable and for augmentation, on a canton purpure a cross of Calatrava within a bordure Or.|
',
'ufo000239|S|Name and acceptance of device transfer from "Laurencius Legnano"|Thomas Alfred|Per pale sable and gules, a griffin segreant contourny reguardant between in chief two goblets Or|
' =>
'Thomas Alfred|9999S|d|Per pale sable and gules, a griffin segreant contourny reguardant between in chief two goblets Or.|
Thomas Alfred|9999S|N||
',
'ufo000205|w|Blanket permission to conflict with name and device "with one CD"|Ellen of Wyteley|Vert, a bend sinister wavy between two beech trees argent|
' =>
'Ellen of Wyteley|9999w|BP|Vert, a bend sinister wavy between two beech trees argent.|(Blanket permission to conflict with device with one CD granted 9999w)
Ellen of Wyteley|9999w|BP||(Blanket permission to conflict with name granted 9999w)
',
'ufo000205|w|Blanket permission to conflict with name and device|Ellen of Wyteley|Vert, a bend sinister wavy between two beech trees argent|
' =>
'Ellen of Wyteley|9999w|BP|Vert, a bend sinister wavy between two beech trees argent.|(Blanket permission to conflict with device granted 9999w)
Ellen of Wyteley|9999w|BP||(Blanket permission to conflict with name granted 9999w)
',
'ufo000140|C|Holding name (see RETURNS for name and device)|Al of Wintermist||
' =>
'Al of Wintermist|9999C|N||(Holding name)
',
'ufo000232|L|Reblazon of Important non-SCA arms|Quebec|Per fess azure and Or, on a fess gules between three fleurs-de-lys Or and a sprig of three maple leaves slipped vert a lion passant guardant Or|
' =>
'Quebec|9999L|b|Per fess azure and Or, on a fess gules between three fleurs-de-lys Or and a sprig of three maple leaves slipped vert a lion passant guardant Or.|(Important non-SCA arms)
',
'ufo000233|L|arms reblazoned|Quebec|Per fess azure and Or, on a fess _ between three fleurs-de-lys Or and a sprig of three maple leaves slipped vert a lion passant guardant Or|
' =>
'Quebec|-9999L|d|Per fess azure and Or, on a fess _ between three fleurs-de-lys Or and a sprig of three maple leaves slipped vert a lion passant guardant Or.|(-reblazoned)
',
'ufo000234|w|Device and blanket permission to conflict with device (see RETURNS for name change and blanket permission to conflict with name)|Columb Finn mac Diarmata|Vert, a fess between two chevrons throughout argent|
' =>
'Columb Finn mac Diarmata|9999w|BP|Vert, a fess between two chevrons throughout argent.|(Blanket permission to conflict with device granted 9999w)
Columb Finn mac Diarmata|9999w|d|Vert, a fess between two chevrons throughout argent.|
',
'ufo000161|D|Acceptance of Order Name Transfer "Ffraid, Order of" from "Drachenwald, Kingdom of"|Insula Draconis, Crown Principality of||
' =>
'Ffraid, Order of|9999D|O|Insula Draconis, Crown Principality of|
',
'ufo000081|A|Blanket permission to conflict with augmented device|Marta as-tu Mika-Mysliwy|Per chevron vert and Or, in base a satyr dancing and piping proper and as an augmentation on a canton azure a sun in glory within a bordure Or|
' =>
'Marta as-tu Mika-Mysliwy|9999A|BP|Per chevron vert and Or, in base a satyr dancing and piping proper and as an augmentation on a canton azure a sun in glory within a bordure Or.|(Blanket permission to conflict with device granted 9999A)
',
'ufo000093|A|Blanket permission to conflict with alternate name "Kameyama Bakumaru" and badge|Symond Bayard le Gris|Sable, a Japanese tapir sejant, head raised, within an annulet argent|
' =>
'Symond Bayard le Gris|9999A|BP|Sable, a Japanese tapir sejant, head raised, within an annulet argent.|(Blanket permission to conflict with badge Kameyama Bakumaru granted 9999A)
Kameyama Bakumaru|9999A|BP|Symond Bayard le Gris|(Blanket permission to conflict with alternate name granted 9999A)
',
'ufo000106|Q|Acceptance of badge transfer from "Clarice of Caer Gelynniog" and designation as for "the populace"|Caer Gelynniog, Canton of|Argent, a tower purpure between two apples in fess and an apple in base vert and on a chief purpure three broadarrows argent|
' =>
'Caer Gelynniog<, Canton of>|9999Q|b|Argent, a tower purpure between two apples in fess and an apple in base vert and on a chief purpure three broadarrows argent.|(For the populace)
',
'ufo000230|L|Name change from "Mala{w^}i" and flag change (important non-SCA flag)|Malawi|Per fess gules and vert, a fess sable and overall a sun argent|
' =>
'Mala{w^}i|9999L|NC|See Malawi|(important non-SCA flag)
Malawi|9999L|b|Per fess gules and vert, a fess sable and overall a sun argent.|(important non-SCA flag)
',
'ufo000087|w|Badge association with "the populace"|Lochac, Kingdom of|Quarterly azure and argent, on a cross gules four mullets of six points argent|
' =>
'populace|9999w|R|See Lochac<, Kingdom of>|
Lochac<, Kingdom of>|-9999w|b|Quarterly azure and argent, on a cross gules four mullets of six points argent.|(-associated with usage)
Lochac<, Kingdom of>|9999w|b|Quarterly azure and argent, on a cross gules four mullets of six points argent.|(For the populace)
',
'ufo000134|M|Name reconsideration from "Ogg the Red" and badge|Og the Red|Or, in pale a viking spangenhelm affronty gules and a wooden tankard proper|
' =>
'Ogg the Red|9999M|Nc|Og the Red|
Og the Red|9999M|b|Or, in pale a viking spangenhelm affronty gules and a wooden tankard proper.|
',
'ufo000173|W|Designator change from "Danegeld Tor, Riding of" (see RETURNS for badge)|Danegeld Tor, Shire of||
' =>
'Danegeld Tor, Riding of|9999W|u|Danegeld Tor<, Shire of>|
',
'ufo000116|C|badge for the "Owlwycke Priory" reblazoned|Sebastian de Grey|Per bend sinister argent and sable, an owl affronty sable and a lamp reversed argent, enflamed Or|
' =>
'Sebastian de Grey|-9999C|b|Per bend sinister argent and sable, an owl affronty sable and a lamp reversed argent, enflamed Or.|(-reblazoned)
',
'ufo000025|X|Change of badge association from "Office of the Minister of Children" to "Award of the Rising Star of Ansteorra"|Ansteorra, Kingdom of|Or, a mullet of five greater and five lesser points sable overall a point issuant from base gules|
' =>
'Ansteorra<, Kingdom of>|9999X|b|Or, a mullet of five greater and five lesser points sable overall a point issuant from base gules.|(For Award of the Rising Star of Ansteorra)
Ansteorra<, Kingdom of>|-9999X|b|Or, a mullet of five greater and five lesser points sable overall a point issuant from base gules.|(-associated with new usage)
',
'ufo000088|K|Release of joint badge|William Graver and Pipa Sparkes|Vert estencely, a vol argent and overall a graver, point to base, Or|
' =>
'Pipa Sparkes|-9999K|j|William Graver|(-released)
William Graver|-9999K|b|Vert estencely, a vol argent and overall a graver, point to base, Or.|(-released)
',
'ufo000048|A|Transfer of alternate name "Helena Handbasket" to "Helena Greenwood"|Helena de Argentoune||
' =>
'Helena Handbasket|-9999A|AN|For Helena de Argentoune|(-transferred to Helena Greenwood)
',
'ufo000110|C|Heraldic will for heraldic title "Noir Licorne Herald"|Jeanne Marie Lacroix||
' =>
'Jeanne Marie Lacroix|9999C|W||
',
'ufo000112|C|Heraldic will for household name "Chateau Noir Licorne"|Jeanne Marie Lacroix||
' =>
'Jeanne Marie Lacroix|9999C|W||
',
'ufo000071|D|Badge change and association for "Order of the Fox"|Insula Draconis, Principality of|(Fieldless) A fox\'s mask per pale azure and Or|
' =>
'Insula Draconis<, Principality of>|-9999D|b|(Fieldless) A fox\'s mask per pale azure and Or.|(-associated with order name)
Insula Draconis<, Principality of>|9999D|b|(Fieldless) A fox\'s mask per pale azure and Or.|(For Order of the Fox)
',
'ufo000138|D|Heraldic title "Sans Merci Herault"|Drachenwald, Kingdom of||
' =>
'Sans Merci< Herault>|9999D|t|Drachenwald<, Kingdom of>|
',
'err000000|C|badge correction|Rand Reynald|Per pale gules and vert, a lion between three oak leaves argent|
' =>
'Rand Reynald|-9999C|b|Per pale gules and vert, a lion between three oak leaves argent.|(-corrected blazon)
',
'ufo000141|Q|badge for "Award of the Quintain" reblazoned|Atlantia, Kingdom of|(Fieldless) In fess a tilting lance sustained by a seahorse argent|
' =>
'Atlantia<, Kingdom of>|-9999Q|b|(Fieldless) In fess a tilting lance sustained by a seahorse argent.|(-reblazoned)
',
'ufo000102|X|Blanket permission to conflict with heraldic title "Troll Herald Extraordinary"|Daniel de Lincoln||
' =>
'Troll< Herald Extraordinary>|9999X|BP|Daniel de Lincoln|(Blanket permission to conflict with heraldic title granted 9999X)
',
'ufo000071|Q|Reblazon of seal|Styrbjørg Ulfethnar|(Tinctureless) An octopus inverted within and conjoined to an annulet|
' =>
'Styrbj{o/}rg Ulfethnar|9999Q|s|(Tinctureless) An octopus inverted within and conjoined to an annulet.|
',
'ufo000072|Q|seal reblazoned|Styrbjørg Ulfethnar|(Tinctureless) A kraken environed of an annulet. [Octopus vulgaris]|
' =>
'Styrbj{o/}rg Ulfethnar|-9999Q|s|(Tinctureless) A kraken environed of an annulet. [Octopus vulgaris].|(-reblazoned)
',
'ufo000044|X|Reblazon of joint badge|Fáelán mac Cathail and Alisandre d\'Ambrecourt|(Fieldless) Within and conjoined to a crescent argent a heart sable|
' =>
'F{a\'}el{a\'}n mac Cathail|9999X|b|(Fieldless) Within and conjoined to a crescent argent a heart sable.|(JB: Alisandre d\'Ambrecourt)
',
'ufo000045|X|joint badge reblazoned|Fáelán mac Cathail and Alisandre d\'Ambrecourt|(Fieldless) A heart sable within the horns of and conjoined to a crescent argent|
' =>
'F{a\'}el{a\'}n mac Cathail|-9999X|b|(Fieldless) A heart sable within the horns of and conjoined to a crescent argent.|(-reblazoned)
',
'ufo000118|K|Alternate name "Alessandra Cicilia di Anselmo da Parma" and badge association|Delis Alms|Per pale gules and vert, a winged lion contourny between its forepaws a mullet of eight points argent|
' =>
'Alessandra Cicilia di Anselmo da Parma|9999K|AN|For Delis Alms|
Delis Alms|-9999K|b|Per pale gules and vert, a winged lion contourny between its forepaws a mullet of eight points argent.|(-associated with alternate name)
Delis Alms|9999K|b|Per pale gules and vert, a winged lion contourny between its forepaws a mullet of eight points argent.|(For Alessandra Cicilia di Anselmo da Parma)
',
'ufo000089|C|Change of badge association to "Order of the Seraph" from "Order of the Seraphic Star"|Angels, Barony of the|Gules, a seraph\'s head Or faced proper|
' =>
'Angels,< Barony of> the|-9999C|b|Gules, a seraph\'s head Or faced proper.|(-associated with new usage)
Angels,< Barony of> the|9999C|b|Gules, a seraph\'s head Or faced proper.|(For Order of the Seraph)
',
'ufo000038|A|Release of name|James O Callan||
' =>
'James O Callan|-9999A|N||(-released)
',
'ufo000077|C|Correction of badge association to "Legion of Courtesy" from "Order of the Legion of Courtesy"|Caid, Kingdom of|(Fieldless) A rose Or barbed and seeded vert|
' =>
'Caid<, Kingdom of>|-9999C|b|(Fieldless) A rose Or barbed and seeded vert.|(-association corrected)
Caid<, Kingdom of>|9999C|b|(Fieldless) A rose Or barbed and seeded vert.|(For Legion of Courtesy)
',
'ufo000114|K|Heraldic title "Rottaler Herold" (see PENDS for other heraldic title)|Calontir, Kingdom of||
' =>
'Rottaler< Herold>|9999K|t|Calontir<, Kingdom of>|
',
'ufo000223|E|Badge|Ivyeinrust, Bailiwick of|(Fieldless) An ivy leaf quarterly vert and argent|
' =>
'Ivyeinrust<, Bailiwick of>|9999E|b|(Fieldless) An ivy leaf quarterly vert and argent.|
',
'ufo000119|C|Joint household name change to "Company of Saint Martin de Tours" from "Company of Martin de Tours" and badge|Juliana Neuneker Hirsch von Schutzhundheim and Arion Hirsch von Schutzhundheim|Azure, two scarpes argent between two furisons Or|
' =>
'Juliana Neuneker Hirsch von Schutzhundheim|9999C|b|Azure, two scarpes argent between two furisons Or.|(For Company of Saint Martin de Tours)(JB: Arion Hirsch von Schutzhundheim)
Arion Hirsch von Schutzhundheim|9999C|j|Juliana Neuneker Hirsch von Schutzhundheim|
Martin de Tours, Company of|9999C|HNC|Saint Martin de Tours, Company of|
',
'ufo000041|X|Joint household name "Bentbow House" and joint badge|Eric Bentbow and Alexandra Bentbow|(Fieldless) On a tower per pale Or and azure, an arrowhead inverted counterchanged|
' =>
'Bentbow House|9999X|HN|"Eric Bentbow" and "Alexandra Bentbow"|
Alexandra Bentbow|9999X|j|Eric Bentbow|
Eric Bentbow|9999X|b|(Fieldless) On a tower per pale Or and azure, an arrowhead inverted counterchanged.|(For Bentbow House)(JB: Alexandra Bentbow)
',
'ufo000162|w|Blanket permission to conflict with name and alternate name "ffride wlffsdotter"|Ásfríðr Úlfvíðardóttir||
' =>
'ffride wlffsdotter|9999w|BP|{A\'}sfr{i\'}{dh}r {U\'}lfv{i\'}{dh}ard{o\'}ttir|(Blanket permission to conflict with alternate name granted 9999w)
{A\'}sfr{i\'}{dh}r {U\'}lfv{i\'}{dh}ard{o\'}ttir|9999w|BP||(Blanket permission to conflict with name granted 9999w)
',
'ufo000068|Q|Name change from "Aillenn DÌlis ingen NÈll" and release of device|EtaÌn DÌlis ingen Fhinn|Per fess azure and vert, a crescent pendant argent and an oak leaf fesswise Or|
' => 
'Aillenn D{\'I}lis ingen N{\'E}ll|9999Q|NC|See Eta{\'I}n D{\'I}lis ingen Fhinn|
Eta{\'I}n D{\'I}lis ingen Fhinn|-9999Q|d|Per fess azure and vert, a crescent pendant argent and an oak leaf fesswise Or.|(-released)
',
    );
}
