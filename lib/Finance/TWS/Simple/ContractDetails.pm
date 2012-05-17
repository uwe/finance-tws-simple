package Finance::TWS::Simple::ContractDetails;

use strict;
use warnings;

sub new {
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

    $tws->ae_call($request, sub { $self->cb(shift) });

    return $self;
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

