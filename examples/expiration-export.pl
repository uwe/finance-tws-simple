#!/usr/bin/env perl

use strict;
use warnings;

use DateTime;
use FindBin;
use IO::File;
use Text::CSV;

use lib "$FindBin::Bin/../../anyevent-tws/lib";
use lib "$FindBin::Bin/../../protocol-tws/lib";
use lib "$FindBin::Bin/../lib";
use Finance::TWS::Simple;


my $symbol  = shift(@ARGV);
my @strikes = @ARGV;

unless ($symbol) {
    print <<"EOF";
Usage: perl $0 SYMBOL [STRIKE1 [STRIKE2 ...]]

 e. g. perl $0 AAPL 625 630 635

Run this script on expiration Friday (after close) or weekend to export
1 minute bars of stock and expired options.
EOF
    exit 1;
}


my $tws = Finance::TWS::Simple->new(
    host => $ENV{TWS_HOST} || '127.0.0.1',
    port => $ENV{TWS_PORT} || '7496',
);


my $date = DateTime->today->subtract(seconds => 1)->add(days => 1);
# weekend?
if ($date->dow > 5) {
    # make it Friday
    $date = $date->subtract(days => $date->dow - 5);
}


# get stock data
# ~~~~~~~~~~~~~~
my $contract = $tws->struct(
    Contract => {
        symbol   => $symbol,
        secType  => 'STK',
        exchange => 'SMART',
        currency => 'USD',
    },
);

export_to_csv($contract, "$symbol.csv");


# get options data
# ~~~~~~~~~~~~~~~~
foreach my $strike (@strikes) {
    foreach my $right (qw/C P/) {
        my $contract = $tws->struct(
            Contract => {
                symbol   => $symbol,
                secType  => 'OPT',
                expiry   => $date->ymd(''),
                strike   => $strike,
                right    => $right,
                exchange => 'SMART',
                currency => 'USD',
            },
        );

        export_to_csv($contract, "$symbol-$strike$right.csv");

        sleep 2;
    }
}


sub export_to_csv {
    my ($contract, $file_name) = @_;

    my $data = $tws->call(
        HistoricalData => {
            contract => $contract,
            duration => '1 D',
            bar_size => '1 min',
            end_date => $date,
            bar_type => 'TRADES',
        },
    );


    my $csv = Text::CSV->new({eol => "\n"});
    my $fh  = IO::File->new('> ' . $file_name);


    $csv->print($fh, [qw/date open high low close/]);
    foreach my $bar (@$data) {
        $csv->print(
            $fh,
            [
                $bar->date,
                $bar->open,
                $bar->high,
                $bar->low,
                $bar->close,
            ],
       );
    }

    $fh->close;
}
