package Finance::TWS::Simple::ContractDetails;

use strict;
use warnings;

sub call {
    my ($class, $tws, $cv, $arg) = @_;

    my $self = bless {
        cv      => $cv,
        results => [],
    }, $class;

    my $request = $tws->request(
        reqContractDetails => {
            id       => $tws->next_id,
            contract => $arg->{contract},
        },
    );

    $tws->ae_call($self, $request);
}

sub cb {
    my ($self, $response) = @_;

    if ($response->_name eq 'contractDetails') {
        push @{$self->{results}}, $response;
    }
    elsif ($response->_name eq 'contractDetailsEnd') {
        $self->{cv}->send($self->{results});
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

  my $contract = $tws->struct(Contract => {
      symbol   => 'AAPL',
      secType  => 'STK',
      exchange => 'SMART',
      currency => 'USD',
  });
  my $details = $tws->call(ContractDetails => {contract => $contract});

=head1 DESCRIPTION

Search for contracts and/or obtain additional information for contracts
(like regular trading hours, exchanges).

=head1 PARAMETER

=head2 contract

L<Protocol::TWS::Simple::Struct::Contract> object.

=head1 RESULT

Arrayref of L<Protocol::TWS::Simple::Struct::ContractDetails> objects.
Can be empty (if no matching security was found).

=head1 SEE ALSO

L<http://www.interactivebrokers.com/php/apiUsersGuide/apiguide.htm#apiguide/c/contract.htm>,
L<http://www.interactivebrokers.com/php/apiUsersGuide/apiguide.htm#apiguide/c/contractdetails1.htm>,
L<Protocol::TWS::Struct::Contract>,
L<Protocol::TWS::Struct::ContractDetails>

=head1 AUTHOR

Uwe Voelker uwe@uwevoelker.de

=cut
