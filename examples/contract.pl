#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use lib '/home/uwe/repos/anyevent-tws/lib';
use lib '/home/uwe/repos/protocol-tws/lib';
use lib '/home/uwe/repos/finance-tws-simple/lib';
use Finance::TWS::Simple;


my $tws = Finance::TWS::Simple->new(
    host => $ENV{TWS_HOST},
    port => $ENV{TWS_PORT},
);

my $contract = Protocol::TWS::Struct::Contract->new(
    symbol      => 'EUR',
    secType     => 'CASH',
    exchange    => 'IDEALPRO',
    localSymbol => 'EUR.USD',
);

my @details = $tws->contract_details($contract);

warn Dumper \@details;

