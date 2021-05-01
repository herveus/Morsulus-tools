#!/usr/local/bin/perl
use strict;
use warnings;
use Daud;
use v5.16;
use utf8;
use warnings qw(FATAL utf8);
use open qw(:std :utf8);

my %notes = (
    'LATIN SMALL LETTER U WITH VERTICAL LINE ABOVE' => 1,
    'UNDERLINED CAPITAL LETTER DJ' => 2,
    'UNDERLINED SMALL LETTER DJ' => 2,
    'UNDERLINED CAPITAL LETTER SH' => 2,
    'UNDERLINED SMALL LETTER SH' => 2,
);

print qq{
<table class="lookup">
<tr>
<th>Da'ud code</th>
<th>ASCII encoding</th>
<th>Unicode code point</th>
<th>Unicode character</th>
<th>HTML entity</th>
<th>Unicode name</th>
</tr>
<tbody>
};

my @entries;
for my $line (Daud::_raw_data()) {
    next if $line =~ /^#/;
    chomp $line;

    my ($daud, $ascii, $codepoint, $html, $name) = split(/;/, $line);

    $html ||= '&#x' . $codepoint;
    $html =~ s/&/&amp;/;

    # Make a sortable version of the name with modifiers after the base letter
    my $sortable = $name;
    $sortable =~ s/((?:LATIN |GREEK |CAPITAL |SMALL |LETTER |LIGATURE |DOTLESS )+)(\w+)/$2 $1/;
    # Sort ETH, ENG, EZH by their Da'ud equivalents
    $sortable =~ s/^(E[NGTHZ]{2} )/\U$daud $1/;

    push @entries, {
        daud => $daud,
        ascii => $ascii,
        html => $html . ';',
        unicode => chr(hex($codepoint)),
        codepoint => $codepoint,
        name => $name,
        sortable => $sortable,
        note => ( ! $notes{$name} ) ? '' :
                  qq{ <sup><a href="#fn$notes{$name}">$notes{$name}</a></sup>},
    }
}

foreach ( sort { $a->{sortable} cmp $b->{sortable} } @entries ) {
    print '<tr>',
        "<td><code>{$_->{daud}}</code></td>",
        "<td>$_->{ascii}</td>",
        "<td>$_->{unicode}</td>",
        "<td><code>$_->{codepoint}</code></td>",
        "<td><code>$_->{html}</code></td>",
        "<td>$_->{name}$_->{note}</td>",
        '</tr>', "\n";
}

print qq{
<tbody>
</table>

<h3>Notes</h3>

<p><sup><a name="fn1">1</a></sup> The <code>{u!}</code> notation represents a character used in Middle High German. It has been proposed by the Medieval Unicode Font Initiative but is not yet part of the official standard. For additional details, see <a href="http://heraldry.sca.org/loar/2012/08/12-08cl.html">the August 2012 cover letter</a>.

<p><sup><a name="fn2">2</a></sup> The <code>{Dj_}</code> and <code>{Sh_}</code> notations represent characters used for the transliteration of Arabic as defined in The Encyclopedia of Islam. For additional details, see <a href="http://heraldry.sca.org/loar/2019/11/19-11cl.html#8">the November 2019 cover letter</a>.

};
