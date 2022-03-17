#!/usr/bin/perl
use warnings;
use strict;
use autodie;

use Socket qw( inet_aton );
use Data::Dump qw(dump);

my $mac;
my $wifi;

foreach my $file ( sort glob "out/*.iw*scan" ) {
	my $ip = $1 if ( $file =~ m/out\/(.+?)\.iw/ );
	open(my $fh, '<', $file);
	while(<$fh>) {
		chomp;
		if ( m/BSS ([0-9a-f:]+)/ ) {
			$mac = $1;
			$wifi->{$mac}->{enc} = 'Open';
			$wifi->{$mac}->{ip} = $ip;
		} elsif ( m/SSID: (\S+)/ ) {
			$wifi->{$mac}->{ssid} = $1;
		} elsif ( m/freq: (\S+)/ ) {
			$wifi->{$mac}->{freq} = $1;
		} elsif ( m/signal: (\S+)/ ) {
			$wifi->{$mac}->{sig} = $1;
		} elsif ( m/Authentication suites: (.+)/ ) {
			$wifi->{$mac}->{enc} = $1;
		} elsif ( m/primary channel: (\d+)/ ) {
			$wifi->{$mac}->{channel} = $1;
		}
	}
}

my $fmt = "%s %s %-20s %2s %4s %-6s %-10s\n";
printf $fmt ,"IP","mac","SSID","ch","Freq","Signal","Encryption";

warn "# wifi = ",dump($wifi);

foreach my $m ( sort { inet_aton($wifi->{$a}->{ip}) cmp inet_aton($wifi->{$b}->{ip}) } keys %$wifi ) {

	printf $fmt,
		$wifi->{$m}->{ip}, 
		$m,
		$wifi->{$m}->{ssid}, 
		$wifi->{$m}->{channel} || '?', 
		$wifi->{$m}->{freq}, 
		$wifi->{$m}->{sig}, 
		$wifi->{$m}->{enc}, 
	;
}

