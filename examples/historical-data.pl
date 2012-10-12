#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use FindBin;

use lib "$FindBin::Bin/../../anyevent-tws/lib";
use lib "$FindBin::Bin/../../protocol-tws/lib";
use lib "$FindBin::Bin/../lib";
use Finance::TWS::Simple;


my $tws = Finance::TWS::Simple->new(
    host => $ENV{TWS_HOST} || '127.0.0.1',
    port => $ENV{TWS_PORT} || '7496',
);

my $contract = $tws->struct(
    Contract => {
        symbol      => 'EUR',
        secType     => 'CASH',
        exchange    => 'IDEALPRO',
        localSymbol => 'EUR.USD',
    },
);

my $data = $tws->call(
    HistoricalData => {
        contract => $contract,
        duration => '2 W',
        bar_size => '1 day',
        bar_type => 'BID_ASK',
    },
);

printf(
    "%-18s | %-7s | %-7s | %-7s | %7s\n",
    'date', 'open', 'high', 'low', 'close',
);
print "-------------------|---------|---------|---------|---------\n";
foreach my $bar (@$data) {
    printf(
        "%-18s | %7.5f | %7.5f | %7.5f | %7.5f\n",
        $bar->date,
        $bar->open,
        $bar->high,
        $bar->low,
        $bar->close,
    );
}

