package Finance::TWS::Simple;

use strict;
use warnings;

use AnyEvent::TWS;
use Protocol::TWS;


sub new {
    my ($class, %arg) = @_;

    my $self = bless {}, $class;

    # connect to TWS
    $self->{tws} = AnyEvent::TWS->new(%arg);
    $self->{tws}->connect->recv;

    return $self;
}



1;

