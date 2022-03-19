#!/usr/bin/perl
use warnings;
use strict;
use autodie;

use Data::Dump qw(dump);

my $mac2name;
my $mac2ip;

open(my $fh, '<', 'dhcp.leases');
while(<$fh>) {
	chomp;
	my (undef, $mac, $ip, $name, undef ) = split(/ /, $_);
	$mac2name->{$mac} = $name;
	$mac2ip->{$mac} = $ip;
}

my $fmt = "%-15s %-17s %10s %10s %6s %4s %-4s %-4s %-15s %-15s %-11s %8s\n";
my @cols = grep { /^.+$/ } split(/\n/, q{
ip
name
rx bytes
tx bytes
tx retries
tx failed
signal
signal avg
tx bitrate
rx bitrate
expected throughput
inactive time
});

my @lens;
@lens = map { s/\D+//g; $_ } split(/ /, $fmt);
warn "# lens = ",dump( \@lens );
printf $fmt, map { substr($cols[$_],0,$lens[$_]) } 0 .. $#cols;

my $s;

sub station_dump {
	return unless defined $s;
	$s->{ip}   = $mac2ip->{$s->{mac}};
	$s->{name} = $mac2name->{$s->{mac}};

	printf $fmt, 
		map { substr($s->{$cols[$_]},0,$lens[$_]) } 0 .. $#cols;
}

open(my $fh, '<', 'station.dump');
while(<$fh>) {
	chomp;
	if ( m/Station ([0-9a-f:]+)/ ) {
		station_dump();
		$s->{mac} = $1;
	} elsif ( m/^\s+(.+?):\s+(.+)/ ) {
		my ($n,$v) = ($1,$2);
		if ( $n =~ m/signal/ ) {
			$v =~ s{\[-.*$}{}; # clean array and dBm
		}
		$s->{$n} = $v;
	}
}
station_dump();
