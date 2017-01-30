#!/usr/bin/perl

use strict;
use warnings;
use DBD::Pg;
#use Encode qw(decode);

my $file = "definitions.units";

open F, "< :encoding(utf-8)", $file or die "$file: $!";

my $dbh = DBI->connect("dbi:Pg:", '', '',
	{AutoCommit => 1, PrintError => 1, RaiseError => 0}
);
$dbh->do("SET synchronous_commit = off");
$dbh->do("TRUNCATE unit_prefixes, unit_units");

my ($n_prefixes, $n_units) = (0, 0);

while (<F>) {
	s/\s*#.*//;
	next if /^\s*$/; # skip emtpy lines
	next if /^!/; # skip pragmas (TODO: choose en_GB/US parts)
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
	next if ($def eq '!'); # base unit
	$def = 1 if ($def eq '!dimensionless');

	if ($is_prefix) {
		$dbh->do("INSERT INTO unit_prefixes (prefix, factor, definition) VALUES (?, value(?::unit), ?)",
			undef,
			$unit, $def, $def);
		# temporarily make the prefix also known as unit (some prefixes are defined in terms of other prefixes)
		$dbh->do("SELECT unit_new (?, ?)",
			undef,
			$unit, $def);
		$n_prefixes++;
	} else {
		#$dbh->do("INSERT INTO unit_units (name, unit, definition) VALUES (?, ?, ?)",
		#	undef,
		#	$unit, $def, $def);
		$n_units++;
	}
}

print "$n_prefixes prefixes, $n_units units\n";
