#!/usr/bin/perl

use strict;
use warnings;
use DBD::Pg;
#use Encode qw(decode);

my $file = "definitions.units";

open F, "< :encoding(utf-8)", $file or die "$file: $!";

my $dbh = DBI->connect("dbi:Pg:", '', '',
	{AutoCommit => 1, PrintError => 0, RaiseError => 0}
);
$dbh->do("SET synchronous_commit = off");
$dbh->do("TRUNCATE unit_prefixes, unit_units");

my ($n_prefixes, $n_units) = (0, 0);
my $skip = 0;
my @todo;

while (<F>) {
	# skip over locale specific parts
	$skip = 1 if /^!var UNITS_ENGLISH GB/;
	$skip = 0 if /^!endvar/;
	next if ($skip);

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
	#print "$unit = $def\n";

	$def = '1|8 B' if ($unit eq 'bit'); # bit is a base unit in definitions.units; we have byte as base unit instead
	$def = '1' if ($unit eq 'wholenote'); # wholenote is a base unit in definitions.units; use 1 instead
	$def = '1' if ($unit eq 'US$'); # for debugging, pretend US$ is a unit so we can see which non-currency units are not imported
	$def = $unit if ($def eq '!'); # base unit
	$def = 1 if ($def eq '!dimensionless');

	$unit =~ s/lambda_C,/lambda_C/; # remove comma from two unit names
	$unit = 'number2_5can' if ($unit eq 'number2.5can');

	if ($is_prefix) {
		$n_prefixes++;
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
		print "prefix $unit=$def not inserted yet\n";
	} else {
		$n_units++;
		my $ret = $dbh->do("INSERT INTO unit_units (name, unit, definition) VALUES (?, ?, ?)",
			undef,
			$unit, $def, $def);
		next if defined $ret;
		print "unit $unit=$def not inserted yet: " . $dbh->errstr . "\n";
	}

	push @todo, { unit => $unit, def => $def, is_prefix => $is_prefix };
}

# compatibility with unit v1/2: mu = µ
$dbh->do("INSERT INTO unit_prefixes (prefix, factor, definition) VALUES ('mu', '1e-6', 'micro')");

print "\n\n\n";
print scalar(@todo) . " units left to try ...\n";

foreach my $u (@todo) {
	my ($unit, $def, $is_prefix) = ($u->{unit}, $u->{def}, $u->{is_prefix});
	if ($is_prefix) {
		$n_prefixes++;
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
		print "prefix $unit=$def not inserted\n";
	} else {
		$n_units++;
		my $ret = $dbh->do("INSERT INTO unit_units (name, unit, definition) VALUES (?, ?, ?)",
			undef,
			$unit, $def, $def);
		next if defined $ret;
		print "unit $unit=$def not inserted: " . $dbh->errstr . "\n";
	}
}

print "$n_prefixes prefixes, $n_units units\n";
