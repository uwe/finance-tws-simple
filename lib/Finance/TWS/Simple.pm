package Finance::TWS::Simple;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::TWS;
use Protocol::TWS;


sub new {
    my ($class, %arg) = @_;

    my $self = bless {}, $class;

    # connect to TWS
    $self->{tws} = AnyEvent::TWS->new(%arg);
    $self->{tws}->connect->recv;

    ###TODO### move id handling to AnyEvent::TWS
    $self->{next_id} = 1;

    return $self;
}

sub contract_details {
    my ($self, $contract) = @_;

    my $request = Protocol::TWS::Request::reqContractDetails->new(
        id       => $self->{next_id}++,
        contract => $contract,
    );

    my $cv = AE::cv;
    my @contract_details = ();
    $self->{tws}->call(
        $request,
        sub {
            my ($response) = @_;
            $self->_collect_contract_details(
                \@contract_details,
                $response,
                $cv,
            );
        },
    );
    $cv->recv;

    return @contract_details;
}

sub _collect_contract_details {
    my ($self, $contract_details, $response, $cv) = @_;

    if ($response->_name eq 'contractDetails') {
        push @$contract_details, $response;
        return;
    }
    elsif ($response->_name eq 'contractDetailsEnd') {
        $cv->send;
        return;
    }
}


1;

