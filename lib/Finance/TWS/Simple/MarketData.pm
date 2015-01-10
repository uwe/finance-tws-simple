package Finance::TWS::Simple::MarketData;

# ABSTRACT: request market data (snapshot)

use strict;
use warnings;

use Carp qw/croak/;

sub call {
    my ($class, $tws, $cv, $arg) = @_;

    # parameter
    my $contract = $arg->{contract} or croak "CONTRACT missing";

    my $request = $tws->request(
        reqMktData => {
            id              => $tws->next_id,
            contract        => $contract,
            genericTicklist => '',
            snapshot        => 1,
        },
    );

    my $self = bless {
        cv => $cv,
    }, $class;

    $tws->ae_call($self, $request);
}

sub cb {
    my ($self, $response) = @_;

    use Data::Dump qw/pp/;

    pp $response;

    $self->{cv}->send($response->price);
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
  my $data = $tws->call(MarketData => {
      contract => $contract,
  });

  print $data->price;

=head1 DESCRIPTION

Return market quotes (realtime, snapshot).

=head1 PARAMETER

=head2 contract

L<Protocol::TWS::Struct::Contract> object.

=head1 RESULT

L<Protocol::TWS::Response::tickPrice> object. ###TODO###

=head1 SEE ALSO

###TODO###

=cut
