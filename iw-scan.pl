#!/usr/bin/perl
use warnings;
use strict;
use autodie;

use Socket qw( inet_aton );
use Data::Dump qw(dump);

my $name;
my $ip2name;

my $name_len = 0;

open(my $fh, '<', '/etc/munin/munin.conf');
while(<$fh>) {
	chomp;
	if ( m/\[wifi.ffzg;(.+?)\]/ ) {
		$name = $1;
		$name_len = length($name) if $name_len < length($name);
	} elsif ( m/address ([0-9\.]+)/ ) {
		$ip2name->{$1} = $name;
	}
}


my $mac2ip;

my $addr_len = 0;

foreach my $file ( glob "out/*ip?addr" ) {

	my $macs;
	my $addr;

	open(my $fh, '<', $file);
	while(<$fh>) {
		chomp;
		if ( m/link\/ether ([0-9a-f:]+)/ ) {
			$macs->{$1}++;
		} elsif ( m/inet ([0-9\.]+)/ ) {
			$addr = $1;
			$addr_len = length($addr) if $addr_len < length($addr);
		}
	}

	foreach my $m ( keys %$macs ) {
		$mac2ip->{$m} = $addr;
	}
}


#warn "# mac2ip = ",dump($mac2ip);

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

my $fmt = "%${name_len}s %-${name_len}s %-20s %2s %4s %-6s %-10s\n";
printf $fmt ,"IP","remote IP","SSID","ch","Freq","Signal","Encryption";

#warn "# wifi = ",dump($wifi);

foreach my $m ( sort { inet_aton($wifi->{$a}->{ip}) cmp inet_aton($wifi->{$b}->{ip}) } keys %$wifi ) {

	my $remote_name = '?';
	if ( exists $mac2ip->{$m} ) {
		$remote_name = $ip2name->{ $mac2ip->{$m} };
	}

	printf $fmt,
		$ip2name->{ $wifi->{$m}->{ip} }, 
		$remote_name,
		$wifi->{$m}->{ssid}, 
		$wifi->{$m}->{channel} || '?', 
		$wifi->{$m}->{freq}, 
		$wifi->{$m}->{sig}, 
		$wifi->{$m}->{enc}, 
	;
}

