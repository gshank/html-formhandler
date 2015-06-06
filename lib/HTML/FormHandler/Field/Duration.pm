package HTML::FormHandler::Field::Duration;
# ABSTRACT: DateTime::Duration from HTML form values

use Moose;
extends 'HTML::FormHandler::Field::Compound';
use DateTime;

our $VERSION = '0.01';

=head1 SubFields

Subfield names:

  years, months, weeks, days, hours, minutes, seconds, nanoseconds

For example:

   has_field 'duration'         => ( type => 'Duration' );
   has_field 'duration.hours'   => ( type => 'Hour' );
   has_field 'duration.minutes' => ( type => 'Minute' );

Customize error message 'duration_invalid' (default 'Invalid value for [_1]: [_2]')

=cut

our $class_messages = {
    'duration_invalid' => 'Invalid value for [_1]: [_2]',
};

sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}


sub validate {
    my ($self) = @_;

    my @dur_parms;
    foreach my $child ( $self->all_fields ) {
        unless ( $child->has_value && $child->value =~ /^\d+$/ ) {
            $self->add_error( $self->get_message('duration_invalid'), $self->loc_label, $child->loc_label );
            next;
        }
        push @dur_parms, ( $child->accessor => $child->value );
    }

    # set the value
    my $duration = DateTime::Duration->new(@dur_parms);
    return $self->_set_value($duration);
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;

