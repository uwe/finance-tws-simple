package Finance::TWS::Simple::ContractDetails;

use strict;
use warnings;

use AnyEvent;

sub name { 'contract_details' }

sub new {
    my ($class, $tws, $contract) = @_;

    my $self = bless {
        cv      => AE::cv,
        results => [],
    }, $class;

    my $request = $tws->request(
        reqContractDetails => {
            id       => $tws->{next_id}++,
            contract => $contract,
        },
    );

    $tws->{tws}->call($request, sub { $self->cb(shift) });

    return $self->{cv};
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

