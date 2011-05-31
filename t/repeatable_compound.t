use strict;
use warnings;
use Test::More 0.89;
use Test::Fatal;

use HTML::FormHandler;

{
    package Form::RepeatableCompound;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has_field timeslots => (type => 'Repeatable');

    has_field 'timeslots.duration' => (type => 'Duration');
    has_field 'timeslots.duration.hours' => (type => 'Integer');
    has_field 'timeslots.duration.minutes' => (type => 'Integer');
}

sub process_form {
    my ($params) = @_;
    my $form = Form::RepeatableCompound->new;
    $form->process(params => $params);

    die 'not valid'
        unless $form->validated;

    return $form->values;
}

is exception {
    my $values = process_form {
        'timeslots.0.duration.hours' => 10,
        'timeslots.0.duration.minutes' => 12,
        'timeslots.1.duration.hours' => 2,
        'timeslots.1.duration.minutes' => 1,
    };

    is scalar @{ $values->{timeslots} }, 2,
        'we got two timeslots';
}, undef;

done_testing;
