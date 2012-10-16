#!/usr/bin/env perl

# export (CSV) 1 minute bars

use strict;
use warnings;

use DateTime;
use Finance::TWS::Simple;
use Text::CSV;


my $symbol = $ARGV[0];
unless ($symbol) {
    print <<"EOF";
Usage: perl $0 SYMBOL

 e. g. perl $0 AAPL > apple.csv

Prints a CSV file of 1 minute bars of today.
EOF
    exit 1;
}


my $csv = Text::CSV->new;

my $tws = Finance::TWS::Simple->new(
    host => $ENV{TWS_HOST} || '127.0.0.1',
    port => $ENV{TWS_PORT} || '7496',
);

my $contract = $tws->struct(
    Contract => {
        symbol   => $symbol,
        secType  => 'STK',
        exchange => 'SMART',
        currency => 'USD',
    },
);

my $today = DateTime->today->subtract(seconds => 1)->add(days => 1);
# weekend?
if ($today->dow > 5) {
    # make it Friday
    $today = $today->subtract(days => $today->dow - 5);
}

my $data = $tws->call(
    HistoricalData => {
        contract => $contract,
        duration => '2 W',
        bar_size => '1 day',
        end_date => $today,
        bar_type => 'OPTION_IMPLIED_VOLATILITY',
    },
);

$csv->combine(qw/date open high low close/);
print $csv->string . "\n";
foreach my $bar (@$data) {
    $csv->combine(
        $bar->date,
        $bar->open,
        $bar->high,
        $bar->low,
        $bar->close,
    );
    print $csv->string . "\n";
}

