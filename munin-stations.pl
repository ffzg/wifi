#!/usr/bin/perl
use warnings;
use strict;
use autodie;

use Storable;
use Data::Dump qw(dump);

foreach my $file ( sort glob "/var/lib/munin/state-wifi.ffzg-wap-*.storable" ) {

	# /var/lib/munin/state-wifi.ffzg-wap-a000-si.storable
	my $host = $1 if ( $file =~ m{ffzg-(.+)\.storable} );

	my $s = retrieve( $file );
	#warn "# $file ", dump( $s );


	my @count;
	foreach my $key ( grep { /wificlients/ } keys %{ $s->{value} } ) {
		# /var/lib/munin/wifi.ffzg/wap-a000-ji-wificlients_wlan0-clients-g.rrd:42
		my $i = $1 if ( $key =~ m/wlan(\d+)/ );
		if ( ! defined $i ) {
			warn "Can't find wlan in $key";
		}
		$count[$i] = $s->{value}->{$key}->{current}->[1];
		#warn "## $host $i = $count[$i]";
	}
	my $sum = 0;
	$sum += $_ foreach @count;

	printf "%-15s %2d %2d\n", $host, @count if ! $sum == 0;
}
