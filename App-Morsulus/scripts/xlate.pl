#!/usr/bin/perl
$|++;
use strict;
# see categorize.pod for detailed docs

#% turn category file into subroutines that return appropriate lists
#% of parsed category file data

use Getopt::Std;

my $USAGE = q{usage: xlate -c category_file -d database_file -e desc_file
};

my %opt = (e => '/Users/herveus/aux/old_new.desc',
	c => '/Users/herveus/aux/mike.cat');
getopts('c:d:e:', \%opt) or die $USAGE;
die $USAGE unless defined $opt{c};
die $USAGE unless defined $opt{d};
die $USAGE unless defined $opt{e};

open(CAT_IN, $opt{c}) or die "Can't open catalog file $opt{c}: $!";
open(DB_FILE, $opt{d}) or die "Can't open database file $opt{d}: $!";
open(DESCS, $opt{e}) or die "Can't open desc file $opt{e}:$!";

my %set_name; # keys are feature_names, values are set_names
my %set_names; # keys are set_names, values are feature counts
my %compatible; # keys are feature_names, values are {feature_name => relationship}
my @feature_names; # values are feature_names in load order
my %xrefs; # keys and values are category_names
my %categories = (); # keys are category_names, values are {heading => heading, features => [allowable_feature_list], group => [category_group_list]}
my %group = (); # keys are group headings, values are ref to ordered list of category_names
my @group; # ordered list of group_headings

print STDERR "Load category file\n";
while (<CAT_IN>)
{	
	chomp;
	
	/^#/ and next; # skip comments
	
	/^[|]/ and do	# feature definition
	{
		my ($set_name, $feature_name, $relationship, $feature2);
		# set_name:feature_name{[<=]related_feature}...
		/^[|]([^:]+):([^<=]+)(.*)$/ or die "cannot parse feature definition: $_";
		($set_name, $feature_name, $_) = ($1, $2, $3);
		
		exists $set_name{$feature_name} and die "duplicated feature name: ($feature_name) $_";
		$set_name{$feature_name} = $set_name;
		$set_names{$set_name}++;
		push @feature_names, $feature_name;
		
		while ($_)
		{
			/^([<=])([^<=]+)(.*)$/ or die "cannot parse feature relationship:
			$_";
			($relationship, $feature2, $_) = ($1, $2, $3);
			
			$compatible{$feature_name}->{$feature2} = $relationship;
		}
		next;
	};
	
	/^(.+) - see (also )?(.+)/ and do # cross-reference
	{
		my ($from, $to) = ($1, $3);
		push @{$xrefs{$from}}, split(/ and /, $to);
		next;
	};
	
	# otherwise a heading
	my ($category, $heading, $features) = split(/[|]/, $_, 3);
	$categories{$category} = {heading => $heading,
		features => []};
	defined $features and $categories{$category}->{features} = [split(/:/, $features)];
	push @{$xrefs{$category}}, $category;
}

# insert compatibility refinement here
print STDERR "Refine compatibility matrix\n";
my $progress = 1;
my $pass = 1;
while ($progress)
{
	$progress = 0;
	foreach my $f1 (keys %compatible)
	{
		foreach my $f2 (keys %{$compatible{$f1}})
		{
			unless (exists $compatible{$f2}->{$f1})
			{
				# if f1 is compatible with f2 then f2 is compatible with f1
				$compatible{$f2}->{$f1} = '=';
				#print "$f1=$f2 -> $f2=$f1\n";
				$progress++;
			}
			
			if ($compatible{$f1}->{$f2} eq '<')
			{
				# if f1 is a subset of f2
				# and f2 is a subset of f3
				# then f1 is a subset of f3
				foreach my $f3 (@feature_names)
				{
					next unless exists $compatible{$f2}->{$f3};
					next unless $compatible{$f2}->{$f3} eq '<';
					next if (exists $compatible{$f1}->{$f3} and  $compatible{$f1}->{$f3} eq '<');
					$compatible{$f1}->{$f3} = '<';
					#print "$f1<<$f2 AND $f2<<$f3 GIVES $f1<<$f3\n";
					$progress++;
				}
			}
			elsif ($compatible{$f1}->{$f2} eq '=')
			{
				# if f1 is compatible with f2
				# and f2 is a subset of f3
				# then f1 is compatible with f3
				foreach my $f3 (@feature_names)
				{
					next unless exists $compatible{$f2}->{$f3};
					next unless $compatible{$f2}->{$f3} eq '<';
					next if exists $compatible{$f1}->{$f3};
					$compatible{$f1}->{$f3} = '=';
					#print "$f1=$f2 and $f2<$f3 -> $f1=$f3\n";
					$progress++;
				}
			}
		}
	}
	print STDERR "pass ", $pass++, " made $progress improvements\n";
}

my %descs;

print STDERR "Reading old descs...\n";
while (<DESCS>)
{
	chomp;
	next if /^$/;
	my ($heading, @features) = split(/:/, $_);
	$descs{$heading} ||= [];
	push @{$descs{$heading}}, \@features if @features;
}

print STDERR "Checking database...\n";
while (<DB_FILE>)
{
	chomp;
	my ($name, $date, $action, $text, $notes, @descs) = split(/[|]/, $_);
	next unless $action =~ /^[abdgsDB]|BD$/;
	next if $date =~ /-/;
	foreach my $desc (@descs)
	{
		my ($heading, @feats) = split(/:/, $desc);
		if (!exists $descs{$heading})
		{
			print STDERR "No such heading: $heading\n",
				"  $name|$action|$text|$desc\n";
		}
		elsif (@{$descs{$heading}} == 0)
		{
			# no features in old desc...alles gut
		}
		else
		{
			my $compats = 0;
			foreach my $odesc (@{$descs{$heading}})
			{
				$compats++ if feature_sets_compatible($odesc, \@feats);
			}
			next if $compats == 1;
			print STDERR "Not one-to-one: $desc maps to $compats different values\n",
				"  $name|$action|$text|$desc\n";
		}
	}
}

sub feature_sets_compatible
{
	my ($descs1, $descs2) = @_;
	return 1 if set_subset($descs1, $descs2);
	foreach my $f1 (@$descs1)
	{
		foreach my $f2 (@$descs2)
		{
			next if $f1 eq $f2;
			next unless $set_name{$f1} eq $set_name{$f2};
			next if exists $compatible{$f1}->{$f2};
			return 0;
		}
	}
	return 1;
}

sub set_subset
{
	my ($set1, $set2) = @_;
	if (@$set1 < @$set2) { ($set1, $set2) = ($set2, $set1); }
	# now set 1 is not larger than set2
	# therefore everything in set1 must be in set2 or return false
	foreach my $m1 (@$set1)
	{
		return 0 unless grep $m1 eq $_, @$set2;
	}
	return 1;
}
