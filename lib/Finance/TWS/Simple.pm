package Finance::TWS::Simple;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::TWS;

sub new {
    my ($class, %arg) = @_;

    my $self = bless {}, $class;

    # connect to TWS
    $self->{tws} = AnyEvent::TWS->new(%arg);
    $self->{tws}->connect->recv;

    return $self;
}

sub next_id { (shift)->{tws}->next_valid_id }

sub ae_call {
   my ($self, $object, $request) = @_;

   $self->{tws}->call($request, sub { $object->cb(shift) });
}

sub call {
    my ($self, $name, $arg) = @_;

    my $cv    = AE::cv;
    my $class = 'Finance::TWS::Simple::' . $name;
    eval "use $class"; die $@ if $@;
    $class->call($self, $cv, $arg);

    return $cv->recv;
}

sub struct {
    my ($self, $name, $arg) = @_;

    my $class = 'Protocol::TWS::Struct::' . $name;
    eval "use $class"; die $@ if $@;
    return $class->new(%$arg);
}

sub request {
    my ($self, $name, $arg) = @_;

    my $class = 'Protocol::TWS::Request::' . $name;
    eval "use $class"; die $@ if $@;
    return $class->new(%$arg);
}

1;

