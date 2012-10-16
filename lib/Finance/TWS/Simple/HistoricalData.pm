package Finance::TWS::Simple::HistoricalData;

# ABSTRACT: request historical quotes

use strict;
use warnings;

use Carp qw/croak/;
use DateTime;

sub call {
    my ($class, $tws, $cv, $arg) = @_;

    # Parameter
    my $contract    = $arg->{contract}    or croak "CONTRACT missing";
    my $duration    = $arg->{duration}    or croak "DURATION missing";
    my $bar_size    = $arg->{bar_size}    or croak "BAR_SIZE missing";
    my $end_date    = $arg->{end_date}    || DateTime->today->subtract(seconds => 1);
    my $bar_type    = $arg->{bar_type}    || 'TRADES';
    my $outside_rth = $arg->{outside_rth} || 0;

    # format conversion
    $end_date = $end_date->strftime('%Y%m%d  %H:%M:%S') if ref $end_date;

    my $request = $tws->request(
        reqHistoricalData => {
            id             => $tws->next_id,
            contract       => $contract,
            endDateTime    => $end_date,
            durationStr    => $duration,
            barSizeSetting => $bar_size,
            whatToShow     => $bar_type,
            useRTH         => $outside_rth ? 0 : 1,
            formatDate     => 1,
        },
    );

    my $self = bless {
        cv => $cv,
    }, $class;

    $tws->ae_call($self, $request);
}

sub cb {
    my ($self, $response) = @_;

    $self->{cv}->send($response->bars);
}

1;

=pod

=head1 SYNOPSIS

  my $contract = $tws->struct(Contract => {
      symbol      => 'EUR',
      secType     => 'CASH',
      exchange    => 'IDEALPRO',
      localSymbol => 'EUR.USD',
  });
  my $data = $tws->call(ContractDetails => {
      contract    => $contract,
      duration    => '2 W',
      bar_size    => '1 day',
      bar_type    => 'BID_ASK',
      outside_rth => 1,
  });

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

=head1 DESCRIPTION

Return historical quotes (for different time periods).

=head1 PARAMETER

=head2 contract

L<Protocol::TWS::Simple::Struct::Contract> object.

=head2 duration

Format: Integer plus space plus S|D|W (seconds, days, weeks).

=head2 bar_size

Valid values: "1 sec", "5 secs", "15 secs", "30 secs", "1 min",
"2 mins", "3 mins", "5 mins", "15 mins", "30 mins", "1 hour", "1 day".

=head2 end_date

L<DateTime> object, or correctly formatted timestamp ("%Y%m%d  %H:%M:%S").

Defaults to yesterday 23:59:59.

=head2 bar_type

Valid values: "TRADES", "MIDPOINT", "BID", "ASK", "BID_ASK",
"HISTORICAL_VOLATILITY", "OPTION_IMPLIED_VOLATILITY".

Defaults to "TRADES".

=head2 outside_rth

Boolean to also include quotes outside regular trading hours (RTH).

Defaults to false (meaning only regular trading hours).

=head1 RESULT

Arrayref of L<Protocol::TWS::Simple::Struct::BarData> objects.

=head1 SEE ALSO

L<http://www.interactivebrokers.com/php/apiUsersGuide/apiguide.htm#apiguide/c/contract.htm>,
L<http://www.interactivebrokers.com/php/apiUsersGuide/apiguide.htm#apiguide/c/reqhistoricaldata.htm>,
L<Protocol::TWS::Struct::Contract>,
L<Protocol::TWS::Struct::BarData>

=cut
