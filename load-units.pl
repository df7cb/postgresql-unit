#!/usr/bin/perl

use strict;
use warnings;
use DBD::Pg;
#use Encode qw(decode);

my $file = "definitions.units.patched";

open F, "< :encoding(utf-8)", $file or die "$file: $!";

my $dbh = DBI->connect("dbi:Pg:", '', '',
	{AutoCommit => 1, PrintError => 0, RaiseError => 0}
) || die "PG connection failed";
$dbh->do("SET synchronous_commit = off");
$dbh->do("TRUNCATE unit_prefixes, unit_units");

my $skip_british = 0;
my @todo;

while (<F>) {
	# skip over locale specific parts
	$skip_british = 1 if /^!var UNITS_ENGLISH GB/;
	$skip_british = 0 if /^!endvar/;
	next if ($skip_british);

	s/\s*#.*//;
	next if /^\s*$/; # skip emtpy lines
	next if /^!/; # skip pragmas
	next if /^[0-9]/; # skip over table contents
	next if /^ /; # skip over table contents/continued lines
	unless (/^(\S+)\s+(.*)/) {
		print "skipping $_";
		next;
	}

	my ($unit, $def) = ($1, $2);
	next if ($unit =~ /[(\[]/); # skip functions and table definitions

	my $is_prefix = ($unit =~ s/-$//); # it's a prefix if it ends with '-'
	$def = $unit if ($def eq '!'); # base unit
	$def = 1 if ($def eq '!dimensionless');

	my $u = { unit => $unit, def => $def, is_prefix => $is_prefix };
	$u->{is_base} = ($u->{unit} eq $u->{def});
	push @todo, $u;
}

my ($n_todo, $new_n_todo);
do {
	$n_todo = @todo;
	print "$n_todo units left to try ...\n";

	my @new_todo;
	foreach my $u (@todo) {
		my ($unit, $def, $is_prefix) = ($u->{unit}, $u->{def}, $u->{is_prefix});
		if ($is_prefix) {
			my $ret = $dbh->do("INSERT INTO unit_prefixes (prefix, factor, definition) VALUES (?, value(?::unit), ?)",
				undef,
				$unit, $def, $def);
			next if defined $ret;
			# see if the prefix is defined in terms of another prefix
			# (we can't simply inject all prefixes as units because conflicts exist, e.g. on 'T')
			$ret = $dbh->do("INSERT INTO unit_prefixes (prefix, factor, definition) SELECT ?, factor, ? FROM unit_prefixes WHERE prefix = ?",
				undef,
				$unit, $def, $def);
			next if defined $ret and $ret > 0;
		} else {
			my ($is_hashed) = $dbh->selectrow_array("SELECT unit_is_hashed(?)", undef, $unit);
			if ($is_hashed and not $u->{is_base}) {
				print "Unit $unit has already been used before being defined. Bad.\n";
			}
			my $ret = $dbh->do("INSERT INTO unit_units (name, unit, definition) VALUES (?, ?, ?)",
				undef,
				$unit, $def, $def);
			next if defined $ret;
			$u->{error} = $dbh->errstr;
		}

		push @new_todo, $u;
	}

	$new_n_todo = @new_todo;
	@todo = @new_todo;
} while ($n_todo != $new_n_todo);

print "$new_n_todo units not inserted:\n";
foreach my $u (@todo) {
	if ($u->{is_prefix}) {
		print "Prefix $u->{unit}: $u->{def}\n";
	} else {
		next if ($u->{error} =~ /dollar|euro|pence|quid|shilling/); # skip currencies so we can see the rest better
		print "$u->{unit}: $u->{def} ($u->{error})\n";
	}
}
