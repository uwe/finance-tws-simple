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

my $details = $tws->call(
    ContractDetails => {
        contract => $contract,
    },
);

warn Dumper $details;

