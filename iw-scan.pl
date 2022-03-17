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
my $ip2macs;

my $addr_len = 0;

foreach my $file ( glob "out/*ip?addr" ) {

	my $macs;
	my $addr;

	if ( -s $file == 0 ) {
		warn "ERROR: $file is empty, SKIPPING\n";
		next;
	}

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

	if ( ! $addr ) {
		die "ERROR: $file didn't include inet address";
	}

	foreach my $m ( keys %$macs ) {
		$mac2ip->{$m} = $addr;
	}
	$ip2macs->{$addr} = [ keys %$macs ];
}


#warn "# mac2ip = ",dump($mac2ip);

my $mac;
my $wifi;

foreach my $file ( sort glob "out/*.iw*scan" ) {

	if ( -s $file == 0 ) {
		warn "ERROR: $file is empty, SKIPPING\n";
		next;
	}

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

my $mac2channel;
my @ips;

foreach my $file ( sort glob "out/*.iw*dev" ) {
	if ( -s $file == 0 ) {
		warn "ERROR: $file is empty, SKIPPING\n";
		next;
	}
	my $ip = $1 if ( $file =~ m/out\/(.+?)\.iw/ );
	push @ips, $ip;
	my $mac;
	open(my $fh, '<', $file);
	while(<$fh>) {
		chomp;
		if ( m/addr ([0-9a-f:]+)/ ) {
			$mac = $1;
		} elsif ( m/channel (\d+)/ ) {
			$mac2channel->{$mac} = $1;
		}
	}

}

my $ip2channels;
foreach my $ip ( @ips ) {
	foreach my $m ( @{ $ip2macs->{$ip} } ) {
		if ( exists $mac2channel->{$m} ) {
			$ip2channels->{$ip}->{ $mac2channel->{$m} }++;
		}
	}
	$ip2channels->{$ip} = [ sort { $a <=> $b } keys %{ $ip2channels->{$ip} } ];
}

#warn "## ip2channels = ",dump( $ip2channels );

my $fmt = "%${addr_len}s %${name_len}s %2s %-2s %-6s %-${name_len}s %17s %-20s %4s %-10s\n";
printf $fmt ,"IP","AP", "ch", "rc", "signal", "remote AP","BSS","SSID","Freq","Encryption";

#warn "# wifi = ",dump($wifi);

foreach my $m ( sort {
		## sort by ip
		#inet_aton($wifi->{$a}->{ip}) cmp inet_aton($wifi->{$b}->{ip})
		## sort by hostname
		$ip2name->{ $wifi->{$a}->{ip} } cmp $ip2name->{ $wifi->{$b}->{ip} }
	} keys %$wifi ) {

	my $ip = $wifi->{$m}->{ip};

	my $remote_name = '?';
	if ( exists $mac2ip->{$m} ) {
		$remote_name = $ip2name->{ $mac2ip->{$m} };
	}

	my $remote_channel = 0;
	$remote_channel = $wifi->{$m}->{channel} if exists $wifi->{$m}->{channel};

	# use local channel from same band as remote one
	my $channels = $ip2channels->{$ip}->[ $remote_channel > 15 ? 1 : 0 ];

	printf $fmt,
		$ip,
		$ip2name->{ $ip },
		$channels,
		$remote_channel,
		$wifi->{$m}->{sig}, 
		$remote_name,
		$m,
		$wifi->{$m}->{ssid}, 
		$wifi->{$m}->{freq}, 
		$wifi->{$m}->{enc}, 
	;
}

