package Finance::TWS::Simple::HistoricalData;

use strict;
use warnings;

use Carp qw/croak/;
use DateTime;

sub new {
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
            useRTH         => $outside_rth ? 1 : 0,
            formatDate     => 1,
        },
    );

    my $self = bless {
        cv => $cv,
    }, $class;

    $tws->ae_call($request, sub { $self->cb(shift) });

    return $self;
}

sub cb {
    my ($self, $response) = @_;

    $self->{cv}->send($response->bars);
}

1;

