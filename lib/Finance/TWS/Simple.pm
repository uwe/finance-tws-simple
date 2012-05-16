package Finance::TWS::Simple;

use strict;
use warnings;

use Module::Find qw/useall/;
use AnyEvent;
use AnyEvent::TWS;
use Protocol::TWS;

my @CALLS = useall 'Finance::TWS::Simple';
###TODO### generate methods


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

sub call {
    my ($self, $name, @args) = @_;

    my $class = 'Finance::TWS::Simple::' . $name;
    return $class->new($self, @args)->recv;
}

sub struct {
    my ($self, $name, $arg) = @_;

    my $class = 'Protocol::TWS::Struct::' . $name;
    return $class->new(%$arg);
}

sub request {
    my ($self, $name, $arg) = @_;

    my $class = 'Protocol::TWS::Request::' . $name;
    return $class->new(%$arg);
}

sub contract_details {
    (shift)->call(ContractDetails => @_);
}


1;

